//
//  WDPRViewController+Navigation.h
//  Pods
//
//  Created by Uribe, Martin on 2/23/16.
//
//

#import "WDPRViewController.h"

@interface WDPRViewController (Navigation)

/**
 * Hides/Shows the PullToDismiss button only available in the WDPRModalNavigationController.
 * @discussion: No effect will occur if the view controller hasn't been loaded, you should call this
 * method once the view controller is loaded
 */
- (void)hidePullToDismissButton:(BOOL)hide animated:(BOOL)animated;

/** Hides/Shows the PullToDismiss button only available in the WDPRModalNavigationController.
 * Also Enables/Disables the PullToDismiss dragging gesture.
 * @discussion: No effect will occur if the view controller hasn't been loaded, you should call this
 * method once the view controller is loaded
 */
- (void)hidePullToDismissButton:(BOOL)hide animated:(BOOL)animated disableDragging:(BOOL)disable;

/**
 * Enables/Disables the PullToDismiss dragging gesture only available in the WDPRModalNavigationController.
 * @discussion: No effect will occur if the view controller hasn't been loaded, you should call this
 * method once the view controller is loaded
 */
- (void)enablePullToDismissDragging:(BOOL)enable;

@end
