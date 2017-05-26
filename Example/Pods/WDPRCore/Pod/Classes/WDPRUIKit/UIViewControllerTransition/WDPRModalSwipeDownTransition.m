//
//  WDPRModalSwipeDownTransition.m
//  DLR
//
//  Created by Delafuente, Rob on 4/15/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRModalSwipeDownTransition.h"
#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

NSString * const WDPRModalNavigationDidDismissNotification = @"modalNavigationDidDismissNotification";
CGFloat const kWDPRNavBarDismissButtonHeight = 32.0f;

static CGFloat const kTransitionInDuration = 0.6f;
static CGFloat const kTransitionInDelay = 0.0f;
static CGFloat const kTransitionInSpringDamping = 0.95f;
static CGFloat const kTransitionInSpringVelocity = 1.0f;
static CGFloat const kTransitionOutDuration = 0.3f;
static CGFloat const kTransitionOutDelay = 0.0f;
static CGFloat const kResetModalDuration = 0.4f;
static CGFloat const kResetModalDelay = 0.0f;
static CGFloat const kResetModalSpringDamping = 0.6f;
static CGFloat const kResetModalSpringVelocity = 0.6f;
static CGFloat const kShowDismissViewDuration = 0.3f; //Jira ticket: IDLR-4062
static CGFloat const kShowDismissViewDelay = 0.0f;
static CGFloat const kShowDismissViewSpringDamping = 0.6f;
static CGFloat const kShowDismissViewSpringVelocity = 0.0f;
static CGFloat const kHideDismissViewOnTouchDuration = 0.3f;
static CGFloat const kDismissButtonRotationDuration = 0.3f;
static CGFloat const kDismissViewOffsetMultiplier = 0.1f;
static CGFloat const kDismissViewLeftMargin = 0.0f;
static CGFloat const kDismissViewRightMargin = 0.0f;
static CGFloat const kDismissViewTopMargin = 0.0f;
static CGFloat const kStatusBarHeight = 20.0f;
static CGFloat const kPanDismissPercentThreshold = 0.3f;
static CGFloat const kSmallSwipeWindowHeight = 100.0f;
static CGFloat const kValidDragDelta = 5.0f;

@interface WDPRModalSwipeDownTransition() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *outerContainerView;
@property (nonatomic, strong) UIView *innerContentContainerView;
@property (nonatomic, strong) UIView *presentingView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *statusBarBackgroundView;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIView *dismissView;
@property (nonatomic, strong) UIView *hideContentView;

@property (nonatomic, strong, readwrite) UIButton *dismissButton;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) BOOL canDrag;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isShowingDismissView;

@property (nonatomic, strong) UIView *previouslyFocusedElement;

// IREF-3393: These properties are needed for fast swipe to dismiss to work for iOS 9.2 and below.
// iOS bug: http://www.openradar.me/21961293
// These can be removed when we stop supporting iOS 9.2.
@property (nonatomic, assign) BOOL animationCompleted;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation WDPRModalSwipeDownTransition

#pragma mark - UIViewControllerAnimatedTransitioning Delegate Methods

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    switch (self.type)
    {
        case TransitionEnter:
            return kTransitionInDuration;
            
        case TransitionExit:
            return kTransitionOutDuration;
            
        default:
            return 1.0;
    }
}

#pragma mark - Accessibility

-(BOOL)accessibilityPerformEscape
{
    [self onTouchUpInside:nil];
    return YES;
}

#pragma mark - Animated Transitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    self.presentingView = [transitionContext containerView];
    
    if (self.type == TransitionEnter)
    {
        UIView *sendingView = fromVC.view;
        if ([fromVC isKindOfClass:[UINavigationController class]])
        {
            // Reduce the total number of subviews to recurse through
            UINavigationController *sender = (UINavigationController *)fromVC;
            sendingView = sender.topViewController.view;
        }
        self.previouslyFocusedElement = [UIView focusedElementForView:sendingView];
        
        self.dismissButton = [self buildDropDownButtonWithFrame:CGRectMake(0, 0,
                                                                           SCREEN_WIDTH,
                                                                           kWDPRNavBarDismissButtonHeight)];
        
        CGRect tempFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.outerContainerView = [UIView new];
        self.outerContainerView.frame = tempFrame;
        self.outerContainerView.backgroundColor = [UIColor clearColor];
        
        self.contentContainerView = [UIView new];
        self.contentContainerView.accessibilityViewIsModal = YES;
        [self resetContentContainerViewFrame];
        
        self.innerContentContainerView = [[UIView alloc]
                                          initWithFrame:CGRectMake(0,
                                                                   kWDPRNavBarDismissButtonHeight,
                                                                   self.contentContainerView.frame.size.width,
                                                                   (self.contentContainerView.frame.size.height -
                                                                    kWDPRNavBarDismissButtonHeight))];
        
        self.contentView = toVC.view;
        self.contentView.frame = CGRectMake(0,
                                            0,
                                            self.innerContentContainerView.frame.size.width,
                                            self.innerContentContainerView.frame.size.height);
        
        self.statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                SCREEN_WIDTH,
                                                                                kStatusBarHeight)];
        self.statusBarBackgroundView.backgroundColor = [UIColor whiteColor];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentContainerView.backgroundColor = [UIColor whiteColor];
        self.innerContentContainerView.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self.innerContentContainerView addSubview:self.contentView];
        [self.contentContainerView addSubview:self.innerContentContainerView];
        [self.contentContainerView addSubview:self.dismissButton];
        [self.outerContainerView addSubview:self.contentContainerView];
        
        [self.presentingView addSubview:self.outerContainerView];
        [self.presentingView addSubview:self.statusBarBackgroundView];
        
        self.contentContainerView.accessibilityElements = @[self.dismissButton, self.innerContentContainerView];
        self.accessibilityElements = @[self.contentContainerView];
        
        CGRect topBarEndFrame = self.statusBarBackgroundView.frame;
        CGRect topBarStartFrame = topBarEndFrame;
        topBarStartFrame.origin.y -= topBarStartFrame.size.height;
        self.statusBarBackgroundView.frame = topBarStartFrame;
        
        CGRect endFrame = self.outerContainerView.frame;
        self.outerContainerView.frame = CGRectMake(endFrame.origin.x,
                                                   self.presentingView.frame.size.height,
                                                   endFrame.size.width,
                                                   endFrame.size.height);
        
        self.animationCompleted = NO;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:kTransitionInDelay
             usingSpringWithDamping:kTransitionInSpringDamping
              initialSpringVelocity:kTransitionInSpringVelocity
                            options:0
                         animations:
         ^{
             self.outerContainerView.frame = endFrame;
             self.statusBarBackgroundView.frame = topBarEndFrame;
         }
                         completion:^(BOOL finished)
         {
             [self enterAnimationCompleted];
         }];
    }
    else if (self.type == TransitionExit)
    {
        // Insert the underlying VC under the presenting view so the user can see what's underneath.
        [self.presentingView insertSubview:toVC.view belowSubview:self.outerContainerView];
        
        CGRect barBackgroundEndFrame = self.statusBarBackgroundView.frame;
        barBackgroundEndFrame.origin.y = -self.statusBarBackgroundView.frame.size.height;
        
        CGRect finalFrame = self.outerContainerView.frame;
        finalFrame.origin.y = self.outerContainerView.frame.size.height;
        
        self.animationCompleted = NO;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:kTransitionOutDelay
                            options:UIViewAnimationOptionCurveLinear
                         animations:
         ^{
             self.outerContainerView.frame = finalFrame;
             self.statusBarBackgroundView.frame = barBackgroundEndFrame;
         }
                         completion:^(BOOL finished)
         {
             [self exitAnimationCompleted];
         }];
    }
}

- (void)enterAnimationCompleted
{
    if (self.animationCompleted)
    {
        return;
    }
    
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    self.transitionContext = nil;
    [self addSwipeGesture];
    self.animationCompleted = YES;
}

- (void)exitAnimationCompleted
{
    if (self.animationCompleted)
    {
        return;
    }
    
    BOOL transitionCancelled = [self.transitionContext transitionWasCancelled];
    
    [self.transitionContext completeTransition:!transitionCancelled];
    self.transitionContext = nil;
    
    if (!transitionCancelled)
    {
        // Post notification to trigger analytics
        [[NSNotificationCenter defaultCenter] postNotificationName:WDPRModalNavigationDidDismissNotification object:nil];
        
        [self removeSwipeGesture];
        executeOnMainThread(^{
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.previouslyFocusedElement);
        });
    }
    
    self.animationCompleted = YES;
}

#pragma mark - UIGestureRecognizer Methods

- (void)addSwipeGesture
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(onPanGesture:)];
    self.panGesture.delegate = self;
    [self.outerContainerView addGestureRecognizer:self.panGesture];
}

- (void)removeSwipeGesture
{
    UIViewController *topViewController = self.navController.topViewController;
    if ([topViewController respondsToSelector:@selector(willBeDismissed)])
    {
        [((id<WDPRModalSwipeDownDelegate>)topViewController) willBeDismissed];
    }
    
    [self.outerContainerView removeGestureRecognizer:self.panGesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [self shouldRecognizeMainScrollableViewGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)shouldRecognizeMainScrollableViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    return [self.scrollView.panGestureRecognizer isEqual:gestureRecognizer];
}

- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture
{
    if ([self isDismissViewEnabled])
    {
        [self handleDismissViewGesture:panGesture];
    }
    else
    {
        [self handleStandardGesture:panGesture];
    }
}

- (void)handleDismissViewGesture:(UIPanGestureRecognizer *)panGesture
{
    // Handling gesture if there is a dismiss view.
    
    CGPoint translation = [panGesture translationInView:self.contentContainerView];
    CGPoint velocity = [panGesture velocityInView:self.contentContainerView];
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.canDrag = [self isValidDragStartPoint:[panGesture locationInView:self.contentContainerView]] && velocity.y > kValidDragDelta;
            [self addDismissView];
            
            if (self.isShowingDismissView)
            {
                //Cancels gesture event
                panGesture.enabled = NO;
                panGesture.enabled = YES;
                
                [self hideDismissViewAction];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (self.isDragging)
            {
                if ([self canDragAtYCoordinate:translation.y])
                {
                    [self dragViewInDismissMode];
                }
                
                self.dismissView.alpha = [self alphaForDismissViewAtYCoordinate:translation.y];
            }
            else
            {
                if (self.canDrag && [self canDragAtYCoordinate:translation.y])
                {
                    self.isDragging = YES;
                    self.scrollView.panGestureRecognizer.enabled = NO;
                    [self createSnapshotView];
                }
                else
                {
                    self.canDrag = NO;
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
            
        case UIGestureRecognizerStateEnded:
        {
            if (self.canDrag)
            {
                if ([self shouldShowDismissViewAtYCoordinate:self.snapshotView.transform.ty])
                {
                    [self showDismissViewAfterDragging];
                }
                else
                {
                    [self endSnapshotView];
                }
            }
            else
            {
                [self resetDragView];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)handleStandardGesture:(UIPanGestureRecognizer *)panGesture
{
    // Handling gesture if there is no dismiss view.
    // http://stackoverflow.com/questions/29290313/in-ios-how-to-drag-down-to-dismiss-a-modal
    
    CGPoint translation = [panGesture translationInView:self.contentContainerView];
    CGPoint velocity = [panGesture velocityInView:self.contentContainerView];
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // Only want to start dragging if the user is dragging down and they are at the top of the scrollView if there is one.
            self.canDrag = [self isValidDragStartPoint:[panGesture locationInView:self.contentContainerView]] && velocity.y > kValidDragDelta;
            
            if (self.canDrag)
            {
                // Start the transition and call dismissViewController so life cycle methods are called.
                self.transitionInteractor.hasStarted = YES;
                [self.navController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (self.isDragging)
            {
                // Calculate the amount of downward movement compared to the height of the screen.
                CGFloat verticalMovement = translation.y / self.contentContainerView.bounds.size.height;
                float downwardMovement = fmaxf((float)verticalMovement, 0.0);
                float downwardMovementPercent = fminf(downwardMovement, 1.0);
                CGFloat progress = (CGFloat)downwardMovementPercent;
                
                // Complete the transition if the dragging is past the percent threshold.
                self.transitionInteractor.shouldFinish = progress > kPanDismissPercentThreshold;
                
                // Update the interactor with the percentage so animate transition is called.
                [self.transitionInteractor updateInteractiveTransition:progress];
            }
            else
            {
                if (self.canDrag)
                {
                    self.isDragging = YES;
                    self.scrollView.panGestureRecognizer.enabled = NO;
                }
                else
                {
                    self.canDrag = NO;
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            if (self.isDragging || self.canDrag)
            {
                // Cancel the transition.
                self.transitionInteractor.hasStarted = NO;
                [self.transitionInteractor cancelInteractiveTransition];
                
                [self completeTransitionForIncompleteAnimation];
                
                [self resetDragView];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (self.isDragging || self.canDrag)
            {
                // Based on the drag percentage, finish or cancel the transition.
                self.transitionInteractor.hasStarted = NO;
                self.transitionInteractor.shouldFinish ? [self.transitionInteractor finishInteractiveTransition] : [self.transitionInteractor cancelInteractiveTransition];
                
                [self completeTransitionForIncompleteAnimation];
                
                [self resetDragView];
            }
        }
            break;
            
        default:
            break;
    }
}

// IREF-3393: This method is needed for fast swipe to dismiss to work for iOS 9.2 and below.
// iOS bug: http://www.openradar.me/21961293
// These can be removed when we stop supporting iOS 9.2.
- (void)completeTransitionForIncompleteAnimation
{
    double delayInSeconds = [self transitionDuration:self.transitionContext];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void)
    {
        if (self.type == TransitionEnter)
        {
            [self enterAnimationCompleted];
        }
        else if (self.type == TransitionExit)
        {
            [self exitAnimationCompleted];
        }
    });
}

- (void)resetDragView
{
    self.scrollView.panGestureRecognizer.enabled = YES;
    self.canDrag = NO;
    self.isDragging = NO;
    [self.panGesture setTranslation:CGPointZero inView:self.presentingView];
}

- (void)dragViewInDismissMode
{
    CGPoint translation = [self.panGesture translationInView:self.presentingView];
    CGFloat ty = translation.y;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, ty);
    [self.snapshotView setTransform:transform];
    
    CGFloat dismissViewCenter = self.dismissView.bounds.size.height/2;
    CGFloat offset = ty * kDismissViewOffsetMultiplier;
    CGFloat dismissViewY = dismissViewCenter + offset;
    self.dismissView.center = CGPointMake(self.dismissView.center.x, dismissViewY);
}

- (BOOL)isValidDragStartPoint:(CGPoint)point
{
    BOOL result = NO;
    if (self.scrollView && self.scrollView.contentOffset.y <= 0)
    {
        CGRect largeWindowSwipeRect = self.contentView.bounds;
        result = CGRectContainsPoint(largeWindowSwipeRect, point);
    }
    else
    {
        CGFloat height = (self.dismissButton.isEnabled) ? kSmallSwipeWindowHeight : 0;
        CGRect smallWindowSwipeRect = CGRectMake(0, 0,
                                                 self.contentView.frame.size.width,
                                                 height);
        result = CGRectContainsPoint(smallWindowSwipeRect, point);
    }
    
    return result;
}

#pragma mark - Dismiss Button

- (UIButton *)buildDropDownButtonWithFrame:(CGRect)frame
{
    const CGSize pullDownIconSize = CGSizeMake(56,24);
    
    UIButton *dropDownButton = [[UIButton alloc] initWithFrame:frame];
    dropDownButton.backgroundColor = [UIColor wdprPaleGrayColor];
    dropDownButton.accessibilityTraits = UIAccessibilityTraitButton;
    dropDownButton.accessibilityLabel = WDPRLocalizedStringInBundle(@"com.wdprcore.dropdownbutton.label.message", WDPRCoreResourceBundleName, nil);
    
    if (!IS_VERSION_10_OR_LATER)
    {
        dropDownButton.isAccessibilityElement = NO;
        dropDownButton.accessibilityElementsHidden = YES;
    }
    
    UIControlEvents touchUpEvents = UIControlEventTouchUpInside | UIControlEventTouchUpOutside |
    UIControlEventTouchDragInside | UIControlEventTouchDragOutside;
    
    [dropDownButton setImage:[WDPRIcon imageOfIcon:WDPRIconPullDown
                                         withColor:[UIColor wdprInactiveGrayColor]
                                           andSize:pullDownIconSize] forState:UIControlStateNormal];
    
    [dropDownButton setImage:[WDPRIcon imageOfIcon:WDPRIconPullDown
                                         withColor:UIColor.whiteColor
                                           andSize:pullDownIconSize] forState:UIControlStateHighlighted];
    
    [dropDownButton addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [dropDownButton addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [dropDownButton addTarget:self action:@selector(onTouchUp:) forControlEvents:touchUpEvents];
    return dropDownButton;
}

- (void)onTouchDown:(UIButton *)button
{
    button.backgroundColor = [UIColor wdprPaleGrayColor];
}

- (void)onTouchUp:(UIButton *)button
{
    button.backgroundColor = [UIColor wdprEnabledTertiaryButtonColor];
}

- (void)onTouchUpInside:(UIButton *)button
{
    if (self.disableDismissAction)
    {
        return;
    }
    
    if (![self isDismissViewEnabled])
    {
        [self.navController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if (self.snapshotView && self.snapshotView.superview)
        {
            [self hideDismissViewAction];
            
        }
        else
        {
            [self showDismissViewAction];
        }
    }
}

- (void)rotateDismissButton:(BOOL)rotate
{
    [UIView animateWithDuration:kDismissButtonRotationDuration animations:
     ^{
         self.dismissButton.imageView.transform = (rotate ? CGAffineTransformMakeRotation(M_PI) :
                                                   CGAffineTransformIdentity);
     }];
}

#pragma mark - SnapshotView

- (void)createSnapshotView
{
    // This is only used if there is a dismiss view.
    
    if (!self.snapshotView)
    {
        UIView *snapshotView = [self.contentContainerView snapshotViewAfterScreenUpdates:NO];
        snapshotView.frame = self.contentContainerView.frame;
        snapshotView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        snapshotView.layer.shouldRasterize = YES;
        
        if ([self isDismissViewEnabled])
        {
            
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            CGFloat maskY = CGRectGetHeight(self.dismissButton.frame);
            CGFloat maskHeight = (CGRectGetHeight(self.contentContainerView.frame) - CGRectGetHeight(self.dismissButton.frame));
            CGRect maskRect = CGRectMake(0, maskY, CGRectGetWidth(self.contentContainerView.frame), maskHeight);
            
            CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
            maskLayer.path = path;
            CGPathRelease(path);
            
            snapshotView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentContainerView.frame),
                                            CGRectGetHeight(self.contentContainerView.frame));
            snapshotView.layer.mask = maskLayer;
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(onTouchUpInside:)];
            [snapshotView addGestureRecognizer:tapGestureRecognizer];
            
            self.snapshotView = [[UIView alloc] initWithFrame:self.contentContainerView.frame];
            [self.snapshotView addSubview:snapshotView];
            [self.snapshotView addSubview:self.dismissButton];
            
        }
        else
        {
            self.snapshotView = snapshotView;
        }
        
        self.hideContentView = [[UIView alloc] initWithFrame:self.contentContainerView.bounds];
        self.hideContentView.backgroundColor = [UIColor wdprPaleGrayColor];
        [self.contentContainerView addSubview:self.hideContentView];
        [self.outerContainerView addSubview:self.snapshotView];
    }
}

- (void)endSnapshotView
{
    // This is only used if there is a dismiss view.
    
    if ([self isDismissViewEnabled])
    {
        [self rotateDismissButton:NO];
        self.dismissView.alpha = 0.0f;
    }
    
    [UIView animateWithDuration:kResetModalDuration
                          delay:kResetModalDelay
         usingSpringWithDamping:kResetModalSpringDamping
          initialSpringVelocity:kResetModalSpringVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:
     ^{
         self.snapshotView.transform  = CGAffineTransformIdentity;
     }
                     completion:^(BOOL finished)
     {
         [self.snapshotView removeFromSuperview];
         self.snapshotView = nil;
         
         if ([self isDismissViewEnabled])
         {
             [self.contentContainerView addSubview:self.dismissButton];
             self.isShowingDismissView = NO;
         }
         
         [self resetContentContainerViewFrame];
         [self.hideContentView removeFromSuperview];
         [self resetDragView];
     }];
}

#pragma mark -  WDPRModalSwipeDownTransition (Private)

- (void)resetContentContainerViewFrame
{
    CGRect frame = CGRectMake(0,
                              kStatusBarHeight,
                              self.outerContainerView.frame.size.width,
                              self.outerContainerView.frame.size.height - kStatusBarHeight);
    self.contentContainerView.frame = frame;
}

#pragma mark - Dismiss View methods

- (BOOL)isDismissViewEnabled
{
    BOOL result = self.dismissView != nil;
    return result;
}

- (BOOL)shouldShowDismissViewAtYCoordinate:(CGFloat)yCoordinate
{
    BOOL result = [self isDismissViewEnabled];
    if (result)
    {
        result = yCoordinate >= CGRectGetHeight(self.dismissView.frame);
    }
    return result;
}

- (CGFloat)alphaForDismissViewAtYCoordinate:(CGFloat)yCoordinate
{
    return yCoordinate / CGRectGetHeight(self.presentingView.frame);
}

- (BOOL)canDragAtYCoordinate:(CGFloat)yCoordinate
{
    BOOL result = self.canDrag;
    
    if ([self isDismissViewEnabled])
    {
        CGFloat maxY = CGRectGetHeight(self.presentingView.frame);
        result = yCoordinate < maxY;
    }
    
    return result;
}

- (void)addDismissView
{
    if (!self.dismissView.superview && self.dismissView)
    {
        [self.outerContainerView addSubview:self.dismissView];
        
        self.dismissView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = @{@"dismissView": self.dismissView};
        NSDictionary *metrics = @{@"lMargin" : @(kDismissViewLeftMargin),
                                  @"rMargin" : @(kDismissViewRightMargin)};
        
        NSString *hFormat = [NSString stringWithFormat:@"H:|-lMargin-[dismissView]-rMargin-|"];
        NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hFormat options:0 metrics:metrics views:views];
        [self.outerContainerView addConstraints:hConstraints];
        
        CGFloat height = CGRectGetHeight(self.dismissView.frame);
        NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self.dismissView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:height];
        [self.dismissView addConstraint:heightConstraint];
        
        NSLayoutConstraint *vConstraint = [NSLayoutConstraint constraintWithItem:self.outerContainerView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.dismissView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0f
                                                                        constant:kDismissViewTopMargin];
        [self.outerContainerView addConstraint:vConstraint];
        self.dismissView.alpha = 0.0f;
    }
}

/// To be used when the user taps on the dismiss view
- (void)showDismissView
{
    if (self.dismissView.superview)
    {
        [UIView animateWithDuration:kShowDismissViewDuration
                              delay:kShowDismissViewDelay
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:
         ^{
             self.dismissView.alpha = 1.0f;
             
         } completion:nil];
    }
}

- (void)showDismissViewAction
{
    [self createSnapshotView];
    
    [UIView animateWithDuration:kShowDismissViewDuration
                          delay:kShowDismissViewDelay
         usingSpringWithDamping:kShowDismissViewSpringDamping
          initialSpringVelocity:kShowDismissViewSpringVelocity
                        options:0
                     animations:
     ^{
         [self.snapshotView setTransform:
          CGAffineTransformMakeTranslation(0, MAX(CGRectGetHeight(self.dismissView.frame), 0))];
         [self rotateDismissButton:YES];
     }
                     completion:^(BOOL finished)
     {
         self.dismissView.accessibilityViewIsModal = YES;
         UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.dismissView);
         [self addDismissView];
         [self showDismissView];
         self.isShowingDismissView = YES;
         
     }];
}

/// To be used after the user ends dragging and the dismiss view should be shown
- (void)showDismissViewAfterDragging
{
    [self rotateDismissButton:YES];
    [UIView animateWithDuration:kShowDismissViewDuration
                          delay:kShowDismissViewDelay
         usingSpringWithDamping:kShowDismissViewSpringDamping
          initialSpringVelocity:kShowDismissViewSpringVelocity
                        options:0
                     animations: ^{
                         [self.snapshotView setTransform:
                          CGAffineTransformMakeTranslation(0,
                                                           MAX(CGRectGetHeight(self.dismissView.frame),
                                                               0))];
                         self.dismissView.center = CGPointMake(self.dismissView.center.x, self.dismissView.bounds.size.height/2);
                         self.dismissView.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         self.isShowingDismissView = YES;
                         [self resetDragView];
                     }];
}

#pragma mark - Public methods

- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated
{
    [self hideDismissButton:hide animated:animated completion:nil];
}

- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated completion:(void (^)(void))completionHandler
{
    CGFloat dismissButtonY = (hide) ? -(kWDPRNavBarDismissButtonHeight) : 0;
    CGFloat dismissButtonOffset = (hide) ? 0 : kWDPRNavBarDismissButtonHeight;
    
    self.dismissButton.enabled = !hide;
    
    if (!hide)
    {
        self.dismissButton.hidden = NO;
    }
    
    [self.innerContentContainerView layoutIfNeeded];
    
    [UIView animateWithDuration:(animated) ? UINavigationControllerHideShowBarDuration : 0
                     animations:
     ^{
         self.dismissButton.frame = CGRectMake(0,
                                               dismissButtonY,
                                               SCREEN_WIDTH,
                                               kWDPRNavBarDismissButtonHeight);
         
         self.innerContentContainerView.frame = CGRectMake(0,
                                                           dismissButtonOffset,
                                                           self.contentContainerView.frame.size.width,
                                                           (self.contentContainerView.frame.size.height -
                                                            dismissButtonOffset));
         [self.innerContentContainerView layoutIfNeeded];
         
     }
                     completion:^(BOOL finished)
     {
         self.dismissButton.hidden = hide;
         if (completionHandler != nil) {
             completionHandler();
         }
     }];
}

- (void)enableDragging:(BOOL)enable
{
    self.panGesture.enabled = enable;
}

- (void)enableViewOnDismiss:(UIView *)dismissView
{
    NSAssert(dismissView, @"Dismiss view cannot be empty");
    self.dismissView = dismissView;
}

- (void)disableViewOnDismiss
{
    [self.dismissView removeFromSuperview];
    self.dismissView = nil;
    self.disableDismissAction = NO;
}

- (void)hideDismissViewAction
{
    [UIView animateWithDuration:kHideDismissViewOnTouchDuration animations:
     ^{
         self.dismissView.alpha = 0.0f;
         
     }
                     completion:^(BOOL finished)
     {
         [self.dismissView removeFromSuperview];
         [self endSnapshotView];
     }];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.dismissButton);
}

@end
