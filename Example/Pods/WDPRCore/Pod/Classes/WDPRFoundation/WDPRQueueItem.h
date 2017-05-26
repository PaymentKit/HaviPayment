//
//  WDPRQueueItem.h
//  WDPR
//
//  Created by Garvin, Cody X. -ND on 9/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WDPRQueuePriority)
{
    WDPRQueuePriorityLow     = 0,
    WDPRQueuePriorityMedium  = 1,
    WDPRQueuePriorityHigh    = 2
};

typedef BOOL (^WDPRIsValidBlock)(void);
typedef void (^WDPRFireBlock)(void);
typedef void (^WDPRPostFlightBlock)(void);

////
// Interface

@protocol WDPRQueueItem <NSObject>

- (BOOL)isValid;
- (void)fireNow;
- (void)postProcess;

@end


@interface WDPRQueueItem : NSObject<WDPRQueueItem>

/// @name Instance Methods
- (id)initWithDelay:(NSTimeInterval)delay 
           uniqueID:(NSString*)identifier;

- (id)initWithDelay:(NSTimeInterval)delay 
           uniqueID:(NSString*)identifier
           priority:(WDPRQueuePriority)priority;

/// @name Properties
@property (nonatomic) BOOL repeats; // default is NO

@property (nonatomic, readonly) NSString*           uniqueID;
@property (nonatomic, readonly) NSTimeInterval      fireDelay;
@property (nonatomic, readonly) WDPRQueuePriority priority;

@end // @interface WDPRQueueItem


@interface WDPRQueueItemWithBlocks : WDPRQueueItem

@property (atomic, readwrite, copy)   WDPRIsValidBlock       isValidBlock;
@property (atomic, readwrite, copy)   WDPRFireBlock          fireBlock;
@property (atomic, readwrite, copy)   WDPRPostFlightBlock    postFlightBlock;

@end // @interface WDPRQueueItemWithBlocks
