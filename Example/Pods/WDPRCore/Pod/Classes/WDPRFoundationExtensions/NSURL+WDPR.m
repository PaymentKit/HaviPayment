//
//  NSURL+WDPR.m
//  WDPR
//
//  Created by Thompson, Greg X. -ND on 9/23/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

@implementation NSURL (WDPR)

- (NSDictionary *)queryParams
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *param in [[self query] componentsSeparatedByString:@"&"])
    {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        
        if([parts count] < 2) continue;
        
        [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
    }
    return params;
}

@end
