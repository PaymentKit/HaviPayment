//
//  NSPredicate+WDPR.m
//  DLR
//
//  Created by Francisco Valbuena on 3/5/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

@implementation NSPredicate (WDPR)

#pragma mark - NSPredicate+WDPR

+ (NSPredicate *)join:(NSPredicate *)lhs and:(NSPredicate *)rhs
{
    NSArray *predicates = [self subPredicatesWithLhs:lhs rhs:rhs];
    
    if (predicates.count <= 1)
    {
        return predicates.firstObject;
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

+ (NSPredicate *)join:(NSPredicate *)lhs or:(NSPredicate *)rhs
{
    NSArray *predicates = [self subPredicatesWithLhs:lhs rhs:rhs];
    
    if (predicates.count <= 1)
    {
        return predicates.firstObject;
    }
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
}

+ (NSPredicate *)predicateWithPrefix:(NSString *)prefix attribute:(NSString *)attribute value:(NSString *)value
{
    if (!value.length)
    {
        return nil;
    }
    
    NSString *format = [NSString stringWithFormat:@"%@%@ == %@", prefix, attribute, @"%@"];
    
    return [NSPredicate predicateWithFormat:format, value];
}

#pragma mark - NSPredicate+WDPR Private

+ (NSArray *)subPredicatesWithLhs:(NSPredicate *)lhs rhs:(NSPredicate *)rhs
{
    if (!lhs && !rhs)
    {
        return nil;
    }
    
    NSMutableArray *predicates = [NSMutableArray new];
    
    if (lhs)
    {
        [predicates addObject:lhs];
    }
    
    if (rhs)
    {
        [predicates addObject:rhs];
    }
    
    return [predicates copy];
}

@end
