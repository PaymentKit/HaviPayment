//
//  WDPRUIKit.h
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <CoreText/CTStringAttributes.h>
#import <UIKit/UIKit.h>
#import "WDPRFoundation.h"

#ifndef WDPR_BASE_VIEW_CONTROLLER
// This might not work, but the idea is that
// WDPRUIKit clients can insert their own
// base class for WDPRUIKit viewControllers
#define WDPR_BASE_VIEW_CONTROLLER WDPRViewController
#endif // WDPR_BASE_VIEW_CONTROLLER

#import "WDPRTheme.h"

// custom views
#import "WDPRIcon.h"
#import "UIGradientView.h"
#import "WDPRActivityIndicator.h"
#import "WDPRActivityAnimationView.h"
#import "WDPRCallToActionButton.h"
#import "WDPRExpandableTableDecorator.h"
#import "WDPRRefreshControl.h"
#import "WDPRUINavigationBar.h"
#import "WDPRCardCell.h"

// calendar component
#import "WDPRBlockOutCalendarView.h"
#import "WDPRDayCalendarCollectionViewCell.h"

// tableDataDelegate
#import "WDPRExpandableCell.h"
#import "WDPRTableViewItem.h"
#import "WDPRTableViewCell.h"
#import "WDPRTableSeparator.h"
#import "WDPRTableDataDelegate.h"
#import "WDPRTableDataDelegate+Validate.h"
#import "WDPRCollapsingTableSectionHeader.h"
#import "WDPRTableDataDelegate+PickerView.h"

// base view controllers
#import "WDPRViewController.h"
#import "WDPRTableController.h"
#import "WDPRWebViewController.h"

// UIKit Class extensions
#import "CGGeometry+WDPR.h"
#import "CAShapeLayer+WDPR.h"
#import "UIAlertView+Blocks.h"
#import "UIAlertView+WDPR.h"
#import "UIActionSheet+Blocks.h"
#import "UIBarButtonItem+WDPR.h"
#import "UIButton+WDPR.h"
#import "UIColor+HexColors.h"
#import "UIColor+WDPR.h"
#import "UIControl+WDPR.h"
#import "UIDevice+WDPR.h"
#import "UIFont+WDPR.h"
#import "UIImage+WDPR.h"
#import "UIImageView+WDPR.h"
#import "UILabel+WDPR.h"
#import "UITableView+WDPR.h"
#import "UITextField+WDPR.h"
#import "UIToolbar+WDPR.h"
#import "UIView+WDPR.h"
#import "UIViewController+WDPR.h"
#import "NSString+WDPRUIKit.h"
#import "NSAttributedString+WDPRUIKit.h"
#import "NSLayoutConstraint+WDPR.h"
#import "WDPRViewController+Navigation.h"
#import "WDPRNotificationBanner.h"

// UIViewControllerTransitions
#import "WDPRModalSwipeDownTransition.h"
#import "WDPRModalTransitionInteractor.h"

// UINavigationController
#import "WDPRModalNavigationController.h"
#import "WDPRMailComposeViewController.h"


/// Display an alert that a function is not implemented
void notYetImplemented(NSString* message);

@interface NSObject (WDPRUIKit)

// Display a not yet implemented alert
- (void)notYetImplemented;

// Display a not yet implemented alert with a custom message
- (void)notYetImplemented:(NSString*)message;

@end
