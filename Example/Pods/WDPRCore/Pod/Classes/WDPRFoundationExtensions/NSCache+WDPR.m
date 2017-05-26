//
//  NSCache+WDPR.m
//  Pods
//
//  Created by J.Rodden on 10/15/15.
//
//

#import "NSCache+WDPR.h"

@implementation NSCache (WDPR)

- (nullable id)objectForKeyedSubscript:(id _Nonnull)key;
{
    return [self objectForKey:key];
}

- (void)setObject:(id _Nullable)obj forKeyedSubscript:(id _Nonnull)key
{
    // NSCache is already thread-safe
    // so no need for @synchronized
    
    if (key)
    {
        if (obj)
        {
            [self setObject:obj
                     forKey:key];
        }
        else
        {
            [self removeObjectForKey:key];
        }
    }
}

@end
