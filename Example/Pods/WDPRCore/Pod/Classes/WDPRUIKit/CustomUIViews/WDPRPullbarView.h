//
//  WDPRPullbarView.h
//  Pods
//
//  Created by Krassi on 4/3/17.
//
//

#import <UIKit/UIKit.h>

/**
    WDPRPullbarView exists to overload hitTest:withEvent: such that the tap gesture recognizer
    attached to the notch view will prevail over the UITableCell recognizer in the edge area.
 */

@interface WDPRPullbarView : UIView

@end
