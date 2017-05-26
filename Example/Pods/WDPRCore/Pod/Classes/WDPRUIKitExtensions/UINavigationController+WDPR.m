//
//  UINavigationController+WDPR.m
//  DLR
//
//  Created by Fuerle, Dmitri on 4/15/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "UINavigationController+WDPR.h"
#import "WDPRUIKit.h"

@implementation UINavigationController (WDPR)

- (BOOL)shouldAutorotate
{
    NSArray *childViewControllers = self.visibleViewController.childViewControllers;
    
    if ([self.visibleViewController isA:[WDPRModalContainerViewController class]])
    {
        UIViewController *navCon = [childViewControllers firstObject];
        return [navCon shouldAutorotate];
    }
    else
    {
        return [self.visibleViewController shouldAutorotate];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSArray *childViewControllers = self.visibleViewController.childViewControllers;
    
    if ([self.visibleViewController isA:[WDPRModalContainerViewController class]])
    {
        UIViewController *navCon = [childViewControllers firstObject];
        return [navCon supportedInterfaceOrientations];
    }
    else
    {
        return [self.visibleViewController supportedInterfaceOrientations];
    }
}

- (UIViewController*)controllerFromNavigationStackWithClass:(Class)vcClass
{
    UIViewController *vc = nil;
    
    for (UIViewController *tempController in self.viewControllers)
    {
        if ([tempController isKindOfClass:vcClass])
        {
            vc = tempController;
            break;
        }
    }
    
    return vc;
}

@end
