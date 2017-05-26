//
//  NSRegularExpression+WDPR.h
//  DLR
//
//  Created by Jeremias Nuñez on 1/29/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRegularExpression (WDPR)

+ (BOOL)string:(NSString *)string exactlyMatchesPattern:(NSString *)pattern;

@end
