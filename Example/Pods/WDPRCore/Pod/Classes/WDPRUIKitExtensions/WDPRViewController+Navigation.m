//
//  WDPRViewController+Navigation.m
//  Pods
//
//  Created by Uribe, Martin on 2/23/16.
//
//

#import "WDPRViewController+Navigation.h"
#import "WDPRModalNavigationController.h"

@implementation WDPRViewController (Navigation)

#pragma mark - Modal Navigation

- (void)hidePullToDismissButton:(BOOL)hide animated:(BOOL)animated
{
    if ([self.navigationController isA:[WDPRModalNavigationController class]])
    {
        [(WDPRModalNavigationController *)self.navigationController hideDismissButton:hide animated:animated];
    }
}

- (void)hidePullToDismissButton:(BOOL)hide animated:(BOOL)animated disableDragging:(BOOL)disable
{
    [self enablePullToDismissDragging:!disable];
    [self hidePullToDismissButton:hide animated:animated];
}

- (void)enablePullToDismissDragging:(BOOL)enable
{
    if ([self.navigationController isA:[WDPRModalNavigationController class]])
    {
        [((WDPRModalNavigationController *)self.navigationController).modalTransition enableDragging:enable];
    }
}

@end
