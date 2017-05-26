//
//  WDPRRefreshControl.m
//  WDPR
//
//  Created by Ricardo Contreras on 7/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRRefreshControl.h"
#import "WDPRRefreshControlView.h"

#import <WDPRCore/WDPRFoundation.h>

static float const kWDPRRCHeight             = 125.0f;
static float const kWDPRRCEndAnimDuration    = 0.3f;
static float const kWDPRRCEndAnimDelay       = 0.3f;

@interface WDPRRefreshControl ()

@property (nullable, strong, nonatomic) UIScrollView *scrollView;
@property (nullable, strong, nonatomic) WDPRRefreshControlView *refreshView;
@property (readwrite, nonatomic) BOOL refreshing;
@property (assign, nonatomic) UIEdgeInsets originalInset;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat endAnimDuration;
@property (assign, nonatomic) CGFloat endAnimDelay;

@end

@implementation WDPRRefreshControl

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    [self attachAnimationToView:newSuperview];
}

- (void)dealloc
{
    self.scrollView = nil;
}

#pragma mark - UIRefreshControl Public

- (void)beginRefreshing
{
    [self startRefreshing];
    self.refreshView.state = WDPRRefreshStateSpringAction;
}

- (void)endRefreshing
{
    self.refreshing = NO;
    
    self.refreshView.state = WDPRRefreshStateFadeOut;
    [UIView animateWithDuration:self.endAnimDuration
                          delay:self.endAnimDelay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:
     ^{
         if (self.scrollView.contentOffset.y < -self.originalInset.top) 
         {
             [self.scrollView setContentOffset:
              CGPointMake(0, -self.originalInset.top) animated:NO];
         }
     } completion:^(BOOL finished)
    {
        if (!self.attributedTitle && !self.title)
        {
            [self.refreshView setText:[self defaultMessage]];
        }
        self.scrollView.contentInset = self.originalInset;
        self.refreshView.state = WDPRRefreshStateDefault;
     }];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    _attributedTitle = attributedTitle;
    [self.refreshView setAttributedText:_attributedTitle];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.refreshView.mainColor = _tintColor;
}

#pragma mark - WDPRRefreshControl Public

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self.refreshView setText:_title];
}

- (void)attachAnimationToView:(nullable UIView *)view;
{
    if ([view isKindOfClass:[UITableView class]])
    {
        [self newScrollView:(UIScrollView *)view];
    }
    else if ([view isKindOfClass:[UICollectionView class]])
    {
        ((UICollectionView *)view).alwaysBounceVertical = YES;
        [self newScrollView:(UICollectionView *)view];
    }
}

- (void)reset
{
    self.refreshing = NO;
    if (self.scrollView.contentOffset.y < -self.originalInset.top)
    {
        [self.scrollView setContentOffset:
         CGPointMake(0, -self.originalInset.top) animated:NO];
    }
    self.scrollView.contentInset = self.originalInset;
    self.refreshView.state = WDPRRefreshStateDefault;
}

#pragma mark - Private methods

- (void)setScrollView:(UIScrollView*)scrollView
{
    if (_scrollView != scrollView)
    {
        onExitFromScope(^{ self->_scrollView = scrollView; });
        [_scrollView removeObserver:self keyPath:NSStringFromSelector(@selector(contentInset))];
        [_scrollView removeObserver:self keyPath:NSStringFromSelector(@selector(contentOffset))];
        [_scrollView.panGestureRecognizer removeTarget:self action:@selector(scrollViewPanGestureChanged:)];
    }
}

- (void)newScrollView:(UIScrollView *)scrollView
{
    self.scrollView = scrollView;
    if (self.isRefreshing)
    {
        self.scrollView.contentInset = self.originalInset;
        [self.scrollView setContentOffset:CGPointMake(0, [self offsetYLockValue]) animated:NO];
    }
    else
    {
        self.originalInset = self.scrollView.contentInset;
    }
    
    [self observeScrollView];
    [self.scrollView.panGestureRecognizer addTarget:self action:@selector(scrollViewPanGestureChanged:)];
}

- (void)observeScrollView
{
    MAKE_WEAK(self);
    [self.scrollView addObserver:self
                         keyPath:NSStringFromSelector(@selector(contentOffset))
                         options:NSKeyValueObservingOptionNew
                           block:^(id observedObject, NSString *keyPath, NSDictionary *change)
    {
        MAKE_STRONG(self);
        NSValue *value = change[NSKeyValueChangeNewKey];
        [strongself contentOffsetChanged:[value CGPointValue]];
    }];
    
    [self.scrollView addObserver:self
                         keyPath:NSStringFromSelector(@selector(contentInset))
                         options:NSKeyValueObservingOptionNew
                           block:^(id observedObject, NSString *keyPath, NSDictionary *change)
     {
         MAKE_STRONG(self);
         NSValue *value = change[NSKeyValueChangeNewKey];
         [strongself contentInsetChanged:[value UIEdgeInsetsValue]];
     }];
}

- (void)contentInsetChanged:(UIEdgeInsets)newContentInset
{
    if (newContentInset.top != self.originalInset.top &&
        newContentInset.top != [self refreshingInset].top)
    {
        self.originalInset = newContentInset;
    }
}

- (void)contentOffsetChanged:(CGPoint)newContentOffset
{
    CGPoint correctOffset = newContentOffset;
    correctOffset.y += self.originalInset.top;
    [self.refreshView scrollOffsetChanged:correctOffset
                                      withWidth:self.scrollView.frame.size.width
                                      andCenter:self.scrollView.center];
    
    if (self.refreshView.state == WDPRRefreshStateReleased &&
        self.scrollView.contentOffset.y == [self offsetYLockValue])
    {
        self.scrollView.contentInset = [self refreshingInset];
        self.refreshView.state = WDPRRefreshStateSpringAction;
    }
}

- (UIEdgeInsets)refreshingInset
{
    UIEdgeInsets refreshingInset = self.originalInset;
    refreshingInset.top += self.height;
    
    return refreshingInset;
}

- (CGFloat)offsetYLockValue
{
    return -[self refreshingInset].top;
}

- (void)scrollViewPanGestureChanged:(UIPanGestureRecognizer *)recognizer
{
    if (!self.isRefreshing &&
        recognizer.state == UIGestureRecognizerStateEnded &&
        self.scrollView.contentOffset.y < - self.height - self.originalInset.top)
    {
        [self startRefreshing];
    }
}

- (void)setUp
{
    self.height = kWDPRRCHeight;
    self.endAnimDuration = kWDPRRCEndAnimDuration;
    self.endAnimDelay = kWDPRRCEndAnimDelay;
    self.refreshView = [WDPRRefreshControlView new];
    self.refreshView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.refreshView];
    _attributedTitle = nil;
    _tintColor = nil;
}

- (void)startRefreshing
{
    [self.scrollView setContentOffset: CGPointMake(0, [self offsetYLockValue]) animated:YES];
    [self.refreshView resetValues];
    self.refreshing = YES;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    self.refreshView.state = WDPRRefreshStateReleased;
}

- (NSString *)defaultMessage
{
    NSString *updateMessage = WDPRLocalizedStringInBundle(@"com.wdprcore.wdprrefreshcontrol.defaultmessage",
                                                          WDPRCoreResourceBundleName, nil);
    
    // TODO: Use the new briefTimeFormat implementation for full compatibility with all reference apps.
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithDateStyle:NSDateFormatterMediumStyle
                                                                       timeStyle:NSDateFormatterNoStyle
                                                                        timeZone:[NSTimeZone systemTimeZone]];
    NSDateFormatter *timeFormatter = [NSDateFormatter userFormatterWithDateStyle:NSDateFormatterNoStyle
                                                                       timeStyle:NSDateFormatterShortStyle
                                                                        timeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [NSDate date];
    NSString *defaultMessage = [NSString stringWithFormat:updateMessage,
                                [dateFormatter stringFromDate:date],
                                [timeFormatter stringFromDate:date]];
    
    return defaultMessage;
}

@end
