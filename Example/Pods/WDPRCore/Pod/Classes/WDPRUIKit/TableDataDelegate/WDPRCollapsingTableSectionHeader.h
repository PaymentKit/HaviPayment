//
//  WDPRCollapsingTableSectionHeader.h
//  WDPR
//
//  Created by Rodden, James on 11/17/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WDPRTableViewCell.h"

@class WDPRTableController;

@interface WDPRCollapsingTableSectionHeader : UIView

- (id)initWithStyle:(WDPRTableViewCellStyle)style
         forSection:(NSUInteger)collapsingSection 
            inTable:(WDPRTableController *)tableController;

- (void)toggleOpen;

@property (nonatomic) NSArray* items;
@property (nonatomic, readonly) UILabel* textLabel;
@property (nonatomic, readonly) UIImageView* imageView;
@property (nonatomic, readonly) UILabel* detailTextLabel;
@property (nonatomic, getter = isCollapsed) BOOL collapsed;

@property (nonatomic, readonly) NSUInteger section;
@property (nonatomic, readonly, weak) WDPRTableController * tableController;

@end
