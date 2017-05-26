//
//  WDPRSharedConstants.h
//  Pods
//
//  Created by Jeremias Nuñez on 7/13/15.
//
//

#import <Foundation/Foundation.h>

@interface WDPRSharedConstants : NSObject

// Notifications
extern NSString * const WDPRSettingsChangedNotification;
extern NSString * const WDPRFinderLocationManagerDidFailGettingUserLocationNotification;
extern NSString * const WDPRFinderLocationManagerDidUpdateUserLocationNotification;

// Resources
extern NSString * const WDPRCoreFrameworkName;
extern NSString * const WDPRCoreResourceBundleName;

// Asset Names
extern NSString * const WDPRCoreCaretUpBlueImageName; // caret_up_blue
extern NSString * const WDPRCoreCaretDownBlueImageName; // caret_down_blue
extern NSString*  const WDPRCoreAlertFailureImageName;// ic_alert_gray_big

extern NSString * const WDPRCoreActivitySpinnerImageName; // activitySpinner
extern NSString * const WDPRCoreActivitySpinnerXLImageName; // activitySpinnerXL

@end
