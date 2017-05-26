//
//  WDPRModalSwipeDownTransition.h
//  DLR
//
//  Created by Delafuente, Rob on 4/15/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDPRUIKit.h"
#import "WDPRModalTransitionInteractor.h"

extern NSString * const WDPRModalNavigationDidDismissNotification;
extern CGFloat const kWDPRNavBarDismissButtonHeight;

@protocol WDPRModalSwipeDownDelegate <NSObject>

@optional

- (void)willBeDismissed;

@end

typedef enum : NSUInteger
{
    TransitionEnter,
    TransitionExit
} TransitionType;

@interface WDPRModalSwipeDownTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) WDPRModalTransitionInteractor *transitionInteractor;
@property (nonatomic, assign) TransitionType type;
@property (nonatomic, weak) UINavigationController *navController;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIButton *dismissButton;
@property (nonatomic, assign) BOOL disableDismissAction;

/**
 * Contains the innerContentContainerView and the dismissButton.
 * Useful for subclasses of WDPRModalSwipeDownTransition
 */
@property (nonatomic, readonly) UIView *outerContainerView;

/**
 * Snapshot of contentContainerView.
 * Useful for subclasses of WDPRModalSwipeDownTransition
 */
@property (nonatomic, readonly) UIView *draggingSnapshotView;

/**
 * Hides/Shows the dismissButton.
 */
- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated;


/**
 * Hides/Shows the dismissButton with completionHandler
 */
- (void)hideDismissButton:(BOOL)hide animated:(BOOL)animated completion:(void (^)(void))completionHandler;

/**
 * Enables/Disables the Pan gesture recognizer.
 */
- (void)enableDragging:(BOOL)enable;
/**
 * When the user dismisses or drags it will display the received view instead of dismissing.
 *
 * @param dismissView View to display on dismiss
 */
- (void)enableViewOnDismiss:(UIView *)dismissView;

/**
 * Removes the Dismiss View (if any)
 */
- (void)disableViewOnDismiss;

/**
 * Hides the Dismiss View (animated)
 */
- (void)hideDismissViewAction;

@end
