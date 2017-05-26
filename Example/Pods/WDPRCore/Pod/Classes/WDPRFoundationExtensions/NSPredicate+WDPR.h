//
//  NSPredicate+WDPR.h
//  DLR
//
//  Created by Francisco Valbuena on 3/5/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (WDPR)

/// Returns an AND compound predicate with the 2 predicates, if any of them is nil the other will be returned.
+ (NSPredicate *)join:(NSPredicate *)lhs and:(NSPredicate *)rhs;

/// Returns an OR compound predicate with the 2 predicates, if any of them is nil the other will be returned.
+ (NSPredicate *)join:(NSPredicate *)lhs or:(NSPredicate *)rhs;

/// Compose a predicate for retrieving an attribute using a prefix if value is nil or empty nil will be returned.
+ (NSPredicate *)predicateWithPrefix:(NSString *)prefix attribute:(NSString *)attribute value:(NSString *)value;

@end
 