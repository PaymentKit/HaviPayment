//
//  WDPRModalNavigationController.h
//  DLR
//
//  Created by Delafuente, Rob on 4/15/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@class WDPRModalSwipeDownTransition, WDPRModalTransitionInteractor;

@interface WDPRModalNavigationController : UINavigationController <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) WDPRModalSwipeDownTransition *modalTransition;
@property (nonatomic, strong) WDPRModalTransitionInteractor *transitionInteractor;

+ (BOOL)isModalDisplayed;

/**
 * Hides/Shows the dismissButton.
 */
- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated;

/**
 * Hides/Shows the dismissButton with completionHandler.
 */
- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated completion:(void (^)(void))completionHandler;

/**
 * Shows the received view on the Outer Container View when user attempts to dismiss
 *
 * @param dismissView View to present on the container. Cannot be nil.
 */
- (void)enableViewOnDismiss:(UIView *)dismissView;

/**
 * Removes the Dismiss View (if any)
 */
- (void)disableViewOnDismiss;

/**
 * Hides the Dismiss View (if visible)
 */
- (void)dismissViewCancel;

/**
 * Hides the Dismiss View (if visible) and prevents the dismiss view from showing again
 */
- (void)dismissViewCancelAndDisable;

@end

@interface WDPRModalContainerViewController : UIViewController

@end
