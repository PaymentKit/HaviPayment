//
//  NSObject+Observed.m
//  WDPR
//
//  Created by Wright, Byron on 12/11/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <objc/runtime.h>
#import "WDPRFoundation.h"

static char WDPRObserversKey;

@interface WDPRObserveInfo : NSObject

@property (nonatomic, copy) NSString * keyPath;
@property (nonatomic, assign) NSKeyValueObservingOptions options;
@property (nonatomic, assign) void * context;
@property (nonatomic, copy) WDPRKVONotificationBlock block;
@property (nonatomic, weak) id observer;
@property (nonatomic, copy) NSString * boundKeyPath;
@end

@implementation WDPRObserveInfo

@end

@implementation NSObject (WDPRObserved)

- (NSMutableDictionary *)observersMap
{
    return objc_getAssociatedObject(self, (void*)&WDPRObserversKey);
}

- (void)setObserversMap:(NSMutableDictionary *)observersMap
{
    objc_setAssociatedObject(self, (void*)&WDPRObserversKey, observersMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeAllObservers
{
    [self.observersMap enumerateKeysAndObjectsUsingBlock:
     ^(NSString* keyPath, NSArray* observers, BOOL *stop) 
    {
        @try
        {   // either we must call removeObserver:forKeyPath: 
            // once per registration, or once per registration
            // with a unique paring of keyPath and options
            for (NSUInteger ii = 0; ii < observers.count; ii++)
            {
                [self removeObserver:self forKeyPath:keyPath];
            }
        }
        @catch(id exception)
        {
            WDPRLog(@"we called removeObserver:"
                    "forKeyPath:\"$@\" too many times", keyPath);
        }
    }];
    
    self.observersMap = nil;
}

- (void)addObserver:(id)observer
            keyPath:(NSString *)keyPath
              block:(WDPRKVONotificationBlock)block
{
    [self addObserver:observer
              keyPath:keyPath
              options:0
                block:block];
}

- (void)addObserver:(id)observer
        keyPath:(NSString *)keyPath
        options:(NSKeyValueObservingOptions)options
          block:(WDPRKVONotificationBlock)block
{
    [self addObserver:self forKeyPath:keyPath 
              options:options context:NULL];
    
    WDPRObserveInfo * info = [WDPRObserveInfo new];
    info.observer = observer;
    info.keyPath = keyPath;
    info.block = block;
    
    //lazy create the observers data structure
    if (!self.observersMap)
    {
        self.observersMap = [NSMutableDictionary new];
    }
    
    NSMutableArray * observers = self.observersMap[keyPath];
    if (!observers)
    {
        self.observersMap[keyPath] = [[NSMutableArray alloc] init];
    }
    
    [self.observersMap[keyPath] addObject:info];
}

- (void)removeObserver:(id)observer keyPath:(NSString *)keyPath
{
    // remove the observerInfo from the observers for this keyPath.
    // because we use the isEqual of the observer we can use the object param to remove the observer
    NSMutableArray * observers = self.observersMap[keyPath];
    if (observers)
    {
        // find the info based on the observer
        NSUInteger observerIndex = 
        [observers indexOfObjectPassingTest:
         ^BOOL(WDPRObserveInfo * info, NSUInteger idx, BOOL *stop)
        {
            Require(info, WDPRObserveInfo);
            if ([info.observer isEqual:observer])
            {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (observerIndex != NSNotFound)
        {
            [observers removeObjectAtIndex:observerIndex];
            
            if ([observers count] == 0)
            {
                [self removeObserver:self forKeyPath:keyPath];
            }
        }
    }
}

- (void)bind:(NSString *)keyPath toObject:(id)object withKeyPath:(NSString *)boundKeyPath options:(NSKeyValueObservingOptions)options
{
    [self addObserver:self forKeyPath:keyPath options:options context:NULL];
    WDPRObserveInfo * info = [[WDPRObserveInfo alloc] init];
    info.observer = object;
    info.keyPath = keyPath;
    info.boundKeyPath = boundKeyPath;
    
    //lazy create the observers data structure
    if (!self.observersMap)
    {
        self.observersMap = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray * observers = self.observersMap[keyPath];
    if (!observers)
    {
        self.observersMap[keyPath] = [[NSMutableArray alloc] init];
    }
    [self.observersMap[keyPath] addObject:info];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSMutableArray * observers = self.observersMap[keyPath];
    if (observers)
    {
        for (WDPRObserveInfo * info in observers)
        {
            if (info.boundKeyPath)
            {
                info.observer[info.boundKeyPath] = change[@"new"];
            }
            else
            {
                info.block(object, keyPath, change);
            }
        }
    }
}

- (void)unobserveAll
{
    [self.observersMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        [self removeObserver:self forKeyPath:key];
        NSMutableArray * observers = self.observersMap[key];
        [observers removeAllObjects];
    }];
    [self.observersMap removeAllObjects];
}
@end
