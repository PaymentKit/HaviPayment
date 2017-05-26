//
//  WDPRUserDefaults.h
//  Pods
//
//  Created by Hart, Nick on 8/3/15.
//
//

#import "WDPRUserSettings.h"

/**
 This class is used to replace NSUserDefaults and control whether user settings are saved to disk or in-memory.
 It is currently only used by the DLP app, because of EU legal requirements about caching user data.
 */
@interface WDPRUserDefaults : NSObject<WDPRUserSettingsProtocol>

/**
 Add keys to allow in the permanent store via a plist.  Any key found in this plist will be allowed in the permanent
 store.  Any key not in it will be use the in-memory store, unless contained in the "no store" keys.
 @param plist the name of the plist to read.
 */
- (void)addPermanentStoreKeysFromPlist:(NSString *)plist;

@end
