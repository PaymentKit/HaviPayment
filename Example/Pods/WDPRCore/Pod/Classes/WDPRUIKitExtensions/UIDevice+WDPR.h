//
//  UIDevice+WDPR.h
//  DLR
//
//  Created by Delafuente, Rob on 5/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (WDPR)

@property (readonly) NSString *deviceProductName;
@property (readonly) BOOL isIphone6Plus;
@property (readonly) BOOL isIphone6;
@property (readonly) BOOL isIphone6SPlus;
@property (readonly) BOOL isIphone5Series;

@end
