//
//  WDPRCardCell.m
//  Pods
//
//  Created by Cesar Rodriguez on 4/08/16.
//
//

#import "WDPRCardCell.h"
#import "WDPRLoader.h"
#import "WDPRPullbarView.h"

enum
{   // integer constants
    kEdgeInsetForPullbar = 35,
    kEdgeInset = 16,
    kFacilityImageSize = 88,
    kLabelVerticalSpacing = 12,
    kCellVerticalSpacing = 10,
    kIconDiameter = 15,
    kIconTextSpace = 8,
    kImageAndLabelSeparator = 12,
    
    kMinimumRowHeight = kEdgeInset * 4 + kFacilityImageSize + kLabelVerticalSpacing + 2 * 20
};

typedef NS_ENUM(int,PullbarDimension)
{
    kPullbarWidth = 36,
    kPullbarHeight = 70
};

#define kTranslationPowerFactor -0.1f
#define kResetAnimationDuration 0.3f
#define kResetAnimationSpringDamping 0.7f
#define kCaretSize CGSizeMake(24,24)

#define kShadowOffset  2.0f
#define KShadowOpacity  0.05f
#define kCornerRadius  2.5f
#define kBorderWidth 1.0f

#define kLoaderSize  16.0f
#define kLoaderLineWidth  1.5f

@interface WDPRCardCell ()

@property (nonatomic, strong) WDPRPullbarView* pullbarView;
@property (nonatomic, strong) UIView* shadowView;
@property (nonatomic, strong) UIView* cardView;
@property (nonatomic, strong) UIView* typeView;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIView* infoView;

@property (nonatomic, strong, readwrite) UIView* footerView;
@property (nonatomic, strong) NSArray* typeViewConstraints;
@property (nonatomic, strong, readwrite) UIImageView* iconTypeView;
@property (nonatomic, strong, readwrite) UILabel* typeLabel;
@property (nonatomic, strong) WDPRLoader *loader;

@property (nonatomic, strong) UIView * disclaimerView;
@property (nonatomic, strong) UILabel * disclaimerLabel;
@property (nonatomic, strong) NSArray* disclaimerViewConstraints;

@property (nonatomic, strong) UITapGestureRecognizer *pullbarTapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *pullbarPanGestureRecognizer;
@property (nonatomic) NSLayoutConstraint *leadingPullConstraint;
@property (nonatomic) NSLayoutConstraint *trailingPullConstraint;

@property (nonatomic, strong) UIView* pullbarHead;
@property (nonatomic, strong) UIView* pullbarTail;
@property (nonatomic) NSLayoutConstraint *pullbarHeadLeftConstraint;

@property (nonatomic, strong) UIView* snapshotView;
@end

@implementation WDPRCardCell

+ (NSString *)reuseIdentifier
{
    return @"cardCell";
}

+ (CGFloat)minimumRowHeight
{
    return kMinimumRowHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:
            UITableViewCellStyleSubtitle
                reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.useAutolayout = YES;
        [self customizeViews];
        self.cardType = WDPRCardTypeDefault;
        _pullbarEnabled = NO;
    }
    
    return self;
}

- (void)customizeViews
{
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    self.imageView.layer.cornerRadius = kFacilityImageSize/2;
    
    self.textLabel.numberOfLines = 0;
    self.detailTextLabel.numberOfLines = 0;
    
    [self.textLabel applyStyle:WDPRTextStyleH3D];
    [self.detailTextLabel applyStyle:WDPRTextStyleB2D];
    
    [self.textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.detailTextLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.shadowView.layer.shadowPath =
    [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-1, -1,
                                                       CGRectGetWidth(self.cardView.bounds) + kShadowOffset,
                                                       CGRectGetHeight(self.cardView.bounds) + kShadowOffset)
                               cornerRadius:kCornerRadius].CGPath;
}

- (void)setupConstraints
{
    [self.contentView addSubview:self.pullbarView];
    
    self.topPullConstraint =
    [NSLayoutConstraint constraintWithItem:self.pullbarView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0f
                                  constant:kCellVerticalSpacing];
    
    self.bottomPullConstraint =
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.pullbarView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0f
                                  constant:kCellVerticalSpacing];
    self.leadingPullConstraint =
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.pullbarView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0f
                                  constant:-kEdgeInset];
    
    self.trailingPullConstraint =
    [NSLayoutConstraint constraintWithItem:self.contentView
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.pullbarView
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0f
                                  constant:kEdgeInset];
    
    self.bottomPullConstraint.priority = UILayoutPriorityDefaultHigh;
    
    [NSLayoutConstraint activateConstraints:@[self.topPullConstraint, self.bottomPullConstraint,
                                              self.leadingPullConstraint,self.trailingPullConstraint]];
}

- (UIView *)shadowView
{
    if (!_shadowView)
    {
        _shadowView = [UIView autolayoutView];
        _shadowView.layer.borderWidth = kBorderWidth;
        _shadowView.layer.cornerRadius = kCornerRadius;
        _shadowView.layer.borderColor = [UIColor wdprHRLineColor].CGColor;
        
        _shadowView.layer.masksToBounds = NO;
        _shadowView.layer.shadowColor = [UIColor wdprDarkBlueColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0.0, kShadowOffset);
        _shadowView.layer.shadowOpacity = KShadowOpacity;
        
        _shadowView.backgroundColor = [UIColor whiteColor];
        
        [_shadowView addSubviews:@{@"cardView":self.cardView}
           withVisualConstraints:@[
                                    @"H:|[cardView]|",
                                   
                                    @"V:|[cardView]|"
                                   ]];
    }
    
    return _shadowView;
}

- (UIView *)cardView
{
    if (!_cardView)
    {
        _cardView = [UIView autolayoutView];
        _cardView.backgroundColor = [UIColor whiteColor];
        
        UIView *separatorView = [UIView autolayoutView];
       separatorView.backgroundColor = [UIColor wdprHRLineColor];
        
        [_cardView addSubviews:@{
                                 @"header":self.headerView,
                                 @"info":self.infoView,
                                 @"separator":separatorView
                                 }
         withVisualConstraints:@[
                                 [NSString stringWithFormat:
                                  @"H:|-%d-[header]-%d-|",
                                  kEdgeInset, kEdgeInset],
                                 
                                 [NSString stringWithFormat:
                                  @"H:|-%d-[separator]-%d-|",
                                  kEdgeInset, kEdgeInset],

                                 
                                 [NSString stringWithFormat:
                                  @"H:|-%d-[info]-%d-|",
                                  kEdgeInset, kEdgeInset],
                                 
                                 
                                 [NSString stringWithFormat:
                                  @"V:|-(>=%d)-[header]-%d-[separator(%d)][info]-(>=0)-|",
                                  kEdgeInset, kIconTextSpace, 1]
                                 ]];
        
        
        self.footerViewConstraints =
        [_cardView addSubviews:@{
                                 @"footer":self.footerView,
                                 @"info":self.infoView
                                 }
         withVisualConstraints:@[
                                 [NSString stringWithFormat:
                                  @"H:|-%d-[footer]-%d-|",
                                  kEdgeInset, kEdgeInset],
                                 
                                 [NSString stringWithFormat:
                                  @"V:[info]-[footer]|"]
                                 ]];

        self.typeViewConstraints =
        [_cardView addSubviews:@{
                                 @"type":self.typeView,
                                 @"header":self.headerView,
                                 @"separatorView":separatorView,
                                 @"info":self.infoView
                                 }
         withVisualConstraints:@[
                                 [NSString stringWithFormat:
                                  @"H:|-%d-[type]-%d-|",
                                  kEdgeInset, kEdgeInset],
                                 
                                 [NSString stringWithFormat:
                                  @"V:|-[type]-%d-[header]",
                                  kLabelVerticalSpacing]
                                 ]];
    }
    
    return _cardView;
}

- (UIView *)typeView
{
    if (!_typeView)
    {
        _typeView = [UIView autolayoutView];

        UIView* separator = [UIView autolayoutView];
        separator.backgroundColor = [UIColor wdprHRLineColor];
        
        [_typeView addSubviews:@{
                                 @"icon":self.iconTypeView,
                                 @"type":self.typeLabel,
                                 @"separator":separator,
                                 @"loader":[self loader]
                                 }
         withVisualConstraints:@[
                                 [NSString stringWithFormat:
                                  @"H:|[icon(0@500)][type][loader(%f)]|", kLoaderSize],
                                 
                                 [NSString stringWithFormat:
                                  @"H:|[separator]|"],
                                 
                                 [NSString stringWithFormat:
                                  @"V:|[loader(%f)]-[separator(1)]|", kLoaderSize],
                                 
                                 [NSString stringWithFormat:
                                  @"V:|[type]-[separator(1)]|"],
                                 
                                 [NSString stringWithFormat:
                                  @"V:|[icon]"]
                                 
                                 ]];
    }
    
    return _typeView;
}

- (WDPRLoader *)loader
{
    if (!_loader)
    {
        _loader = [[WDPRLoader alloc] initWithFrame:
                   CGRectMake(0, 0, kLoaderSize, kLoaderSize)];
        _loader.hidesWhenStop = NO;
        _loader.lineWidth = kLoaderLineWidth;
        _loader.customRadius = kLoaderSize/2 - kLoaderLineWidth;
        _loader.distanceFromTop = 0;
        [_loader setImageYOffset:-(50 - kLoaderSize)/2];
    }
    
    return _loader;
}

- (void)showLoader
{
    self.loader.hidden = NO;
    [self.loader startAnimating];
}

- (void)hideLoader
{
    [self.loader stopAnimating];
    self.loader.hidden = YES;
}

- (UILabel *)typeLabel
{
    if (!_typeLabel)
    {
        _typeLabel = [UILabel autolayoutView];
        [_typeLabel applyStyle:WDPRTextStyleC1D];
    }
    
    return _typeLabel;
}

- (UIImageView *)iconTypeView
{
    if (!_iconTypeView)
    {
        _iconTypeView = [UIImageView autolayoutView];
    }
    
    return _iconTypeView;
}

- (UIView *)headerView
{
    if (!_headerView)
    {
        _headerView = [UIView autolayoutView];
        UIView* labelsView = [UIView autolayoutView];
        
        [labelsView addSubviews:@{
                                  @"textLabel":self.textLabel,
                                  @"detailLabel":self.detailTextLabel
                                  }
          withVisualConstraints:@[@"V:|[textLabel][detailLabel]|",
                                  @"H:|[textLabel]|",
                                  @"H:|[detailLabel]|",
                                  ]];
        
        [_headerView addSubviews:@{
                                   @"imageView":self.imageView,
                                   @"labelsView":labelsView
                                   }
           withVisualConstraints:@[
                                   [NSString stringWithFormat:
                                    @"H:|[imageView(%d)]-%d-[labelsView]|",
                                    kFacilityImageSize, kImageAndLabelSeparator],
                                   
                                   [NSString stringWithFormat:
                                    @"V:|[imageView(%d)]-(>=0@500)-|",
                                    kFacilityImageSize],
                                   
                                   [NSString stringWithFormat:
                                    @"V:|-(>=0)-[labelsView]-(>=0)-|"]
                                   ]];
        
        [_headerView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:
                                                          @"H:[headerView]-(<=1)-[labelsView]"]
                                                 options:NSLayoutFormatAlignAllCenterY
                                                 metrics:nil
                                                   views:@{
                                                           @"headerView":_headerView,
                                                           @"labelsView":labelsView,
                                                           }]];
    }
    
    return _headerView;
}

- (UIView *)footerView
{
    if (!_footerView)
    {
        _footerView = [UIView autolayoutView];
        
        UIView * individualSeparatorView = [UIView autolayoutView];
        individualSeparatorView.backgroundColor = [UIColor wdprHRLineColor];
        
        [_footerView addSubviews:@{
                                   @"individualSeparatorView" : individualSeparatorView,
                                   @"disclaimerView" : self.disclaimerView,
                                   }
           withVisualConstraints:@[
                                   [NSString stringWithFormat:@"H:|[individualSeparatorView]|"],
                                   [NSString stringWithFormat:@"H:|[disclaimerView]|"],
                                   [NSString stringWithFormat:@"V:|[individualSeparatorView(1)]-[disclaimerView]-(%d)-|",
                                    kEdgeInset],
                                   ]];
    }
    
    return _footerView;
}


- (UIView *)infoView
{
    if (!_infoView)
    {
        _infoView = [UIView autolayoutView];        
    }

    return _infoView;
}

- (void)setCardType:(WDPRCardType)cardType
{
    _cardType = cardType;

    // set a sensible default value for footer visibility according to car type
    self.showFooter = (cardType == WDPRCardTypeWithHeaderNBE);
    
    NSString* type = @"";
    WDPRIconID iconID = 0x0000;

    switch (cardType)
    {
        case WDPRCardTypeWithHeaderNextFP:
            type = [NSString stringWithFormat:@"%@: ",
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.nextprefix", WDPRCoreResourceBundleName, nil)];
        case WDPRCardTypeWithHeaderFP:
            type = [type stringByAppendingString:
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.fastpasscard.header", WDPRCoreResourceBundleName, nil)];

            iconID = WDPRIconFastPassPlus;
            break;
            
        case WDPRCardTypeWithHeaderNextDine:
            type = [NSString stringWithFormat:@"%@: ",
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.nextprefix", WDPRCoreResourceBundleName, nil)];
        case WDPRCardTypeWithHeaderDine:
            type = [type stringByAppendingString:
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.diningcard.header", WDPRCoreResourceBundleName, nil)];
            iconID = WDPRIconBookDining;
            break;
            
        case WDPRCardTypeWithHeaderNextResort:
        case WDPRCardTypeWithHeaderResort:
            type = [type stringByAppendingString:
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.resortcard.header", WDPRCoreResourceBundleName, nil)];
            iconID = WDPRIconResorts;
            break;
            
        case WDPRCardTypeWithHeaderNextNBE:
            type = [NSString stringWithFormat:@"%@: ",
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.nextprefix", WDPRCoreResourceBundleName, nil)];
        case WDPRCardTypeWithHeaderNBE:
            type = [NSString stringWithFormat:@"%@: %@",
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.nextprefix", WDPRCoreResourceBundleName, nil),
                    WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.notecard.header", WDPRCoreResourceBundleName, nil)];
            break;
            
        case WDPRCardTypeDefault: // Fallthrough
        case WDPRCardTypeWithHeaderNote:
            self.typeView.hidden = YES;
            [NSLayoutConstraint deactivateConstraints:self.typeViewConstraints];
            return;
    }
    
    self.typeView.hidden = NO;
    [NSLayoutConstraint activateConstraints:self.typeViewConstraints];
    
    self.typeLabel.text = type;
    self.iconTypeView.image = [self imageWithSpaceFromIconID:iconID];
}

- (UIImage*)imageWithSpaceFromIconID:(WDPRIconID)iconID
{
    if (iconID == 0x0000)
    {
        return nil;
    }
    
    UIView* view = [[UIView alloc] initWithFrame:
                    CGRectWithSize(CGSizeMake(kIconDiameter+kIconTextSpace, kIconDiameter))];
    WDPRIcon* icon = [WDPRIcon iconWithID:iconID andColor:[UIColor wdprDarkBlueColor]];
    icon.frame = view.bounds;
    icon.center = CGPointMake(kIconDiameter/2, view.center.y);
    [view addSubview:icon];
    
    return view.imageOfSelf;
}

- (UIView *)disclaimerView
{
    if(!_disclaimerView)
    {
        _disclaimerView = [UIView autolayoutView];
        
        WDPRIcon *disclaimerIcon = [WDPRIcon iconWithID:WDPRIconInfo andColor:[UIColor wdprDarkBlueColor]];
        [_disclaimerView addSubviews:@{
                                 @"disclaimerIcon":disclaimerIcon,
                                 @"disclaimerText":self.disclaimerLabel,
                                 }
         withVisualConstraints:@[
                                 [NSString stringWithFormat:
                                  @"H:|-%d-[disclaimerIcon]-%d-[disclaimerText]-(>=0@500)-|", kEdgeInset,kEdgeInset],
                                 
                                 [NSString stringWithFormat:@"V:|-[disclaimerIcon]-|"],
                                 
                                 [NSString stringWithFormat:@"V:|-[disclaimerText]-|"]
                                 
                                 ]];
    }
    return _disclaimerView;
}

- (UILabel*)disclaimerLabel
{
    if (!_disclaimerLabel)
    {
        _disclaimerLabel = [UILabel autolayoutView];
        [_disclaimerLabel applyStyle:WDPRTextStyleB2D];
        [_disclaimerLabel setTextOrAttributedText:WDPRLocalizedStringInBundle(@"com.wdprcore.cardcell.footer.disclaimer", WDPRCoreResourceBundleName, nil)];
    }
    return _disclaimerLabel;
}

- (void)setFooterDisclaimerText:(NSString*)text
{
    [self.disclaimerLabel setTextOrAttributedText:text];
}

- (void)setBottomInfo:(NSArray *)bottomInfo
{
    _bottomInfo = bottomInfo;
    
    if (self.textLabels.count - 1 != bottomInfo.count) {
        [self removeExtraLabels];
        [self createMissingLabels];
    }
    
    for (int i = 0; i < self.bottomInfo.count; i++)
    {
        UILabel* titleLabel = [self textLabelAtIndex:i+1];
        UILabel* detailLabel = [self detailTextLabelAtIndex:i+1];

        NSDictionary* info = bottomInfo[i];
        
        [titleLabel setTextOrAttributedText:[info objectForKey:WDPRCardInfoTitle]];
        [detailLabel setTextOrAttributedText:[info objectForKey:WDPRCardInfoDetail]];
    }
}

- (void)createMissingLabels
{
    [self.infoView removeConstraints:self.infoView.constraints];
    
    UILabel* oldTitleLabel;
    UILabel* oldDetailLabel;
    
    for (int i = 0; i < self.bottomInfo.count; i++)
    {
        UILabel* titleLabel = [self textLabelAtIndex:i+1];
        UILabel* detailLabel = [self detailTextLabelAtIndex:i+1];

        if (titleLabel.superview != self.infoView) {

            [titleLabel applyStyle:WDPRTextStyleC2D];
            [detailLabel applyStyle:WDPRTextStyleB2D];

            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            [detailLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh
                                           forAxis:UILayoutConstraintAxisHorizontal];
            
            [detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                           forAxis:UILayoutConstraintAxisHorizontal];

            [self.infoView addSubview:titleLabel];
            [self.infoView addSubview:detailLabel];
        }
        
        NSMutableArray *constraints = [NSMutableArray new];
        
        NSMutableDictionary* views = [NSMutableDictionary new];
        [views setObject:titleLabel forKey:@"title"];
        [views setObject:detailLabel forKey:@"detail"];
        
        NSDictionary *metrics =@{
                                @"space"        :@(kEdgeInset),
                                @"textSpacing"  :@(kLabelVerticalSpacing),
                                @"kFacilityImageSize"  :@(kFacilityImageSize),
                                };
        
        if (!oldTitleLabel)
        {
            [constraints addObject:@"V:|-(space)-[title]"];
            [constraints addObject:@"V:|-(space)-[detail]"];
            [constraints addObject:@"H:|[title(kFacilityImageSize)]-(space)-[detail]-(>=0@500)-|"];
        }
        else
        {
            [views setObject:oldTitleLabel forKey:@"oldTitle"];
            [views setObject:oldDetailLabel forKey:@"oldDetail"];

            [constraints addObject:@"H:|[title(kFacilityImageSize)]-(space)-[detail(==oldDetail)]-(>=0@500)-|"];
            [constraints addObject:@"V:[oldTitle]-(textSpacing)-[title(==oldTitle)]"];
            [constraints addObject:@"V:[oldDetail]-(textSpacing)-[detail(==oldDetail)]"];
        }
        
        if (i == self.bottomInfo.count-1)
        {
            [constraints addObject:@"V:[title]-(space)-|"];
            [constraints addObject:@"V:[detail]-(space)-|"];
        }

        for (NSString* formattedConstraint in constraints) {
            [self.infoView addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:formattedConstraint
                                                     options:0
                                                     metrics:metrics
                                                       views:views]];
        }
        

        
        oldTitleLabel = titleLabel;
        oldDetailLabel = detailLabel;
    }
}

- (void)setShowFooter:(BOOL)showFooter
{
    _showFooter = showFooter;
    
    self.footerView.hidden = !showFooter;
    
    if (showFooter)
    {
        [NSLayoutConstraint activateConstraints:self.footerViewConstraints];
    }
    else
    {
        [NSLayoutConstraint deactivateConstraints:self.footerViewConstraints];
    }
}

- (BOOL)supportsAutolayout
{
    return YES;
}

#pragma - mark Pullbar related

- (void) prepareForPopAnimation
{
    self.pullbarTail.backgroundColor = [UIColor wdprBlueColor];
    self.leadingPullConstraint.constant = self.bounds.size.width;
    self.trailingPullConstraint.constant = self.bounds.size.width;
}

-(void) animateIfNeeded
{
    [self resetPullbarConstraintsConstants];
}

- (void) resetPullbarConstraintsConstants
{
    [UIView animateWithDuration: kResetAnimationDuration
                          delay: 0
         usingSpringWithDamping: kResetAnimationSpringDamping
          initialSpringVelocity: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:
     ^{
         self.leadingPullConstraint.constant = -(self.trailingPullConstraint.constant = kEdgeInset);
         [self.contentView layoutIfNeeded];
     }
                     completion:nil];
}

- (void)setPullbarHidden:(BOOL)pullbarHidden
{
    _pullbarHidden = pullbarHidden;
    self.pullbarTail.alpha = !pullbarHidden;
    
    if (pullbarHidden)
    {
        self.pullbarHeadLeftConstraint.constant = kPullbarWidth+kEdgeInset;
    }
    else
    {
        self.pullbarHeadLeftConstraint.constant = -kEdgeInset;
    }
    
    [self.pullbarView layoutSubviews];
}

- (void) setPullbarEnabled:(BOOL) enabled
{
    WDPRPullbarView *pullbarRootView = self.pullbarView;
    
    if((_pullbarEnabled = enabled))
    {
        [pullbarRootView addSubviews:@{ @"pullbarHead":self.pullbarHead }
               withVisualConstraints:@[ [NSString stringWithFormat: @"H:[pullbarHead(%d)]",kPullbarWidth],
                                        [NSString stringWithFormat: @"V:[pullbarHead(%d)]",kPullbarHeight]
                                        ]];
        
        self.pullbarHeadLeftConstraint = [NSLayoutConstraint constraintWithItem:self.pullbarHead
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:pullbarRootView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-2*kEdgeInset];
        
        [pullbarRootView addConstraint:self.pullbarHeadLeftConstraint];
        
        [pullbarRootView addConstraint:
         [NSLayoutConstraint
          constraintWithItem:self.pullbarHead
          attribute:NSLayoutAttributeCenterY
          relatedBy:NSLayoutRelationEqual
          toItem:pullbarRootView
          attribute:NSLayoutAttributeCenterY
          multiplier:1.f constant:0.f]];
        
        [self.contentView addSubviews:@{ @"pullbarTail":self.pullbarTail }
                withVisualConstraints:@[ [NSString stringWithFormat:@"H:|-(%d)-[pullbarTail]|", kEdgeInsetForPullbar],
                                         [NSString stringWithFormat:@"V:[pullbarTail(%d)]",kPullbarHeight]
                                         ]];
        
        [self.contentView addConstraint:
         [NSLayoutConstraint
          constraintWithItem:self.pullbarTail
          attribute:NSLayoutAttributeCenterY
          relatedBy:NSLayoutRelationEqual
          toItem:self.contentView
          attribute:NSLayoutAttributeCenterY
          multiplier:1.f constant:0.f]];
        
        [self.contentView sendSubviewToBack:self.pullbarTail];
    }
    else
    {
        [self.pullbarHead removeFromSuperview];
        [self.pullbarTail removeFromSuperview];
    }
}

- (UIView*)pullbarHead
{
    if (!_pullbarHead)
    {
        _pullbarHead = [UIView autolayoutView];
        _pullbarHead.backgroundColor = [UIColor wdprBlueColor];
        _pullbarHead.layer.cornerRadius = 2.0f;

        UIImageView *arrowView =
        
        [[UIImageView alloc] initWithImage:
         
           [WDPRIcon imageOfIcon:WDPRIconPullDown withColor:UIColor.whiteColor andSize: kCaretSize]
         
         ];
        
        arrowView.contentMode = UIViewContentModeCenter;
        arrowView.center = CGPointMake(0, 0);
        arrowView.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        // TODO: calculate or define a constant (from Redlines)
        [_pullbarHead addSubviews:@{ @"arrowView" : arrowView}
            withVisualConstraints:@[[NSString stringWithFormat: @"H:|-%d-[arrowView]", 4]]];
        
        [_pullbarHead addConstraint:
         [NSLayoutConstraint
          constraintWithItem:arrowView
          attribute:NSLayoutAttributeCenterY
          relatedBy:NSLayoutRelationEqual
          toItem:_pullbarHead
          attribute:NSLayoutAttributeCenterY
          multiplier:1.f
          constant:0.f]];

        // add tap gesture recognizer
        self.pullbarTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePullbarTap:)];
        self.pullbarTapGestureRecognizer.delegate = self;
        [_pullbarHead addGestureRecognizer:self.pullbarTapGestureRecognizer];
    }
    return _pullbarHead;
}

- (UIView *) pullbarTail
{
    if (!_pullbarTail)
    {
        _pullbarTail = [UIView autolayoutView];
        _pullbarTail.backgroundColor = [UIColor clearColor];
    }
    return _pullbarTail;
}

- (WDPRPullbarView *) pullbarView
{
    if (!_pullbarView)
    {
        _pullbarView = [WDPRPullbarView autolayoutView];
        [_pullbarView addSubviews:@{@"shadowView":self.shadowView}
            withVisualConstraints:@[
                                    @"H:|[shadowView]|",
                                    
                                    @"V:|[shadowView]|"
                                    ]];

        // add pan gesture recognizer
        self.pullbarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(handlePullbarPan:)];
        self.pullbarPanGestureRecognizer.delegate = self;
        [_pullbarView addGestureRecognizer:self.pullbarPanGestureRecognizer];
    }
    return _pullbarView;
}

#pragma mark - Gesture recognizer actions

- (void)handlePullbarTap:(UITapGestureRecognizer*)gestureRecognizer
{
    [self.pullbarDelegate didTapPullbarInCard:self];
}

- (void)handlePullbarPan:(UIPanGestureRecognizer*)recognizer
{
    CGFloat xTranslation = kTranslationPowerFactor * [recognizer translationInView:self.contentView].x;

    self.pullbarTail.backgroundColor = xTranslation > 0 ? [UIColor wdprBlueColor] : [UIColor clearColor];

    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.snapshotView = [[UIImageView alloc] initWithImage:self.contentView.imageOfSelf];
            [self.contentView addSubview:self.snapshotView];
            if (self.pullbarDelegate)
            {
                [self.pullbarDelegate didBeginPullGestureRecognizer:recognizer
                                                             inCard:self];
            }

            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            self.pullbarView.hidden = YES;
            CGRect rect = self.snapshotView.frame;
            rect.origin.x = -xTranslation;
            self.snapshotView.frame = rect;

            break;
        }
        case  UIGestureRecognizerStateCancelled:
        {
            [self removeSnapshotView];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:kResetAnimationDuration animations:^
             {
                 CGRect rect = self.snapshotView.frame;
                 rect.origin.x = 0;
                 self.snapshotView.frame = rect;
             }
                             completion:^(BOOL finished)
             {
                 [self removeSnapshotView];
             }];

            break;
        }
        default: break;
    }
}

- (void)removeSnapshotView
{
    [self.snapshotView removeFromSuperview];
    self.snapshotView = nil;
    self.pullbarView.hidden = NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // NOTE: This method needs to be implemented and return NO to prevent the standard cell
    // tap gesture recognizer from firing when the custom pullbar tap gesture recognizer fires.
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)recognizer
{
    if (recognizer == self.pullbarPanGestureRecognizer)
    {
        CGPoint translation = [self.pullbarPanGestureRecognizer translationInView:self.contentView];
        return fabs(translation.x) > fabs(translation.y);
    }
    else
    {
        return (recognizer == self.pullbarTapGestureRecognizer);
    }
}

@end
