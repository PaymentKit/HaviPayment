//
//  WDPREnum.h
//  DisneyFoundationKit
//
//  Created by Jaime Laino on 2/23/15.
//  Copyright (c) 2015 Disney. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSStringFromEnumType(type) @#type

@interface WDPREnum : NSObject

+ (void)registryType:(NSString *)type withValuesAndStrings:(NSDictionary *)valuesAndStrings;
+ (NSString *)stringFromValue:(NSInteger)value type:(NSString *)type;
+ (NSInteger)valueFromString:(NSString *)string type:(NSString *)type;
+ (NSArray *)allTypes;

@end
