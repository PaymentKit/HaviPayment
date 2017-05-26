//
//  WDPRTableSeparator.h
//  DLR
//
//  Created by Rodden, James on 12/5/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPRTableViewItem.h"

@interface WDPRTableSeparator : UITableViewCell

@property (nonatomic) UIColor* lineColor;
@property (nonatomic) UIEdgeInsets separatorInset;

+ (id)tableSeparatorItemWithHeight:(NSUInteger)height;

@end

