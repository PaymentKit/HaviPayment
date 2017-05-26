//
//  WDPRViewController.m
//  DLR
//
//  Created by Delafuente, Rob on 3/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import "WDPRFoundation.h"
#import "WDPRFontSizing.h"
#import <WDPRCore/WDPRCore-Swift.h>
#import "WDPRPhoneTextView.h"

static CGFloat const WDPRHeaderDefaultFontSize = 20.0f;
static CGFloat const WDPRAccessibilityDelay = 1.0f;

@interface WDPRViewController () <WDPRNotificationBannerDelegate>

@property (nonatomic) NSDate* mdxStyleAnalyticsStartTime;
@property (nonatomic) BOOL screenNameIsBeingRead;
@property (nonatomic) BOOL justClosedBanner;

@end

@implementation WDPRViewController

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.mdxStyleAnalyticsStartTime = NSDate.date;
        self.screenNameIsBeingRead = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.mdxStyleAnalyticsStartTime = NSDate.date;
    }
    
    return self;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupRuleUnderHeader];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.mdxStyleAnalyticsStartTime)
    {
        self.mdxStyleAnalyticsStartTime = NSDate.date;
    }
    
    self.justClosedBanner = NO;
    [self handleAccessibility];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self fireMdxStyleAnalytics:
     [NSDate.date timeIntervalSinceDate:
      self.mdxStyleAnalyticsStartTime]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.mdxStyleAnalyticsStartTime = nil;
    
    if (!IS_VERSION_10_OR_LATER) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIAccessibilityVoiceOverStatusChanged object:nil];
    }
}

#pragma mark -

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Title

- (void)setTitle:(NSString *)title
{
    self.titleLabel = title;
    self.navigationItem.title = title;
}

- (void)setTitleLabel:(NSString*)title
{
    UILabel* titleLabel = ((UILabel*)self.
                           navigationItem.titleView);
    
    if (![titleLabel isKindOfClass:UILabel.class])
    {
        titleLabel = [UILabel new];
        
        [titleLabel setAttributedText:
         [NSAttributedString
          string:titleLabel.text ?:@"" attributes:
          @{ NSKernAttributeName : NSNull.null }]];
        
        titleLabel.numberOfLines = 2;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        WDPRFontSizing *wdprFontSizing = [[WDPRFontSizing alloc] initWithDefaultFontSize:WDPRHeaderDefaultFontSize
                                                                              forElement:WDPRHeaders];
        
        [titleLabel setFont:[[UIFont wdprFontStyleH2] fontWithSize:[wdprFontSizing preferredFontSize]]];
        titleLabel.textColor = UIColor.wdprDarkBlueColor;
        titleLabel.backgroundColor = UIColor.clearColor;
    }
    
    titleLabel.text = title;
    titleLabel.isAccessibilityElement = YES;
    titleLabel.accessibilityTraits = UIAccessibilityTraitHeader;
    titleLabel.accessibilityLabel = title;

    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

- (void)handleAccessibility
{
    if (!IS_VERSION_10_OR_LATER) {
        // This will avoid some accessibility delay issues in iOS 9
        self.screenNameIsBeingRead = NO;
        [self setupAccessibility:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupAccessibility:)
                                                     name:UIAccessibilityVoiceOverStatusChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAccessibility)
                                                     name:UIAccessibilityAnnouncementDidFinishNotification
                                                   object:nil];
    } else if (self.screenNameToAnnounce != nil) {
        // This will read the screen title ONCE (before reading pull to dismiss)
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.screenNameToAnnounce);
    }
}

- (void)setupAccessibility:(NSNotification*) notification
{
    if (!UIAccessibilityIsVoiceOverRunning())
    {
        return;
    }
    
    if (self.screenNameToAnnounce != nil
        && (![self visibleBanner] || self.justClosedBanner))
    {
        if (!self.screenNameIsBeingRead)
        {
            self.navigationController.view.accessibilityElementsHidden = YES;
            self.screenNameIsBeingRead = YES;
            if(notification != nil || !IS_VERSION_10_OR_LATER)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WDPRAccessibilityDelay * NSEC_PER_SEC)),
                               dispatch_get_main_queue(),
                               ^{
                                   UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                                                   self.screenNameToAnnounce);
                               });
            }
            else
            {
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                                self.screenNameToAnnounce);
            }
        }
    }
    else
    {
        [self resetAccessibility];
    }
}

- (void)resetAccessibility
{
    UINavigationController *navController = self.navigationController;
    navController.view.accessibilityElementsHidden = NO;
    if ([navController isKindOfClass:[WDPRModalNavigationController class]])
    {
        UIButton *dismissButton = ((WDPRModalNavigationController *)navController).modalTransition.dismissButton;
        dismissButton.isAccessibilityElement = YES;
        dismissButton.accessibilityElementsHidden = NO;
        WDPRNotificationBanner *banner = [self visibleBanner];
        if (!banner)
        {
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, dismissButton);
        }
        else if (self.screenNameIsBeingRead)
        {
            for (UIView *subView in ((UIView*)banner.subviews[0]).subviews)
            {
                if ([subView isKindOfClass:[WDPRPhoneTextView class]])
                {
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                                    ((WDPRPhoneTextView *)subView).text);
                    break;
                }
            }
        }
    }
    else if (self.justClosedBanner && self.navigationItem.leftBarButtonItem != nil)
    {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationItem.leftBarButtonItem);
    }
    else
    {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, navController.view);
    }
    self.screenNameIsBeingRead = NO;
    
}

- (WDPRNotificationBanner *)visibleBanner
{
    for (UIView *subview in [UIApplication sharedApplication].keyWindow.subviews)
    {
        if ([subview isA:[WDPRNotificationBanner class]])
        {
            ((WDPRNotificationBanner *)subview).delegate = self;
            return (WDPRNotificationBanner *)subview;
            break;
        }
    }
    return nil;
}

#pragma mark WDPRNotificationBannerDelegate

- (void)didCloseNotificationBanner:(WDPRNotificationBanner *)notificationBanner
{
    self.justClosedBanner = YES;
    [self setupAccessibility:nil];
}

#pragma mark - MdxStyleAnalytics

- (void)fireMdxStyleAnalytics:(NSTimeInterval)loadTime
{
    // overridden by category extension as needed
}

- (NSString*)viewTrackingName
{
    return nil; // overridden by subclasses as needed
}

- (NSDictionary*)viewTrackingContext
{
    return nil; // overridden by subclasses as needed
}

@end
