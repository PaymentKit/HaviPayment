//
//  WDPRExpandableCell.h
//  Mdx
//
//  Created by J.Rodden on 3/25/16.
//  Copyright © 2016 WDPRO. All rights reserved.
//

#import "WDPRTableViewCell.h"

@interface WDPRExpandableCell : WDPRTableViewCell

- (void)toggleExpansionState;

@property (nonatomic, retain) UIView* expandedView;
@property (nonatomic, retain) UIView* contractedView;
@property (nonatomic, getter=isExpanded) BOOL expanded;

/// Keeps the cell always expanded as long as the expandedView is set
/// that means hiding the disclosure indicator and avoiding user interaction
@property (nonatomic, getter=isAlwaysExpanded) BOOL alwaysExpanded;

/// Determines if the expandable cell should use
/// separate focusable areas for contracted and expanded views
@property (nonatomic, getter=focusesExpandedViewSeparatelyForAccessibility) BOOL focusExpandedViewSeparatelyForAccessibility;

@end
