//
//  UIControl+WDPR.m
//  DLR
//
//  Created by Rodden, James on 12/8/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "UIControl+WDPR.h"

#import <objc/runtime.h>
#import "WDPRFoundation.h"

#define Key @selector(executeBlock)

@implementation UIControl (WDPR)

- (NSMutableDictionary*)controlEventBlocks
{
    return (NSMutableDictionary*)objc_getAssociatedObject(self, Key);
}

- (PlainBlock)blockForControlEvents:(UIControlEvents)controlEvents
{
    return ((PlainBlockWrapper*)self.controlEventBlocks[@(controlEvents)]).block;
}

- (void)inResponseToControlEvents:(UIControlEvents)controlEvents executeBlock:(PlainBlock)block
{
    if (block)
    {
        NSMutableDictionary* blocks = self.controlEventBlocks;
        PlainBlockWrapper* wrapper = [PlainBlockWrapper wrapBlock:block];
        
        [wrapper addDeallocBlock:
         ^{
             WDPRLog(@"I'm outa here!");
         }];
        
        if (!blocks)
        {
            objc_setAssociatedObject(self, Key, 
                                     blocks = [NSMutableDictionary new], 
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        blocks[@(controlEvents)] = wrapper;
        [self addTarget:wrapper action:@selector(executeBlock) forControlEvents:controlEvents];
    }
    else
    {
        PlainBlockWrapper* wrapper = self.controlEventBlocks[@(controlEvents)];
        [self.controlEventBlocks removeObjectForKey:@(controlEvents)];
        [self removeTarget:wrapper action:@selector(executeBlock) forControlEvents:controlEvents];
    }
}

@end
