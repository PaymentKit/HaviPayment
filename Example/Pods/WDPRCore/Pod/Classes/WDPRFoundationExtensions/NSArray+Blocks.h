//
//  NSArray+Blocks.h
//  WDPR
//
//  Created by Garcia, Jesus on 7/15/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WDPRSenderBlock)(id sender);
typedef BOOL (^WDPRValidationBlock)(id obj);
typedef id (^WDPRTransformBlock)(id obj);
typedef id (^WDPRAccumulationBlock)(id sum, id obj);
typedef BOOL (^WDPRKeyValueValidationBlock)(id key, id obj);

@interface NSArray (Blocks)

// Execute a validation block on a matched object. Returns that object after
- (id)match:(WDPRValidationBlock)block;
// Executes a validation block on matched objects and returns that set of objects after
- (NSArray *)filter:(WDPRValidationBlock)block;
// Executes a validation block that returns the items that don't pass in the block
- (NSArray *)reject:(WDPRValidationBlock)block;
- (NSArray *)map:(WDPRTransformBlock)block;
// Check if any items match the object passed in the block
- (BOOL)any:(WDPRValidationBlock)block;
@end
