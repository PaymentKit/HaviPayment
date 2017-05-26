//
//  WDPRCoreServiceConstants.h
//  WDPRCoreServices
//
//  Created by Clark, Daniel on 6/25/15.
//
//

#ifndef Pods_WDPRCoreServiceConstants____FILEEXTENSION___
#define Pods_WDPRCoreServiceConstants____FILEEXTENSION___

// From WDPRPublicDataService.m
#define kServiceEndPointFacilities @"facilities"
#define kServiceEndPointDiningMenu @"dining-menu"
#define kServiceEndPointActivitySchedules @"ancestor-activity-schedules"
#define kServiceEndPointAllWaitTimes @"all-wait-times"
#define kServiceEndPointWaitTimes @"wait-times"
#define kServiceEndPointCharacters @"characters"
#define kServiceEndPointCharactersSchedule @"characters-schedule"
#define kServiceEndPointAllCharacterAppearances @"all-character-appearances"
#define kServiceEndPointParkHours @"park-hours"
#define kServiceEndPointCreateAccount @"create-account"
#define kServiceEndPointSecurityPasswordSendEmail @"security-password-send-email"
#define kServiceEndPointSecurityQuestions @"security-questions"
#define kServiceEndPointSecuritySubmitAnswers @"security-submit-answers"
#define kServiceEndPointSecurityChangePassword @"security-change-password"
#define kServiceEndPointSecurityQuestionsChangePassword @"security-questions-change-password"
#define kServiceEndPointSecurityClickbackChangePassword @"security-clickback-change-password"
#define kServiceEndPointSecurityClickbackRedeem @"security-redeem-clickback"
#define kServiceEndPointTableAvailability @"table-availability"
#define kServiceEndPointEndecaSearch @"endeca-search"
#define kServiceEndPointContentSearch @"content-search"
#define kServiceEndPointFetchFacilitiesWithAvailableTimes @"facilities-available-times"
#define kServiceEndPointDirtyWordsCheck @"dirty-words-check"
#define kServiceEndPointScheduleHours @"schedule-hours"
#define kServiceEndPointFacilitySchedule @"facility-schedule"
#define kServiceKeyOAuthToken @"OAuthToken"
#define kServiceParamAttributes @"attributes"
#define kServiceParamDestinationID @"destinationID"
#define kServiceParamEntityType @"entityType"
#define kServiceParamFacilityID @"facilityID"
#define kServiceParamFields @"fields"
#define kServiceParamFilters @"filters"
#define kServiceParamQuery @"query"
#define kServiceParamThemeParkID @"themeParkID"
#define kServiceParamThemeParkType @"themeParkType"
#define kServiceEndPointBlockoutDates @"blockout-dates"
#define kServicesEndPointGuestConfiguration @"guest-configuration"
#define kServicesEndPointDiningMenu @"dining-menus"

#define kParkSuffix @"park"
#define kLandSuffix @"land"
#define kRelationAncestors @"ancestors"
#define kDestinationSuffix @"destination"
#define kRelationDescendants @"decendants"

#define kEntryKey_ID @"id"

#define kFacilityType_ThemePark @"theme-park"
#define kFacilityType_WaterPark @"water-park"

#define kEntryKey_WaitTime @"waitTime"

#define kTokenKey_ThemeParkID @"themeParkID"

#define kResultsKey_Requests @"requests"

// From WDPRPrivateDataService.m
#define kServiceEndPointAddressValidation @"address-validation"

// From "WDPRCommonDataService.m"
#define MdxAppInstanceId @"MdxAppInstanceId"
#define XConversationId @"X-Conversation-Id"
#define kServiceKeySoftLaunchHeader @"X-Disney-Internal-PoolOverride-WDPROAPI"
#define kServiceValueSoftLaunchHeader @"YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
#define kServiceKeyOneViewEnvOverride @"Oneview-Env-Override"
#define kServiceOneViewEnvOverrideHeader @"X-Disney-Internal-Oneview-Env"

#define WDPRDestinationValue @"destination"
#define WDPRDataEntityType @"entityType"

#define WDPRCoreServicesFrameworkName @"WDPRCoreServices"
#define WDPRCoreServicesResourceBundleName @"WDPRCoreServices"

#endif
