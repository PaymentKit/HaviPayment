//
//  WDPRTableControllerDelegate.m
//  WDPR
//
//  Created by Rodden, James on 7/3/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

@interface WDPRTableController ()
{
    // since we have both setter and
    // getter methods, we need an ivar
    // (it isn't auto generated for us)
    WDPRTableDataDelegate * _dataDelegate;
}

@property (nonatomic) IBOutlet UITableView* tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, weak) UIButton *callToActionButton;

@end // @interface WDPRTableControllerDelegate ()

static UITableView* tableViewWithStyle(UITableViewStyle style)
{
    UITableView* tableView = 
    [[UITableView alloc] initWithFrame:CGRectZero style:style];
    
    // default autolayout
    [tableView setAutoresizingMask:
     (UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleHeight)];

    // default backgrounds
    tableView.backgroundView = nil;
    tableView.backgroundColor = UIColor.whiteColor;
    
    return tableView;
}

#pragma mark -

@implementation WDPRTableController

static BOOL autoHideModalDismissButtonUponScroll = NO;

enum {
    // How far to drag before refresh is triggered
    kRefreshDistance = 150
};

BOOL blockPullDownRefresh = NO;

- (id)init 
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    
    [self removeAllObservers];
}

- (id)initWithStyle:(UITableViewStyle)style 
{
    self = [super init];
    
    if (self && !_tableView)
    {
        _tableView = tableViewWithStyle(style);
    }
    
    return self;
}

#pragma mark -

- (void)loadView
{
    [super loadView];
    
    if (!self.tableView.delegate)
    {
        self.tableView.delegate = self;
    }
    
    if (!self.tableView.dataSource)
    {
        self.tableView.dataSource = self;
    }
    
    if (!self.tableView.superview)
    {
        [self.view addSubview:self.tableView];
    }
    
    if (CGRectEqualToRect(CGRectZero,
                          self.tableView.frame))
    {
        self.tableView.frame = self.view.bounds;
    }
    
    self.refreshControlIsSyncronous = YES;
    self.clearsSelectionOnViewDidAppear = YES;
    
    if (!self.dataDelegate.webNavigationBlock)
    {
        MAKE_WEAK(self);
        self.dataDelegate.webNavigationBlock = ^(NSURL* url, NSDictionary* item)
        {
            MAKE_STRONG(self);
            WDPRWebViewController *vc = [WDPRWebViewController alloc];
            NSString *title = item[WDPRCellWebViewTitle] ?: item[WDPRCellTitle];
            
            if ([title isKindOfClass:NSAttributedString.class])
            {
                title = ((NSAttributedString*)title).string;
            }
            
            if (url.host &&
                !url.isFileURL &&
                !url.isFileReferenceURL)
            {
                vc = [vc initWithURL:url title:title];
                // MDX did the following:
                // vc.viewTrackingName = trackingName;
                // if (url) {
                //      vc.viewTrackingContext = @{@"URL" : [url description]};
                // }
            }
            else if ([url.scheme hasPrefix:@"tel"])
            {
                vc = nil; // nothing to push onto navStack
                
                NSURL* phoneCall = 
                [NSURL URLWithString:
                 [url.absoluteString stringByReplacingOccurrencesOfString:@"tel:" 
                                                               withString:@"telprompt:"]];
                 
                if ([UIApplication.sharedApplication canOpenURL:phoneCall])
                {
                    [UIApplication.sharedApplication openURL:phoneCall];
                }
                else
                {
                    [UIAlertView 
                     showAlertWithTitle:WDPRLocalizedStringInBundle(@"com.wdprcore.alertview.phonecallerror.title", WDPRCoreResourceBundleName, nil)
                     message:WDPRLocalizedStringInBundle(@"com.wdprcore.alertview.phonecallerror.message", WDPRCoreResourceBundleName, nil)];
                }
            }
            else
            {
                vc = [vc initWithBundleResource:url.absoluteString title:title];
                //vc.viewTrackingName = trackingName;
            }
            
            vc.allowZoom = [item[WDPRCellAllowZoom] boolValue];
            vc.webControlsEnabled = [item[WDPRCellEnableWebControls] boolValue];
            vc.navigationBarEnabled = ![item[WDPRCellHideNavigationBar] boolValue];
            
            [strongself presentModally:vc];
        };
    }
}

- (UITableView*)tableView
{
    if (!_tableView)
    {
        _tableView = tableViewWithStyle(UITableViewStylePlain);
    }
    
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupRuleUnderHeader];
    
    if (!self.navigationController ||
        self.extendedLayoutIncludesOpaqueBars)
    {
        UIEdgeInsets contentInset = self.contentInset;
        
        contentInset.top += (UIApplication.
                             sharedApplication.
                             statusBarFrame.size.height);
        
        contentInset.top += (self.navigationController.
                             navigationBar.frame.size.height);
        
        self.contentInset = contentInset;
    }
    
    [self.dataDelegate customizeTable:self.tableView];
    
    if ([self respondsToSelector:@selector(didSelectRefresh)]) 
    {
        [self.tableView addSubview:
         self.refreshControl = [UIRefreshControl new]];
        
        /*
        [self.refreshControl setAttributedTitle:
         [[NSAttributedString alloc] initWithString:@" "]];//*/
        
        [self.refreshControl addTarget:self
                                action:@selector(beginRefresh)
                      forControlEvents:UIControlEventValueChanged];
    }

    executeOnNextRunLoop
    (^{ // ensure checkmarkedItem is visible
        if (self.dataDelegate.checkmarkedItem)
        {
            [self.tableView scrollToRowAtIndexPath:self.dataDelegate.checkmarkedItem 
                                  atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
    });
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.removeActivityIndicatorBlock)
    {
        self.removeActivityIndicatorBlock();
        self.removeActivityIndicatorBlock = nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView flashScrollIndicators];
    
    if (self.removeActivityIndicatorBlock)
    {
        self.removeActivityIndicatorBlock();
        self.removeActivityIndicatorBlock = nil;
    }

    if (self.clearsSelectionOnViewDidAppear)
    {
        if (self.tableView.indexPathForSelectedRow)
        {
            [self.tableView deselectRowAtIndexPath:
             self.tableView.indexPathForSelectedRow animated:YES];
        }
        else for (NSIndexPath* selectedItem in
                  self.tableView.indexPathsForSelectedRows)
        {
            [self.tableView deselectRowAtIndexPath:selectedItem animated:YES];
        }
    }
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];

    self.dataDelegate.focusedIndexPath = nil; // this may dismiss keyboard, unsubscribe after
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//- (void)dealloc
//{
//    // For some reason, the embedded tableview's delegate reference does not get set to nil,
//    // when this VC is dealloc'd, which results in the app crashing due to attempting to
//    // reference a dealloc'd object.
//    
//    // The crash usually, but not always, rears it's head, after completing a flow, such as
//    // Fastpass, and then immediately selecting the same flow in the root menu.
//    
//    // Explicity setting the delegate reference to nil is more of an interim solution. A more
//    // permanent solution involves discovering why the embeddeed table view is left hanging,
//    // and does not get cleaned up, during deallocation of it's parent view controller.
//    self.tableView.delegate = nil;
//    self.tableView.dataSource = nil;
//}

+ (instancetype)formWithInputData:(id)inputData
                      actionTitle:(NSString *)title
                       completion:(void (^)(id outputData))completion
{
    return [self formWithInputData:inputData
                       actionTitle:title
                        completion:completion
               dataCollectionBlock:nil];
}

+ (instancetype)formWithInputData:(id)inputData
                      actionTitle:(NSString *)title
                       completion:(void (^)(id outputData))completion
              dataCollectionBlock:(void (^)(id item, id data))dataCollectionBlock
{
    WDPRTableController *formScreen = [[self alloc]
                                      initWithStyle:UITableViewStyleGrouped];
    
    formScreen.dataDelegate.accessoryType = UITableViewCellAccessoryNone;
    formScreen.dataDelegate.cellStyle = WDPRTableCellStyleFloatLabelField;
    
    MAKE_WEAK(formScreen);
    UIButton* callToAction =
    [formScreen addCallToAction:title block:
     ^{
         MAKE_STRONG(formScreen);
         strongformScreen.dataDelegate.focusedIndexPath = nil;
         
         if ([strongformScreen.dataDelegate validateDataEntry])
         {
             onExitFromScope
             (^{
                 if (completion)
                 {
                     completion(inputData);
                 }
             });
             
             if (inputData)
             {
                 [strongformScreen.dataDelegate enumerateObjectsUsingBlock:
                  ^(WDPRTableViewItem *item, NSIndexPath *indexPath, BOOL *stop)
                  {
                      Require(item, WDPRTableViewItem);
                      
                      if (dataCollectionBlock)
                      {
                          dataCollectionBlock(item, inputData);
                      }
                      else if (item[WDPRCellRowID])
                      {
                          inputData[item[WDPRCellRowID]] = item[WDPRCellDetail];
                      }
                      
                  }];
             }
             
         }
     }];
    formScreen.callToActionButton = callToAction;
    
    executeOnNextRunLoop
    (^{// defer this in until later so client can finish setup first
        [formScreen debugDeallocation:formScreen.navigationItem.title];
        callToAction.enabled = formScreen.dataDelegate.allItemsAreValid;
    });
    
    MAKE_WEAK(callToAction);
    void (^enableCallToAction)(WDPRTableDataDelegate *) = ^(WDPRTableDataDelegate *dataDelegate)
    {
        executeOnNextRunLoop
        (^{
            MAKE_STRONG(callToAction);
            strongcallToAction.enabled = dataDelegate.allItemsAreValid;
        });
    };
    
    [formScreen.dataDelegate // dynamically enable/disable the callToAction
     addObserver:formScreen
     keyPath:@"focusedIndexPath"
     block:^(WDPRTableDataDelegate * dataDelegate, NSString *keyPath, NSDictionary *change)
     {
         if ([change[NSKeyValueChangeOldKey] isKindOfClass:NSIndexPath.class])
         {
             enableCallToAction(dataDelegate);
         }
     }];
    
    [formScreen.dataDelegate
     addObserver:formScreen
     keyPath:@"invalidItems"
     block:^(WDPRTableDataDelegate * dataDelegate, NSString *keyPath, NSDictionary *change)
     {
         enableCallToAction(dataDelegate);
     }];
    
    return formScreen;
}

#pragma mark - Properties

PassthroughGetter(UIEdgeInsets, contentInset, self.tableView)

- (UIView*)alternateView
{
    return self.tableView;
}

- (WDPRTableDataDelegate *)dataDelegate
{
    if (!_dataDelegate)
    {
        if ([self respondsToSelector:@selector(pList)])
        {
            _dataDelegate = [[WDPRTableDataDelegate alloc]
                             initWithPlist:self.pList];
        }
        else 
        {
            _dataDelegate = [WDPRTableDataDelegate new];
            
            if ([self respondsToSelector:@selector(initialData)])
            {
                _dataDelegate.items = self.initialData;
            }
            
            if ([self respondsToSelector:@selector(sectionHeaders)])
            {
                _dataDelegate.headers = self.sectionHeaders;
            }
            
            if ([self respondsToSelector:@selector(sectionFooters)])
            {
                _dataDelegate.footers = self.sectionFooters;
            }
        }
    }
    
    return _dataDelegate;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [self.tableView setContentOffset:
     CGPointMake(0, -contentInset.top)];
    
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

- (void)setDataDelegate:(WDPRTableDataDelegate *)dataDelegate
{
    if (_dataDelegate != dataDelegate)
    {
        _dataDelegate = dataDelegate;
        
        if (self.isViewLoaded)
        {
            [_dataDelegate customizeTable:self.tableView];
            [self.tableView reloadData];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

+ (BOOL)isAutoHideModalDismissButtonUponScrollEnabled
{
    return autoHideModalDismissButtonUponScroll;
}

+ (void)setAutoHideModalDismissButtonUponScrollEnabled:(BOOL)enabled
{
    autoHideModalDismissButtonUponScroll = enabled;
}

#pragma mark -

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.dataDelegate respondsToSelector:anInvocation.selector])
    {
        [anInvocation invokeWithTarget:self.dataDelegate];
    }
    else [super forwardInvocation:anInvocation];
}

- (CGFloat)idealContentHeight
{
    return self.tableView.idealContentHeight;
}

- (UIButton*)addCallToAction:(NSString*)title 
                       block:(PlainBlock)block
{
    UIButton* button = [super addCallToAction:title 
                                        block:block];
    
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.bottom += button.frame.size.height;
    
    self.contentInset = contentInset;
    
    return button;
}

#pragma mark - Refresh Support
- (void)beginRefresh 
{
    if (!NSThread.isMainThread)
    {
        executeInBackground
        (^{
            [self beginRefresh];
        });
    }
    else
    {
        if ([self respondsToSelector:@selector(didSelectRefresh)]) 
        {
            [self performSelector:@selector(didSelectRefresh) withObject:self];
        }
        
        if (self.refreshControlIsSyncronous) 
        {
            [self endRefresh];
        }
    }
}

/*
 * Example implementation.  This is an SYNC call.
- (void)didSelectRefresh {
    NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 2.0];
    [NSThread sleepUntilDate:future];
}
*/

- (void)endRefresh 
{
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self endRefresh];
        });
    }
    else if (self.refreshControl.isRefreshing)
    {
        [self blockPullDownRefresh];
        
        [self.refreshControl endRefreshing];
        
        // SLING-3120, dunno why this is even a problem...
        [self.tableView setContentOffset:
         CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
        
        [self.refreshControl setAttributedTitle:
         [[NSAttributedString alloc] initWithString:
          [NSString stringWithFormat:@"Last Updated: %@", 
           [NSDateFormatter localizedStringFromDate:[NSDate date] 
                                          dateStyle:NSDateFormatterShortStyle 
                                          timeStyle:NSDateFormatterShortStyle]]]];
        
        [self.tableView reloadData];
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Reloading

- (void)reloadItems
{
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self reloadItems];
        });
    }
    else
    {
        self.dataDelegate.items = self.initialData;
        [self.tableView reloadData];
        
        [self setPreferredContentSize:
         CGSizeMake(self.tableView.frame.size.width, 
                    self.tableView.idealContentHeight)];
    }
}

- (void)reloadItemsAndHeaders:(BOOL)headers andFooters:(BOOL)footers
{
    if (NSThread.isMainThread)
    {
        self.dataDelegate.items = self.initialData;

        if (headers &&
            [self respondsToSelector:@selector(sectionHeaders)])
        {
            self.dataDelegate.headers = self.sectionHeaders;
        }
        
        if (footers &&
            [self respondsToSelector:@selector(sectionFooters)])
        {
            self.dataDelegate.footers = self.sectionFooters;
        }
        
        [self reloadItems];
    }
    else
    {
        executeOnMainThread
        (^{
            [self reloadItemsAndHeaders:headers andFooters:footers];
        });
    }
}

#pragma mark - Keyboard Support

- (void)keyboardWillShow:(NSNotification*)notification
{
    if (self.dataDelegate.transitioningFocus)
    {
        [self keyboardWillAnimate:notification show:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    if (self.dataDelegate.transitioningFocus)
    {
        [self keyboardWillAnimate:notification show:NO];
    }
}

- (void)keyboardWillAnimate:(NSNotification*)notification show:(BOOL)show
{
    CGSize keyboardSize = [[[notification userInfo] 
                            objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat kbHeight = MIN(keyboardSize.width, keyboardSize.height);
    if (IS_IPAD) 
    {
        if (self.presentingViewController) 
        { // if modal
            if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) 
            {
                kbHeight = 275; // Unsure how to compute these values, since modal moves with keyboard
            } 
            else 
            {
                kbHeight = 100;  // Unsure how to compute these values, since modal moves with keyboard
            }
        }
    }
    
    self.dataDelegate.keyboardHeight = kbHeight;
    // TODO:
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.topEdge, 0, show ? kbHeight : 0, 0);
//    self.tableView.contentInset = contentInsets;
//    self.tableView.scrollIndicatorInsets = contentInsets;
    
    if (self.dataDelegate.focusedIndexPath)
    {
        [self.dataDelegate updateTableInsets:show];
        // ensure focusedIndexPath is visible
        [self.tableView scrollToRowAtIndexPath:self.dataDelegate.focusedIndexPath
                              atScrollPosition:(IS_IPAD ? 
                                                UITableViewScrollPositionBottom : 
                                                UITableViewScrollPositionNone) animated:NO];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([self.dataDelegate respondsToSelector:
             @selector(numberOfSectionsInTableView:)] ?
            [self.dataDelegate numberOfSectionsInTableView:tableView] : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataDelegate tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.removeActivityIndicatorBlock ? nil : 
            [self.dataDelegate tableView:tableView willSelectRowAtIndexPath:indexPath]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Headers & Footers

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return (![self.dataDelegate respondsToSelector:
              @selector(tableView:titleForHeaderInSection:)] ? nil :
            [self.dataDelegate tableView:tableView titleForHeaderInSection:section]);
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    return (![self.dataDelegate respondsToSelector:
              @selector(tableView:titleForFooterInSection:)] ? nil :
            [self.dataDelegate tableView:tableView titleForFooterInSection:section]);
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    return (![self.dataDelegate respondsToSelector:
              @selector(tableView:viewForHeaderInSection:)] ? 0 :
            [self.dataDelegate tableView:tableView viewForHeaderInSection:section]);
}

- (UIView *)tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section
{
    return (![self.dataDelegate respondsToSelector:
              @selector(tableView:viewForFooterInSection:)] ? 0 :
            [self.dataDelegate tableView:tableView viewForFooterInSection:section]);
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return (![self.dataDelegate respondsToSelector:
              @selector(tableView:heightForHeaderInSection:)] ?
            UITableViewAutomaticDimension : [self.dataDelegate tableView:tableView
                                                heightForHeaderInSection:section]);
}

- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return (![self.dataDelegate respondsToSelector:
              @selector(tableView:heightForFooterInSection:)] ?
            UITableViewAutomaticDimension : [self.dataDelegate tableView:tableView
                                                heightForFooterInSection:section]);
}

#pragma mark - UIScrollView Delegate Protocols

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    const CGFloat kMinDraggingDistance = 10;
    
    if ((scrollView.contentOffset.y < -kRefreshDistance) && 
        !self.refreshControl.isRefreshing && !blockPullDownRefresh) 
    {
        [self blockPullDownRefresh];
        
        executeOnNextRunLoop
        (^{
            [self.refreshControl beginRefreshing];
            [self beginRefresh];
        });
    }
    
    if (autoHideModalDismissButtonUponScroll)
    {
        WDPRModalSwipeDownTransition *transition = (SAFE_CAST(self.navigationController.transitioningDelegate, WDPRModalNavigationController)).modalTransition;
        
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        
        if ( scrollView.isTracking && fabs(translation.y) >= kMinDraggingDistance )
        {
            BOOL isScrollDirectionUp = translation.y < 0;
            [transition hideDismissButton: isScrollDirectionUp animated:YES];
        }
    }
}


- (void)blockPullDownRefresh 
{
    blockPullDownRefresh = YES;
    [self performSelector:@selector(unblockPullDownRefresh) withObject:nil afterDelay:0.5f];
}

- (void)unblockPullDownRefresh 
{
    blockPullDownRefresh = NO;
}

@end
