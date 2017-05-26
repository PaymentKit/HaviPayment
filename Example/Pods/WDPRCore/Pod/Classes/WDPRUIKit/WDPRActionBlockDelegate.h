//
//  ActionBlockDelegate.h
//  DLR
//
//  Created by Fernando Nicola on 5/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WDPRFoundation.h"

@interface WDPRActionBlockDelegate : NSObject <UIAlertViewDelegate>
@property (nonatomic) NSMutableArray* blocks;

+ (NSMutableDictionary*)map;
@end
