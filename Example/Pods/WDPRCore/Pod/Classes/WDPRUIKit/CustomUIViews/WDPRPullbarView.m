//
//  WDPRPullbarView.m
//  Pods
//
//  Created by Krassi on 4/3/17.
//
//

#import "WDPRPullbarView.h"

@implementation WDPRPullbarView

- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event
{
    NSArray *reversedSubviews = [[self.subviews reverseObjectEnumerator] allObjects];

    for ( UIView *nextReversedSubview in reversedSubviews )
    {
        UIView *nextHitView = [nextReversedSubview hitTest:[self convertPoint:point toView:nextReversedSubview] withEvent:event];
        
        if( nextHitView )
        {
            return nextHitView;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end
