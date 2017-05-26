//
//  WDPRQueueItem.m
//  WDPR
//
//  Created by Garvin, Cody X. -ND on 9/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

@interface WDPRQueueItem ()

@property (nonatomic) NSTimeInterval fireDelay;

@end

@implementation WDPRQueueItem

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization Methods

- (BOOL)isValid
{
    return YES;
}

- (void)fireNow
{
    WDPRLog(@"%@ has no fire action", self.uniqueID);
}

- (void)postProcess
{
}

- (NSString *)description
{
    NSString* (^fireDelay)(void) = 
    ^{
        NSString* suffix = @"seconds";
        NSTimeInterval time = self.fireDelay;
        
        if (time > 60)
        {
            time /= 60;
            suffix = @"minutes";
        }
        
        if (time > 60)
        {
            time /= 60;
            suffix = @"hours";
        }
        
        if (time > 2*24)
        {
            time /= 24;
            suffix = @"days";
        }
        
        return [NSString stringWithFormat:
                @"%.0f %@", time, suffix];
    };
    
    return [NSString stringWithFormat:@"%@%@", self.uniqueID, 
            (!self.repeats ? @"" : [NSString stringWithFormat:
                                    @" (every %@)", fireDelay()])];

}

- (id)initWithDelay:(NSTimeInterval)delay 
           uniqueID:(NSString*)identifier
{
    return [self initWithDelay:delay 
                      uniqueID:identifier 
                      priority:WDPRQueuePriorityMedium];
}

- (id)initWithDelay:(NSTimeInterval)delay 
           uniqueID:(NSString*)identifier
           priority:(WDPRQueuePriority)priority
{
    self = [super init];
    
    if (self)
    {
        _fireDelay = delay;
        _priority = priority;
        _uniqueID = identifier;
    }
    
    return self;
}

@end // @implementation WDPRQueueItem

#pragma mark -

@implementation WDPRQueueItemWithBlocks

- (BOOL)isValid
{
    return (self.isValidBlock ? 
            self.isValidBlock() : super.isValid);
}

- (void)fireNow
{
    if (self.fireBlock)
    {
        self.fireBlock();
    }
    else [super fireNow];
}

- (void)postProcess
{
    if (self.postFlightBlock)
    {
        self.postFlightBlock();
    }
    else [super postProcess];
}

#pragma mark -

- (id)initWithDelay:(NSTimeInterval)delay 
           uniqueID:(NSString*)indentifier
           priority:(WDPRQueuePriority)priority;
{
    self = [super initWithDelay:delay 
                       uniqueID:indentifier 
                       priority:priority];
    
    if (self)
    {
        _isValidBlock   = ^{ return YES; };
    }
    return self;
}

@end // @implementation WDPRQueueItemWithBlocks
