//
//  WDPRRefreshControlView.h
//  WDPR
//
//  Created by Ricardo Contreras on 7/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

typedef NS_ENUM(NSUInteger, WDPRRefreshState)
{
    WDPRRefreshStateDefault,
    WDPRRefreshStateAnimating,
    WDPRRefreshStateReleased,
    WDPRRefreshStateSpringAction,
    WDPRRefreshStateFadeOut
};

@interface WDPRRefreshControlView : UIView

/**
 * Changes the state of WDPRRefreshControlView
 */
@property (nonatomic, assign) WDPRRefreshState state;

/**
 * Changes the color of the main circle
 */
@property (nullable, nonatomic, strong) UIColor *mainColor;

/**
 * Changes the view according to Y Offset of the scrollView
 */
- (void)scrollOffsetChanged:(CGPoint)offset withWidth:(float)width andCenter:(CGPoint)center;

/** Sets text on the label
 @param text - NSString of text to be set
 */
- (void)setText:(nullable NSString *)text;

/** Sets attributed text on the label
 @param attributedText - NSAttributedString to be set
 */
- (void)setAttributedText:(nullable NSAttributedString *)attributedText;

/**
 * Sets values for the start of animation
 */
- (void)resetValues;

@end
