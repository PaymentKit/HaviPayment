//
//  UIViewController+WDPR.m
//  DLR
//
//  Created by Francisco Valbuena on 3/9/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRLoader.h"

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

static NSString *const kActivityIndicator = @"activityIndicator";
static NSString *const kDisplayCount = @"displayCount";
static NSString *const kPositionView = @"positionView";
static CGFloat   const kAccessibilityLoaderDelay = 1.5f;
static CGFloat   const kAlignmentTopDistance = 100.0f;
static CGFloat   const kAlignmentBottomDistance = 100.0f;
static CGFloat   const kAlignmentBottomDistanceLabelAndLoader = 24.0f;
static CGFloat   const kDefaultDistanceFromTopForAlignmentTop = 100.0f;
static CGFloat   const kDefaultDistanceFromBottomForAlignmentBottom = 20.0f;

@implementation UIViewController (WDPR)

- (BOOL)isModal
{
    return ((self.presentingViewController &&
             self.presentingViewController.presentedViewController == self) ||
            (self.navigationController &&
             self.navigationController.presentingViewController &&
             (self.navigationController.presentingViewController.
              presentedViewController == self.navigationController)));
}

#pragma mark -

- (UIButton*)addCallToAction:(NSString*)title block:(PlainBlock)block
{
    UIButton* button;
    [self.view addSubview:button =
     [WDPRCallToActionButton buttonWithTitle:title block:block]];
    
    button.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleTopMargin);
    
    enum { kCTAButtonHeight = 48 };
    [button setFrame:
     CGRectOffsetAndShrink(self.view.bounds, 0,
                           self.view.bounds.size.height - kCTAButtonHeight)];
    
    return button;
}

#pragma mark -

- (void)presentModally:(UIViewController*)vc
{
    [self presentModally:vc withLeftCancelButton:NO];
}

- (void)pushViewController:(UIViewController*)vc
{
    if (vc)
    {
        // this is where custom-stylized back button is added
        if (!vc.navigationItem.leftBarButtonItem)
        {
            __weak UIViewController* weakRef = vc;
            [vc.navigationItem setLeftBarButtonItem:
             [UIBarButtonItem backButtonItem:
              ^{
                  __strong UIViewController *strongRef = weakRef;
                  
                  strongRef.navigationItem.leftBarButtonItem.enabled = NO;
                  [strongRef.navigationController popViewControllerAnimated:YES];
              }]];
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)dismissViewController
{
    [self dismissViewControllerCompletion:nil];
}

#pragma mark - Activity Indicator

- (void)displayActivityIndicator
{
    [self displayActivityIndicatorTransactional:NO message:nil inView:self.view];
}

- (void)displayActivityIndicatorWithMessage:(NSString*)message
{
    [self displayActivityIndicatorTransactional:NO message:message inView:self.view];
}

- (void)displayActivityIndicatorTransactional
{
    [self displayActivityIndicatorTransactionalWithMessage:nil];
}

- (void)displayActivityIndicatorTransactionalWithMessage:(NSString*)message
{
    [self displayActivityIndicatorTransactional:YES
                                        message:message
                                         inView:nil];
}

- (void)displayActivityIndicatorTransactional:(BOOL)transactional message:(NSString*)message distanceFromTop:(CGFloat)distanceFromTop
{
    if (transactional == NO)
    {
        UIView *positionView = [[UIView alloc] initWithFrame:CGRectMake(0, distanceFromTop, self.view.bounds.size.width, self.view.bounds.size.height - distanceFromTop)];
        positionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:positionView];
        self[kPositionView] = positionView;
        [self displayActivityIndicatorTransactional:NO message:message inView:positionView];
    }
    else
    {
        [self displayActivityIndicatorTransactional:YES message:message inView:self.view];
        WDPRLoader* activityIndicator = self[kActivityIndicator];
        activityIndicator.distanceFromTop = distanceFromTop;
        activityIndicator.distanceBetweenLabelAndLoader = 16.f;
    }
}

- (void)displayActivityIndicatorTransactional:(BOOL)transactional
                                      message:(NSString*)message
                                    alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment
{
    [self displayActivityIndicatorTransactional:transactional message:message inView:self.view];
    WDPRLoader* activityIndicator = self[kActivityIndicator];
    
    switch (alignment)
    {
        case WDPRViewControllerActivityIndicatorAlignmentTop:
        {
            activityIndicator.distanceFromTop = kAlignmentTopDistance;
        }
            break;
        case WDPRViewControllerActivityIndicatorAlignmentBottom:
        {
            activityIndicator.distanceFromBottom = kAlignmentBottomDistance;
            activityIndicator.distanceBetweenLabelAndLoader = kAlignmentBottomDistanceLabelAndLoader;
        }
            break;
        default:
            break;
    }
}

// NOTE: the underlying API this relies on, UIView's
// showStatusView:message:spinner ignores all its
// arguments per creative direction, but this
// withMessage variant of the wrapper method is being
// kept, along with all the calls that pass a message
// string in case that creative direction changes.
- (void)displayActivityIndicatorTransactional:(BOOL)transactional message:(NSString*)message inView:(UIView *)inView
{
    if (!message)
    {
        message = WDPRLocalizedStringInBundle(@"com.wdprcore.viewcontrollerwdpr.message", WDPRCoreResourceBundleName, nil);
    }
    
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self displayActivityIndicatorTransactional:transactional message:message inView:inView];
        });
    }
    else
    {
        WDPRLoader* activityIndicator = self[kActivityIndicator];
        
        if (!activityIndicator)
        {
            self.view.userInteractionEnabled = ! transactional;
            self.navigationController.navigationBar.userInteractionEnabled = ! transactional;
            self.navigationController.navigationBar.topItem.leftBarButtonItem.enabled = ! transactional;
            
            WDPRLoader *activityIndicator = nil;
            if (transactional)
            {
                activityIndicator = [WDPRLoader showTransactionalLoaderWithLabel:message];
                [activityIndicator setIsViewBlocking:YES];
            }
            else
            {
                activityIndicator = [WDPRLoader showNonTransactionalLoaderWithLabel:message inView:inView];
            }
            
            activityIndicator.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.90];
            self[kActivityIndicator] = activityIndicator;
        }
        
        MAKE_WEAK(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAccessibilityLoaderDelay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),
                       ^{
                           MAKE_STRONG(self);
                           if (strongself[kActivityIndicator] && strongself.isViewLoaded &&
                               strongself.view.window)
                           {
                               UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                                               strongself[kActivityIndicator]);
                           }
                       });
        int displayCount = [self[kDisplayCount] intValue];
        displayCount = MAX(displayCount + 1, 1);
        self[kDisplayCount] = @(displayCount);
    }
}

- (void)updateActivityIndicatorWithMessage:(NSString*)message
{
    WDPRLoader* activityIndicator = self[kActivityIndicator];
    [activityIndicator setText:message];
}

- (void)dismissActivityIndicator
{
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self dismissActivityIndicator];
        });
    }
    else
    {
        executeOnNextRunLoop
        (^{ // always defer so dismiss/display pairs get coalesced (no flash)
            WDPRLoader* activityIndicator = self[kActivityIndicator];
            
            int displayCount = [self[kDisplayCount] intValue];
            if (--displayCount <= 0)
            {
                [activityIndicator stopAnimatingWithCompletionHandler:nil];
                [activityIndicator removeFromSuperview];
                self.navigationController.navigationBar.userInteractionEnabled = YES;
                self.view.userInteractionEnabled = YES;
                self.navigationController.navigationBar.topItem.leftBarButtonItem.enabled = YES;
                self[kActivityIndicator] = nil;
                self[kDisplayCount] = nil;
                [self[kPositionView] removeFromSuperview];
            }
            else
            {
                self[kDisplayCount] = @(displayCount);
            }
        });
    }
}

- (WDPRLoader *)showNonTransactionalActivityIndicatorWithLabel:(NSString *)text
                                                     alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment
{
    return [self showNonTransactionalActivityIndicatorInView:self.view label:text alignment:alignment];
}

- (WDPRLoader *)showNonTransactionalActivityIndicatorInView:(UIView*)view
                                                      label:(NSString *)text
                                                  alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment
{
    // SLING-18469: We need to do this since the WDPRLoader doesn't handle resizing of it's bounds.
    CGFloat loaderSize = MIN(view.bounds.size.width, view.bounds.size.height);
    CGRect loaderFrame = CGRectMake(0, 0, loaderSize, loaderSize);
    
    WDPRLoader *activityIndicator = [[WDPRLoader alloc] initWithFrame:loaderFrame];
    [activityIndicator setParentView:view];
    [activityIndicator setText:text];
    [activityIndicator startAnimating];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addConstraint:[NSLayoutConstraint setConstantConstraintFor:activityIndicator
                                                           attribute:NSLayoutAttributeWidth
                                                            constant:loaderSize]];
    
    [view addConstraint:[NSLayoutConstraint setConstantConstraintFor:activityIndicator
                                                           attribute:NSLayoutAttributeHeight
                                                            constant:loaderSize]];
    
    switch (alignment) 
    {
        case WDPRViewControllerActivityIndicatorAlignmentCenter: 
        {   [view addConstraint:[NSLayoutConstraint centerViewHorizontally:activityIndicator inContainingView:view]];
            [view addConstraint:[NSLayoutConstraint centerViewVertically:activityIndicator inContainingView:view]];
        }   break;
            
        case WDPRViewControllerActivityIndicatorAlignmentTop: 
        {   [activityIndicator setDistanceFromTop:kDefaultDistanceFromTopForAlignmentTop];
            [view addConstraint:[NSLayoutConstraint pinTopOfView:activityIndicator toTopOfView:view]];
        }   break;
            
        case WDPRViewControllerActivityIndicatorAlignmentBottom: 
        {   [activityIndicator setDistanceFromBottom:kDefaultDistanceFromBottomForAlignmentBottom];
            [view addConstraint:[NSLayoutConstraint pinBottomOfView:activityIndicator toBottomOfView:view]];
        }   break;

        default:
            break;
    }
    
    [self themeActivityIndicator:activityIndicator];
    return activityIndicator;
}

- (WDPRLoader *)showTransactionalActivityIndicatorWithLabel:(NSString *)text
                                                  alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment
{
    WDPRLoader *activityIndicator = [WDPRLoader showTransactionalLoaderWithLabel:text];
    [activityIndicator setIsViewBlocking:YES useWhiteView:YES];
    
    switch (alignment) 
    {
        case WDPRViewControllerActivityIndicatorAlignmentTop: 
        {   [activityIndicator setDistanceFromTop:kDefaultDistanceFromTopForAlignmentTop];
        }   break;
            
        case WDPRViewControllerActivityIndicatorAlignmentBottom: 
        {   [activityIndicator setDistanceFromBottom:kDefaultDistanceFromBottomForAlignmentBottom];
        }   break;
            
        default:
            break;
    }
    
    [self themeActivityIndicator:activityIndicator];
    return activityIndicator;
}

- (void)themeActivityIndicator:(WDPRLoader *)activityIndicator
{
    [activityIndicator setFont:[UIFont wdprFontStyleB2]];
    [activityIndicator setTextColor:[UIColor wdprDarkBlueColor]];
}

- (void)removeActivityIndicator:(WDPRLoader *)activityIndicator completion:(void (^)())completion
{
    const CGFloat kActivityIndicatorFadeAnimationDuration = 0.2;
    
    [activityIndicator stopAnimatingWithCompletionHandler:
     ^{
         [UIView animateWithDuration:kActivityIndicatorFadeAnimationDuration animations:
          ^{
              activityIndicator.alpha = 0;
          } 
                          completion:^(BOOL finished) 
          {
              [activityIndicator removeFromSuperview];
              SAFE_CALLBACK(completion);
          }];
     }];
}

#pragma mark -

- (void)setupRuleUnderHeader 
{
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[whiteView imageOfSelf]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    UIView *paleGrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [paleGrayView setBackgroundColor:[UIColor wdprPaleGrayColor]];
    [self.navigationController.navigationBar setShadowImage:[paleGrayView imageOfSelf]];
}

#pragma mark - Properties

- (void)dismissViewControllerCompletion:(void (^)(void))completion
{
    [self dismissViewControllerCompletion:completion animated:YES];
}

- (void)dismissViewControllerCompletion:(void (^)(void))completion animated:(BOOL)animated
{
    if (self.presentingViewController)
    {
        [self.presentingViewController
         dismissViewControllerAnimated:animated completion:completion];
    }
    else if (self.presentedViewController)
    {
        [self dismissViewControllerAnimated:animated completion:completion];
    }
    else
    {
        UINavigationController *navController =
        ([self isKindOfClass:UINavigationController.class] ?
         (UINavigationController *)self : self.navigationController);
        
        [navController popViewControllerAnimated:animated];
        if (completion)
        {
            completion();
        }
    }
}

- (void)presentModally:(UIViewController*)vc
  withLeftCancelButton:(BOOL)leftCancelButton
{
    [self presentModally:vc withLeftCancelButton:leftCancelButton completion:nil];
}

- (void)presentModally:(UIViewController*)vc
  withLeftCancelButton:(BOOL)leftCancelButton
            completion:(void (^)(void))completion
{
    if (vc)
    {
        // centralize "modal state" configuration
        __weak UIViewController* weakRef = vc;
        
        if (leftCancelButton)
        {
            vc.view.clipsToBounds = NO;
            [vc.navigationItem setLeftBarButtonItem:
             [UIBarButtonItem cancelButtonItem:
              ^{
                  __strong UIViewController *strongRef = weakRef;
                  [strongRef dismissViewController];
              }]];
        }
        
        WDPRModalNavigationController *navCon;
        if([vc isKindOfClass:[WDPRModalNavigationController class]])
        {
            navCon = (WDPRModalNavigationController *)vc;
        }
        else if([vc isKindOfClass:[UINavigationController class]])
        {
            WDPRModalContainerViewController *containerVC = [WDPRModalContainerViewController new];
            containerVC.view.frame = CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT);
            [containerVC addChildViewController:vc
                                             withFrame:containerVC.view.frame];
            navCon = [[WDPRModalNavigationController alloc] initWithRootViewController:containerVC];
            navCon.navigationBarHidden = YES;
        }
        else
        {
            navCon = [[WDPRModalNavigationController alloc]
                                                     initWithRootViewController:vc];
        }

        
        [self presentViewController:navCon animated:YES completion:completion];
    }
}

- (void)addChildViewControllerFullScreen:(UIViewController *)childController
{
    childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:childController withFrame:self.view.bounds];
}

- (void)addChildViewController:(UIViewController *)childController withFrame:(CGRect)frame
{
    [self addChildViewController:childController];
    [self.view addSubview:childController.view];
    childController.view.frame = frame;
    [childController didMoveToParentViewController:self];
}

- (void)presentChildControllerAsModal:(UIViewController *)viewController withHeight:(CGFloat)height animated:(BOOL)animated
{
    const CGFloat width = CGRectGetWidth(self.view.bounds);
    
    // animate from off-screen
    viewController.view.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds), width, height);
    
    // add small drop-shadow if smaller than screen height
    if (height < SCREEN_HEIGHT)
    {
        viewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
        viewController.view.layer.shadowOffset = CGSizeMake(1.0f, 8.0f);
        viewController.view.layer.shadowOpacity = 0.6f;
        viewController.view.layer.shadowRadius = 10.0f;
        viewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:viewController.view.bounds].CGPath;
    }
    
    [self.view addSubview:viewController.view];
    [self.view bringSubviewToFront:viewController.view];
    [self addChildViewController:viewController];
    
    [UIView
     animateWithDuration:animated ? 0.5 : 0
     animations:^
     {
         viewController.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                                CGRectGetMinY(self.view.bounds),
                                                width, height);
     }
     completion:^(BOOL finished)
     {
         [viewController didMoveToParentViewController:self];
     }];
}

- (void)presentChildControllerAsModal:(UIViewController *)viewController animated:(BOOL)animated
{
    [self presentChildControllerAsModal:viewController withHeight:CGRectGetHeight(self.view.bounds) animated:animated];
}

- (void)dismissModalChildController:(BOOL)animated completion:(void (^)(void))completion
{
    UIViewController *presentedController = [self.childViewControllers lastObject];
    
    [presentedController willMoveToParentViewController:nil];
    
    [UIView
     animateWithDuration:animated ? 0.5 : 0
     animations:^
     {
         presentedController.view.frame = CGRectMake(0,
                                                     SCREEN_HEIGHT,
                                                     CGRectGetWidth(presentedController.view.frame),
                                                     CGRectGetHeight(presentedController.view.frame));
     }
     completion:^(BOOL finished)
     {
         [presentedController.view removeFromSuperview];
         [presentedController removeFromParentViewController];
         
         if (completion)
         {
             completion();
         }
     }];
}

@end
