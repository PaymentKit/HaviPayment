//
//  WDPRPriorityQueue.h
//  WDPR
//
//  Created by Garvin, Cody on 9/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDPRPriorityQueue : NSObject

/** @name The number of objects in the queue */
@property (readonly) NSUInteger count;

/**
 * Create the priority queue with a NSComparator.
 * @param comparator  An NSComaparator, t MUST be friendly with all objects that are added to the Queue, run-time selectors should not be used.
 */
- (id)initWithComparator:(NSComparator)comparator;

/**
 * Calls test to determine if such an item exists 
 */
- (BOOL)hasQueueItem:(BOOL (^)(id obj))test;

/**
 * Calls test to find a particular item 
 */
- (id)queueItemMeetingTest:(BOOL (^)(id obj))test;

/** 
 * Adds the item passed into the queue. A sort is automatically executed as part
 * of the modification.
 * @param object can be any object that adheres to the comparator the queue was created with.
 */
- (void)addObject:(id)object;

/**
 * Returns the first object in the queue (assumed to have been sorted already).
 * @return can be any type of object in the queue, but preferred to be WDPRQueueItem.
 */
- (id)firstObject;

/**
 * Removes the first item for which test returns YES.
 */
- (id)removeObject:(BOOL (^)(id obj))test;

@end
