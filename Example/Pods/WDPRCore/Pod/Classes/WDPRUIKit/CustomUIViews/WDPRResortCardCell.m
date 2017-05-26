//
//  WDPRResortCard.m
//  Pods
//
//  Created by Gerardo Quintanar Morales on 8/10/16.
//
//

#import "WDPRResortCardCell.h"


enum
{   // integer constants
    kEdgeInset = 16,
    kFacilityImageSize = 88,
    kRoomInfoViewHeight = 88,
};

const CGFloat kRoomNumberViewWidthRatio = 0.2;

@interface WDPRResortCardCell ()
{
    NSArray *_bottomInfo;
}

@property (nonatomic,strong) UIStackView* footerStack;

@end

@implementation WDPRResortCardCell

+ (NSString*)reuseIdentifier
{
    return @"WDPRResortCardCell";
}

// Overriding from WDPRCardCell
- (UIView *)headerView
{
    if(!_headerView)
    {
        _headerView = [UIView autolayoutView];

        [_headerView addSubviews:@{
                                   @"textLabel":self.textLabel,
                                   @"detailLabel":self.detailTextLabel,
                                   }
           withVisualConstraints:@[
                                   [NSString stringWithFormat:
                                    @"H:|[textLabel]|"
                                    ],
                                   
                                   [NSString stringWithFormat:
                                    @"H:|[detailLabel]|"
                                    ],
                                   
                                   [NSString stringWithFormat:
                                    @"V:|[textLabel][detailLabel]|"]
                                   ]];
    }
    
    return _headerView;
}

- (UIView *)footerView
{
    if(!_footerView)
    {
        _footerView = [UIView autolayoutView];
        [_footerView addSubviews:@{@"footerStack":self.footerStack}
           withVisualConstraints:@[@"V:|[footerStack]|",
                                   @"H:|[footerStack]|"]];
    }

    return _footerView;
}

- (UIView *)footerStack
{
    if(!_footerStack)
    {
        _footerStack = [UIStackView autolayoutView];
        _footerStack.axis = UILayoutConstraintAxisVertical;
    }

    return _footerStack;
}

- (void)setBottomInfo:(NSArray *)bottomInfo
{
    _bottomInfo = bottomInfo;
    self.showFooter = bottomInfo.count != 0;

    for (UIView *subview in self.footerStack.arrangedSubviews)
    {
        [self.footerStack removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }

    for (NSDictionary* room in bottomInfo)
    {
        [self.footerStack addArrangedSubview:[self viewForRoomNumber:[room objectForKey:WDPRCardInfoTitle]
                                                     andRoomLocation:[room objectForKey:WDPRCardInfoDetail]]];

        if (room != bottomInfo.lastObject)
        {
            [self.footerStack addArrangedSubview:[self separatorForAxis:UILayoutConstraintAxisHorizontal]];
        }
    }
}

- (UIView *)viewForRoomNumber:(NSString *)roomNumber andRoomLocation:(NSString *)roomLocation
{
    UIView *separatorView = [self separatorForAxis:UILayoutConstraintAxisVertical];
    UIView *roomNumberView = [self stackViews:@[[self centeredLabelWithStyle:WDPRTextStyleC1G
                                                                        text:WDPRLocalizedStringInBundle(@"com.wdprcore.resortcardcell.roominfo.room",
                                                                                                         WDPRCoreResourceBundleName, nil)],
                                                [self centeredLabelWithStyle:WDPRTextStyleH1D
                                                                        text:roomNumber]]
                                       inAxis:UILayoutConstraintAxisVertical];
    UILabel *roomLocationView = [self centeredLabelWithStyle:WDPRTextStyleB1D
                                                        text:roomLocation];

    UIStackView *roomInfoView = [self stackViews:@[roomNumberView,separatorView,roomLocationView]
                                          inAxis:UILayoutConstraintAxisHorizontal];
    roomInfoView.alignment = UIStackViewAlignmentCenter;
    roomInfoView.spacing = kEdgeInset;

    [NSLayoutConstraint setConstantConstraintFor:roomInfoView
                                       attribute:NSLayoutAttributeHeight
                                        constant:kRoomInfoViewHeight];

    NSLayoutConstraint *roomNumberViewWidthRatio =
    [NSLayoutConstraint constraintWithItem:roomNumberView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:roomInfoView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:kRoomNumberViewWidthRatio constant:0.0];

    NSLayoutConstraint *separatorHeight =
    [NSLayoutConstraint constraintWithItem:separatorView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:roomInfoView
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1.0 constant:-2*kEdgeInset];

    [NSLayoutConstraint activateConstraints:@[roomNumberViewWidthRatio,separatorHeight]];

    return roomInfoView;
}

#pragma mark Helpers

- (UIStackView *)stackViews:(NSArray<UIView *> *)views inAxis:(UILayoutConstraintAxis)axis
{
    UIStackView *stack = [UIStackView autolayoutView];
    stack.axis = axis;
    for (UIView *view in views)
    {
        [stack addArrangedSubview:view];
    }

    return stack;
}

- (UILabel *)centeredLabelWithStyle:(WDPRTextStyle)style text:(NSString *)text
{
    UILabel *label = [UILabel autolayoutView];
    [label applyStyle: style];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    return label;
}

- (UIView *)separatorForAxis:(UILayoutConstraintAxis)axis
{
    UIView *separator = [UIView autolayoutView];
    separator.backgroundColor = [UIColor wdprHRLineColor];
    NSLayoutAttribute attribute = (axis == UILayoutConstraintAxisHorizontal ?
                                   NSLayoutAttributeHeight : NSLayoutAttributeWidth);
    [NSLayoutConstraint setConstantConstraintFor:separator
                                       attribute:attribute
                                        constant:1];
    
    return separator;
}

@end
