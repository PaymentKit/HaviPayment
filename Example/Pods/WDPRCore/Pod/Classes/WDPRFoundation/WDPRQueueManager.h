//
//  WDPRQueueManager.h
//  WDPR
//
//  Created by Garvin, Cody X. -ND on 9/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

////
// Interface
@interface WDPRQueueManager : NSObject

// Class Methods
+ (WDPRQueueManager *)sharedManager;

// Instance Methods

/// (re)registrItem with retry delay
- (void)retryItem:(WDPRQueueItem *)item;

/// clear internal retry counter
- (void)resetRetries:(WDPRQueueItem *)item;

/// Add item to queue with default delay
- (void)registerItem:(WDPRQueueItem *)item;

/// add item to queue with arbitrary delay
- (void)registerItem:(WDPRQueueItem *)item
           withDelay:(NSTimeInterval)delay;

/// (re)registerItem with zero (initial) delay
- (void)registerItemAndFire:(WDPRQueueItem *)item;

/// returns specified queueItem (if exists), or nil
- (WDPRQueueItem*)queueItemWithID:(NSString*)uniqueID;

/// Checks to see if a specific item type exists
- (BOOL)hasQueueItemWithID:(NSString*)uniqueID;

/// Remove a specific item from the queue
- (void)removeItem:(WDPRQueueItem*)item;

/// Remove an item from the queue based on the type
- (void)removeItemWithID:(NSString*)uniqueID;

/// reschedule item based on fireDelay
- (void)rescheduleItemWithID:(NSString*)uniqueID;

/// Replace an items attributes based on uniqueID
- (void)replaceItemWithID:(NSString*)uniqueID withItem:(WDPRQueueItem *)item;

@end
