//
//  WDPRExpandableCell.m
//  Mdx
//
//  Created by J.Rodden on 3/25/16.
//  Copyright © 2016 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

enum 
{   // integer consts
    kEdgeInset = 16,
    kWidgetSize = 15
};

@interface WDPRExpandableCell ()

@property (nonatomic, retain) WDPRIcon* disclosureWidget;
@property (nonatomic, retain) NSLayoutConstraintArray* expandedConstraints;

@end // @interface WDPRExpandableCell ()

#pragma mark -

@implementation WDPRExpandableCell

- (UIView*)accessoryView
{
    return nil;
}

- (void)setAccessoryView:(UIView *)ignored
{
    // block superclass implementation
}

- (void)setUseAutolayout:(BOOL)useIt
{
    // ignore incoming value
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateCellAccessibility];
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    if (selectionStyle != UITableViewCellSelectionStyleNone)
    {
        super.selectionStyle = selectionStyle;
    }
}

- (BOOL)supportsAutolayout
{
    return YES;
}

#pragma mark -

@synthesize contractedView = _contractedView;
@synthesize expandedView = _expandedView;

- (UIView*)contractedView
{
    return (_contractedView ?:
            self.textLabel);
}

- (void)setContractedView:(UIView *)contractedView
{
    if (_contractedView != contractedView)
    {
        _contractedView = contractedView;
        [self setupConstraints];
    }
}

- (UIView*)expandedView
{
    return (_expandedView ?: 
            self.detailTextLabel);
}

- (void)setExpandedView:(UIView *)expandedView
{
    if (_expandedView != expandedView)
    {
        _expandedView = expandedView;
        
        if (self.isAlwaysExpanded)
        {
            self.expanded = YES;
        }
        
        if (self.expandedConstraints.count)
        {
            onExitFromScope(^{ self.expandedConstraints = nil; });
            [self.contentView setNeedsUpdateConstraints];
            [self.contentView removeConstraints:self.expandedConstraints];
        }
    }
}

- (WDPRIconID)expansionIcon
{
    return (self.isExpanded ?
            WDPRIconUpTriangle :
            WDPRIconDownTriangle);
}

- (void)setExpanded:(BOOL)expanded
{
    if (_expanded != (expanded || self.isAlwaysExpanded))
    {
        _expanded = expanded;
        
        self.expandedView.hidden = !expanded;
        self.disclosureWidget.code = self.expansionIcon;
    }
}

- (void)updateCellAccessibility
{
    if (self.focusesExpandedViewSeparatelyForAccessibility)
    {
        self.accessibilityElements = self.isExpanded ? @[self.textLabel, self.expandedView] : nil;
        self.isAccessibilityElement = !self.isExpanded;
    }
}

- (void)setAlwaysExpanded:(BOOL)alwaysExpanded
{
    _alwaysExpanded = alwaysExpanded;
    
    if (_alwaysExpanded)
    {
        super.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (WDPRIcon*)disclosureWidget
{
    return (_disclosureWidget ?: (_disclosureWidget = 
                                  [WDPRIcon iconWithID:
                                   self.expansionIcon]));
}

#pragma mark -

- (void)setupConstraints
{
    [self.contentView removeConstraints:self.constraints];
    
    // If cell is always expanded there is no need for a disclosure widget
    if (self.isAlwaysExpanded)
    {
        [self.disclosureWidget removeFromSuperview];
        [self.contentView addSubviews:@{@"contractedView" : self.contractedView}
                withVisualConstraints:@[[NSString stringWithFormat:
                                         @"V:|-%d-[contractedView]-(>=%d)-|",
                                         kEdgeInset, kEdgeInset],
                                        
                                        [NSString stringWithFormat:
                                         @"H:|-%d-[contractedView]-%d-|",
                                         kEdgeInset, kEdgeInset]
                                        ]];
    }
    else
    {
        [self.contentView addSubviews:@{
                                        @"contractedView" : self.contractedView,
                                        @"widget" : self.disclosureWidget
                                        }
                withVisualConstraints:@[[NSString stringWithFormat:
                                         @"V:|-%d-[contractedView]-(>=%d)-|",
                                         kEdgeInset, kEdgeInset],
                                        
                                        [NSString stringWithFormat:
                                         @"H:|-%d-[contractedView]-[widget]-(%d)-|",
                                         kEdgeInset, kEdgeInset],
                                        
                                        [NSString stringWithFormat:@"V:[widget(%d)]",
                                         kWidgetSize],
                                        
                                        [NSString stringWithFormat:@"H:[widget(%d)]",
                                         kWidgetSize],
                                        
                                        ]];
                
        [self.contentView addConstraint: [NSLayoutConstraint centerViewVertically:self.disclosureWidget
                                                                 inContainingView:self.contractedView]];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.isExpanded && self.expandedView)
    {
        if (!self.expandedConstraints.count)
        {
            self.expandedConstraints = @[];
            [self.contentView addSubview:self.expandedView];
            
            NSDictionary* views =
            @{
              @"contractedView" : self.contractedView,
              @"expandedView" : self.expandedView,
              };
            
            self.expandedView.translatesAutoresizingMaskIntoConstraints = NO;
            
            for (NSString* constraints in
                 @[[NSString stringWithFormat:
                    @"H:|-%d-[expandedView]-%d-|", kEdgeInset, kEdgeInset],
                   [NSString stringWithFormat:
                    @"V:[contractedView]-%d-[expandedView]-%d-|", kEdgeInset, kEdgeInset],
                   ])
            {
                [self.expandedConstraints arrayByAddingObjectsFromArray:
                 [self.contentView addConstraintsWithFormat:constraints 
                                                    metrics:nil views:views]];
            }
        }
        
        [NSLayoutConstraint activateConstraints:self.expandedConstraints];
    }
    else if (self.expandedConstraints.count)
    {
        [NSLayoutConstraint deactivateConstraints:self.expandedConstraints];
    }
}

- (void)toggleExpansionState
{
    self.expanded = !self.isExpanded;
    [self.contentView setNeedsUpdateConstraints];

    UITableView* tableView = 
    (SAFE_CAST(self.superview.superview, UITableView));
    
    NSIndexPath* indexPath = [tableView indexPathForCell:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    executeOnNextRunLoop
    (^{
        [tableView reloadRowsAtIndexPaths:@[indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView scrollToRowAtIndexPath:indexPath 
                         atScrollPosition:UITableViewScrollPositionNone animated:YES];
    });
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:
            UITableViewCellStyleDefault 
                reuseIdentifier:reuseIdentifier];
    if (self)
    {
        super.useAutolayout = YES;
        
        [self.textLabel applyStyle:WDPRTextStyleB2B];
        
        super.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return self;
}

@end
