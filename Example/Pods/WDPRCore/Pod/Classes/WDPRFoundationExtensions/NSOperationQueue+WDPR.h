//
//  NSOperationQueue+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 10/23/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (WDPR)

+ (NSOperationQueue*)backgroundQueue;
+ (NSOperationQueue*)serviceCallQueue;

/// Method used by the BuildPhase to execute the facility sync and wait for completion
- (void)addOperationWithBlockAndWait:(dispatch_block_t)block;
- (void)withPriority:(NSOperationQueuePriority)priority execute:(dispatch_block_t)block;

@end

@interface NSBlockOperation (WDPR)

+ (instancetype)blockOperationWithQueuePriority:(NSOperationQueuePriority)priority 
                                       andBlock:(void (^)(void))block;

@end