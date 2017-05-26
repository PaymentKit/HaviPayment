//
//  WDPRTableViewController+Navigation.h
//  Pods
//
//  Created by Nguyen, Kevin on 4/19/17.
//
//

#import "WDPRTableViewController.h"

@interface WDPRTableViewController (Navigation)

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
