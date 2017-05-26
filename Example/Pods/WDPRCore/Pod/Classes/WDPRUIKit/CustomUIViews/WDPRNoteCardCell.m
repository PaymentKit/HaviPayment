//
//  WDPRNoteCardCell.m
//  Pods
//
//  Created by Martin Di Bella on 8/25/16.
//
//

#import "WDPRNoteCardCell.h"

@implementation WDPRNoteCardCell

+ (NSString *)reuseIdentifier
{
    return @"WDPRNoteCardCell";
}

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [UIView autolayoutView];
        [_headerView addSubviews:@{
                                   @"textLabel" : self.textLabel,
                                   @"detailLabel" : self.detailTextLabel
                                   }
           withVisualConstraints:@[
                                   @"H:|[textLabel]|",
                                   @"H:|[detailLabel]|",
                                   @"V:|[textLabel][detailLabel]|"
                                   ]];
    }
    
    return _headerView;
}

@end
