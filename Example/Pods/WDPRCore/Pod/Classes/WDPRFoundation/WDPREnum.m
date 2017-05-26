//
//  WDPREnum.m
//  DisneyFoundationKit
//
//  Created by Jaime Laino on 2/23/15.
//  Copyright (c) 2015 Disney. All rights reserved.
//

#import "WDPREnum.h"

@implementation WDPREnum

+ (void)registryType:(NSString *)type withValuesAndStrings:(NSDictionary *)valuesAndStrings
{
    self.mainRegistry[type] = valuesAndStrings;
}

+ (NSString *)stringFromValue:(NSInteger)value type:(NSString *)type
{
    return self.mainRegistry[type][@(value)];
}

+ (NSInteger)valueFromString:(NSString *)string type:(NSString *)type
{
    NSNumber *enumValue = [[self.mainRegistry[type] keysOfEntriesPassingTest:^BOOL(NSNumber *enumValue, NSString *stringValue, BOOL *stop) {
        *stop = [stringValue isEqualToString:string];
        return *stop;
    }] anyObject];
    
    return [enumValue integerValue];
}

+ (NSArray *)allTypes
{
    return [self.mainRegistry allKeys];
}

#pragma mark - Private Methods

+ (NSMutableDictionary *)mainRegistry
{
    static NSMutableDictionary *_mainRegistry = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _mainRegistry = [[NSMutableDictionary alloc] init];
    });
    return _mainRegistry;
}

@end
