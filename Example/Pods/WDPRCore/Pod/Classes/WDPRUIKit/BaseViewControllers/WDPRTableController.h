//
//  WDPRTableController.h
//  WDPR
//
//  Created by Rodden, James on 7/3/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

/**
 WDPRTableControllerDelegate provides a quick (& dirty) tableView
 controller which does basic stuff for free and lets you 
 focus on customizing appearance/behavior. It behaves 
 very similarly to UITableViewController, but without 
 the limitations inherent in that class.

 Most of the functionality is off-loaded to
 WDPRTableDataDelegate, look there for more info.
 */

@protocol WDPRTableController

@optional

/// Implementing this method adds support for pullToRefresh.
/// It is called in response to pullToRefresh gesture.
- (void)didSelectRefresh;

/// (optional) provide the name of a plist file
/// containing the array of initial items to be
/// loaded into the WDPRTableDataDelegate.
/// If this method is implemented, it takes
/// precedence over the initialData property.
@property(nonatomic, readonly) NSString* pList;

/// (optional) provide an array of initial items
/// to be loaded into the WDPRTableDataDelegate.
/// This method is only called if the pList
/// getter is not implemented.
@property(nonatomic, readonly) NSArray* initialData;

/// (optional) Provide an array of initial
/// section headers to be loaded into the
/// WDPRTableDataDelegate. See WDPRTableDataDelegate's
/// headers property for more information.
@property(nonatomic, readonly) NSArray* sectionHeaders;

/// (optional) Provide an array of initial
/// section footers to be loaded into the
/// WDPRTableDataDelegate. See WDPRTableDataDelegate's
/// footers property for more information.
@property(nonatomic, readonly) NSArray* sectionFooters;

@end  // @protocol WDPRTableControllerDelegate

// ------------------------------------------------------------------

@interface WDPRTableController : WDPR_BASE_VIEW_CONTROLLER
<WDPRTableController, WDPRTableViewDataSource, WDPRTableViewDelegate>

/// @name Initialization Methods

- (id)initWithStyle:(UITableViewStyle)style;

/// @name Properties

@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) WDPRTableDataDelegate * dataDelegate;
@property (nonatomic, readonly) CGFloat idealContentHeight __deprecated_msg("use UITableView's idealContentHeight");

/// If not set via IB, one will be created automatically
@property (nonatomic, readonly) UITableView* tableView;

/// Set refreshControlIsSyncronous to NO if it's needed to override when the refresh
/// control stops. Otherwise defaults to syncronous refresh of the table. Must
/// execute self.refreshControl endRefreshing on the main thread if overriding.
@property (nonatomic, assign) BOOL refreshControlIsSyncronous;

/// Mimick what UITableViewController does regarding selection on viewDidAppear, defaults to YES
@property (nonatomic, assign) BOOL clearsSelectionOnViewDidAppear;

@property (nonatomic, readonly) UIRefreshControl *refreshControl;

/// Getter and setter for static variable to enable hide dismiss button when the user scrolls.
+ (BOOL)isAutoHideModalDismissButtonUponScrollEnabled;
+ (void)setAutoHideModalDismissButtonUponScrollEnabled:(BOOL)enabled;

+ (instancetype)formWithInputData:(id)inputData
                      actionTitle:(NSString *)title
                       completion:(void (^)(id data))completion;

+ (instancetype)formWithInputData:(id)inputData
                      actionTitle:(NSString *)title
                       completion:(void (^)(id outputData))completion
              dataCollectionBlock:(void (^)(id item, id data))dataCollectionBlock;

/// @name Override/Hook Methods

/// Override this method to be notified when the tableView is
/// resized in response to the keyboard or a pickerView being
/// shown or hidden. Be sure to call base class implementation.
- (void)keyboardWillAnimate:(NSNotification*)notification show:(BOOL)show;

/// Override point to catch pullToRefresh gesture...only call as part of override.
/// You should never call this method directly yourself.
- (void)beginRefresh;

/// Stops the UIRefresh in the table and reloads the data. Must call at the end
/// of an asyncronous call to stop refreshing.
- (void)endRefresh;

/// Reloads initialItems into dataDelegate and updates table. Thread safe.
- (void)reloadItems;

/// Reloads initialItems, sectionHeaders, and sectionFooters
/// into dataDelegate and updates table. Thread safe.
- (void)reloadItemsAndHeaders:(BOOL)headers
                   andFooters:(BOOL)footers;

/// block returned by UITableView's addActivityIndicatorToRowAtIndexPath:
/// subclasses may assign this inside their tableView:didSelectRowAtIndexPath:
/// in order to block future selection of other rows while awaiting a service
/// response and/or setting up a VC to push or present, thereby avoiding
/// multiple user initiated actions and hosing the view hierachy
@property (nonatomic, copy) PlainBlock removeActivityIndicatorBlock;

/// Holds a reference to the button that's added at the end of form 
@property (nonatomic, weak, readonly) UIButton *callToActionButton;

@end    // @interface WDPRTableControllerDelegate
