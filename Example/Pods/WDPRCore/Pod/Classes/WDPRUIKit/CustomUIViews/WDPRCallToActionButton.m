//
//  WDPRCallToActionButton.m
//  
//
//  Created by Pierce, Owen on 12/5/14.
//
//

#import "WDPRUIKit.h"
#import "WDPRFontSizing.h"

static CGFloat const WDPRCTAButtonDefaultFontSize = 16.0f;

@implementation WDPRCallToActionButton

+ (instancetype)buttonWithTitle:(NSString *)title
{
    WDPRCallToActionButton *button = [[super alloc] init];

    WDPRFontSizing *wdprFontSizing = [[WDPRFontSizing alloc] initWithDefaultFontSize:WDPRCTAButtonDefaultFontSize
                                                                          forElement:WDPRCTAButtons];
    
    [button.titleLabel setFont:[[UIFont wdprStandardButtonFont] fontWithSize:[wdprFontSizing preferredFontSize]]];

    [button setDefaultColor:[UIColor wdprEnabledButtonColor]];
    [button setHighlightedColor:[UIColor wdprSelectedButtonColor]];
    [button setDisabledColor:[UIColor wdprMutedGrayColor]];

    [button setDefaultTextColor:[UIColor whiteColor]];
    [button setHighlightedTextColor:[UIColor whiteColor]];
    [button setDisabledTextColor:[UIColor whiteColor]];

    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    return button;
}

+ (instancetype)buttonWithTitle:(NSString *)title block:(PlainBlock)block
{
    WDPRCallToActionButton *button = [self buttonWithTitle:title];
    
    [button setBlock:block];

    return button;
}

+ (instancetype)secondaryButtonWithTitle:(NSString *)title
{
    WDPRCallToActionButton *button = [self buttonWithTitle:title];

    [button setDefaultColor:[UIColor wdprEnabledSecondaryButtonColor]];
    [button setHighlightedColor:[UIColor wdprSelectedSecondaryButtonColor]];
    [button setDisabledColor:[UIColor wdprDisabledSecondaryButtonColor]];

    [button setDefaultTextColor:[UIColor wdprBlueColor]];
    [button setHighlightedTextColor:[UIColor whiteColor]];
    [button setDisabledTextColor:[[UIColor wdprBlueColor] colorWithAlphaComponent:0.3]];

    [button setDefaultBorderColor:[[UIColor wdprSecondaryButtonBorderColor] CGColor]];
    [button setDisabledBorderColor:[[UIColor wdprSecondaryButtonBorderColor] CGColor]];

    button.layer.cornerRadius = 2.5;
    button.layer.borderWidth = 1.0;

    return button;
}

+ (instancetype)secondaryButtonWithTitle:(NSString *)title block:(PlainBlock)block
{
    WDPRCallToActionButton *button = [self secondaryButtonWithTitle:title];

    [button setBlock:block];

    return button;
}

+ (instancetype)secondaryDismissiveButtonWithTitle:(NSString *)title
{
    WDPRCallToActionButton *button = [self buttonWithTitle:title];

    [button setDefaultColor:[UIColor wdprEnabledTertiaryButtonColor]];

    [button setDefaultTextColor:[UIColor wdprBlueColor]];

    return button;
}

+ (instancetype)tertiaryButtonWithTitle:(NSString *)title
{
    WDPRCallToActionButton *button = [self buttonWithTitle:title];

    [button setDefaultColor:[UIColor wdprEnabledTertiaryButtonColor]];

    [button setDefaultTextColor:[UIColor wdprBlueColor]];
    [button setHighlightedTextColor:[UIColor wdprDarkBlueColor]];
    [button setDisabledTextColor:[[UIColor wdprBlueColor] colorWithAlphaComponent:0.3]];

    button.titleLabel.font = [UIFont wdprFontStyleB2];

    [button setTitleColor:[UIColor wdprBlueColor]
                 forState:UIControlStateNormal];

    return button;
}

+ (instancetype)tertiaryButtonWithTitle:(NSString *)title block:(PlainBlock)block
{
    WDPRCallToActionButton *button = [self tertiaryButtonWithTitle:title];

    [button setBlock:block];

    return button;
}

// IBDesignable Overrides

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self createSubviews];
}

- (void) createSubviews
{
    // Same as calling buttonWithTitle:
    [self.titleLabel setFont:[UIFont wdprStandardButtonFont]];
    
    [self setDefaultColor:[UIColor wdprEnabledButtonColor]];
    [self setHighlightedColor:[UIColor wdprSelectedButtonColor]];
    [self setDisabledColor:[UIColor wdprMutedGrayColor]];
    
    [self setDefaultTextColor:[UIColor whiteColor]];
    [self setHighlightedTextColor:[UIColor whiteColor]];
    [self setDisabledTextColor:[UIColor whiteColor]];
    
    [self setTitle:@"Default"
            forState:UIControlStateNormal];
    
    [self setTitleColor:[UIColor whiteColor]
                 forState:UIControlStateNormal];
}

- (CGSize) intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

- (void) prepareForInterfaceBuilder
{
    [self createSubviews];
}

// Properties

- (void)setDefaultColor:(UIColor *)defaultColor
{
    _defaultColor = defaultColor;
    [self setBackgroundImage:[UIImage imageWithColor:defaultColor]
                    forState:UIControlStateNormal];
}

- (void)setDefaultTextColor:(UIColor *)defaultTextColor
{
    _defaultTextColor = defaultTextColor;
    [self setTitleColor:defaultTextColor
               forState:UIControlStateNormal];
}

- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    _highlightedColor = highlightedColor;
    [self setBackgroundImage:[UIImage imageWithColor:highlightedColor]
                    forState:UIControlStateHighlighted];
    
    [self setBackgroundImage:[UIImage imageWithColor:highlightedColor]
                    forState:UIControlStateSelected];
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    _highlightedTextColor = highlightedTextColor;
    [self setTitleColor:highlightedTextColor
               forState:UIControlStateHighlighted];
    
    [self setTitleColor:highlightedTextColor
               forState:UIControlStateSelected];
}

- (void)setDisabledColor:(UIColor *)disabledColor
{
    _disabledColor = disabledColor;
    [self setBackgroundImage:[UIImage imageWithColor:disabledColor]
                    forState:UIControlStateDisabled];
}

- (void)setDefaultBorderColor:(CGColorRef)defaultBorderColor
{
    _defaultBorderColor = defaultBorderColor;
    self.layer.borderColor = defaultBorderColor;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (!enabled && self.disabledBorderColor)
    {
        if (self.layer.borderWidth > 0)
        {
            self.layer.borderColor = self.disabledBorderColor;
        }
    }
    else if (self.defaultBorderColor)
    {
        if (self.layer.borderWidth > 0)
        {
            self.layer.borderColor = self.defaultBorderColor;
        }
    }
}

@end
