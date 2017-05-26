//
//  WDPRActivityIndicator.h
//  WDPR
//
//  Created by Thompson, Greg X. -ND on 5/6/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDPRActivityIndicator : UIView

+ (instancetype)createActivityIndicatorWithTitle:(NSString*)title
                         message:(NSString*)message
                         andSpinner:(BOOL)withSpinner;

+ (void)dismissActivityIndicator:(WDPRActivityIndicator*)indicator
                        animated:(BOOL)animated;

@property (nonatomic) NSInteger displayCount;
@end
