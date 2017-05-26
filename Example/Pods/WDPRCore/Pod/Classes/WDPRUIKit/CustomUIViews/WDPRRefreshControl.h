//
//  WDPRRefreshControl.h
//  WDPR
//
//  Created by Ricardo Contreras on 7/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

@interface WDPRRefreshControl : UIControl

#pragma mark - UIRefreshControl

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nullable, nonatomic, strong) UIColor *tintColor;
@property (nullable, nonatomic, strong) NSAttributedString *attributedTitle;

/**
 * May be used to indicate to the refreshControl that an external event has initiated the refresh action
 */
- (void)beginRefreshing;

/**
 * Must be explicitly called when the refreshing has completed
 */
- (void)endRefreshing;

#pragma mark - WDPRRefreshControl Specific

@property (nullable, nonatomic, strong) NSString *title;

/**
 * Attaches the Refresh Control circle animation to a view.
 * By default this is done when adding the Refresh Control to the superview.
 * Only use this method to re-atach the animation when needed.
 *
 * @param view UIView to attach the animation to. The view must be either a UItableView or a UICollectionView.
 */
- (void)attachAnimationToView:(nullable UIView *)view;

/**
 * Restores the Refresh Control to its original state without animation.
 */
- (void)reset;

@end
