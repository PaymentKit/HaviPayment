//
//  WDPRModalTransitionInteractor.h
//  Pods
//
//  Created by Nguyen, Kevin on 6/17/16.
//
//

#import <UIKit/UIKit.h>

/*
 * When used with a transition class, this class tells the transition how much to animate
 * according to a percentage.  The animateTransition method will animate the transition
 * to the provided percentage.
 */

@interface WDPRModalTransitionInteractor : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign) BOOL hasStarted;
@property (nonatomic, assign) BOOL shouldFinish;

@end
