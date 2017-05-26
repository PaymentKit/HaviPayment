//
//  NSCache+WDPR.h
//  Pods
//
//  Created by J.Rodden on 10/15/15.
//
//

#import <Foundation/Foundation.h>

@interface NSCache <KeyType, ObjectType> (WDPR)

- (nullable ObjectType)objectForKeyedSubscript:(KeyType _Nonnull)key;
- (void)setObject:(ObjectType _Nullable)obj forKeyedSubscript:(KeyType _Nonnull)key;

@end
