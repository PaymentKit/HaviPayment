//
//  WDPRCollapsingTableSectionHeader.m
//  WDPR
//
//  Created by Rodden, James on 11/17/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@interface WDPRCollapsingTableSectionHeader ()

@property (nonatomic) NSUInteger section;
@property (nonatomic) WDPRTableViewCell * cell;
@property (nonatomic, weak) WDPRTableController * tableController;

@end

@implementation WDPRCollapsingTableSectionHeader

PassthroughGetter(UILabel*, textLabel, self.cell);
PassthroughGetter(UILabel*, detailTextLabel, self.cell);
PassthroughGetter(UIImageView*, imageView, self.cell);

- (id)initWithStyle:(WDPRTableViewCellStyle)style
         forSection:(NSUInteger)collapsingSection 
            inTable:(WDPRTableController *)tableController
{
    self = [super initWithFrame://CGRectZero];/*
            CGRectMake(0, 0, 
                       tableController.tableView.frame.size.width, 44)];//*/
    
    if (self)
    {
        _collapsed = NO;
        _section = collapsingSection;
        _tableController = tableController;
        
        // configure nested cell
        [self addSubview:_cell = 
         [[WDPRTableViewCell alloc] initWithStyle:
          (UITableViewCellStyle)style reuseIdentifier:nil]];
        
        _cell.frame = self.bounds;
        
        [_cell setBackgroundColor:
         (UITableViewStyleGrouped == 
          tableController.tableView.style) ?
         UIColor.clearColor : [UIColor.wdprLightBlueColor
                               colorWithAlphaComponent:0.9]];
        
        _cell.textLabel.font = UIFont.wdprFontStyleC1;
        _cell.detailTextLabel.font = UIFont.wdprFontStyleC2;
        
        _cell.textLabel.textColor = UIColor.wdprDarkBlueColor;
        _cell.detailTextLabel.textColor = UIColor.wdprDarkBlueColor;
        
        _cell.autoresizingMask = (UIViewAutoresizingFlexibleWidth | 
                                  UIViewAutoresizingFlexibleHeight);
        
        // place an invisible button atop the nested cell
        UIButton* button;
        [self addSubview:button = 
         [UIButton buttonWithType:UIButtonTypeCustom]];
        
        button.frame = self.bounds;
        [button addTarget:self 
                   action:@selector(toggleOpen) 
         forControlEvents:UIControlEventTouchUpInside];
        button.autoresizingMask = (UIViewAutoresizingFlexibleWidth | 
                                   UIViewAutoresizingFlexibleHeight);

        UIImage *image = [[UIImage imageNamed:WDPRCoreCaretDownBlueImageName
                                     inBundle:[WDPRFoundation wdprCoreResourceBundle]
                                   compatibleWithTraitCollection:nil]
                         sizedTo:CGSizeMake(10, 10)];

        [_cell setAccessoryView:
         [[UIImageView alloc] initWithImage:image]];
    }
    
    return self;
}

- (void)toggleOpen
{
    self.collapsed = !self.isCollapsed;
}

- (void)setCollapsed:(BOOL)collapsed
{
    if ((_collapsed != collapsed) && 
        // don't collapse the section with checkmarkedItem
        (!self.tableController.dataDelegate.checkmarkedItem || 
         (self.section != self.tableController.dataDelegate.checkmarkedItem.section)))
    {
        _collapsed = collapsed;
        
        [self.tableController.tableView beginUpdates];

        UIImage *image = [[UIImage imageNamed:collapsed ? WDPRCoreCaretDownBlueImageName : WDPRCoreCaretUpBlueImageName
                                     inBundle:[WDPRFoundation wdprCoreResourceBundle]
                                   compatibleWithTraitCollection:nil]
                         sizedTo:CGSizeMake(10, 10)];

        [self.cell setAccessoryView:
         [[UIImageView alloc] initWithImage:image]];
        
        WDPRCollapsingTableSectionHeader * strongSelf = self;
        id footer = self.tableController.dataDelegate.footers[self.section];
        
        if (collapsed)
        {
            self.items = self.tableController.dataDelegate.items[strongSelf.section];
            
            [self.tableController.dataDelegate deleteSection:strongSelf.section 
                                            withRowAnimation:UITableViewRowAnimationBottom];
            
            [self.tableController.dataDelegate insertSection:@[] 
                                                     atIndex:strongSelf.section 
                                                  withHeader:strongSelf andFooter:footer 
                                            withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            [self.tableController.dataDelegate deleteSection:strongSelf.section 
                                            withRowAnimation:UITableViewRowAnimationNone];
            
            [self.tableController.dataDelegate insertSection:strongSelf.items 
                                                     atIndex:strongSelf.section 
                                                  withHeader:strongSelf andFooter:footer 
                                            withRowAnimation:UITableViewRowAnimationBottom];
        }
        
        [self.tableController.tableView endUpdates];
    }
}

@end
