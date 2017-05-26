//
//  NSArray+Blocks.m
//  WDPR
//
//  Created by Garcia, Jesus on 7/15/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

@implementation NSArray (Blocks)

- (id)match:(WDPRValidationBlock)block
{
    NSParameterAssert([block isA:NSClassFromString(@"NSBlock")]);
    
	NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
		return block(obj);
	}];
    
	if (index == NSNotFound)
		return nil;
    
	return [self objectAtIndex:index];
}

- (NSArray *)filter:(WDPRValidationBlock)block
{
    NSParameterAssert([block isA:NSClassFromString(@"NSBlock")]);
    
	return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
		return block(obj);
	}]];
}

- (NSArray *)reject:(WDPRValidationBlock)block
{
    NSParameterAssert([block isA:NSClassFromString(@"NSBlock")]);

    return [self filter:^BOOL(id obj)
    {
		return !block(obj);
	}];
}

- (NSArray *)map:(WDPRTransformBlock)block
{
    NSParameterAssert([block isA:NSClassFromString(@"NSBlock")]);
    
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
		id value = block(obj);
		if (!value)
			value = [NSNull null];
        
		[result addObject:value];
	}];
    
	return result;
}

- (BOOL)any:(WDPRValidationBlock)block
{
    __block BOOL any = NO;
    NSParameterAssert([block isA:NSClassFromString(@"NSBlock")]);
    
    [self enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop)
     {
         any = *stop = block(obj);
     }];
    
    return any;
}

@end
