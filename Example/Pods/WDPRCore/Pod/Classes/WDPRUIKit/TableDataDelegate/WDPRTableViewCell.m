//
//  WDPRTableViewCell.m
//  WDPR
//
//  Created by Rodden, James on 9/26/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import <QuartzCore/QuartzCore.h>

// DO NOT CHANGE W/O DESIGN APPROVAL!!!
enum 
{
    kEdgeInset = 16,
    bubbleStyleOuterInset = 10,
};

#define cellBorderColor         [UIColor colorWithHexValue:0xbfbfbf]
#define selectionFillColor      [UIColor colorWithHexValue:0xf7f9fb]
#define defaultSeparatorColor   [UIColor colorWithHexValue:0xc8c7cc]

#define defaultSeparatorHeight  1.f / [UIScreen mainScreen].scale

#pragma mark -

@interface WDPRTableViewCell ()
{
    BOOL _useAutolayout;
    UIImageView* _mainImageView;
    UILabel* _primaryTextLabel;
    UILabel* _secondaryTextLabel;
    
    WDPRTableViewCellSelectionStyle _selectionStyle;
}

@property (nonatomic) BOOL hasImageView;
@property (nonatomic) BOOL hasTextLabel;
@property (nonatomic) BOOL hasDetailTextLabel;

@property (nonatomic) NSArray* extraTextLabels;
@property (nonatomic) NSArray* extraDetailTextLabels;

@property (nonatomic, copy) UIColor* backgroundColor;
@property (nonatomic) WDPRTableViewCellStyle cellStyle; // WDPRCellStyle
@property (nonatomic) WDPRTableViewCellSelectionStyle selectionStyle;

@property (nonatomic) UIView* separatorView;

@end

#pragma mark -

@interface WDPRTableCellButton : WDPRTableViewCell
{
    UIButton* _button;
}
@end

@interface WDPRTableCellFloatLabel : WDPRTableViewCell
{
    BOOL _isEditing;
    UIView* _bottomLine;
}
@end

@interface WDPRTableCellWithBubble : WDPRTableViewCell
{
    UILabel* _extraTextLabel;
}
@end

@interface WDPRTableViewCellCenterAligned : WDPRTableViewCell
@end

@interface WDPRTableViewCellLeftLeftAligned : WDPRTableViewCell
@end

@interface WDPRTableViewCellLeftLeftAutoSized : WDPRTableViewCellLeftLeftAligned
@end

@interface WDPRTableViewCellSubtitleBelowImage : WDPRTableViewCell
@end

#pragma mark -

@implementation WDPRTableViewCell

- (void)drawRect:(CGRect)rect
{
    [self.subviews[0] setBackgroundColor:UIColor.clearColor];

    [super drawRect:rect];
    
    if (![self isKindOfClass:WDPRTableCellButton.class] &&
        !(self.bubbleType & WDPRTableViewCellBubbleNoFrame))
    {
        UIBezierPath* border = self.borderPath;
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIGraphicsPushContext(context);
        
        // TODO: the border should be inserted as a view in self
        UIColor* backgroundColor =
        ((![self.backgroundColor 
            isEqual:UIColor.clearColor] && 
          (self.selectionStyle >
                  WDPRTableViewCellSelectionStyleNone) &&
          (self.isSelected || self.isHighlighted)) ?
         selectionFillColor : self.backgroundColor);
        
        // first draw background
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        
        if (border) [border fill];
        else CGContextFillRect(context, self.bounds);
        
        if (border)
        {
            // next draw the frame
            CGContextSetStrokeColorWithColor(context, cellBorderColor.CGColor);
            
            [border stroke];
        }
        
        UIGraphicsPopContext();
    }
}

#pragma mark -

- (UIButton*)button
{
    return nil;
}

- (UIBezierPath*)borderPath
{
    UIBezierPath* borderPath = nil;
    
    if (self.styleGuideAdjustments &&
        self.bubbleType != WDPRTableViewCellBubbleNone)
    {
        UIRectCorner roundedCorners = 0;
        
        CGRect frame = self.bounds;
        
        if (!(self.bubbleType & WDPRTableViewCellBubbleNoInset))
        {
            frame = CGRectInset(frame, 
                                bubbleStyleOuterInset, 0);
        }
        
        if (self.bubbleType & WDPRTableViewCellBubbleTop)
        {
            frame.origin.y++;
            frame.size.height--;
            roundedCorners |= (UIRectCornerTopLeft |
                               UIRectCornerTopRight);
        }
        
        if (self.bubbleType & WDPRTableViewCellBubbleBottom)
        {
            frame.size.height--;
            roundedCorners |= (UIRectCornerBottomLeft |
                               UIRectCornerBottomRight);
        }
        
        borderPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                           byRoundingCorners:roundedCorners
                                                 cornerRadii:CGSizeMake(2, 2)];
    }
    
    return borderPath;
}

- (UIImageView*)imageView
{
    UIImageView* imageView;
    
    if (!self.useAutolayout)
    {
        imageView = super.imageView;
        _mainImageView.hidden = YES;
    }
    else
    {
        if (!_mainImageView)
        {
            _mainImageView = [[UIImageView alloc] 
                              initWithFrame:CGRectZero];
            [self.contentView addSubview:_mainImageView];
        }
        
        _mainImageView.hidden = NO;
        imageView = _mainImageView;
    }
    
    self.hasImageView = (imageView != nil);
    return imageView;
}

- (UILabel*)textLabel
{
    UILabel* textLabel;
    
    if (!self.useAutolayout)
    {
        textLabel = super.textLabel;
        _primaryTextLabel.hidden = YES;
    }
    else
    {
        if (!_primaryTextLabel)
        {
            _primaryTextLabel = [[UILabel alloc] 
                                 initWithFrame:CGRectZero];
            [self.contentView addSubview:_primaryTextLabel];
        }
        
        _primaryTextLabel.hidden = NO;
        textLabel = _primaryTextLabel;
    }
    
    self.hasTextLabel = (textLabel != nil);
    return textLabel;
}

- (NSArray*)textLabels
{

    NSArray* textLabels = nil;
    UILabel* textLabel = self.textLabel;
    if (textLabel)
    {
        textLabels = @[textLabel];
    }
    return (!self.extraTextLabels.count ? textLabels :
            [textLabels arrayByAddingObjectsFromArray:self.extraTextLabels]);
}

- (UILabel*)detailTextLabel
{
    UILabel* detailTextLabel;
    
    if (!self.useAutolayout)
    {
        _secondaryTextLabel.hidden = YES;
        detailTextLabel = super.detailTextLabel;
    }
    else
    {
        if (!_secondaryTextLabel)
        {
            _secondaryTextLabel = [[UILabel alloc] 
                                   initWithFrame:CGRectZero];
            [self.contentView addSubview:_secondaryTextLabel];
        }
        
        _secondaryTextLabel.hidden = NO;
        detailTextLabel = _secondaryTextLabel;
    }

    self.hasDetailTextLabel = (detailTextLabel != nil);
    return detailTextLabel;
}

- (NSArray*)detailTextLabels
{
    NSArray* detailTextLabels = nil;
    UILabel* detailTextLabel = self.detailTextLabel;
    if (detailTextLabel)
    {
        detailTextLabels = @[detailTextLabel];
    }
    return (!self.extraDetailTextLabels.count ? detailTextLabels :
            [detailTextLabels arrayByAddingObjectsFromArray:self.extraDetailTextLabels]);
}

- (UILabel*)extraTextLabel
{
    return nil;
}

#ifndef __clang_analyzer__ // Suppress the following warning
/*
The Objective-C class 'WDPRTableViewCell', which is derived from class 'UITableViewCell',
    defines the instance method 'selectionStyle' whose return type is 
    'WDPRTableViewCellSelectionStyle'.  A method with the same name
    (same selector) is also defined in class 'UITableViewCell' and has 
    a return type of 'UITableViewCellSelectionStyle'.  These two types 
    are incompatible, and may result in undefined behavior for clients of these classes
 */
// This is an intentional fake-out of the UITableViewCell property, we overload it to support our own cellStyles
- (WDPRTableViewCellSelectionStyle)selectionStyle
{
    return _selectionStyle;
}
#endif

- (BOOL)supportsAutolayout
{
    switch (self.cellStyle)
    {
        default: return NO;
            
        // this is only needed for the native styles
        case UITableViewCellStyleSubtitle: return YES;
    }
}

- (UILabel*)textLabelAtIndex:(NSUInteger)index
{
    UILabel* label = self.textLabel;
    
    if (index == 0)
    {
        return label;
    }
    else while (index > self.extraTextLabels.count)
    {
        label = [[UILabel alloc] 
                 initWithFrame:CGRectZero];
        
        [self setExtraTextLabels:
         [(_extraTextLabels ?:
           @[]) arrayByAddingObject:label]];

        [self.contentView addSubview:label];
        label.tag = self.extraTextLabels.count;
        
        label.font = self.textLabel.font;
        label.textColor = self.textLabel.textColor;
    }
    
    return self.extraTextLabels[index-1];
}

- (NSUInteger)numberOfTextLabels
{
    return self.extraTextLabels.count + 1;
}

- (UILabel*)detailTextLabelAtIndex:(NSUInteger)index
{
    UILabel* label = self.detailTextLabel;
    
    if (index == 0)
    {
        return label;
    }
    else while (index > self.extraDetailTextLabels.count)
    {
        label = [[UILabel alloc] 
                 initWithFrame:CGRectZero];
        
        [self setExtraDetailTextLabels:
         [(_extraDetailTextLabels ?: 
           @[]) arrayByAddingObject:label]];
        
        [self.contentView addSubview:label];
        label.tag = self.extraDetailTextLabels.count;
        
        label.font = self.detailTextLabel.font;
        label.textColor = self.detailTextLabel.textColor;
    }
    
    return self.extraDetailTextLabels[index-1];
}

- (BOOL)styleGuideAdjustments
{
    return (self.bubbleType != WDPRTableViewCellBubbleNone);
}

- (void)setShowSeparator:(BOOL)showSeparator
{
    [self setNeedsLayout];
    
    if (showSeparator && !self.separatorView)
    {
        self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        self.separatorView.backgroundColor = defaultSeparatorColor;
        
        [self.contentView addSubviews:@{@"separator":self.separatorView}
    withVisualConstraints:
         @[[NSString stringWithFormat:@"V:[separator(%f)]|",
            defaultSeparatorHeight],
           [NSString stringWithFormat:@"H:|-(%f)-[separator]-(%f)-|",
            self.separatorInset.left, self.separatorInset.right]]];
    }
    
    self.separatorView.hidden = !showSeparator;
}

- (BOOL)showSeparator
{
    return (self.separatorView && !self.separatorView.hidden);
}

- (UILabel*)auxiliaryAccessoryLabel
{
    UILabel* auxiliaryAccessoryLabel = (id)_auxiliaryAccessoryView;
    
    if (!auxiliaryAccessoryLabel)
    {
        [self setAuxiliaryAccessoryView:
         [[UILabel alloc] initWithFrame:CGRectZero]];
        
        auxiliaryAccessoryLabel = (id)_auxiliaryAccessoryView;
        
        auxiliaryAccessoryLabel.numberOfLines = 0;
        auxiliaryAccessoryLabel.font = UIFont.wdprFontStyleC2;
        auxiliaryAccessoryLabel.textAlignment = NSTextAlignmentRight;
        auxiliaryAccessoryLabel.textColor = UIColor.wdprDarkBlueColor;
        auxiliaryAccessoryLabel.highlightedTextColor = UIColor.whiteColor;
    }
    
    return ([auxiliaryAccessoryLabel
             isKindOfClass:UILabel.class] ? auxiliaryAccessoryLabel : nil);
}

// depricated 12/23/14
//- (void)autolayoutLabels
//{
//    if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
//    {
//        NSAttributedString *tempString =
//        [[NSAttributedString alloc] initWithString:self.detailTextLabel.text
//                                        attributes:@{NSFontAttributeName: self.detailTextLabel.font ?: [UIFont wdprFontStyleC2]}];
//        CGSize tempDetailSize =
//        [tempString boundingRectWithSize:CGSizeMake(self.detailTextLabel.frame.size.width - 1, NSIntegerMax)
//                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                 context:nil].size; // Subtracts one to clean up any antialiasing sizing
//
//        CGRect detailTextLabelFrame = self.detailTextLabel.frame;
//        detailTextLabelFrame.size.height = tempDetailSize.height;
//        self.detailTextLabel.frame = CGRectIntegral(detailTextLabelFrame);
//    }
//}

- (WDPRTableViewCell*)asWDPRTableViewCell
{
    return self;
}

#pragma mark -

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.hidden = (CGRectGetHeight(frame) == 0);
}

- (void)setSelectionStyle:(WDPRTableViewCellSelectionStyle)selectionStyle
{
    _selectionStyle = selectionStyle;
    
    super.selectionStyle = ((selectionStyle !=
            WDPRTableViewCellSelectionStyleLogicalOnly) ?
                            selectionStyle : UITableViewCellSelectionStyleNone);
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    super.accessoryType = accessoryType;
    
    if (self.styleGuideAdjustments)
    {
        [self setAccessoryView:
         (accessoryType == UITableViewCellAccessoryDisclosureIndicator) ?
         [[UIImageView alloc] initWithImage:
          [WDPRIcon imageOfIcon:WDPRIconRightCaret 
                      withColor:[UIColor colorWithHexValue:0xD7D7D7] 
                        andSize:CGSizeMake(8, 13)]] : nil];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor.copy;
    
    [super setBackgroundColor:
     !self.styleGuideAdjustments ? 
             backgroundColor : UIColor.clearColor];
}

- (void)setLeftAccessoryView:(UIView *)leftAccessoryView
{
    if (_leftAccessoryView != leftAccessoryView)
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
        
        if (self.contentView == 
            _leftAccessoryView.superview)
        {
            [_leftAccessoryView removeFromSuperview];
        }
        
        _leftAccessoryView = leftAccessoryView;
        
        if (leftAccessoryView)
        {
            [self.contentView addSubview:leftAccessoryView];
        }
    }
}

- (void)setAuxiliaryAccessoryView:(UIView *)accessoryView
{
    if (_auxiliaryAccessoryView != accessoryView)
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
        
        if (self.contentView == 
            _auxiliaryAccessoryView.superview)
        {
            [_auxiliaryAccessoryView removeFromSuperview];
        }
        
        _auxiliaryAccessoryView = accessoryView;
        
        if (accessoryView)
        {
            [self.contentView addSubview:accessoryView];
        }
    }
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    onExitFromScope
    (^{
        if (self.postLayoutBlock)
        {
            self.postLayoutBlock();
        }
    });
    
    if (self.useAutolayout)
    {
        [self relayoutSubviews];
        return;
    }
    
    if (self.styleGuideAdjustments && 
        !(self.bubbleType & WDPRTableViewCellBubbleNoInset))
    {
        // DO NOT CHANGE W/O DESIGN APPROVAL!!!
        enum { innerInset = 9, outerInset = bubbleStyleOuterInset };
        
        if (!self.accessoryView && 
            (self.accessoryType == UITableViewCellAccessoryNone))
        {
            [self.contentView setFrame:
             CGRectInset(self.contentView.frame, outerInset, 0)];
        }
        else
        {
            [self.contentView setFrame:
             CGRectOffsetAndShrink(self.contentView.frame, outerInset, 0)];
        }
        
        if (self.hasImageView && 
            !CGSizeEqualToSize(CGSizeZero, self.imageView.frame.size))
        {
            const CGFloat delta = 
            (innerInset - self.imageView.frame.origin.x);
            
            [self.imageView setFrame:
             CGRectOffset(self.imageView.frame, delta, 0)];
        
            if (self.hasTextLabel && self.textLabel.text.length)
            {
                [self.textLabel setFrame:
                 CGRectOffsetAndShrink(self.textLabel.frame, delta, 0)];
                //SLING-19209/21070/20398: Shrink frame's width without changing the offset, to cover edge case of label exceeding the background's border
                //The "-4" corresponds to the width of the bubble outline plus some inset in order to avoid overlapping of text over the bubble's edge
                [self.textLabel setFrame:
                 CGRectGrow(self.textLabel.frame, -4, CGRectMaxXEdge)];
            }
            
            if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
            {
                [self.detailTextLabel setFrame:
                 CGRectOffsetAndShrink(self.detailTextLabel.frame, delta, 0)];
            }
        }
        else if (self.hasTextLabel && self.textLabel.text.length)
        {
            const CGFloat delta = 
            (innerInset - self.textLabel.frame.origin.x);
            
            if (self.textLabel.textAlignment != NSTextAlignmentCenter)
            {
                [self.textLabel setFrame:
                 CGRectOffsetAndShrink(self.textLabel.frame, delta, 0)];
            }
            else
            {
                self.textLabel.frame = self.contentView.bounds;
            }
            
            if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
            {
                if ((self.cellStyle == WDPRTableCellStyleSubtitleBelowImage) ||
                    (self.cellStyle == WDPRTableCellStyleSubtitleRightOfImage))
                {
                    // offset begins with origin 0,0 due to bounds
                    [self.detailTextLabel setFrame:
                     CGRectOffset(self.detailTextLabel.bounds, 
                                  CGRectGetMinX(self.textLabel.frame),
                                  CGRectGetMinY(self.detailTextLabel.frame))];

                    [self.detailTextLabel setFrame:
                     CGRectGrow(self.detailTextLabel.frame, 
                                -CGRectGetMinX(self.textLabel.frame), CGRectMaxXEdge)];
                }
                else
                {
                    CGRect detailTextFrame = 
                    CGRectOffsetAndShrink(self.detailTextLabel.frame, delta, 0);
                    
                    CGFloat offset = (detailTextFrame.size.width - 
                                      (self.contentView.frame.size.width - 
                                       innerInset - detailTextFrame.origin.x));
                    
                    self.detailTextLabel.frame = CGRectOffset(detailTextFrame, -offset, 0);
                }
            }
        }
        else if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
        {
            [self.detailTextLabel setFrame:
             CGRectOffsetAndShrink(self.detailTextLabel.frame, innerInset - 
                                   self.detailTextLabel.frame.origin.x, 0)];
        }

        if (self.accessoryView)
        {
            CGRect contentFrame = self.contentView.frame;
            CGRect accessoryViewFrame = self.accessoryView.frame;
            
            const CGFloat delta = (self.bounds.size.width - 
                                   (innerInset + outerInset) - 
                                   accessoryViewFrame.origin.x - 
                                   accessoryViewFrame.size.width);
            
            contentFrame.size.width += delta;
            self.contentView.frame = contentFrame;
            self.accessoryView.frame = CGRectOffset(accessoryViewFrame, delta, 0);
            
            if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
            {
                if (self.cellStyle != WDPRTableCellStyleSubtitleRightOfImage)
                {
                    [self.detailTextLabel setFrame:
                     CGRectOffset(self.detailTextLabel.frame, delta, 0)];
                }     
                else if (self.hasTextLabel && self.textLabel.text.length)
                {
                    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
                    detailTextLabelFrame.origin.x = self.textLabel.frame.origin.x;
                    self.detailTextLabel.frame = detailTextLabelFrame;
                }
            }
        }
    }
    
    if (self.leftAccessoryView)
    {
        // hack-workaround for missing leftAccessoryViews
        [self.contentView addSubview:self.leftAccessoryView];
        
        CGRect leftAccessoryFrame =
        CGRectOffset(self.leftAccessoryView.bounds, kHorizontalInset, 
                     (self.contentView.bounds.size.height -
                      self.leftAccessoryView.bounds.size.height)/2);
        
        leftAccessoryFrame = CGRectIntegral(leftAccessoryFrame);
        leftAccessoryFrame.size = self.leftAccessoryView.frame.size;
        self.leftAccessoryView.frame = leftAccessoryFrame;
        
        if (self.hasImageView && 
            !CGSizeEqualToSize(CGSizeZero, self.imageView.frame.size))
        {
            [self.imageView setFrame:
             CGRectIntegral(CGRectOffset(self.imageView.frame, 
                                         CGRectGetMaxX(leftAccessoryFrame), 0))];
        }
        
        if (self.hasTextLabel && self.textLabel.text.length)
        {
            CGRect textLabelFrame = 
            CGRectOffset(self.textLabel.frame, 
                         CGRectGetMaxX(leftAccessoryFrame), 0);
                            
            if (CGRectGetMaxX(textLabelFrame) > 
                (self.contentView.frame.size.width - kHorizontalInset))
            {
                textLabelFrame.size.width -= 
                    (CGRectGetMaxX(textLabelFrame) - 
                     (self.contentView.frame.size.width - kHorizontalInset));
            }
            
            CGFloat textLabelHeight = CGRectGetHeight(textLabelFrame);
            textLabelFrame.size.height = (self.textLabel.attributedText.length ?
                                          [self.textLabel.attributedText
                                           heightWithBoundingWidth:textLabelFrame.size.width] :
                                          textLabelHeight);

            //moving text label to compensate the height difference
            textLabelFrame.origin.y += (textLabelHeight - CGRectGetHeight(textLabelFrame)) / 2;
            
            self.textLabel.frame = CGRectIntegral(textLabelFrame);
        }
        
        if ((self.cellStyle != WDPRTableCellStyleLeftRightAligned) &&
            self.hasDetailTextLabel && self.detailTextLabel.text.length)
        {
            CGRect detailTextLabelFrame =
            CGRectOffset(self.detailTextLabel.frame, 
                         CGRectGetMaxX(leftAccessoryFrame), 0);
            
            if (CGRectGetMaxX(detailTextLabelFrame) > CGRectGetWidth(self.contentView.frame))
            {
                // fix the frame so it doesn't go out of bounds
                CGFloat delta = CGRectGetMaxX(detailTextLabelFrame) - CGRectGetWidth(self.contentView.frame);
                detailTextLabelFrame = CGRectGrow(detailTextLabelFrame, -delta, CGRectMaxXEdge);
            }
            
            if (self.textLabel.text.length || self.textLabel.attributedText.length)
            {
                detailTextLabelFrame.origin.y = CGRectGetMaxY(self.textLabel.frame);
            }
            
            self.detailTextLabel.frame = CGRectIntegral(detailTextLabelFrame);
        }
    }
    
    if (self.auxiliaryAccessoryView)
    {
        if (CGRectEqualToRect(CGRectZero, self.auxiliaryAccessoryLabel.frame))
        {
            [self.auxiliaryAccessoryLabel sizeToFit];
        }
        
        CGRect accessoryViewFrame = self.auxiliaryAccessoryView.bounds;
        
        accessoryViewFrame.origin.x =
        (self.contentView.bounds.size.width -
         accessoryViewFrame.size.width - kHorizontalInset);
        
        accessoryViewFrame.origin.y = (self.contentView.
                                       bounds.size.height -
                                       accessoryViewFrame.size.height)/2;
        
        accessoryViewFrame = CGRectIntegral(accessoryViewFrame);
        accessoryViewFrame.size = self.auxiliaryAccessoryView.frame.size;
        self.auxiliaryAccessoryView.frame = accessoryViewFrame;
        
        if (self.hasTextLabel && self.textLabel.text.length &&
            (self.cellStyle != WDPRTableCellStyleWithBubble) &&
            (self.cellStyle != WDPRTableCellStyleLeftLeftAligned) &&
            (self.cellStyle != WDPRTableCellStyleLeftRightAligned) &&
            (self.cellStyle != WDPRTableCellStyleRightLeftAligned))
        {
            CGRect textLabelFrame = self.textLabel.frame;
            
            if (CGRectGetMaxX(textLabelFrame) >
                (CGRectGetMinX(accessoryViewFrame) + kHorizontalInset))
            {
                textLabelFrame.size.width -= (kHorizontalInset +
                                              accessoryViewFrame.size.width);
                
                self.textLabel.frame = CGRectIntegral(textLabelFrame);
            }
        }
        
        if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
        {
            CGRect detailTextLabelFrame = self.detailTextLabel.frame;
            
            if (CGRectGetMaxX(detailTextLabelFrame) >
                (CGRectGetMinX(accessoryViewFrame) + kHorizontalInset))
            {
                detailTextLabelFrame.size.width -= (kHorizontalInset +
                                                    accessoryViewFrame.size.width);
            }
            
            if (self.textLabel.text.length || self.textLabel.attributedText.length)
            {
                CGRect textLabelFrame = self.textLabel.frame;
                
                CGFloat textLabelHeight = CGRectGetHeight(textLabelFrame);
                
                textLabelFrame.size.height = (self.textLabel.attributedText.length ?
                                              [self.textLabel.attributedText
                                               heightWithBoundingWidth:textLabelFrame.size.width] :
                                              textLabelHeight);
                
                //moving text label to compensate the height difference
                textLabelFrame.origin.y += (textLabelHeight - CGRectGetHeight(textLabelFrame)) / 2;
                
                self.textLabel.frame = CGRectIntegral(textLabelFrame);
                
                detailTextLabelFrame.origin.y = CGRectGetMaxY(textLabelFrame);
            }
            
            self.detailTextLabel.frame = CGRectIntegral(detailTextLabelFrame);
            
        }
    }

// depricated 12/23/14
//    if (self.autosizeLabels)
//    {
//        [self autolayoutLabels];
//    }
//
//    if (self.shouldStandardizeLabels)
//    {
//        [self standardizeLabels];
//    }
    
    for (NSArray* extras in 
         @[@[self.textLabel ?: NSNull.null,
             self.extraTextLabels ?: @[]], 
           @[self.detailTextLabel ?: NSNull.null,
             self.extraDetailTextLabels ?: @[]]])
    {
        UILabel* reference = extras.firstObject;
        NSArray* extraLabels = extras.lastObject;
        
        if (extraLabels.count && 
            [reference isKindOfClass:UILabel.class])
        {
            CGRect frame = 
            CGRectInset(self.contentView.bounds, 
                        CGRectGetMinX(reference.frame), 0);
            
            frame.origin.x = CGRectGetMinX(reference.frame);
            frame.origin.y = CGRectGetMinY(reference.frame);
            frame.size.height = CGRectGetHeight(reference.frame);
            
            frame.size.width /= extraLabels.count + 1;
            
            if (CGRectGetWidth(frame) <
                CGRectGetWidth(reference.frame))
            {
                reference.frame = frame;
            }
            
            for (UIView* extraLabel in extraLabels)
            {
                [extraLabel setFrame:frame = 
                 CGRectOffset(frame, CGRectGetWidth(frame), 0)];
            }
        }
    }
}

// depricated 12/23/14
//- (void)standardizeLabels
//{
//    if (!self.hasTextLabel || !self.textLabel.text.length)
//    {
//        return;
//    }
//    
//    [self.textLabel sizeToFit];
//    
//    if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
//    {
//        CGRect detailTextLabelFrame = self.detailTextLabel.frame;
//        detailTextLabelFrame.origin.y = CGRectGetMaxY(self.textLabel.frame);
//        self.detailTextLabel.frame = detailTextLabelFrame;
//    }
//    
//    CGFloat maxTextLabelHeight =
//    (self.contentView.frame.size.height - 
//     self.detailTextLabel.frame.size.height - offset*2);
//    
//    if (self.textLabel.frame.size.height > maxTextLabelHeight)
//    {
//        CGRect textLabelFrame = self.textLabel.frame;
//        textLabelFrame.size.height = maxTextLabelHeight;
//        self.textLabel.adjustsFontSizeToFitWidth = YES;
//        self.textLabel.frame = textLabelFrame;
//    }
//    
//    CGFloat totalLabelHeight = self.textLabel.frame.size.height;
//    
//    if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
//    {
//        totalLabelHeight += self.detailTextLabel.frame.size.height;
//    }
//    
//    CGRect textLabelFrame = self.textLabel.frame;
//    textLabelFrame.origin.y = (self.contentView.frame.size.height - totalLabelHeight)/2;
//    self.textLabel.frame = CGRectIntegral(textLabelFrame);
//    
//    if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
//    {
//        CGRect detailTextLabelFrame = self.detailTextLabel.frame;
//        detailTextLabelFrame.origin.y = CGRectGetMaxY(self.textLabel.frame);
//        self.detailTextLabel.frame = detailTextLabelFrame;
//    }
//}

- (void)setupConstraints
{
    switch (self.cellStyle)
    {
        default: break;
            
        // only needed for native styles
        case UITableViewCellStyleSubtitle:
        {   if (self.contentView.constraints.count)
            {
                [self.contentView removeConstraints:self.contentView.constraints];
            }
            
            [self.contentView
             addSubviews:@{@"imageView" : self.imageView,
                           @"textLabel" : self.textLabel,
                           @"detailLabel" : self.detailTextLabel
                           } 
             withVisualConstraints:
             @[[NSString stringWithFormat:
                @"V:|-%d-[imageView]-%d-|", kEdgeInset, kEdgeInset], 
               
               [NSString stringWithFormat:
                @"V:|-%d-[textLabel][detailLabel]-%d-|", kEdgeInset, kEdgeInset], 
               
               [NSString stringWithFormat:
                @"H:|-%d-[imageView]-%d-[textLabel]-%d-|", kEdgeInset, kEdgeInset, kEdgeInset],
               
               [NSString stringWithFormat:
                @"H:|-%d-[imageView]-%d-[detailLabel]-%d-|", kEdgeInset, kEdgeInset, kEdgeInset]]];
        }   break;
    }
}

- (void)relayoutSubviews
{
    __block BOOL relayout = NO;
    NSParameterAssert(self.useAutolayout);
    
    // see "Intrinsic Content Size of Multi-Line Text" section in
    // https://www.objc.io/issues/3-views/advanced-auto-layout-toolbox/
    
    onExitFromScope
    (^{
        if (relayout) [super layoutSubviews];
    });
    
    if (self.hasTextLabel &&
        !self.textLabel.preferredMaxLayoutWidth)
    {
        relayout = YES;
        
        [self.textLabel 
         setPreferredMaxLayoutWidth:
         CGRectGetWidth(self.textLabel.frame)];
    }
    
    if (self.hasDetailTextLabel &&
        !self.detailTextLabel.preferredMaxLayoutWidth)
    {
        relayout = YES;
        
        [self.detailTextLabel 
         setPreferredMaxLayoutWidth:
         CGRectGetWidth(self.detailTextLabel.frame)];
    }
}

- (void)prepareForReuse
{
    _touchedSubview = nil;
    [super prepareForReuse];
    self.hidden = NO;
    self.accessibilityElementsHidden = NO;
}

- (void)removeExtraLabels
{
    for (NSArray* extras in 
         @[self.extraTextLabels ?: @[], 
           self.extraDetailTextLabels ?: @[]])
    {
        for (UIView* extraLabel in extras)
        {
            [extraLabel removeFromSuperview];
        }
    }
    
    self.extraTextLabels = nil;
    self.extraDetailTextLabels = nil;
}

- (void)turnOffSelectionStyle:(BOOL)animated
{
    [super setSelectionStyle:
     UITableViewCellSelectionStyleNone];
    
    if (animated &&
        (self.isSelected || self.isHighlighted))
    {
        UIImageView* selectionLayer;
        [self addSubview:selectionLayer =
         [[UIImageView alloc] initWithFrame:self.bounds]];
        
        [self sendSubviewToBack:selectionLayer];
        
        UIBezierPath* borderPath = self.borderPath;
        
        if (!borderPath)
        {
            selectionLayer.backgroundColor = selectionFillColor;
        }
        else
        {
            selectionLayer.backgroundColor = UIColor.clearColor;
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, selectionFillColor.CGColor);
            [borderPath fill];
            
            CGContextSetStrokeColorWithColor(context, cellBorderColor.CGColor);
            [borderPath stroke];
            
            selectionLayer.image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
        }
        
        [UIView
         animateWithDuration:0.2 animations:^{ selectionLayer.alpha = 0; }
         completion:^(BOOL finished){ [selectionLayer removeFromSuperview]; }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.isSelected != selected)
    {
        WDPRTableViewCellSelectionStyle
        selectionStyle = self.selectionStyle;
        
        [self turnOffSelectionStyle:animated];
        [super setSelected:selected animated:animated];
        
        self.selectionStyle = selectionStyle;
        [self setNeedsDisplay];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.isHighlighted != highlighted)
    {
        WDPRTableViewCellSelectionStyle
        selectionStyle = _selectionStyle;
        
        [self turnOffSelectionStyle:animated];
        [super setHighlighted:highlighted animated:animated];
        
        self.selectionStyle = selectionStyle;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchedSubview = nil;
    [super touchesEnded:touches withEvent:event];
    
    if (touches.count == 1)
    {
        CGPoint touchPoint = [touches.anyObject 
                              locationInView:self.contentView];
        
        for (UIView* subview in self.contentView.subviews)
        {
            if (CGRectContainsPoint(subview.frame, touchPoint))
            {
                _touchedSubview = subview;
                break;
            }
        }
    }
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // This is the class cluster design pattern
    // used in various parts of Foundation and UIKit
    // in which the return type and object from an
    // init method may be different than self.
    
    // This pattern allows for swapping in an
    // instance of a private implementation class.
    
    WDPRTableViewCellStyle wdprCellStyle = (NSInteger)style;
    
    switch (wdprCellStyle)
    {
        case WDPRTableCellStylePlainButton:
        case WDPRTableCellStyleDeleteButton:
        case WDPRTableCellStyleStandardButton:
        case WDPRTableCellStyleSolidGrayButton:
        case WDPRTableCellStylePrimaryButton:
        case WDPRTableCellStyleSecondaryButton:
        case WDPRTableCellStyleTertiaryButton:
        {   self = [[WDPRTableCellButton alloc]
                    initWithStyle:style
                    reuseIdentifier:reuseIdentifier];
        }   break;
            
        case WDPRTableCellStyleCenterAligned:
        {   style = UITableViewCellStyleSubtitle;
            self = [[WDPRTableViewCellCenterAligned alloc]
                    initWithStyle:style reuseIdentifier:reuseIdentifier];
        }   break;
        
        case WDPRTableCellStyleLeftLeftAligned:
        {   style = UITableViewCellStyleValue1;
            self = [[WDPRTableViewCellLeftLeftAligned alloc]
                    initWithStyle:style reuseIdentifier:reuseIdentifier];
        }   break;
            
        case WDPRTableCellStyleLeftLeftAutoSized:
        {   style = UITableViewCellStyleValue1;
            self = [[WDPRTableViewCellLeftLeftAutoSized alloc]
                    initWithStyle:style reuseIdentifier:reuseIdentifier];
        }   break;
            
        case WDPRTableCellStyleSubtitleBelowImage:
        {   style = UITableViewCellStyleSubtitle;
            self = [[WDPRTableViewCellSubtitleBelowImage alloc]
                    initWithStyle:style reuseIdentifier:reuseIdentifier];
        }   break;
            
        case WDPRTableCellStyleWithBubble:
        {   style = UITableViewCellStyleValue1;
            self = [[WDPRTableCellWithBubble alloc]
                    initWithStyle:style reuseIdentifier:reuseIdentifier];
        }   break;
        
        case WDPRTableCellStyleFloatLabelField:
        {   style = UITableViewCellStyleSubtitle;
            self = [[WDPRTableCellFloatLabel alloc]
                    initWithStyle:style reuseIdentifier:reuseIdentifier];
        }   break;
            
        default:
        {   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        }   break;
    }
    
    if (self)
    {
        if (self.useAutolayout)
        {
            [self setupConstraints];
        }
        
        _cellStyle = wdprCellStyle;
        _backgroundColor = UIColor.whiteColor;
    }
    
    return self;
}

@end // @implementation WDPRTableViewCell

#pragma mark -

@implementation WDPRTableCellButton

- (UIButton*)button
{
    return _button;
}

- (UIImageView*)imageView
{
    return nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    enum { backgroundTag = 0xBAAC };

    [self.button setFrame:self.contentView.bounds];
    
    self.textLabel.hidden = YES;
    [self.button setTitle:self.textLabel.text 
                 forState:UIControlStateNormal];
    
    if (self.hasDetailTextLabel)
    {
        [self.detailTextLabel setFrame:
         CGRectOffset(self.button.frame, 0, 
                      CGRectGetMinY(self.detailTextLabel.frame))];
        
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (!(self.bubbleType & WDPRTableViewCellBubbleNoInset))
    {
        self.button.frame = CGRectInset(self.button.frame, kHorizontalInset, 0);
    }
    
    if (self.cellStyle == WDPRTableCellStyleStandardButton)
    {
//        // bah!! layer should be added inside init method, and
//        // simply resized here (or autosize itself), but API's don't work
//        [self.button.layer insertSublayer:
//         [MdxHelpers buttonGradient:self.button.bounds] atIndex:0];
//        //[self.button.layer.sublayers[0] setBounds:self.button.bounds];
    }
    
    [self sendSubviewToBack:self.button];
}

- (void)setSelectionStyle:(WDPRTableViewCellSelectionStyle)selectionStyle
{
    // do nothing, block super's implementation
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // do nothing, block super's implementation
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    WDPRTableViewCellStyle wdprCellStyle = (NSInteger)style;
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.isAccessibilityElement = NO;
        self.backgroundColor = UIColor.clearColor;
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Note: GradientView might work better
        if (wdprCellStyle == WDPRTableCellStyleSecondaryButton)
        {
            _button = [WDPRCallToActionButton secondaryButtonWithTitle:nil];
        }
        else if (wdprCellStyle == WDPRTableCellStyleTertiaryButton)
        {
            _button = [WDPRCallToActionButton tertiaryButtonWithTitle:nil];
        }
        else
        {
            _button = [WDPRCallToActionButton buttonWithTitle:nil];
        }

        //[UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.contentView insertSubview:_button atIndex:0];
        
        _button.clipsToBounds = YES;
        _button.layer.cornerRadius = 5;
        _button.layer.borderWidth = 0.5;
//        _button.layer.borderColor = [UIColor darkGrayColor].CGColor;

        _button.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleTopMargin);
        
        // add an overlay view to show during highlighting
        UIView* overlay;
        [_button addSubview:overlay =
         [[UIView alloc] initWithFrame:_button.bounds]];
        
        overlay.hidden = YES;
        overlay.layer.cornerRadius = _button.layer.cornerRadius;
        overlay.backgroundColor = [UIColor.blackColor
                                   colorWithAlphaComponent:0.25];
        overlay.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight);
        
        switch (wdprCellStyle)
        {
            default: break; // nothing to do
                
            case WDPRTableCellStylePlainButton:
            {   // per SLING-3392
                _button.layer.borderWidth = 0;
                _button.layer.cornerRadius = 2;
                _button.backgroundColor = UIColor.whiteColor;
            }   break;
                
            case WDPRTableCellStyleDeleteButton:
            {   _button.backgroundColor = UIColor.redColor;
            }   break;
                
            case WDPRTableCellStyleSolidGrayButton:
            {   _button.backgroundColor = UIColor.lightGrayColor;
            }   break;
            /*
            case WDPRTableCellStyleStandardButton:
            {   [_button.layer insertSublayer:
                 [MdxHelpers buttonGradient:_button.bounds] atIndex:0];
            }   break;//*/
        }
    }
    
    return self;
}

@end // @implementation WDPRTableCellButton

#pragma mark -

@implementation WDPRTableCellFloatLabel

- (UIView*)bottomLine
{
    return _bottomLine;
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (_isEditing != isEditing)
    {
        _isEditing = isEditing;
        
        self.bottomLine.backgroundColor = (isEditing ?
                                           UIColor.wdprBlueColor :
                                           [UIColor wdprLightGrayColor]);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect lineFrame = CGRectInset(self.contentView.bounds, 16, 0);
    
    CGFloat dyDetailLabel = (CGRectGetHeight(self.contentView.bounds) -
                             CGRectGetMaxY(self.detailTextLabel.frame));
    
    [self.detailTextLabel setFrame:CGRectOffset(self.detailTextLabel.frame,
                                                0, dyDetailLabel)];
    [self.bottomLine setFrame:
     CGRectIntegral(CGRectOffsetAndShrink(lineFrame, 0, 
                                          CGRectGetHeight(self.contentView.bounds) - 1))];
}

- (NSString*)accessibilityValue
{
    return self.shouldSetAccessibilityValue ? self.detailTextLabel.text : @"";
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) 
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:
         _bottomLine = [[UIView alloc] initWithFrame:CGRectZero]];
        
        _bottomLine.autoresizingMask = (UIViewAutoresizingFlexibleWidth | 
                                        UIViewAutoresizingFlexibleTopMargin);
        
        _bottomLine.backgroundColor = [UIColor wdprLightGrayColor];
        _bottomLine.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 1);
    }
    
    return self;
}

@end // @implementation WDPRTableCellFloatLabel

#pragma mark -

@implementation WDPRTableViewCellCenterAligned

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.useAutolayout) return;
    
    CGRect frame = self.bounds;
    
    if (self.auxiliaryAccessoryView)
    {
        CGRect auxAccessoryFrame =
        self.auxiliaryAccessoryView.frame;
        
        frame = CGRectGrow(frame, CGRectGetMaxX(frame) -
                           CGRectGetMinX(auxAccessoryFrame), 0);
    }
    
    if (self.hasTextLabel)
    {
        CGRect textLabelFrame = self.textLabel.frame;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.textLabel setFrame:
         CGRectGrow(textLabelFrame,
                    CGRectGetMaxX(frame) -
                    (CGRectGetMinX(textLabelFrame) +
                     CGRectGetMaxX(textLabelFrame)), CGRectMaxXEdge)];
    }
    
    if (self.hasDetailTextLabel)
    {
        CGRect detailTextLabelFrame = self.detailTextLabel.frame;
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.detailTextLabel setFrame:
         CGRectGrow(detailTextLabelFrame,
                    CGRectGetMaxX(frame) -
                    (CGRectGetMinX(detailTextLabelFrame) +
                     CGRectGetMaxX(detailTextLabelFrame)), CGRectMaxXEdge)];
    }
}

- (void)setupConstraints
{
    NSDictionary* labels = 
    @{
      @"textLabel" : self.textLabel,
      @"detailLabel" : self.detailTextLabel,
      };
    
    for (UILabel* label in labels.allValues)
    {
        NSDictionary* views = 
        @{ @"subview" : label,
           @"superview" : self.contentView, 
           };
        
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addConstraintsWithFormat:
         @"H:[subview(<=superview)]" metrics:nil views:views];
        
        [self.contentView 
         addConstraintsWithFormat:@"V:[superview]-(<=1)-[subview]"
         options:NSLayoutFormatAlignAllCenterX metrics:nil views:views];
    }
         
    [self.contentView addSubviews:labels withVisualConstraints:
     @[[NSString stringWithFormat:
        @"H:|-(>=%d)-[textLabel]-(>=%d)-|", kEdgeInset, kEdgeInset],
       
       [NSString stringWithFormat:
        @"H:|-(>=%d)-[detailLabel]-(>=%d)-|", kEdgeInset, kEdgeInset],
       
       [NSString stringWithFormat:
        @"V:|-%d-[textLabel][detailLabel]-%d-|", kEdgeInset, kEdgeInset]]];
}

- (NSString *)accessibilityLabel
{
    NSArray *labels = [self.textLabels arrayByAddingObjectsFromArray:self.detailTextLabels];
    NSArray *accessibilityLabels = [labels map:^NSString*(UILabel *label)
    {
        return label.accessibilityLabel;
    }];
    
    return [accessibilityLabels componentsJoinedByString:@" "];
}

- (BOOL)supportsAutolayout
{
    return YES;
}

@end

#pragma mark -

@implementation WDPRTableViewCellLeftLeftAligned

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.hasDetailTextLabel)
    {
        CGRect detailFrame = self.detailTextLabel.frame;
        
        if (!CGRectEqualToRect(detailFrame, CGRectZero))
        {
            // fixed offset, or midpoint?
            //enum { xPos = 120 }; /*// per creative
            const unsigned xPos = (self.contentView.
                                   bounds.size.width / 2);//*/
            const CGFloat delta = (detailFrame.origin.x - xPos);
            
            detailFrame.origin.x = xPos;
            detailFrame.size.width += delta;
            self.detailTextLabel.frame = detailFrame;
            self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        // depricated 12/23/14
//        [self autolayoutLabels];
    }
}

@end // @implementation WDPRTableViewCellLeftLeftAligned

#pragma mark -

@implementation WDPRTableViewCellLeftLeftAutoSized

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.hasDetailTextLabel)
    {
        CGRect detailFrame = self.detailTextLabel.frame;
        
        if (!CGRectEqualToRect(detailFrame, CGRectZero))
        {
            // fixed offset, or midpoint?
            //enum { xPos = 120 }; /*// per creative
            const unsigned xPos = (self.textLabel.frame.origin.x + self.textLabel.bounds.size.width + 10.0f);//*/
            const CGFloat delta = (detailFrame.origin.x - xPos);
            
            detailFrame.origin.x = xPos;
            detailFrame.size.width += delta;
            self.detailTextLabel.frame = detailFrame;
            self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
}

@end // @implementation WDPRTableViewCellLeftLeftAutoSized

#pragma mark -

@implementation WDPRTableViewCellSubtitleBelowImage

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.useAutolayout) return;
    
    CGRect textFrame = ((self.hasTextLabel && 
                         self.textLabel.text.length) ?
                        self.textLabel.frame : CGRectZero);
    
    CGRect imageFrame = (self.hasImageView ?
                         self.imageView.frame : CGRectZero);
    
    imageFrame.origin.y = textFrame.origin.y = 10;
    
    if (textFrame.size.height < imageFrame.size.height)
    {
        textFrame.origin.y += (imageFrame.size.height -
                               textFrame.size.height)/2;
    }
    else
    {
        imageFrame.origin.y += (textFrame.size.height -
                                imageFrame.size.height)/2;
    }
    
    if (self.hasTextLabel)
    {
        self.textLabel.frame = CGRectIntegral(textFrame);
    }
    
    if (self.hasImageView)
    {
        self.imageView.frame = CGRectIntegral(imageFrame);
    }
    
    if (self.hasDetailTextLabel)
    {   // this hasn't been tested w/o
        // imageView or w/leftAccessoryView
        CGRect detailFrame = self.detailTextLabel.frame;
        
        detailFrame.origin.x = imageFrame.origin.x;
        detailFrame.origin.y = MAX(CGRectGetMaxY(textFrame),
                                   CGRectGetMaxY(imageFrame))+ 5;
        
        detailFrame.size.width = (self.contentView.
                                  frame.size.width - 5 -
                                  detailFrame.origin.x);
        
        if (!self.detailTextLabel.attributedText)
        {
            CGSize size = CGSizeMake(detailFrame.size.width, 9999);
            CGRect textRect = [self.detailTextLabel.text boundingRectWithSize:size
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName:[UIFont wdprFontStyleC2]}
                                                                      context:nil];
            detailFrame.size = textRect.size;
        }
        
        self.detailTextLabel.frame = CGRectIntegral(detailFrame);
        self.detailTextLabel.backgroundColor = UIColor.clearColor;
    }
}

- (void)setupConstraints
{
    [self.contentView
     addSubviews:@{@"imageView" : self.imageView,
                   @"textLabel" : self.textLabel,
                   @"detailLabel" : self.detailTextLabel
                   } 
     withVisualConstraints:
     @[[NSString stringWithFormat:
        @"H:|-%d-[detailLabel]-%d-|", kEdgeInset, kEdgeInset],
       
       [NSString stringWithFormat:
        @"V:|-%d-[textLabel][detailLabel]-%d-|", kEdgeInset, kEdgeInset], 
       
       [NSString stringWithFormat:
        @"H:|-%d-[imageView]-%d-[textLabel]-%d-|", kEdgeInset, kEdgeInset, kEdgeInset],
       
       [NSString stringWithFormat:
        @"V:|-%d-[imageView]-%d-[detailLabel]-%d-|", kEdgeInset, kEdgeInset, kEdgeInset]]];
}

- (BOOL)supportsAutolayout
{
    return YES;
}

@end //@implementation WDPRTableViewCellSubtitleBelowImage

#pragma mark -

@implementation WDPRTableCellWithBubble

- (UILabel*)textLabel
{
    UILabel* textLabel = super.textLabel;
    textLabel.backgroundColor = UIColor.clearColor;
    
    return textLabel;
}

- (UILabel*)detailTextLabel
{
    UILabel* detailTextLabel = super.detailTextLabel;
    detailTextLabel.backgroundColor = UIColor.clearColor;
    
    return detailTextLabel;
}

- (UILabel*)extraTextLabel
{
    return _extraTextLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.hasDetailTextLabel)
    {
        CGRect detailFrame = self.detailTextLabel.frame;
        
        if (!CGRectEqualToRect(detailFrame, CGRectZero))
        {
            // fixed offset, or midpoint?
            //enum { xPos = 120 }; /*// per creative
            const unsigned xPos = (self.contentView.
                                   bounds.size.width / 2);//*/
            const CGFloat delta = (detailFrame.origin.x - xPos);
            
            detailFrame.origin.x = xPos;
            detailFrame.size.width += delta;
            self.detailTextLabel.frame = detailFrame;
            self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        [self autolayoutLabels];
    }
}

- (void)autolayoutLabels
{
    if (self.hasDetailTextLabel && self.detailTextLabel.text.length)
    {
        CGSize tempTextSize =
        [self.textLabel.attributedText boundingRectWithSize:CGSizeMake(self.textLabel.frame.size.width - 1, NSIntegerMax)
                                                          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                          context:nil].size; // Subtracts one to clean up any antialiasing sizing
        
        CGSize tempDetailSize =
        [self.detailTextLabel.attributedText boundingRectWithSize:CGSizeMake(self.detailTextLabel.frame.size.width - 1, NSIntegerMax)
                                                          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                          context:nil].size; // Subtracts one to clean up any antialiasing sizing
        
        CGFloat maxHeight = MAX( tempDetailSize.height, tempTextSize.height );
        CGFloat cellHeight = ([_extraTextLabel.text length]) ? maxHeight+10 : self.bounds.size.height;
        
        CGRect detailTextLabelFrame = self.detailTextLabel.frame;
        detailTextLabelFrame.size.height = MAX( maxHeight, cellHeight );
        detailTextLabelFrame.origin.y = (cellHeight - detailTextLabelFrame.size.height) / 2;
        self.detailTextLabel.frame = detailTextLabelFrame;
        
        CGRect textLabelFrame = self.textLabel.frame;
        textLabelFrame.size.height = maxHeight;
        textLabelFrame.origin.y = cellHeight/2 - maxHeight/2;
        self.textLabel.frame = textLabelFrame;
    }
}

- (UILabel*)textLabelAtIndex:(NSUInteger)index
{
    return ((index == 0) ? self.textLabel : nil);
}

- (UILabel*)detailTextLabelAtIndex:(NSUInteger)index
{
    return ((index == 0) ? self.detailTextLabel : nil);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        const CGFloat sideMargin = 10;
        CGRect frame = self.bounds;
        
        frame.size.width -= sideMargin * 2;
        frame.origin.x += sideMargin;
        
        self.backgroundColor = UIColor.clearColor;
        self.layer.borderWidth = 0.0f;
                
        UIView *bubbleView = [[UIView alloc] initWithFrame:frame];
        bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [self.backgroundView addSubview:bubbleView];
        [self.backgroundView sendSubviewToBack:bubbleView];
        
        bubbleView.backgroundColor = [UIColor wdprPaleGrayColor];
        bubbleView.layer.cornerRadius = 3;
        
        _extraTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalInset,
                                                                    self.textLabel.frame.origin.y + self.textLabel.bounds.size.height,
                                                                    self.bounds.size.width - kHorizontalInset*2,
                                                                    20)];
        _extraTextLabel.numberOfLines = 0;
        _extraTextLabel.font = [UIFont wdprFontStyleC2];
        _extraTextLabel.textColor = [UIColor whiteColor];
        _extraTextLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_extraTextLabel];
    }
    
    return self;
}

@end // @implementation WDPRTableCellWithBubble

#pragma mark -

@implementation WDPRTableViewCell (Autolayout)

- (BOOL)useAutolayout
{
    return (_useAutolayout && 
            self.supportsAutolayout);
}

- (void)setUseAutolayout:(BOOL)useIt
{
    if (_useAutolayout != useIt)
    {
        _useAutolayout = useIt;
        
        if (self.useAutolayout)
        {
            [self setupConstraints];
        }
        else 
        {
            [self.contentView removeConstraints:self.contentView.constraints];
        }
    }
}

@end // @@implementation WDPRTableViewCell (Autolayout)

#pragma mark -

@implementation UITableViewCell (WDPRTableViewCell)

- (UIImageView *)mainImageView
{
    return self.imageView;
}

- (UILabel *)primaryTextLabel
{
    return self.textLabel;
}

- (UILabel *)secondaryTextLabel
{
    return self.detailTextLabel;
}

- (WDPRTableViewCell*)asWDPRTableViewCell
{
    return nil;
}

@end // @interface UITableViewCell (WDPRTableViewCell)

