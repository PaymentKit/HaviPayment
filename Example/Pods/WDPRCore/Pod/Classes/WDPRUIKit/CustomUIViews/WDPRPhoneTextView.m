//
//  WDPRPhoneTextView.m
//  Pods
//
//  Created by Quezada, Jose on 3/7/16.
//
//

#import "WDPRPhoneTextView.h"

@implementation WDPRPhoneTextView


- (BOOL)canBecomeFirstResponder
{
    return NO;
}

-(void)layoutSubviews
{
    NSArray *originalArrayOfGestureRecognizers = self.gestureRecognizers;
    NSMutableArray *finalArrayOfGestureRecognizers = [[NSMutableArray alloc] initWithCapacity:originalArrayOfGestureRecognizers.count];
    
    for (UIGestureRecognizer *gestureRecognizer in originalArrayOfGestureRecognizers)
    {
        if (![gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        {
            [finalArrayOfGestureRecognizers addObject:gestureRecognizer];
        }
        else
        {
            UILongPressGestureRecognizer *longPressGestureRecognizer = (UILongPressGestureRecognizer *)gestureRecognizer;
            if (longPressGestureRecognizer.minimumPressDuration < 0.3)
            {   // Removed Zooming Long Press And Text Selection Long Press. Yet Kept Click On Link Long Press.
                [finalArrayOfGestureRecognizers addObject:gestureRecognizer];
            }
        }
    }
    
    self.gestureRecognizers = finalArrayOfGestureRecognizers;
}

@end
