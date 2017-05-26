//
//  UIControl+WDPR.h
//  DLR
//
//  Created by Rodden, James on 12/8/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPRFoundation.h"

@interface UIControl (WDPR)

/// return block to be executed in response to controlEvents
- (PlainBlock)blockForControlEvents:(UIControlEvents)controlEvents;

/// establish a block for execution when specified controlEvents occur,
/// replacing prior entry (pass nil block to remove block for controlEvents)
- (void)inResponseToControlEvents:(UIControlEvents)controlEvents executeBlock:(PlainBlock)block;

@end
