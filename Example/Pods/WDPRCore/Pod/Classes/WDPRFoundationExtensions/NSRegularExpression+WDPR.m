//
//  NSRegularExpression+WDPR.m
//  WDPR
//
//  Created by Jeremias Nuñez on 1/29/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

@implementation NSRegularExpression (WDPR)

+ (BOOL)string:(NSString *)string exactlyMatchesPattern:(NSString *)pattern
{
    NSError *error;
    
    NSRegularExpression* regex =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:0
                                                error:&error];
    
    if (error)
    {
        WDPRLog(@"failed to create NSRegularExpression: %@", error);
    }
    
    return ([regex numberOfMatchesInString:string
                                   options:0
                                     range:NSMakeRange(0, string.length)]
            == 1);
}

@end
