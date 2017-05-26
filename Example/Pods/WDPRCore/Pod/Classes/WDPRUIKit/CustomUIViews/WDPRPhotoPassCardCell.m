//
//  WDPRPhotoPassCardCell.m
//  Pods
//
//  Created by Cesar Rodriguez on 10/08/16.
//
//

#import "WDPRPhotoPassCardCell.h"

enum
{   // integer constants
    kEdgeInset = 16,
    kLabelVerticalSpacing = 5,
    kMinimumRowHeight = 120 + kEdgeInset*2 + 20*2,
    kWDPRCaretImageDimension = 12
};

#define kCornerRadius  2.5f

@interface WDPRPhotoPassCardCell ()

@property (nonatomic, strong) UIView* cardView;

@end

@implementation WDPRPhotoPassCardCell

+ (NSString*)reuseIdentifier
{
    return @"WDPRPhotopassCardCell";
}

+ (CGFloat)minimumRowHeight
{
    return kMinimumRowHeight;
}

- (void)customizeViews
{
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.textLabel.numberOfLines = 0;
    self.detailTextLabel.numberOfLines = 0;
    
    [self.textLabel applyStyle:WDPRTextStyleH3D];
    [self.detailTextLabel applyStyle:WDPRTextStyleC2G];
}

- (UIView *)cardView
{
    if (!_cardView)
    {
        _cardView = [UIView autolayoutView];
        
        _cardView.layer.cornerRadius = kCornerRadius;
        _cardView.layer.masksToBounds = YES;
        
        UIView *caretView = [self caretView];
        
        [_cardView addSubviews:@{
                 @"image":self.imageView,
                 @"text":self.textLabel,
                 @"detail":self.detailTextLabel,
                 @"caret" :caretView
            
         }
         withVisualConstraints:@[//Horizontal
                 [NSString stringWithFormat:
                                   @"H:|[image]|"],
                
                 [NSString stringWithFormat:
                                   @"H:|-%d-[text]-%d-|",
                                   kEdgeInset, kEdgeInset],
                
                 [NSString stringWithFormat:
                                   @"H:|-%d-[detail]-[caret(%d)]",
                                   kEdgeInset, kWDPRCaretImageDimension],
                
                 // Vertical
                 [NSString stringWithFormat:
                                   @"V:|[image(%d)]-%d-[text]-%d-[detail]-%d-|",
                                   [self imageViewHeight], kLabelVerticalSpacing, kLabelVerticalSpacing, kEdgeInset],
                
                 [NSString stringWithFormat:
                                   @"V:|[image(%d)]-%d-[text]-(>=%d)-[caret(%d)]",
                                   [self imageViewHeight], kLabelVerticalSpacing, kLabelVerticalSpacing, kWDPRCaretImageDimension]
        
         ]];
        
        // Vertically center caretView with the detailTextLabel
        [_cardView addConstraint:[NSLayoutConstraint constraintWithItem:caretView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.detailTextLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        
    }
    
    return _cardView;
}

-(int)imageViewHeight
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat margin = self.layoutMarginsGuide.layoutFrame.origin.x + self.contentView.layoutMarginsGuide.layoutFrame.origin.x;
    int imageViewHeight = (screenWidth - 2*margin)*9/16;
    return imageViewHeight;
}

-(UIView *) caretView
{
    UIView *caretView =
    [WDPRIcon iconWithID:WDPRIconRightCaret
                andColor:[UIColor wdprBlueColor]];
    caretView.frame = CGRectMake(0, 0, kWDPRCaretImageDimension, kWDPRCaretImageDimension);
    caretView.isAccessibilityElement = NO;
    return caretView;
}
    
@end
