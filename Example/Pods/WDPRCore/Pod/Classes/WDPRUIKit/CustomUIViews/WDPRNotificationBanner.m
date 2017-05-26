//
//  WDPRNotificationBanner.m
//  Pods
//
//  Created by Nguyen, Kevin on 7/15/16.
//
//

#import "WDPRNotificationBanner.h"
#import "NSBundle+WDPR.h"
#import "WDPRFoundation.h"
#import "WDPRPhoneTextView.h"
#import "UIColor+WDPR.h"
#import "UIView+WDPR.h"
#import "WDPRNotificationUserInfo+AlertView.h"
#import <WDPRCore/WDPRCore-Swift.h>

NSString * const WDPRNotificationBannerDidShowNotification = @"notificationBannerDidShowNotification";

@interface WDPRNotificationBanner()

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet WDPRPhoneTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retryButtonRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;

#pragma mark - Properties
@property (strong, nonatomic) UIAccessibilityElement *phoneAccessibilityElement;
@property (strong, nonatomic) NSLayoutConstraint *superViewBottomConstraint;
@property (readwrite, nonatomic) WDPRNotificationBannerType type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) id notificationsObserver;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) BOOL errorIsNetworkError;
@property (assign, nonatomic) BOOL phoneNumberEnable;

@end

@implementation WDPRNotificationBanner

#pragma mark - Constants

#define kDefaultNotificationFontColor   [UIColor whiteColor]
#define kDefaultNotificationTitleFont   [UIFont fontWithName:@"Avenir-Heavy" size:16.0f]
#define kDefaultNotificationMessageFont [UIFont fontWithName:@"Avenir-Book" size:16.0f]

static NSTimeInterval const kShowDismissAnimationDuration = 0.5f;
static CGFloat const kMessageLabelToCloseButtonDefaultSpacing = 60.0f;
static CGFloat const kParagraphLineSpacing = 2.0f;
static CGFloat const kRetryRightDefaultSpacing = 52.0f;
static CGFloat const kRetryRightMinimumSpacing = 8.0f;
static NSString * const kFillSuperViewConstraintHorizontal = @"|-(0)-[subview]-(0)-|";
static NSString * const kSubviewKey = @"subview";

#pragma mark - Life Cycle

- (id)initWithType:(WDPRNotificationBannerType)type
             title:(NSString *)title
           message:(NSString *)message
{
    NSBundle *bundle = [WDPRFoundation wdprCoreResourceBundle];
    self = [[bundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    
    if (self)
    {
        _bannerId = [[NSUUID UUID] UUIDString];
        _type = type;
        _title = title;
        _message = message;
        _retryButton.hidden = YES;
        self.accessibilityViewIsModal = YES;
    }
    
    return self;
}

#pragma mark - Convenience

+ (instancetype)promotionalBannerWithTitle:(NSString *)title
                                   message:(NSString *)message
{
    return [[WDPRNotificationBanner alloc] initWithType:WDPRNotificationBannerTypePromotional
                                                  title:title
                                                message:message];
}

+ (instancetype)positiveBannerWithTitle:(NSString *)title
                                message:(NSString *)message
{
    return [[WDPRNotificationBanner alloc] initWithType:WDPRNotificationBannerTypePositive
                                                  title:title
                                                message:message];
}

+ (instancetype)validationErrorBannerWithTitle:(NSString *)title
                                       message:(NSString *)message
{
    return [[WDPRNotificationBanner alloc] initWithType:WDPRNotificationBannerTypeValidationError
                                                  title:title
                                                message:message];
}

+ (instancetype)networkErrorBannerWithTitle:(NSString *)title
                                    message:(NSString *)message
{
    return [[WDPRNotificationBanner alloc] initWithType:WDPRNotificationBannerTypeNetworkError
                                                  title:title
                                                message:message];
}

+ (instancetype)serviceErrorBannerWithError:(NSError *)error
                                      title:(NSString *)title
                                    message:(NSString *)message
{
    WDPRNotificationBanner *networkErrorBanner = [self bannerForConnectionError:error];
    
    if (networkErrorBanner)
    {
        networkErrorBanner.errorIsNetworkError = YES;
        return networkErrorBanner;
    }
    
    return [[WDPRNotificationBanner alloc] initWithType:WDPRNotificationBannerTypeServiceError
                                                  title:title
                                                message:message];
}

+ (instancetype)transactionalErrorBannerWithError:(NSError *)error
                                            title:(NSString *)title
                                          message:(NSString *)message
{
    WDPRNotificationBanner *networkErrorBanner = [self bannerForConnectionError:error];
    
    if (networkErrorBanner)
    {
        networkErrorBanner.errorIsNetworkError = YES;
        return networkErrorBanner;
    }
    
    return [[WDPRNotificationBanner alloc] initWithType:WDPRNotificationBannerTypeTransactionalError
                                                  title:title
                                                message:message];
}

+ (instancetype)bannerForConnectionError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    BOOL canCheckForConnectionError = [error respondsToSelector:@selector(isConnectionError)];
    if (canCheckForConnectionError && [error performSelector:@selector(isConnectionError)])
    {
#pragma clang diagnostic pop
        NSString *message = WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewblock.message",
                                                        WDPRCoreResourceBundleName, nil);
        return [self networkErrorBannerWithTitle:nil
                                         message:message];
    }
    
    return nil;
}

#pragma mark - Property setters/getters

- (void)setRetryBlock:(WDPRNotificationBannerRetryBlock)retryBlock
{
    NSAssert(retryBlock, @"retryBlock should not be nil");
    if (self.errorIsNetworkError || !retryBlock)
    {
        return;
    }
    
    NSAssert(self.type == WDPRNotificationBannerTypeServiceError, @"retryBlock should only be used with service errors.");
    if (self.type == WDPRNotificationBannerTypeServiceError)
    {
        self.type = WDPRNotificationBannerTypeServiceErrorRetry;
        _retryBlock = retryBlock;
        self.retryButton.hidden = NO;
    }
}

#pragma mark - Setup

- (void)setup
{
    [self setupBackgroundColor];
    [self setupTextView];
    [self setupCloseAndRetryButtons];
    [self addAndPositionOnTopView];
    [self setupAccesibilityPhone];
}

- (void)setupBackgroundColor
{
    self.notificationView.backgroundColor = [self backgroundColorForNotificationBannerType:self.type];
}

- (UIColor *)backgroundColorForNotificationBannerType:(WDPRNotificationBannerType)type
{
    switch (type)
    {
        case WDPRNotificationBannerTypePromotional:
            return [UIColor wdprMossGreenColor];
            
        case WDPRNotificationBannerTypePositive:
            return [UIColor wdprBlueColor];
            
        case WDPRNotificationBannerTypeValidationError:
            return [UIColor wdprDarkBlueColor];
            
        case WDPRNotificationBannerTypeNetworkError:
            return [UIColor wdprDarkBlueColor];
            
        case WDPRNotificationBannerTypeServiceError:
            return [UIColor wdprDarkBlueColor];
            
        case WDPRNotificationBannerTypeServiceErrorRetry:
            return [UIColor wdprDarkBlueColor];
            
        case WDPRNotificationBannerTypeTransactionalError:
            return [UIColor wdprRedColor];
            
        default:
            return [UIColor wdprDarkBlueColor];
    }
}

- (void)setupCloseAndRetryButtons
{
    self.retryButtonRightConstraint.constant = self.closeButton.isHidden ? kRetryRightMinimumSpacing : kRetryRightDefaultSpacing;
    self.retryButton.accessibilityLabel = WDPRLocalizedStringInBundle(@"com.wdprcore.wdpruikit.notificationbanner.retry",
                                                                      WDPRCoreResourceBundleName,
                                                                      @"Retry");
    self.closeButton.accessibilityTraits = UIAccessibilityTraitButton;
    self.closeButton.accessibilityLabel = WDPRLocalizedStringInBundle(@"com.wdprcore.wdpruikit.notificationbanner.dismissalert",
                                                                      WDPRCoreResourceBundleName,
                                                                      @"Dismiss connectivity alert");
}

- (void)setupTextView
{
    NSAttributedString *titleAttributedString = [self titleAttributedString];
    NSAttributedString *messageAttributedString = [self messageAttributedString];
    NSMutableAttributedString *message = [NSMutableAttributedString new];
    
    if (titleAttributedString)
    {
        [message appendAttributedString:titleAttributedString];
    }
    
    if (messageAttributedString)
    {
        [message appendAttributedString:messageAttributedString];
    }
    
    [self addParagraphLineSpacingToAttributedString:message];
    
    self.textView.delegate = self;
    self.textView.attributedText = message;
    self.textView.textColor = kDefaultNotificationFontColor;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.accessibilityTraits = UIAccessibilityTraitStaticText;
    
    // if there's no retry button, expand the message label
    self.messageLabelRightConstraint.constant = (self.retryBlock == nil) ? 0 : kMessageLabelToCloseButtonDefaultSpacing;
}

- (void)setupAccesibilityPhone
{
    if (self.phoneNumber && self.phoneNumberEnable)
    {
        self.phoneAccessibilityElement = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        self.phoneAccessibilityElement.accessibilityLabel = self.phoneNumber;
        self.phoneAccessibilityElement.accessibilityTraits = UIAccessibilityTraitLink;
    }
}

- (void)addAndPositionOnTopView
{
    self.hidden = YES;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self];
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:kFillSuperViewConstraintHorizontal
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{kSubviewKey : self}]];
    
    [self layoutIfNeeded];
    CGFloat bannerHeight = self.notificationView.frame.size.height;
    
    // This centers the text view in the notification view if the notification view is at the minimum height.
    if (self.notificationView.frame.size.height == self.notificationViewHeightConstraint.constant)
    {
        [self.notificationView removeConstraint:self.textViewTopConstraint];
        [self.notificationView removeConstraint:self.textViewBottomConstraint];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:bannerHeight]];
    
    self.superViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.superview
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:-bannerHeight];
    [self.superview addConstraint:self.superViewBottomConstraint];
}

#pragma mark - Text Formatting

- (void)addParagraphLineSpacingToAttributedString:(NSMutableAttributedString *)attributedString
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:kParagraphLineSpacing];
    NSRange attributedStringRange = NSMakeRange(0, [attributedString length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:attributedStringRange];
}

- (NSAttributedString *)titleAttributedString
{
    UIFont *titleFont = kDefaultNotificationTitleFont;
    
    NSAttributedString *titleAttributedString = nil;
    
    if (self.title && ![self.title isEmpty])
    {
        titleAttributedString = [[NSAttributedString alloc] initWithString:self.title
                                                                attributes:@{NSFontAttributeName : titleFont}];
    }
    
    return titleAttributedString;
}

- (NSAttributedString *)messageAttributedString
{
    UIFont *messageFont = kDefaultNotificationMessageFont;
    UIFont *titleFont = kDefaultNotificationTitleFont;
    
    NSMutableAttributedString *messageAttributedString = nil;
    
    if (self.message && ![self.message isEmpty])
    {
        NSString *message = (!self.title || [self.title isEmpty]) ? self.message : [NSString stringWithFormat:@"\n%@", self.message];
        NSRange phoneNumberRange = [self findPhoneNumberRangeInString:message];
        
        if (phoneNumberRange.location != NSNotFound)
        {
            self.phoneNumberEnable = YES;
        }
        
        messageAttributedString = [[NSMutableAttributedString alloc] initWithString:message
                                                                         attributes:@{NSFontAttributeName : messageFont}];
        [messageAttributedString addAttribute:NSFontAttributeName value:titleFont range:phoneNumberRange];
    }
    
    return messageAttributedString;
}

/**
 * Given a message find the location of the phone number in it
 */
- (NSRange)findPhoneNumberRangeInString:(NSString *)message
{
    if (self.phoneNumber && message)
    {
        return [message rangeOfString:self.phoneNumber];
    }
    
    return NSMakeRange(0, 0);
}

/**
 * Given a phone number string, return a string containing only digits and +
 */
- (NSString *)dialablePhoneNumber:(NSString *)phoneNumber
{
    if (phoneNumber.length > 0)
    {
        NSCharacterSet *phoneChars = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
        NSArray *components = [phoneNumber componentsSeparatedByCharactersInSet:[phoneChars invertedSet]];
        return [components componentsJoinedByString:@""];
    }
    
    return @"";
}

#pragma mark - Show/Dismiss

- (WDPRNotificationBannerShowResult)show
{
    if (!self.onDismissFocusElement) {
        // last chance to query existing focus element before setting focus on self
        UIView *mainWindow = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
        self.onDismissFocusElement = [UIView focusedElementForView:mainWindow];
    }
    
    WDPRNotificationBanner *currentBanner = [WDPRNotificationBannerManager sharedInstance].currentBanner;
    
    if (currentBanner)
    {
        BOOL nextBannerWasQueued = [[WDPRNotificationBannerManager sharedInstance] queueNextBanner:self];
        BOOL canDismissBanner = nextBannerWasQueued && !currentBanner.isAnimating;
        
        if (canDismissBanner)
        {
            [currentBanner dismiss];
        }
        
        return nextBannerWasQueued ? WDPRNotificationBannerShowResultQueued : WDPRNotificationBannerShowResultSuppressed;
    }
    else
    {
        [self displayBanner];
        return WDPRNotificationBannerShowResultDisplayed;
    }
}

+ (void)dismissBannerWithBannerId:(NSString *)bannerId
{
    WDPRNotificationBannerManager *manager = [WDPRNotificationBannerManager sharedInstance];
    
    WDPRNotificationBanner *currentBanner = manager.currentBanner;
    WDPRNotificationBanner *nextBanner = manager.nextBanner;
    
    if (currentBanner && [currentBanner.bannerId isEqualToString:bannerId])
    {
        if (currentBanner.isAnimating)
        {
            manager.bannerIdToDismiss = bannerId;
        }
        else
        {
            [currentBanner dismiss];
        }
    }
    
    if (nextBanner && [nextBanner.bannerId isEqualToString:bannerId])
    {
        manager.nextBanner = nil;
    }
}

+ (void)dismissNetworkBanner
{
    WDPRNotificationBannerManager *manager = [WDPRNotificationBannerManager sharedInstance];
    
    WDPRNotificationBanner *currentBanner = manager.currentBanner;

    if (currentBanner.type == WDPRNotificationBannerTypeNetworkError)
    {
        [WDPRNotificationBanner dismissBannerWithBannerId:currentBanner.bannerId];
    }
}

#pragma mark - Internal Display/Dismiss Methods

- (void)displayBanner
{
    [WDPRNotificationBannerManager sharedInstance].currentBanner = self;
    
    [self setup];
    [self.superview layoutIfNeeded];
    self.hidden = NO;
    self.isAnimating = YES;
    self.superViewBottomConstraint.constant = 0;
    
    MAKE_WEAK(self);
    
    [UIView animateWithDuration:kShowDismissAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         MAKE_STRONG(self);
         [strongself.superview layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         MAKE_STRONG(self);
         strongself.isAnimating = NO;
         
         if (finished)
         {
             [strongself onDidShowBanner];
         }
     }];
}

- (void)dismiss
{
    self.superViewBottomConstraint.constant = -self.notificationView.frame.size.height;
    
    [self onWillDissmissBanner];
    
    MAKE_WEAK(self);
    
    [UIView animateWithDuration:kShowDismissAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         MAKE_STRONG(self);
         [strongself.superview layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         MAKE_STRONG(self);
         
         strongself.isAnimating = NO;
         
         if (finished)
         {
             [strongself onDidDismissBanner];
         }
     }];
}

#pragma mark - Show/Dismiss Delegate

- (void)onDidShowBanner
{
    WDPRNotificationUserInfo *userInfo = [WDPRNotificationUserInfo new];
    
    userInfo.title = self.title;
    userInfo.message = self.message;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WDPRNotificationBannerDidShowNotification
                                                        object:self
                                                      userInfo:[userInfo.userInfoDictionary copy]];
    
    if ([self.delegate respondsToSelector:@selector(didShowNotificationBanner:)])
    {
        [self.delegate didShowNotificationBanner:self];
    }
    
    WDPRNotificationBannerManager *manager = [WDPRNotificationBannerManager sharedInstance];
    
    WDPRNotificationBanner *currentBanner = manager.currentBanner;
    WDPRNotificationBanner *nextBanner = manager.nextBanner;
    
    BOOL currentBannerNeedsToDismiss = currentBanner.bannerId && [currentBanner.bannerId isEqualToString:manager.bannerIdToDismiss];
    
    if ((nextBanner && ![nextBanner isEqual:self]) || currentBannerNeedsToDismiss)
    {
        manager.bannerIdToDismiss = nil;
        [self dismiss];
    }
    else
    {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self);
    }

}

- (void)onWillDissmissBanner
{
    if ([self.delegate respondsToSelector:@selector(willCloseNotificationBanner:)])
    {
        [self.delegate willCloseNotificationBanner:self];
    }
}

- (void)onDidDismissBanner
{
    if ([self.delegate respondsToSelector:@selector(didCloseNotificationBanner:)])
    {
        [self.delegate didCloseNotificationBanner:self];
    }
    
    [WDPRNotificationBannerManager sharedInstance].currentBanner = nil;
    [self removeFromSuperview];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.onDismissFocusElement);
    
    WDPRNotificationBanner *nextBanner = [WDPRNotificationBannerManager sharedInstance].nextBanner;
    
    if ([nextBanner isEqual:self])
    {
        [WDPRNotificationBannerManager sharedInstance].nextBanner = nil;
    }
    else
    {
        [nextBanner displayBanner];
    }
}

#pragma mark - Actions

- (IBAction)onTapCloseButton:(id)sender
{
    [self dismiss];
}

- (IBAction)onTapRetryButton:(id)sender
{
    SAFE_CALLBACK(self.retryBlock, self);
    [self dismiss];
}

#pragma mark - Accessibility

- (CGRect)texViewFrameForPhoneNumber
{
    NSRange range = [self.textView.text rangeOfString:self.phoneNumber];
    UITextPosition *beginning = self.textView.beginningOfDocument;
    UITextPosition *start = [self.textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [self.textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self.textView textRangeFromPosition:start toPosition:end];
    
    return [self.textView firstRectForRange:textRange];
}

- (void)reloadPhoneNumberAccesibilityFrame
{
     self.phoneAccessibilityElement.accessibilityFrame = UIAccessibilityConvertFrameToScreenCoordinates([self.textView convertRect:[self texViewFrameForPhoneNumber]
                                                                                                                          fromView:self.textView.textInputView],
                                                                                                        self.textView);
}

- (NSArray *)accessibilityElements
{
    if (self.phoneAccessibilityElement)
    {
        [self reloadPhoneNumberAccesibilityFrame];
        return @[self.textView, self.phoneAccessibilityElement, self.retryButton, self.closeButton];
    }
    else
    {
        return @[self.textView, self.retryButton, self.closeButton];
    }
}

@end
