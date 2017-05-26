//
//  WDPRQueueManager.m
//  WDPR
//
//  Created by Garvin, Cody X. -ND on 9/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

////
// Private Interface

enum
{   // integer consts
    kMaxRetryCount = 3
};

@interface WDPRQueueManager ()

// Private Properties
@property (nonatomic) NSTimer *queueTimer;
@property (nonatomic) WDPRPriorityQueue *priorityQueue;
@property (nonatomic) NSOperationQueue *operationQueue;

@end

#define kFireTime   @"fireTime"
#define kTryCount   @"attempts"
#define kQueueItem  @"queueItem"

////
// Implementation
@implementation WDPRQueueManager

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization Methods

- (void)dealloc
{
    [self.queueTimer invalidate];
}

+ (WDPRQueueManager *)sharedManager
{
    // Start a single instance for singleton
    static WDPRQueueManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager)
            manager = [[self alloc] init];
    });
    
    return manager;
}

- (WDPRPriorityQueue*)priorityQueue
{
    if (!_priorityQueue)
    {
        _priorityQueue =
        [[WDPRPriorityQueue alloc] initWithComparator:
         ^NSComparisonResult(NSDictionary *item1, NSDictionary *item2)
         {
             WDPRQueueItem* queueItem1 = item1[kQueueItem];
             WDPRQueueItem* queueItem2 = item2[kQueueItem];
             
             // compare: returns NSComparisonResult, as do we here
             // but when the dates are the same (NSOrderedSame, which is zero)
             // we want to disambiguate with the priorities of each item
             return ([item1[kFireTime] compare:item2[kFireTime]] ?: 
                     [@(queueItem1.priority) compare:@(queueItem2.priority)]);
         }];
    }
    
    return _priorityQueue;
}

- (NSOperationQueue*)operationQueue
{
    if (!_operationQueue)
    {
        _operationQueue = [NSOperationQueue new];
    }
    
    return _operationQueue;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

- (void)retryItem:(WDPRQueueItem *)item
{
    @synchronized(item)
    {
        NSDictionary* itemWrapper =
        [self.priorityQueue
         queueItemMeetingTest:
         ^BOOL(NSDictionary* itemWrapper)
         {
             return (item == itemWrapper[kQueueItem]);
         }];
        
        NSUInteger attemptCounter =
        [itemWrapper[kTryCount] intValue];
        
        // reschedule w/short delay, but
        // only for kMaxRetryCount attempts
        if (attemptCounter >= kMaxRetryCount)
        {
            [self registerItem:item];
        }
        else [self registerItem:item withDelay:15
                       tryCount:(attemptCounter+1)];
    }
}

- (void)resetRetries:(WDPRQueueItem *)item
{
    @synchronized(item)
    {
        NSDictionary* itemWrapper = 
        [self.priorityQueue 
         queueItemMeetingTest:
         ^BOOL(NSDictionary* itemWrapper) 
         {
             return (item == itemWrapper[kQueueItem]);
         }];
        
        if ([itemWrapper[kTryCount] intValue])
        {
            [self registerItem:item];
        }
    }
}

- (void)registerItem:(WDPRQueueItem *)item
{
    [self registerItem:item 
             withDelay:item.fireDelay];
}

- (void)registerItemAndFire:(WDPRQueueItem *)item
{
    [self registerItem:item withDelay:0];
}

- (void)rescheduleItemWithID:(NSString*)uniqueID
{
    NSDictionary* itemWrapper = 
    [self.priorityQueue 
     queueItemMeetingTest:
     ^BOOL(NSDictionary* itemWrapper) 
     {
         WDPRQueueItem* queueItem = itemWrapper[kQueueItem];
         return [uniqueID isEqualToString:queueItem.uniqueID];
     }];
    
    [self registerItem:itemWrapper[kQueueItem]];
}

- (void)registerItem:(WDPRQueueItem *)item
           withDelay:(NSTimeInterval)delay
{
    [self registerItem:item 
             withDelay:delay tryCount:0];
}

- (void)registerItem:(WDPRQueueItem *)item
           withDelay:(NSTimeInterval)delay
            tryCount:(NSUInteger)attemptCount
{
    if (!item) return;
    NSAssert(delay >= 0, @"invalid");
    
    [self removeItemWithID:item.uniqueID];
    
    // Add the item to the priority queue
    NSDictionary* itemWrapper =
    @{
      kQueueItem : item,
      kFireTime : [NSDate.date
                   dateByAddingTimeInterval:delay]
      };
    
    if (attemptCount)
    {
        itemWrapper = itemWrapper.mutableCopy;
        itemWrapper[kTryCount] = @(attemptCount);
    }
    
    [self.priorityQueue addObject:itemWrapper.copy];
    
    // If the new item is now first, invalidate the 
    // timer and let it be set up by the setup and start
    if (item == self.priorityQueue.firstObject[kQueueItem])
    {
        [self setupAndStartTimer];
    }
}

- (WDPRQueueItem*)queueItemWithID:(NSString*)uniqueID
{
    @synchronized(self)
    {
        return [self.priorityQueue 
                queueItemMeetingTest:^BOOL(NSDictionary* itemWrapper)
                { 
                    WDPRQueueItem* queueItem = itemWrapper[kQueueItem];
                    return [queueItem.uniqueID isEqualToString:uniqueID];
                }][kQueueItem];
    }
}

- (BOOL)hasQueueItemWithID:(NSString*)uniqueID
{
    return ([self queueItemWithID:uniqueID] != nil);
}

- (void)removeItem:(WDPRQueueItem*)itemToRemove
{
    @synchronized(self)
    {
        // Remove the item with an identical type
        [self.priorityQueue removeObject:
         ^BOOL(NSDictionary* itemWrapper)
         { 
             return (itemWrapper[kQueueItem] == itemToRemove);
         }];
    }
}

- (void)removeItemWithID:(NSString*)uniqueID
{
    @synchronized(self)
    {
        // Remove the item with an identical type
        [self.priorityQueue removeObject:
         ^BOOL(NSDictionary* itemWrapper)
         { 
             WDPRQueueItem* queueItem = itemWrapper[kQueueItem];
             return [queueItem.uniqueID isEqualToString:uniqueID];
         }];
    }
}

- (void)replaceItemWithID:(NSString*)uniqueID 
                 withItem:(WDPRQueueItem *)item
{
    // First remove the original
    [self removeItemWithID:uniqueID];
    
    // Next add the new item
    [self registerItem:item];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods
- (void)handleTimerFire:(NSTimer *)timer
{
    [self.queueTimer invalidate];
    
    NSDictionary *itemWrapper = 
    self.priorityQueue.firstObject;
    
    NSDate* now = NSDate.date;
    NSDate* fireDate = itemWrapper[kFireTime];
    
    if ([fireDate isEqualToDate:now] ||
        [fireDate isEqualToDate:[fireDate earlierDate:now]])
    {
        WDPRQueueItem* queueItem;
        [self removeItem:(queueItem = 
                          itemWrapper[kQueueItem])];
        
        if (queueItem.isValid)
        {
            [self.operationQueue addOperationWithBlock:
             (^{
                [queueItem fireNow];
                [queueItem postProcess];
                
                if (queueItem.repeats)
                {
                    [self registerItem:queueItem 
                             withDelay:queueItem.fireDelay 
                              tryCount:[itemWrapper[kTryCount] intValue]];
                }
            })];
        }
    }
    
    [self setupAndStartTimer];
}

- (void)setupAndStartTimer
{
    if (self.priorityQueue.count > 0)
    {        
        // Start the timer
        executeOnMainThread
        (^{
            NSDictionary *nextItem = self.priorityQueue.firstObject;
            NSDate* fireDate = [NSDate.date laterDate:nextItem[kFireTime]];
            
            if (self.queueTimer.isValid)
            {
                self.queueTimer.fireDate = fireDate;
            }
            else
            {
                self.queueTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                           interval:0
                                                             target:self
                                                           selector:@selector(handleTimerFire:)
                                                           userInfo:nil
                                                            repeats:NO];    // its manually started, every time
            }
            [[NSRunLoop mainRunLoop] addTimer:self.queueTimer forMode:NSDefaultRunLoopMode];
        });
    }
}

@end
