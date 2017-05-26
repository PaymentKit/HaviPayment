//
//  WDPRFoundation.h
//  WDPR
//
//  Created by Wright, Byron on 6/12/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#ifndef WDPR_FOUNDATION
#define WDPR_FOUNDATION
#endif

#import <Foundation/Foundation.h>

//! Project version number for WDPRFoundation.
FOUNDATION_EXPORT double WDPRFoundationVersionNumber;

//! Project version string for WDPRFoundation.
FOUNDATION_EXPORT const unsigned char WDPRFoundationVersionString[];

// utilities
#import "WDPRLog.h"
#import "WDPRUtil.h"
#import "WDPRMacros.h"
#import "WDPRSharedConstants.h"

// custom classes
#import "WDPRQueueItem.h"
#import "WDPRQueueManager.h"
#import "WDPRPriorityQueue.h"
#import "WDPRModelTransform.h"
#import "WDPREnum.h"

// class extensions
#import "NSArray+Blocks.h"
#import "NSArray+WDPR.h"
#import "NSAttributedString+WDPR.h"
#import "NSCache+WDPR.h"
#import "NSDate+WDPR.h"
#import "NSDateFormatter+WDPR.h"
#import "NSTimeZone+WDPR.h"
#import "NSDictionary+WDPR.h"
#import "NSObject+WDPR.h"
#import "NSObject+WDPRObserved.h"
#import "NSOperationQueue+WDPR.h"
#import "NSPredicate+WDPR.h"
#import "NSRegularExpression+WDPR.h"
#import "NSString+WDPR.h"
#import "NSURL+WDPR.h"
#import "NSBundle+WDPR.h"

// localization support
#import "WDPRLocalization.h"

@interface WDPRFoundation : NSObject

+ (NSBundle *) wdprCoreResourceBundle;

@end