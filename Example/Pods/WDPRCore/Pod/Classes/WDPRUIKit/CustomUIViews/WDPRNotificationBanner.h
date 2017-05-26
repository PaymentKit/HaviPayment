//
//  WDPRNotificationBanner.h
//
//  Widget used to show notification banner.
//  When showing a banner, if a banner is already present on the screen,
//  The next banner will only be shown only if it has a higher priority.
//  Otherwise, the banner will be suppressed. Lower priority banners can only be shown
//  if the higher priority banner is dismissed by the user.
//
//  Notification banner types: (priority order lowest to highest)
//  Promotional: notification on a UIColor.wdprMossGreenColor background with a close button.
//  Positive: notification on a UIColor.wdprBlueColor background with a close button.
//  Validation Error: notification on a UIColor.wdprDarkBlueColor background with a close button.
//  Network Error: notification on a UIColor.wdprDarkBlueColor background with a close button.
//  Service Error (nontransactional): notification on a UIColor.wdprDarkBlueColor background with close button.
//  Service Error Retry (nontransactional): notification on a UIColor.wdprDarkBlueColor background with retry and close buttons.
//  Transactional Error: notification on a UIColor.wdprRedColor background with a close button.
//
//  Created by Nguyen, Kevin on 7/15/16.
//

#import <UIKit/UIKit.h>
#import "WDPRUIKit.h"

@class WDPRNotificationBanner;

#pragma mark - WDPRNotificationBannerDelegate

/**
 * Use these delegate methods to be notified of the different stages of the notification banner show/dismiss actions.
 */
@protocol WDPRNotificationBannerDelegate <NSObject>

@optional

- (void)didShowNotificationBanner:(nullable WDPRNotificationBanner *)notificationBanner;  // after animation
- (void)willCloseNotificationBanner:(nullable WDPRNotificationBanner *)notificationBanner;  // before animation and closing view
- (void)didCloseNotificationBanner:(nullable WDPRNotificationBanner *)notificationBanner;  // after animation

@end

#pragma mark - Constants

/**
 * Notification constant for analytics.
 */
extern NSString * __nonnull const WDPRNotificationBannerDidShowNotification;

/**
 * Constants for the different types of notification banners in priority order (lowest to highest).
 */
typedef NS_ENUM(NSUInteger, WDPRNotificationBannerType)
{
    WDPRNotificationBannerTypePromotional,
    WDPRNotificationBannerTypePositive,
    WDPRNotificationBannerTypeValidationError,
    WDPRNotificationBannerTypeNetworkError,
    WDPRNotificationBannerTypeServiceError,
    WDPRNotificationBannerTypeServiceErrorRetry,
    WDPRNotificationBannerTypeTransactionalError,
};

/**
 * Constants for the banner show action result.
 */
typedef NS_ENUM(NSUInteger, WDPRNotificationBannerShowResult)
{
    WDPRNotificationBannerShowResultDisplayed,
    WDPRNotificationBannerShowResultQueued,
    WDPRNotificationBannerShowResultSuppressed
};

/**
 * Typedef retry block for when the user selects the retry button.
 */
typedef void (^WDPRNotificationBannerRetryBlock) ( WDPRNotificationBanner * _Nullable notificationBanner);

@interface WDPRNotificationBanner : UIView <UITextViewDelegate>

#pragma mark - Properties

/**
 * Delegate for the WDPRNotificationBannerDelegate protocol.
 */
@property (weak, nonatomic) id<WDPRNotificationBannerDelegate> _Nullable delegate;

/**
 * Read only property for the unique ID of the banner.
 */
@property (readonly, nonatomic) NSString * _Nonnull bannerId;

/**
 * Read only property for the type of the banner.
 */
@property (readonly, nonatomic) WDPRNotificationBannerType type;

/**
 * Property for specifying which part of the banner message is a phone number for formatting purposes.
 */
@property (strong, nonatomic) NSString * _Nullable phoneNumber;

/**
 * Property for the block that needs to be executed when the user selects the retry button.
 */
@property (copy, nonatomic) WDPRNotificationBannerRetryBlock _Nullable retryBlock;

/** The last focused element prior to displaying the banner. Upon dismissal, focus will be returned to this element.
 @note the element is of type UIView, subclass there of, or UIAccessibilityElement*/
@property (weak, nonatomic, nullable) id <UIAccessibilityIdentification> onDismissFocusElement;

#pragma mark - Convenience initialization methoes

/**
 * Create a promotional banner (UIColor.wdprMossGreenColor background).
 * Example message: "Free shipping on all products for a limited period!"
 *
 * @param title The title of the banner.
 * @param message The message of the banner.
 * @return The initialized banner object.
 */
+ (_Nonnull instancetype)promotionalBannerWithTitle:(nullable NSString *)title
                                            message:(nullable NSString *)message;

/**
 * Create a positive banner (UIColor.wdprBlueColor background).
 * Example message: "Your account settings have been updated!"
 *
 * @param title The title of the banner.
 * @param message The message of the banner.
 * @return The initialized banner object.
 */
+ (_Nonnull instancetype)positiveBannerWithTitle:(nullable NSString *)title
                                         message:(nullable NSString *)message;

/**
 * Create a validation banner (UIColor.wdprDarkBlueColor background).
 * Example message: "The email and/or password do not match. Please try again"
 *
 * @param title The title of the banner.
 * @param message The message of the banner.
 * @return The initialized banner object.
 */
+ (_Nonnull instancetype)validationErrorBannerWithTitle:(nullable NSString *)title
                                                message:(nullable NSString *)message;

/**
 * Create a network banner (UIColor.wdprDarkBlueColor background).
 * Example message: "Weak or No Internet Connection"
 *
 * @param title The title of the banner.
 * @param message The message of the banner.
 * @return The initialized banner object.
 */
+ (_Nonnull instancetype)networkErrorBannerWithTitle:(nullable NSString *)title
                                             message:(nullable NSString *)message;

/**
 * Create a service error banner (UIColor.wdprDarkBlueColor background) using the service error object.
 * Set the phoneNumber property if there is a phone number in the banner message.
 * Set the retryBlock property if there needs to be a retry button.
 * Example title: "Something Went Wrong"
 * Example message: "There was a problem loading the requested information. Please try again later."
 * NOTE: If the error object indicates a network error, a network error will
 * be created instead.
 *
 * @param error The error returned by the service call.
 * @param title The title of the banner.
 * @param message The message of the banner.
 * @return The initialized banner object.
 */
+ (_Nonnull instancetype)serviceErrorBannerWithError:(nullable NSError *)error
                                               title:(nullable NSString *)title
                                             message:(nullable NSString *)message;

/**
 * Create a transactional error banner (UIColor.wdprRedColor background) using the service error object.
 * Set the phoneNumber property if there is a phone number in the banner message.
 * Example title: "Something Went Wrong"
 * Example message: "We're having trouble confirming your FASTPASS selection."
 * NOTE: If the error object indicates a network error, a network error will
 * be created instead.
 *
 * @param error The error returned by the service call.
 * @param title The title of the banner.
 * @param message The message of the banner.
 * @return The initialized banner object.
 */
+ (_Nonnull instancetype)transactionalErrorBannerWithError:(nullable NSError *)error
                                                     title:(nullable NSString *)title
                                                   message:(nullable NSString *)message;

#pragma mark - Show

/**
 * Method used to display the banner.
 * NOTE: Invoking this method will not always display the banner. 
 * If there is a banner already present and the invoking banner has a lower priority than the present banner, the invoking banner will be surpressed.
 * If there is a banner already present and the invoking banner has a higher priority than the present banner, the invoking banner will be queued.
 * The queued banner will be presented after the present banner is dismissed.
 * If a third banner is attempting to show before the first banner finishes dismissing and has a higher priority than the queued banner, 
 * the queued banner is suppressed and the third banner will become the queued banner instead.
 * @return A WDPRNotificationBannerShowResult indicating if the banner was displayed, queued, or suppressed.
 */
- (WDPRNotificationBannerShowResult)show;

/**
 * A static method that can be used to dismiss a banner with a given banner ID if it is present.
 * If the banner is queued (next), the banner is removed from the queue (next).
 * If the banner with the specified banner is already dismissed, this method does nothing.
 */
+ (void)dismissBannerWithBannerId:(NSString * _Nonnull)bannerId;

/**
 * A static method that can be used to dismiss a network banner if it is present.
 */
+ (void)dismissNetworkBanner;

@end
