//
//  NSObject+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 7/30/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef dispatch_block_t PlainBlock;

@interface PlainBlockWrapper : NSObject

- (void)executeBlock;

@property (atomic, copy) PlainBlock block;

+ (instancetype)wrapBlock:(PlainBlock)block;

@end // @interface PlainBlockWrapper


@interface NSObject (WDPR)

+ (NSArray *)classMethods;

- (BOOL)isA:(Class)type;

/// outputs WDPRLog message when this object is dealloc'd
- (void)debugDeallocation;
- (void)debugDeallocation:(NSString*)name;

/// Print object properties.. debug only
- (NSDictionary *) wdpr_description;

/// Used for UI strings and elements
/// "long-form" string, defaults to self.description
- (NSString *)formattedDescription;

// Add a block to be executed when dealloc is executed on any object
- (void)addDeallocBlock:(void (^)(void))block;

- (id)objectForKeyPath:(NSString*)keyPath;
- (id)objectForKeyedSubscript:(NSString*)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString*)key;

- (void)observeNotificationName:(NSString *)name 
                         object:(id)obj queue:(NSOperationQueue *)queue 
                     usingBlock:(void (^)(NSNotification *note))block;

/** safeCast:.
 @param obj An object you want to cast
 @return It return the same object if the cast was successful, if not return nil.
 */
+ (instancetype)safeCast:(NSObject *)obj;

/** nullify.
 @param obj An object you want to make sure is not nil
 @return It return the same object if obj != nil, if not it returns an instance of the class.
 */
+ (instancetype)nullify:(NSObject *)obj;

- (id)deepCopy;

@end // @interface NSObject (WDPR)

