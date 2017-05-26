//
//  WDPRModalNavigationController.m
//  DLR
//
//  Created by Delafuente, Rob on 4/15/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRModalNavigationController.h"
#import "WDPRModalTransitionInteractor.h"
#import "WDPRModalPresentationController.h"

__weak static WDPRModalNavigationController *firstDisplayedNavCon = nil;

@interface WDPRModalNavigationController() <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL disableDismissAction;

@end

@implementation WDPRModalNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Transition Setup
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    // View Setup
    [self setValue:[WDPRUINavigationBar new] forKey:@"navigationBar"];
    self.view.clipsToBounds = NO;
    self.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!firstDisplayedNavCon)
    {
        firstDisplayedNavCon = self;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (firstDisplayedNavCon == self)
    {
        firstDisplayedNavCon = nil;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (WDPRModalSwipeDownTransition *)modalTransition
{
    if (!_modalTransition)
    {
        _modalTransition = [WDPRModalSwipeDownTransition new];
        _modalTransition.navController = self;
        _modalTransition.transitionInteractor = self.transitionInteractor;
    }
    
    return _modalTransition;
}

- (WDPRModalTransitionInteractor *)transitionInteractor
{
    if (!_transitionInteractor)
    {
        _transitionInteractor = [WDPRModalTransitionInteractor new];
    }
    
    return _transitionInteractor;
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.modalTransition.type = TransitionEnter;
    return self.modalTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.modalTransition.type = TransitionExit;
    return self.modalTransition;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                               presentingViewController:(UIViewController *)presenting
                                                                   sourceViewController:(UIViewController *)source
{
    // WDPRModalPresentationController is used so the life cycle methods are called.
    // With UIPresentationController, the underlying view controller gets removed from the view stack.
    return [[WDPRModalPresentationController alloc]initWithPresentedViewController:presented presentingViewController:presenting];
}


// The interaction controller tells the transition class how much to animate according to a percentage.
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.transitionInteractor.hasStarted ? self.transitionInteractor : nil;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    self.modalTransition.scrollView = [self searchForFirstScrollView:viewController.view];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    NSUInteger countOfVCs = [self.viewControllers count];
    
    if (countOfVCs > 1)
    {
        UIViewController *nextViewController = self.viewControllers[countOfVCs-2];
        UIScrollView *scrollView = [self searchForFirstScrollView:nextViewController.view];
        self.modalTransition.scrollView = scrollView;
    }
    
    return [super popViewControllerAnimated:animated];
}

- (UIScrollView *)searchForFirstScrollView:(UIView *)view
{
    UIScrollView *foundScrollView;
    
    // We need to check if the view itself is a scrollView.
    // This fixes the issue the pull to dismiss issue for UITableViewControllers.
    if ([view isA:[UIScrollView class]])
    {
        return (UIScrollView *)view;
    }
    
    for (UIView *subView in view.subviews)
    {
        if ([subView isA:[UIScrollView class]])
        {
            foundScrollView = (UIScrollView *)subView;
            break;
        }
    }
    
    return foundScrollView;
}

#pragma mark - Public methods

+ (BOOL)isModalDisplayed
{
    return (firstDisplayedNavCon) ? YES : NO;
}

- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated
{
    [self hideDismissButton:hide animated:animated completion:nil];
}

- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated completion:(void (^)(void))completionHandler {
    [self.modalTransition hideDismissButton:hide animated:animated completion:completionHandler];
}

- (void)enableViewOnDismiss:(UIView *)dismissView
{
    NSAssert(dismissView, @"DismissView is empty");
    [self.modalTransition enableViewOnDismiss:dismissView];
}

- (void)disableViewOnDismiss
{
    [self.modalTransition disableViewOnDismiss];
}

- (void)dismissViewCancel
{
    [self.modalTransition hideDismissViewAction];
}

- (void)dismissViewCancelAndDisable
{
    self.modalTransition.disableDismissAction = YES;
    [self dismissViewCancel];
}

@end

@implementation WDPRModalContainerViewController

@end
