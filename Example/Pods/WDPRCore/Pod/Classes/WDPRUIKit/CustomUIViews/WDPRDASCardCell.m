//
//  WDPRDASCardCell.m
//  Pods
//
//  Created by Ignacio Rodrigo on 8/10/16.
//
//

#import "WDPRDASCardCell.h"


enum
{   // integer constants
    kEdgeInset = 16,
    kFacilityImageSize = 88,
};


@interface WDPRDASCardCell ()

@property (nonatomic, strong) UILabel *disabilityAccessServiceLabel;

@end


@implementation WDPRDASCardCell

+ (NSString*)reuseIdentifier
{
    return @"WDPRDASCardCell";
}

// Overriding from WDPRCardCell
- (UIView *)headerView
{
    if(!_headerView)
    {
        _headerView = [UIView autolayoutView];

        [_headerView addSubviews:@{
                                   @"imageView":self.imageView,
                                   @"disabilityAccessServiceLabel":self.disabilityAccessServiceLabel,
                                   @"textLabel":self.textLabel,
                                   @"detailLabel":self.detailTextLabel,
                                   }
           withVisualConstraints:@[
                                   [NSString stringWithFormat:
                                    @"H:|[imageView(%d)]-%d-[disabilityAccessServiceLabel]|",
                                    kFacilityImageSize, kEdgeInset],

                                   [NSString stringWithFormat:
                                    @"H:|[imageView(%d)]-%d-[textLabel]|",
                                    kFacilityImageSize, kEdgeInset],

                                   [NSString stringWithFormat:
                                    @"H:|[imageView(%d)]-%d-[detailLabel]|",
                                    kFacilityImageSize, kEdgeInset],

                                   [NSString stringWithFormat:
                                    @"V:|[imageView(%d)]-(>=0@500)-|",
                                    kFacilityImageSize],

                                   [NSString stringWithFormat:
                                    @"V:|[disabilityAccessServiceLabel][textLabel][detailLabel]-(>=%d@500)-|",
                                    0]
                                   ]];
    }

    return _headerView;
}

- (UILabel*)disabilityAccessServiceLabel
{
    if (!_disabilityAccessServiceLabel)
    {
        _disabilityAccessServiceLabel = [UILabel autolayoutView];
        _disabilityAccessServiceLabel.text = WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.disablityaccessservice", WDPRCoreResourceBundleName, nil);
        _disabilityAccessServiceLabel.font = [UIFont wdprFontStyleB2];
        _disabilityAccessServiceLabel.textColor = [UIColor wdprBlueColor];
        _disabilityAccessServiceLabel.numberOfLines = 0;
    }
    return _disabilityAccessServiceLabel;
}

@end
