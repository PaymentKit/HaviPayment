//
//  NSOperationQueue+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 10/23/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

@implementation NSBlockOperation (WDPR)

+ (instancetype)blockOperationWithQueuePriority:(NSOperationQueuePriority)priority 
                             andBlock:(void (^)(void))block
{
    NSBlockOperation* operation = 
    [NSBlockOperation blockOperationWithBlock:block];
    
    operation.queuePriority = priority;
    return operation;
}

@end

#pragma mark -

@implementation NSOperationQueue (WDPR)

+ (NSOperationQueue*)backgroundQueue
{
    static NSOperationQueue* queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [NSOperationQueue new];
        queue.name = @"com.disney.wdpro.background.queue";
    });
    
    return queue;
}

+ (NSOperationQueue*)serviceCallQueue
{
    static NSOperationQueue* queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [NSOperationQueue new];
        queue.name = @"com.disney.wdpro.servicecall.queue";
    });
    
    return queue;
}


#pragma mark -

- (void)withPriority:(NSOperationQueuePriority)priority execute:(dispatch_block_t)block
{
    [self addOperation:[NSBlockOperation blockOperationWithQueuePriority:priority 
                                                                andBlock:block]];
}

- (void)addOperationWithBlockAndWait:(dispatch_block_t)block
{
    [self addOperations:@[[NSBlockOperation blockOperationWithBlock:block]] waitUntilFinished:YES];
}

@end
