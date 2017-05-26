//
//  WDPRTableViewController+Navigation.m
//  Pods
//
//  Created by Nguyen, Kevin on 4/19/17.
//
//

#import "WDPRTableViewController+Navigation.h"
#import "WDPRModalNavigationController.h"

@implementation WDPRTableViewController (Navigation)

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
