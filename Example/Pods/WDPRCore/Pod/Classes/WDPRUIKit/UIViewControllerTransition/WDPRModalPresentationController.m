//
//  WDPRModalPresentationController.m
//  WDPRO
//
//  Created by Contreras, Ricardo on 9/11/16.
//  Copyright (c) 2016 WDPRO. All rights reserved.
//

#import "WDPRModalPresentationController.h"

@implementation WDPRModalPresentationController

- (BOOL)shouldRemovePresentersView
{
    return YES;
}

- (void)presentationTransitionWillBegin
{
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    
}

- (void)dismissalTransitionWillBegin
{
    
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    
}

- (CGRect)frameOfPresentedViewInContainerView
{
    return self.presentedView.frame;
}

@end
