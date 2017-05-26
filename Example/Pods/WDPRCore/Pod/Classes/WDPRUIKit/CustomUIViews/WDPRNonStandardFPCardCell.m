//
// WDPRNonStandardFPCardCell.m
//  Pods
//
//  Created by Sipani, Ankita on 9/13/16.
//
//

#import "WDPRNonStandardFPCardCell.h"

enum
{   // integer constants
    kEdgeInset = 16,
};

@interface WDPRNonStandardFPCardCell ()

@property (nonatomic, strong) UILabel * footerLabel;

@end

@implementation WDPRNonStandardFPCardCell

+ (NSString*)reuseIdentifier
{
    return @"WDPRNonStandardFPCardCell";
}

- (UIView *)footerView
{
    if (!_footerView)
    {
        _footerView = [UIView autolayoutView];
        
        [_footerView addSubviews:@{ @"footerLabel" : self.footerLabel }
           withVisualConstraints:@[
                                   [NSString stringWithFormat: @"H:|-%d-[footerLabel]-%d-|", kEdgeInset,kEdgeInset],
                                   [NSString stringWithFormat: @"V:|-[footerLabel]-|"]
                                   ]];
    }
    
    return _footerView;
}

- (void)setFooterDisclaimerText:(NSString *)text {
    
    [self.footerLabel setTextOrAttributedText: text];
}

- (UILabel *)footerLabel
{
    if (!_footerLabel)
    {
        _footerLabel = [UILabel autolayoutView];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        [_footerLabel setTextOrAttributedText: WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.footer.disclaimer", WDPRCoreResourceBundleName, nil)];
        [_footerLabel applyStyle: WDPRTextStyleC2D];
    }
    return _footerLabel;
}


@end
