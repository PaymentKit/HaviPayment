//
//  WDPRTableSeparator.m
//  DLR
//
//  Created by Rodden, James on 12/5/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@interface WDPRTableSeparator ()

@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat rightInset;
@property (nonatomic) UIView* separatorLine;

@end

#pragma mark -

@implementation WDPRTableSeparator

+ (id)tableSeparatorItemWithHeight:(NSUInteger)height
{
    return @{
            WDPRCellType : self.class,
            WDPRCellRowHeight : @(height),
            WDPRCellSelectionStyle: @(UITableViewCellSelectionStyleNone),
             };
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _leftInset = _rightInset = 16;
        
        // we have setters to block changes
        super.isAccessibilityElement = NO;
        super.accessibilityElementsHidden = YES;
        super.accessoryType = UITableViewCellAccessoryNone;
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:
         _separatorLine = [[UIView alloc] initWithFrame:CGRectZero]];
        
        _separatorLine.backgroundColor = [UIColor wdprMutedGrayColor];
        _separatorLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 1);
    }
    
    return self;
}

#pragma mark - Getters

- (UIColor*)lineColor
{
    return self.separatorLine.backgroundColor;
}

- (UIEdgeInsets)separatorInset
{
    return UIEdgeInsetsMake(0, self.leftInset,
                            0, self.rightInset);
}

#pragma mark - Setters

- (void)setLineColor:(UIColor *)lineColor
{
    [self setNeedsDisplay];
    
    self.separatorLine.backgroundColor = lineColor;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    [self setNeedsDisplay];
    
    self.leftInset = separatorInset.left;
    self.rightInset = separatorInset.right;
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    // block super's implementation
}

- (void)setAccessoryView:(UIView *)accessoryView
{
    // block super's implementation
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    // block super's implementation
}

- (void)setIsAccessibilityElement:(BOOL)isAccessibilityElement
{
    // block super's implementation
}

- (void)setAccessibilityElementsHidden:(BOOL)accessibilityElementsHidden
{
    // block super's implementation
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat separatorWidth = (CGRectGetWidth(self.frame) -
                              self.leftInset - self.rightInset);
    
    [self.separatorLine setFrame:
     CGRectIntegral(CGRectMake(self.leftInset, 0, separatorWidth,
                               CGRectGetHeight(self.bounds)))];
}

@end
