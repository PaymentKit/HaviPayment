//
//  ActionBlockDelegate.m
//  DLR
//
//  Created by Fernando Nicola on 5/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRActionBlockDelegate.h"

@implementation WDPRActionBlockDelegate

+ (NSMutableDictionary*)map
{
    static NSMutableDictionary* map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [NSMutableDictionary new];
    });
    
    return map;
}

- (NSMutableArray*)blocks
{
    if (!_blocks)
    {
        _blocks = [NSMutableArray new];
    }
    
    return _blocks;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSAssert(buttonIndex < self.blocks.count, @"");
    PlainBlock block = self.blocks[buttonIndex];
    
    SAFE_CALLBACK(block,);
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.class.map removeObjectForKey:@((unsigned long long)alertView)];
}
@end

