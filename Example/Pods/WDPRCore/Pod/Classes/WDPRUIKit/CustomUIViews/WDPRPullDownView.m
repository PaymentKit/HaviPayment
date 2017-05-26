//
//  WDPRDropDownView.m
//  DLR
//
//  Created by Francisco Valbuena on 3/31/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRPullDownView.h"

static const CGFloat kDropDownViewHeight = 32;
static const CGFloat kDropDownViewMaxDropDuration = 0.5;
static const CGFloat kDropDownViewMinDropDuration = 0.16;
static const CGFloat kDropDownViewMinVelocityToDrop = 100.0;
static const CGFloat kDefaultMinDraggingFactorToDrop = 0.35;

@interface WDPRPullDownView ()
@property (nonatomic, readonly) UIButton *dropDownButton;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGesture;
@property (nonatomic, readwrite) WDPRPullDownState state;
@end

@implementation WDPRPullDownView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    // Hardcode this frame to follow the guide specs.
    frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kDropDownViewHeight);
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor wdprPaleGrayColor];
        _minDraggingFactorToDrop = kDefaultMinDraggingFactorToDrop;
        _panGesture = [self buildPanGestureRecognizer];
        _dropDownButton = [self buildDropDownButtonWithFrame:frame];
    }
    
    return self;
}

- (void)didMoveToSuperview
{
    if (!self.viewToPull)
    {
        UIViewController *viewController = [self closestViewController];
        
        if (viewController)
        {
            self.viewToPull = viewController.navigationController.view ?: viewController.view;
        }
        else
        {
            self.viewToPull = self.superview;
        }
    }
}

- (void)layoutSubviews
{
    self.dropDownButton.frame = self.bounds;
    [super layoutSubviews];
}

#pragma mark - WDPRDropDownView Private Methods

- (UIButton *)buildDropDownButtonWithFrame:(CGRect)frame
{
    const CGSize pullDownIconSize = CGSizeMake(56,24);
    
    UIButton *dropDownButton = [[UIButton alloc] initWithFrame:frame];
    UIControlEvents touchUpEvents = UIControlEventTouchUpInside | UIControlEventTouchUpOutside;
    
    [dropDownButton setImage:[WDPRIcon imageOfIcon:WDPRIconPullDown 
                                         withColor:[UIColor colorWithHexValue:0xBAC6D7] 
                                           andSize:pullDownIconSize] forState:UIControlStateNormal];
    
    [dropDownButton setImage:[WDPRIcon imageOfIcon:WDPRIconPullDown 
                                         withColor:UIColor.whiteColor 
                                           andSize:pullDownIconSize] forState:UIControlStateHighlighted];
    
    [dropDownButton addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [dropDownButton addTarget:self action:@selector(onTouchUp:) forControlEvents:touchUpEvents];
    [dropDownButton addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:dropDownButton];
    return dropDownButton;
}

- (UIPanGestureRecognizer *)buildPanGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(onPanGesture:)];
    
    panGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:panGesture];
    return panGesture;
}

- (void)onTouchDown:(UIButton *)button
{
    self.backgroundColor = [UIColor wdprMutedGrayColor];
}

- (void)onTouchUp:(UIButton *)button
{
    self.backgroundColor = [UIColor wdprPaleGrayColor];
}

- (void)onTouchUpInside:(UIButton *)button
{
    id<WDPRPullDownViewDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(pullDownViewDidDTap:)])
    {
        [delegate pullDownViewDidDTap:self];
    }
}

- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        [self willStartDragging];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        [self didDrag];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
    {
        [self didEndDragging];
    }
}

- (void)willStartDragging
{
    id<WDPRPullDownViewDelegate> delegate = self.delegate;
    
    self.state = WDPRPullDownStateDragging;
    
    if ([delegate respondsToSelector:@selector(pullDownViewWillStartDragging:)])
    {
        [delegate pullDownViewWillStartDragging:self];
    }
}

- (void)didDrag
{
    id<WDPRPullDownViewDelegate> delegate = self.delegate;
    CGPoint translation = [self.panGesture translationInView:self.viewToPull];
    
    [self.viewToPull setTransform:CGAffineTransformMakeTranslation(0, MAX(translation.y, 0))];
    
    if ([delegate respondsToSelector:@selector(pullDownViewDidDrag:)])
    {
        [delegate pullDownViewDidDrag:self];
    }
}

- (void)didEndDragging
{
    BOOL shouldDrop = [self shouldDropView];
    __weak WDPRPullDownView *weakSelf = self;
    id<WDPRPullDownViewDelegate> delegate = self.delegate;
    
    [self.panGesture setTranslation:CGPointZero inView:self.viewToPull];
    
    if ([delegate respondsToSelector:@selector(pullDownViewDidEndDragging:willDrop:)])
    {
        [delegate pullDownViewDidEndDragging:self willDrop:shouldDrop];
    }
    
    self.state = shouldDrop ? WDPRPullDownStateDropping : WDPRPullDownStateBouncing;
    [UIView animateWithDuration:[self durationForAnimationDropping:shouldDrop] animations:^{
        if (!shouldDrop)
        {
            self.viewToPull.transform = CGAffineTransformIdentity;
        }
        else
        {
            [self.viewToPull setTransform:CGAffineTransformMakeTranslation(0, self.viewToPull.bounds.size.height)];
        }
    } completion:^(BOOL finished)
    {
        if (shouldDrop)
        {
            [weakSelf didDrop];
        }
    }];
}

- (void)didDrop
{
    id<WDPRPullDownViewDelegate> delegate = self.delegate;
    
    self.state = WDPRPullDownStateDropped;
    
    if ([delegate respondsToSelector:@selector(pullDownViewDidDrop:)])
    {
        [delegate pullDownViewDidDrop:self];
    }
}

- (BOOL)shouldDropView
{
    CGFloat velocity = [self.panGesture velocityInView:self.viewToPull].y;
    CGFloat distanceToDrop = self.minDraggingFactorToDrop * self.viewToPull.bounds.size.height;
    
    return (self.viewToPull.transform.ty > distanceToDrop && velocity > 0) || velocity > kDropDownViewMinVelocityToDrop;
}

- (CGFloat)durationForAnimationDropping:(BOOL)drop
{
    CGFloat velocity = [self.panGesture velocityInView:self.viewToPull].y;
    CGFloat distance = drop ? self.viewToPull.bounds.size.height - self.viewToPull.transform.ty : self.viewToPull.transform.ty;
    
    return MAX(MIN(fabs(distance / velocity), kDropDownViewMaxDropDuration), kDropDownViewMinDropDuration);
}

@end
