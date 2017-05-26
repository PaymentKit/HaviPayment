//
//  NSObject+Observed.h
//  DLR
//
//  Created by Wright, Byron on 12/11/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @abstract Block called on key-value change notification.
 @param observedObject The object changed.
 @param keyPath The keypath changed.
 @param change The change dictionary.
 */
typedef void (^WDPRKVONotificationBlock)(id observedObject, NSString * keyPath, NSDictionary *change);

@interface NSObject (WDPRObserved)


/**
 @abstract Registers observer for key-value change notification.
 @param observer A unique token representing the observer.
 @param keyPath The key path to observe.
 @param options The NSKeyValueObservingOptions to use for observation.
 @param block The block to execute on notification.
 */
- (void)addObserver:(id)observer 
            keyPath:(NSString *)keyPath 
            options:(NSKeyValueObservingOptions)options 
              block:(WDPRKVONotificationBlock)block;

- (void)addObserver:(id)observer 
            keyPath:(NSString *)keyPath 
              block:(WDPRKVONotificationBlock)block;

/// remove all currently registered keyPath observations
- (void)removeAllObservers;

/// remove a specific currently registered keyPath observation
- (void)removeObserver:(id)observer keyPath:(NSString *)keyPath;

- (void)bind:(NSString *)keyPath toObject:(id)object withKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
@end
