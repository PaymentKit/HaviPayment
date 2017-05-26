//
//  UITableView+WDPR.m
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@implementation UITableView (WDPR)

- (CGFloat)idealContentHeight
{
    CGFloat idealContentHeight = 0;
    
    idealContentHeight += self.tableHeaderView.frame.size.height;
    idealContentHeight += self.tableFooterView.frame.size.height;
    
    const NSUInteger numSections = [self.dataSource
                                    numberOfSectionsInTableView:self];
    
    for (NSUInteger section = 0; section < numSections; section++)
    {
        CGFloat height = UITableViewAutomaticDimension;
        
        if ([self.delegate respondsToSelector:
             @selector(tableView:heightForHeaderInSection:)])
        {
            height = [self.delegate tableView:self 
                     heightForHeaderInSection:section];
        }
        
        if (height != UITableViewAutomaticDimension)
        {
            idealContentHeight += height;
        }
        else if ([self.delegate respondsToSelector:
                  @selector(tableView:viewForHeaderInSection:)])
        {
            UIView* header = [self.delegate tableView:self 
                               viewForHeaderInSection:section];
            
            if (header)
            {
                idealContentHeight += [header 
                                       systemLayoutSizeFittingSize:
                                       UILayoutFittingExpandedSize].height;
            }
        }
        
        height = UITableViewAutomaticDimension;
        if ([self.delegate respondsToSelector:
             @selector(tableView:heightForFooterInSection:)])
        {
            height = [self.delegate tableView:self 
                     heightForFooterInSection:section];
        }
        
        if (height != UITableViewAutomaticDimension)
        {
            idealContentHeight += height;
        }
        else if ([self.delegate respondsToSelector:
                  @selector(tableView:viewForFooterInSection:)])
        {
            UIView* footer = [self.delegate tableView:self 
                               viewForFooterInSection:section];
            
            if (footer)
            {
                idealContentHeight += [footer 
                                       systemLayoutSizeFittingSize:
                                       UILayoutFittingExpandedSize].height;
            }
        }
        
        for (NSUInteger row = 0, numRows =
             [self.dataSource tableView:self
                  numberOfRowsInSection:section]; row < numRows; row++)
        {
            height = UITableViewAutomaticDimension;
            
            if ([self.delegate respondsToSelector:
                 @selector(tableView:heightForRowAtIndexPath:)])
            {
                height = [self.delegate
                          tableView:self heightForRowAtIndexPath:
                          [NSIndexPath indexPathForRow:row inSection:section]];
            }
            
            if (height != UITableViewAutomaticDimension)
            {
                idealContentHeight += height;
            }
            else
            {
                UITableViewCell* cell = [self.dataSource
                                         tableView:self cellForRowAtIndexPath:
                                         [NSIndexPath indexPathForRow:row 
                                                            inSection:section]];
                if (cell)
                {
                    [cell setNeedsUpdateConstraints];
                    [cell updateConstraintsIfNeeded];
                    
                    [cell setBounds:
                     CGRectWithSize(CGSizeMake(CGRectGetWidth(self.frame),
                                               CGRectGetHeight(cell.frame)))];
                    [cell setNeedsLayout];
                    [cell layoutIfNeeded];
                    
                    idealContentHeight += [cell.contentView
                                           systemLayoutSizeFittingSize:
                                           UILayoutFittingExpandedSize].height;
                    
                    if (self.separatorStyle != // accomodate separator line
                        UITableViewCellSeparatorStyleNone) idealContentHeight++;
                }
            }
        }
    }
    
    return idealContentHeight;
}

- (void)reloadDataAnimated
{
    [self reloadDataAnimated:UITableViewRowAnimationFade];
}

- (void)reloadDataAnimated:(UITableViewRowAnimation)animation
{
    const NSUInteger tableSections = self.numberOfSections;
    const NSUInteger dataSections = [self.dataSource numberOfSectionsInTableView:self];
    
    if (dataSections == 0) // this conditional block should be eliminated
    {   // This is masking issues, but in order to avoid mass breakage, I'll leave for now.
        WDPRLog(@"WARNING: Invalid usage!! This could cause issues.");
        return; // This isn't correct, UITableView API contract requires at least 1 section.
    }
    
    NSParameterAssert(dataSections > 0); // this is a UITableView requirement
    
    [self beginUpdates];
    
    if (dataSections && tableSections)
    {
        [self reloadSections:
         [NSIndexSet indexSetWithIndexesInRange:
          NSMakeRange(0, MIN(dataSections, tableSections))]
            withRowAnimation:animation];
    }
    
    if (dataSections > tableSections)
    {
        [self insertSections:
         [NSIndexSet indexSetWithIndexesInRange:
          NSMakeRange(tableSections, dataSections - tableSections)]
            withRowAnimation:animation];
    }
    else if ((tableSections > 1) && (dataSections <= tableSections))
    {
        // always leave at least 1 section
        [self deleteSections:
         [NSIndexSet indexSetWithIndexesInRange:
          NSMakeRange(MAX(1,dataSections),
                      MIN(tableSections-1,tableSections - dataSections))]
            withRowAnimation:animation];
        
        //Now delete all extra rows
        
        NSMutableArray *rows = [NSMutableArray array];
        for ( int i = 1; i < [self numberOfRowsInSection:0]; ++i )
        {
            [rows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        if ( rows.count > 0 )
        {
            [self deleteRowsAtIndexPaths:[NSArray arrayWithArray:rows]
                        withRowAnimation:animation];
        }
    }
    
    [self endUpdates];
    
    if (self.numberOfSections != dataSections)
    {
        WDPRLog(@"something went wrong in a UITableView");
        [self reloadData];
        NSAssert(self.numberOfSections == dataSections, @"...unable to recover");
    }
}

- (NSIndexPath *)indexPathOfParentCellFromView:(UIView *)view
{
    return [self indexPathForCell:[self parentCellOfView:view]];
}

- (PlainBlock)addActivityIndicatorToRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [self cellForRowAtIndexPath:indexPath];
    
    PlainBlock removeActivityIndicatorBlock = ^{};
    UIView* previouseAccessoryView = cell.accessoryView;
    
    if (cell)
    {
        MAKE_WEAK(self);
        removeActivityIndicatorBlock =
        ^{
            MAKE_STRONG(self);
            THIS_MUST_BE_ON_MAIN_THREAD
            [[strongself cellForRowAtIndexPath:indexPath]
             setAccessoryView:previouseAccessoryView];
        };
        
        #if 1 // use system spinner
        cell.accessoryView = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        
        #else // use our custom spinner
        cell.accessoryView = [WDPRActivityAnimationView
                              smallActivityIndicator:
                              WDPRActivityAnimationViewTypeSpinning];
        #endif
        
        [(id)cell.accessoryView startAnimating];
    }
    
    return removeActivityIndicatorBlock;
}

#pragma mark - Private

- (UITableViewCell*)parentCellOfView:(UIView *)view
{
    if ([view isKindOfClass:UITableViewCell.class])
    {
        return (UITableViewCell*)view;
    }
    else
    {
        UIView *superview = view.superview;
        
        while (superview && 
               ![superview isKindOfClass:
                 UITableViewCell.class])
        {
            superview = superview.superview;
        }
        
        return (UITableViewCell*)superview;
    }
}

@end
