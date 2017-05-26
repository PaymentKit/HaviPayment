//
//  WDPRPriorityQueue.m
//  WDPR
//
//  Created by Garvin, Cody on 9/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

#define MINIMUM_QUEUE_SIZE 16

@interface WDPRPriorityQueue()

// Private Properties
@property (nonatomic) NSMutableArray *queueArray;
@property (nonatomic, copy) NSComparator comparator;

@end

@implementation WDPRPriorityQueue

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Instance Methods
- (id)initWithComparator:(NSComparator)comparator
{
    if ((self = [super init]))
    {
        NSAssert(comparator != nil, @"Comparator must not be nil");
        _comparator = comparator;
        
        _queueArray = [[NSMutableArray alloc] 
                       initWithCapacity:MINIMUM_QUEUE_SIZE];
    }
    return self;
}

- (NSString*)description
{
    NSMutableString* mstr= [NSMutableString new];
    [mstr appendFormat:@":%@\n", NSStringFromClass(self.class)];
    
    @synchronized(self)
    {
        [self.queueArray enumerateObjectsUsingBlock:
         ^(id item, NSUInteger idx, BOOL *stop) 
        {
            [mstr appendFormat:@"%@\n", [item description]];
            
        }];
    }
    
    return mstr;
}

- (void)addObject:(id)object
{
    @synchronized(self)
    {
        NSUInteger index = self.queueArray.count;
        
        if (self.comparator && (index > 0))
        {
            // find where the new object belongs
            // (self.queueArray is already sorted)
            
            for ( ; index > 0; index--)
            {
                id neighbor = self.queueArray[index-1];
                
                NSComparisonResult result = 
                self.comparator(neighbor, object);
                
                // new object goes after existing 
                // one that is NSOrderedSame
                if (result != NSOrderedDescending)
                {
                    break;
                }
            }
        }
        
        [self.queueArray insertObject:object atIndex:index];
        WDPRLog(@"current queue:\n%@", self.queueArray);
    }
}

- (id)firstObject
{
    @synchronized(self)
    {
        return self.queueArray.firstObject;
    }
}

- (id)removeObject:(BOOL (^)(id obj))test
{
    if (!test) return nil;
    
    @synchronized(self)
    {
        id object;
        NSUInteger index = 
        [self.queueArray indexOfObjectPassingTest:
         ^BOOL(id obj, NSUInteger idx, BOOL *stop) 
         {
             return (*stop = test(obj));
         }];
        
        if (index != NSNotFound)
        {
            object = self.queueArray[index];
            [self.queueArray removeObjectAtIndex:index];
        }
        
        return object;
    }
}

- (NSUInteger)count
{
    @synchronized(self)
    {
        return self.queueArray.count;
    }
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark - Uniqueness check

- (id)queueItemMeetingTest:(BOOL (^)(id obj))test
{
    __block id object;
    @synchronized(self)
    {
        [self.queueArray enumerateObjectsUsingBlock:
         ^(id obj, NSUInteger idx, BOOL *stop)
         {
             if (test(obj))
             {
                 *stop = YES;
                 object = obj;
             }
         }];
    }
    
    return object;
}

- (BOOL)hasQueueItem:(BOOL (^)(id obj))test
{
    return ([self queueItemMeetingTest:test] != nil);
}


@end
