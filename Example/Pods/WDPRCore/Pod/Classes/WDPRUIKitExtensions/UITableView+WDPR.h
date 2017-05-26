//
//  UITableView+WDPR.h
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPRFoundation.h"

@interface UITableView (WDPR)

@property (nonatomic, readonly) CGFloat idealContentHeight;

/// animated alternative to relaodData
/// (sometimes messes up section headers)
- (void)reloadDataAnimated;  // Defaults to fade

- (void)reloadDataAnimated:(UITableViewRowAnimation)animation;

- (NSIndexPath *)indexPathOfParentCellFromView:(UIView *)view;

/// add a (spinning) UIActivityIndicatorView to UITableViewCell
/// at specified indexPath, returning previous accessoryView
- (PlainBlock)addActivityIndicatorToRowAtIndexPath:(NSIndexPath*)indexPath;

@end
