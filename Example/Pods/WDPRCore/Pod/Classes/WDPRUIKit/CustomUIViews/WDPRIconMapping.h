//
//  WDPRIconMapping.h
//  Pods
//
//  Created by Sergio Sanchez on 10/27/15.
//  Copyright © 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDPRIconMapping : NSObject

- (instancetype)initPeptasiaIconsWithFileName:(NSString *)fileName;
- (instancetype)initPeptasiaIconsWithFileName:(NSString *)fileName language:(NSString *)language;

- (NSDictionary *)getIcons;

@end
