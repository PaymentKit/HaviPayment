//
//  WDPRIcon.m
//  DLR
//
//  Created by Pierce, Owen on 3/3/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

#import <CoreText/CoreText.h>

#if !(DEBUG || PRERELEASE)
#define kHighlightIcons NO
#else
#define kHighlightIcons \
[NSUserDefaults.standardUserDefaults \
boolForKey:@"highlightPeptasiaIcons"]
#endif

// The font has wacky ascender/descender values.
// These two constants workaround that.
#define kFontGlyphOverflow (0.5 * self.pointSize)// 18 for 40pt
#define kGlyphOverflowAdjustment (kFontGlyphOverflow/2)

@interface WDPRIcon ()

@property (nonatomic) UILabel *label;

@end // @interface WDPRIcon ()

#pragma mark -

@implementation WDPRIcon

PassthroughProperty(BOOL, isHighlighted, 
                    setHighlighted, self.label)
PassthroughProperty(UIColor*, backgroundColor, 
                    setBackgroundColor, self.label)


PassthroughGetter(UIFont*, font, self.label)
PassthroughGetter(BOOL, isEnabled, self.label)
PassthroughGetter(CGFloat, pointSize, self.label.font)

- (id)initWithID:(WDPRIconID)iconID
{
    self = [super init];
    
    if (self)
    {
        self.clipsToBounds = YES;
        self.isAccessibilityElement = NO;
        self.userInteractionEnabled = NO;
        self.backgroundColor = UIColor.clearColor;
        
        _label = [[UILabel alloc] 
                  initWithFrame:CGRectZero];

        _label.isAccessibilityElement = NO;
        
        _disabledColor = [UIColor.wdprBlueColor
                          colorWithAlphaComponent:0.3];
        
        _label.backgroundColor = UIColor.clearColor;
        _label.textAlignment = NSTextAlignmentCenter;
        
        self.defaultColor = (kHighlightIcons ?
                             UIColor.cyanColor : 
                             UIColor.wdprBlueColor);
        
        self.highlightedColor = UIColor.wdprDarkBlueColor;
        
        [_label setText:
         [NSString stringWithCharacters:&iconID length:1]];

        [self setFont: // this calls sizeToFit
         [UIFont fontWithName:WDPRIcon.fontName size:40]];
        
        [self addSubview:_label];
     }
    
    return self;
}

+ (void)loadPeptasiaFont
{
    NSData *inData = [NSData dataWithContentsOfFile:[[WDPRFoundation wdprCoreResourceBundle] pathForResource:@"PEPIconFont"
                                                                                                      ofType:@"otf"]];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    
    if (!CTFontManagerRegisterGraphicsFont(font, &error))
    {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    
    CFRelease(font);
    CFRelease(provider);
}

+ (NSString*)fontName
{
    return [UIFont fontNamesForFamilyName:@"Untitled"].firstObject;
}

+ (instancetype)iconWithID:(WDPRIconID)iconID
{
    return [[self alloc] initWithID:iconID];
}

+ (instancetype)iconWithID:(WDPRIconID)iconID 
                  andColor:(UIColor*)defaultColor
{
    WDPRIcon* icon = [self iconWithID:iconID];
    
    icon.defaultColor = (!kHighlightIcons ?
                         defaultColor : UIColor.cyanColor);
    
    return icon;
}

+ (UIImage*)imageOfIcon:(WDPRIconID)iconID 
              withColor:(UIColor*)defaultColor 
                andSize:(CGSize)sizeOfImage
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectWithSize(sizeOfImage)];    
    WDPRIcon* icon = [self iconWithID:iconID andColor:defaultColor];
    
    [view addSubview:icon];
    icon.frame = view.bounds;
    icon.center = view.center;
    
    return view.imageOfSelf;
}

+ (UIImage*)imageOfEmbeddedIcon:(WDPRIconID)iconID
                      withColor:(UIColor*)defaultColor
                      imageSize:(CGSize)sizeOfImage
                       iconSize:(CGSize)sizeOfIcon
{
    if (sizeOfIcon.height > sizeOfImage.height || sizeOfIcon.width > sizeOfImage.width)
    {
        return nil;
    }
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectWithSize(sizeOfImage)];
    WDPRIcon* icon = [self iconWithID:iconID andColor:defaultColor];
    
    icon.frame = CGRectWithSize(sizeOfIcon);
    icon.center = view.center;
    [view addSubview:icon];    
    return view.imageOfSelf;
}

+ (void)renderIcon:(WDPRIconID)iconID
         withColor:(UIColor*)defaultColor
            inRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIView *view = [[UIView alloc] initWithFrame:CGRectWithSize(rect.size)];
    WDPRIcon *icon = [self iconWithID:iconID andColor:defaultColor];
    
    [view addSubview:icon];
    icon.frame = view.bounds;
    icon.center = view.center;
    CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
    view.layer.contentsScale = [UIScreen mainScreen].scale;
    [view.layer renderInContext:ctx];
    CGContextTranslateCTM(ctx, -rect.origin.x, -rect.origin.y);
}

+ (UIImage*)imageOfIcon:(WDPRIconID)iconID 
              withColor:(UIColor *)defaultColor 
             background:(UIColor*)backgroundColor 
            andDiameter:(CGFloat)circleDiameter
{
    return [self imageOfIcon:iconID 
                   withColor:defaultColor 
                  background:backgroundColor 
                    diameter:circleDiameter 
                  percentage:0.5];
}

+ (UIImage*)imageOfIcon:(WDPRIconID)iconID
              withColor:(UIColor *)defaultColor
             background:(UIColor*)backgroundColor
               diameter:(CGFloat)circleDiameter
             percentage:(CGFloat)iconPercentage
{
    UIImageView* iconView =
    [[UIImageView alloc] initWithFrame:
     CGRectMake(0, 0, circleDiameter, circleDiameter)];
    
    iconView.clipsToBounds = YES;
    iconView.backgroundColor = backgroundColor;
    iconView.contentMode = UIViewContentModeCenter;
    iconView.layer.cornerRadius = circleDiameter/2;
    
    [iconView setImage:
     [WDPRIcon imageOfIcon:iconID withColor:defaultColor
                   andSize:CGSizeMake(circleDiameter * iconPercentage,
                                      circleDiameter * iconPercentage)]];
    
    return iconView.imageOfSelf;
}

#pragma mark -

- (WDPRIconID)code
{
    return (!self.label.text.length ? 0 :
            [self.label.text characterAtIndex:0]);
}

- (void)setCode:(WDPRIconID)code
{
    [self.label setText:
     [NSString stringWithCharacters:&code length:1]];
    
    [self sizeToFit];
}

- (void)setFont:(UIFont*)font
{
    self.label.font = font;
    [self sizeToFit];
}

- (void)sizeToFit
{
    if (self.label.text.length)
    {
        [self.label sizeToFit];
        
        CGRect tmp = self.label.bounds;
        
        tmp = CGRectOffset(tmp, 
                           CGRectGetMinX(self.frame), 
                           CGRectGetMinY(self.frame));
        
        // see note at top of this file
        [self.label setFrame:
         CGRectGrow(self.label.bounds, 
                    kFontGlyphOverflow, CGRectMaxYEdge)];
        
        // call super's setFrame to avoid infinite loop
        // that would happen if we called our override
        [super setFrame: // (exlude descender & overflow from frame)
         CGRectGrow(tmp, self.font.descender + 
                    kGlyphOverflowAdjustment, CGRectMaxYEdge)];
    }
}

- (void)setFrame:(CGRect)frame
{
    // only origin and height are utilized
    // frame is actually set inside sizeToFit
    
    // (ignore font descender & overflow)
    self.pointSize = (CGRectGetHeight(frame) - 
                      self.font.descender - 
                      kGlyphOverflowAdjustment);
    
    super.frame = CGRectOffset(self.bounds, 
                               CGRectGetMinX(frame), 
                               CGRectGetMinY(frame));
}

- (void)setBounds:(CGRect)bounds
{
    CGPoint origin = self.frame.origin;
    self.frame = CGRectOffset(bounds, origin.x, origin.y);
}

- (void)setEnabled:(BOOL)enabled
{
    self.label.enabled = enabled;
    
    [self.label setTextColor:
     (enabled || !self.disabledColor) ? 
     self.defaultColor : self.disabledColor];
}

- (void)setPointSize:(CGFloat)pointSize
{
    // this adjusts the frame as well
    self.font = [self.font fontWithSize:pointSize];
}

- (void)setDefaultColor:(UIColor *)defaultColor
{
    self.label.textColor = _defaultColor = defaultColor;
}

- (UIColor*)highlightedColor
{
    return self.label.highlightedTextColor;
}

- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    self.label.highlightedTextColor = highlightedColor;
}

@end // @implementation WDPRIcon

#pragma mark -

@interface WDPRIconSampler : WDPRTableController

@property (nonatomic) UIColor* iconColor;

@end // @interface WDPRIconSampler

@implementation WDPRIconSampler

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

#define itemData(iconID) metaData(iconID, @""#iconID)

- (NSArray*)initialData
{
    MAKE_WEAK(self);
    NSDictionary* (^metaData)(WDPRIconID, NSString*) = 
    ^(WDPRIconID iconID, NSString* iconConstantName)
    {
        UILabel* hexCode = [[UILabel alloc] 
                         initWithFrame:CGRectZero];
        
        [hexCode applyStyle:WDPRTextStyleC1D];
        hexCode.text = [NSString stringWithFormat:@"0x%X", iconID];
        
        [hexCode sizeToFit];
        
        return
        @{
                WDPRCellTitle : iconConstantName,
                WDPRCellAccessoryView : hexCode,
                WDPRCellLeftAccessoryView : [WDPRIcon iconWithID:iconID],

                WDPRCellConfigurationBlock : ^(WDPRTableViewCell * cell)
          {
              MAKE_STRONG(self);
              [(WDPRIcon*)cell.leftAccessoryView
               setDefaultColor:strongself.iconColor];
          }
          };
    };
    
    return @[
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.accessibility", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconWheelchair),
                         itemData(WDPRIconWheelchairFromECV),
                         itemData(WDPRIconWheelchairToECV),
                         itemData(WDPRIconWheelchairThenRide),
                         itemData(WDPRIconAmbulatory),
                         itemData(WDPRIconVisualImpairment),
                         itemData(WDPRIconHearingAid),
                         itemData(WDPRIconSignLanguage),
                         itemData(WDPRIconAudioDescription),
                         itemData(WDPRIconHandheldCaptioning),
                         itemData(WDPRIconReflectiveCaptioning),
                         itemData(WDPRIconVideoCaptioning),
                         itemData(WDPRIconPhysicalConsiderations),
                         itemData(WDPRIconScaryConsiderations),
                         itemData(WDPRIconMobilityDisabilitiesDLP),
                         itemData(WDPRIconHearingDisabilitiesDLP),
                         itemData(WDPRIconVisualDisabilitiesDLP),
                         itemData(WDPRIconPhotosensitive),
                         itemData(WDPRIconMentalDisabilities),
                         itemData(WDPRIconSuitableAmputees),
                         itemData(WDPRIconSuitableDifficultyStanding),
                         itemData(WDPRIconCapableClimbingSteps),
                         itemData(WDPRIconServiceForDisabilityGuest),
                         itemData(WDPRIconGuideBookDisabilityGuest),
                         itemData(WDPRIconWheelchairRental),
                         itemData(WDPRIconAccessForDisabilities),
                         itemData(WDPRIconMayRemainInWheelchair),
                         itemData(WDPRIconMustBeAmbulatoryNew),
                         itemData(WDPRIconSuitableForBlindGuest),
                         itemData(WDPRIconSuitableForAutismGuest),
                         itemData(WDPRIconSignLanguageNew),
                         itemData(WDPRIconTactileMaps),
                         itemData(WDPRIconBrailleGuideBooks),
                         itemData(WDPRIconSuitableLearningDisability),
                         itemData(WDPRIconInductionLoop),
                         itemData(WDPRIconSpaceDimlyLit),
                         itemData(WDPRIconLightRainIndoors),
                         itemData(WDPRIconShowContainsBubbles),
                         itemData(WDPRIconHealthDisorder),
                         itemData(WDPRIconOpenCaptioning)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.activities", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconAllActivities),
                         itemData(WDPRIconAttractions),
                         itemData(WDPRIconCharacters),
                         itemData(WDPRIconEntertainment),
                         itemData(WDPRIconEvents),
                         itemData(WDPRIconShopping),
                         itemData(WDPRIconSpas),
                         itemData(WDPRIconParisTours),
                         itemData(WDPRIconOutdoorActivities),
                         itemData(WDPRIconAttractionsDLP),
                         itemData(WDPRIconCharactersMeetDLP),
                         itemData(WDPRIconMeetingsEvents),
                         itemData(WDPRIconTours),
                         itemData(WDPRIconSpringBreak)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.headerbrand", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconUnusedCharacter),
                         itemData(WDPRIconDLR),
                         itemData(WDPRIconDCA),
                         itemData(WDPRIconDLP),
                         itemData(WDPRIconSHDR),
                         itemData(WDPRIconHKDL),
                         itemData(WDPRIconTDR),
                         itemData(WDPRIconAulaniResort),
                         itemData(WDPRIconAdventuresByDisney),
                         itemData(WDPRIconDisneyParkGeneric),
                         itemData(WDPRIconLeadership),
                         itemData(WDPRIconTraining),
                         itemData(WDPRIconQualityService),
                         itemData(WDPRIconBrandLoyalty),
                         itemData(WDPRIconInnovation),
                         itemData(WDPRIconBusinessExcellence),
                         itemData(WDPRIconMedicalExcellence),
                         itemData(WDPRIconCatalogs),
                         itemData(WDPRIconDisneyPark),
                         itemData(WDPRIconDLR2),
                         itemData(WDPRIconCityHallServices),
                         itemData(WDPRIconMagicalAccess),
                         itemData(WDPRIconDowntownDisney),
                         itemData(WDPRIconWeddingEngagements),
                         itemData(WDPRIconWeddingsEverAfterBlog),
                         itemData(WDPRIconBridalBoutique),
                         itemData(WDPRIconDisneyTownSHDR),
                         itemData(WDPRIconWishingStarParkSHDR),
                         itemData(WDPRIconStoreDisneyParksApp),
                         itemData(WDPRIconShopDisneyParksBag)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.commercetickets", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconCartEmpty),
                         itemData(WDPRIconCartFull),
                         itemData(WDPRIconTickets),
                         itemData(WDPRIconTicketSales),
                         itemData(WDPRIconFastPassPlus),
                         itemData(WDPRIconFastPassMake),
                         itemData(WDPRIconFastPassCopy),
                         itemData(WDPRIconFastPassCancel),
                         itemData(WDPRIconWaterPark),
                         itemData(WDPRIconSuitcase),
                         itemData(WDPRIconMyMagic),
                         itemData(WDPRIconFlorida),
                         itemData(WDPRIconDVC),
                         itemData(WDPRIconKey),
                         itemData(WDPRIconUSMilitary),
                         itemData(WDPRIconSpecialOffers),
                         itemData(WDPRIconBookingRooms),
                         itemData(WDPRIconFastPass),
                         itemData(WDPRIconVoucher),
                         itemData(WDPRIconWillCallTickets),
                         itemData(WDPRIconMainPass),
                         itemData(WDPRIconGuestPass),
                         itemData(WDPRIconCityPassDLR),
                         itemData(WDPRIconCalifornia),
                         itemData(WDPRIconSouthernCal),
                         itemData(WDPRIconETicket),
                         itemData(WDPRIconCompareOffers),
                         itemData(WDPRIconBajaCalifornia),
                         itemData(WDPRIconAreaAttractions),
                         itemData(WDPRIconAnaheimResortTransit),
                         itemData(WDPRIconEditFastPass),
                         itemData(WDPRIconSpecialPricingDLP),
                         itemData(WDPRIconFiscalChangesDLP),
                         itemData(WDPRIconInParkMerch),
                         itemData(WDPRIconTravelInsurance),
                         itemData(WDPRIconTexasResident),
                         itemData(WDPRIconCanadianResident),
                         itemData(WDPRIconAddTickets),
                         itemData(WDPRIconSplurge),
                         itemData(WDPRIconDisneylandAP),
                         itemData(WDPRIconTicketsAndPassesDLR),
                         itemData(WDPRIconVacationOfferRecommend),
                         itemData(WDPRIconVacationOfferCreated),
                         itemData(WDPRIconFastPassSHDR),
                         itemData(WDPRIconLinkTicketsWDW),
                         itemData(WDPRIconMyTicketsWDW),
                         itemData(WDPRIconAnnualPassBlockout),
                         itemData(WDPRIconLinkResortReservations),
                         itemData(WDPRIconCurrencyConvertor),
                         itemData(WDPRIconRenewAnnualPassWDW),
                         itemData(WDPRIconRenewAnnualPassDLR),
                         itemData(WDPRIconAnnualPassesWDW),
                         itemData(WDPRIconMobileOrder),
                         itemData(WDPRIconLinkTicketsDLR)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.dcl", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconDCL),
                         itemData(WDPRIconShipsDCL),
                         itemData(WDPRIconDestinationsDCL),
                         itemData(WDPRIconOnboardFunDCL),
                         itemData(WDPRIconNewCruisersDCL),
                         itemData(WDPRIconPortAdventuresDCL),
                         itemData(WDPRIconAppInstructions),
                         itemData(WDPRIconFeaturedArticle),
                         itemData(WDPRIconDrinkOfTheDay),
                         itemData(WDPRIconDeckPlans),
                         itemData(WDPRIconViewFolio),
                         itemData(WDPRIconKeyToTheWorld),
                         itemData(WDPRIconInRoomEntertainment),
                         itemData(WDPRIconShipDirectory),
                         itemData(WDPRIconTheatre),
                         itemData(WDPRIconSuitcaseCheckmark),
                         itemData(WDPRIconYouthActivities),
                         itemData(WDPRIconTeenActivities),
                         itemData(WDPRIconAdultActivities),
                         itemData(WDPRIconYouthClubs),
                         itemData(WDPRIconColdAndFlu),
                         itemData(WDPRIconSecurityNotice),
                         itemData(WDPRIconEnvironmentalMessage),
                         itemData(WDPRIconRotationalDining),
                         itemData(WDPRIconRoomUpgrade),
                         itemData(WDPRIconRemyRawFoods),
                         itemData(WDPRIconCastawayClub)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.dining", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconDining),
                         itemData(WDPRIconBookDining),
                         itemData(WDPRIconLinkDining),
                         itemData(WDPRIconSolidCircleCheckmark),
                         itemData(WDPRIconFastPassBlocked),
                         itemData(WDPRIconDiningReservations),
                         itemData(WDPRIconDiningMenu),
                         itemData(WDPRIconPrixFixeQSR),
                         itemData(WDPRIconPrixFixeTSR),
                         itemData(WDPRIconEntreesQSR),
                         itemData(WDPRIconPlaceOrder),
                         itemData(WDPRIconBeverages),
                         itemData(WDPRIconWine),
                         itemData(WDPRIconBeer),
                         itemData(WDPRIconCocktails),
                         itemData(WDPRIconAppetizers),
                         itemData(WDPRIconSandwiches),
                         itemData(WDPRIconBeefPorkChicken),
                         itemData(WDPRIconSeafood),
                         itemData(WDPRIconPasta),
                         itemData(WDPRIconSalads),
                         itemData(WDPRIconSides),
                         itemData(WDPRIconDesserts),
                         itemData(WDPRIconBuffet),
                         itemData(WDPRIconFavorites),
                         itemData(WDPRIconKidsPicks),
                         itemData(WDPRIconFeaturedItems),
                         itemData(WDPRIconNutritionalContent),
                         itemData(WDPRIconNutritionalInfo),
                         itemData(WDPRIconGlutenFree),
                         itemData(WDPRIconDairyFree),
                         itemData(WDPRIconCharacterMeals),
                         itemData(WDPRIconMickeyHeadCheckmark),
                         itemData(WDPRIconSpecialDietaryNeeds),
                         itemData(WDPRIconPrioritySeating),
                         itemData(WDPRIconVegetarian),
                         itemData(WDPRIconRawFoods),
                         itemData(WDPRIconGuestFavorite),
                         itemData(WDPRIconOrderFood)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.dlp", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconDLP2),
                         itemData(WDPRIconHotelRating1Key),
                         itemData(WDPRIconHotelRating2Key),
                         itemData(WDPRIconHotelRating3Key),
                         itemData(WDPRIconHotelRating4Key),
                         itemData(WDPRIconHotelRating5Key),
                         itemData(WDPRIconHotelRating1Star),
                         itemData(WDPRIconHotelRating2Star),
                         itemData(WDPRIconHotelRating3Star),
                         itemData(WDPRIconHotelRating4Star),
                         itemData(WDPRIconHotelRating5Star),
                         itemData(WDPRIconDistanceWalk0Min),
                         itemData(WDPRIconDistanceWalk5Min),
                         itemData(WDPRIconDistanceWalk10Min),
                         itemData(WDPRIconDistanceWalk15Min),
                         itemData(WDPRIconDistanceWalk20Min),
                         itemData(WDPRIconDistanceCar15Min),
                         itemData(WDPRIconDistanceBus10Min),
                         itemData(WDPRIconAnnualPassDLP),
                         itemData(WDPRIconHotelsDLP),
                         itemData(WDPRIconDisneyParkParis),
                         itemData(WDPRIconWaltDisneyStudiosParis),
                         itemData(WDPRIconCityHallServicesDLP),
                         itemData(WDPRIconDisneyVillageDLP),
                         itemData(WDPRIconForumDLP),
                         itemData(WDPRIconCallDLP),
                         itemData(WDPRIconLiveChatDLP),
                         itemData(WDPRIconStandardMealPlanDLP),
                         itemData(WDPRIconHotelMealPlanDLP),
                         itemData(WDPRIconPlusMealPlanDLP),
                         itemData(WDPRIconPremiumMealPlanDLP)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.guestservices", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconMap),
                         itemData(WDPRIconInfo),
                         itemData(WDPRIconConcierge),
                         itemData(WDPRIconResortCheckIn),
                         itemData(WDPRIconCelebration),
                         itemData(WDPRIconAED),
                         itemData(WDPRIconSmokingArea),
                         itemData(WDPRIconNoSmoking),
                         itemData(WDPRIconLostAndFound),
                         itemData(WDPRIconBabyCare),
                         itemData(WDPRIconBabyCareCenter),
                         itemData(WDPRIconCribsAndPlaypens),
                         itemData(WDPRIconCurrencyExchange),
                         itemData(WDPRIconATM),
                         itemData(WDPRIconRestroom),
                         itemData(WDPRIconFirstAid),
                         itemData(WDPRIconEpiPen),
                         itemData(WDPRIconLaundry),
                         itemData(WDPRIconValet),
                         itemData(WDPRIconInRoomBabysitting),
                         itemData(WDPRIconInRoomRefrigerator),
                         itemData(WDPRIconBusinessCenter),
                         itemData(WDPRIconCabanas),
                         itemData(WDPRIconECVRentals),
                         itemData(WDPRIconStrollerRentals),
                         itemData(WDPRIconParking),
                         itemData(WDPRIconKennel),
                         itemData(WDPRIconPackagePickup),
                         itemData(WDPRIconGasStation),
                         itemData(WDPRIconPinTrading),
                         itemData(WDPRIconTranslationDevices),
                         itemData(WDPRIconWeddingCeremonies),
                         itemData(WDPRIconResortAmenities),
                         itemData(WDPRIconMoviesUnderStars),
                         itemData(WDPRIconPictureSpot),
                         itemData(WDPRIconLockerRentals),
                         itemData(WDPRIconHereAndNow),
                         itemData(WDPRIconStarTrek),
                         itemData(WDPRIconSuperviseChildren),
                         itemData(WDPRIconRiderSwap),
                         itemData(WDPRIconServiceAnimals),
                         itemData(WDPRIconFreeDisneyWifi),
                         itemData(WDPRIconGenericWifi),
                         itemData(WDPRIconVIPService),
                         itemData(WDPRIconBunkBeds),
                         itemData(WDPRIconRoomService),
                         itemData(WDPRIconKitchen),
                         itemData(WDPRIconLocationPin),
                         itemData(WDPRIconExpectantMothers),
                         itemData(WDPRIconDisneyExpressLuggage),
                         itemData(WDPRIconPetServices),
                         itemData(WDPRIconStorageSpecialProducts),
                         itemData(WDPRIconPicnicAreaNew),
                         itemData(WDPRIconBreakfastChalet),
                         itemData(WDPRIconConventionCenter),
                         itemData(WDPRIconInternetPoints),
                         itemData(WDPRIconGuestStorage),
                         itemData(WDPRIconFenceCode),
                         itemData(WDPRIconNikonPictureSpot),
                         itemData(WDPRIconATMNew),
                         itemData(WDPRIconDrinkingFountains),
                         itemData(WDPRIconPackageExpress),
                         itemData(WDPRIconKingdomClubBellman),
                         itemData(WDPRIconBoardInfo),
                         itemData(WDPRIconMagicalCoinMachine),
                         itemData(WDPRIconStrollerParking),
                         itemData(WDPRIconElectricCarCharge),
                         itemData(WDPRIconParadeShowArea),
                         itemData(WDPRIconMobileChargingStation),
                         itemData(WDPRIconDisneyFloralAndGifts)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.guestservices2", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconSingleRider),
                         itemData(WDPRIconATMChina),
                         itemData(WDPRIconManeuverSlightLeft),
                         itemData(WDPRIconManeuverSlightRight),
                         itemData(WDPRIconManeuverTurnLeft),
                         itemData(WDPRIconManeuverTurnRight),
                         itemData(WDPRIconManeuverHardLeft),
                         itemData(WDPRIconManeuverHardRight),
                         itemData(WDPRIconManeuverLeft),
                         itemData(WDPRIconManeuverRight),
                         itemData(WDPRIconManeuverForward),
                         itemData(WDPRIconManeuverBack),
                         itemData(WDPRIconManeuverForwardBack),
                         itemData(WDPRIconManeuverRightLeft),
                         itemData(WDPRIconManeuverAroundSlightLeft),
                         itemData(WDPRIconManeuverAroundSlightRight),
                         itemData(WDPRIconManeuverAroundTurnLeft),
                         itemData(WDPRIconManeuverAroundTurnRight),
                         itemData(WDPRIconManeuverAroundHardLeft),
                         itemData(WDPRIconManeuverAroundHardRight),
                         itemData(WDPRIconManeuverAroundLeft),
                         itemData(WDPRIconManeuverAroundRight),
                         itemData(WDPRIconManeuverAroundForwardLeft),
                         itemData(WDPRIconManeuverAroundForwardRight),
                         itemData(WDPRIconManeuverUTurnRight),
                         itemData(WDPRIconManeuverUTurnLeft),
                         itemData(WDPRIconManeuverRampLeft),
                         itemData(WDPRIconManeuverRampRight),
                         itemData(WDPRIconManeuverForkLeft),
                         itemData(WDPRIconManeuverForkRight),
                         itemData(WDPRIconManeuverAroundAboutLeft),
                         itemData(WDPRIconManeuverAroundAboutRight),
                         itemData(WDPRIconManeuverMerge),
                         itemData(WDPRIconRepellant),
                         itemData(WDPRIconHurricaneInformation),
                         itemData(WDPRIconCourtesyStarSHDR)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.interactive", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconClose),
                         itemData(WDPRIconAdd),
                         itemData(WDPRIconInfo2),
                         itemData(WDPRIconShare),
                         itemData(WDPRIconSave),
                         itemData(WDPRIconShowFilters),
                         itemData(WDPRIconHideFilters),
                         itemData(WDPRIcon3DSpin),
                         itemData(WDPRIconPlay),
                         itemData(WDPRIconPause),
                         itemData(WDPRIconInfoPDF),
                         itemData(WDPRIconInfoDuplicateOffer),
                         itemData(WDPRIconRightCaret),
                         itemData(WDPRIconLeftCaret),
                         itemData(WDPRIconRightTriangle),
                         itemData(WDPRIconPrint),
                         itemData(WDPRIconSearch),
                         itemData(WDPRIconCalendarDay),
                         itemData(WDPRIconCalendar),
                         itemData(WDPRIconMore),
                         itemData(WDPRIconHamburger),
                         itemData(WDPRIconMinus),
                         itemData(WDPRIconDownTriangle),
                         itemData(WDPRIconUpload),
                         itemData(WDPRIconList),
                         itemData(WDPRIconFilter),
                         itemData(WDPRIconBarcode),
                         itemData(WDPRIconKeyboard),
                         itemData(WDPRIconDownloadMobileApp),
                         itemData(WDPRIconViewGallery),
                         itemData(WDPRIconSeeInfoPage),
                         itemData(WDPRIconMediaGalleryPhotos),
                         itemData(WDPRIconMediaGalleryVideo),
                         itemData(WDPRIconRefresh),
                         itemData(WDPRIconComposeMessage),
                         itemData(WDPRIconAddContact),
                         itemData(WDPRIconContactList),
                         itemData(WDPRIconUpTriangle),
                         itemData(WDPRIconLeftTriangle),
                         itemData(WDPRIconMobileApp),
                         itemData(WDPRIconShopDisneyParksApp),
                         itemData(WDPRIconBreadcrumbHomeIcon),
                         itemData(WDPRIconGoBackTo),
                         itemData(WDPRIconRelatedItems),
                         itemData(WDPRIconTrash),
                         itemData(WDPRIconFForward),
                         itemData(WDPRIconRewind),
                         itemData(WDPRIconPullDown),
                         itemData(WDPRIconIncrease),
                         itemData(WDPRIconDecrease),
                         itemData(WDPRIconTurnOver),
                         itemData(WDPRIconLeftCaret2),
                         itemData(WDPRIconRightCaret2),
                         itemData(WDPRIconBack),
                         itemData(WDPRIconUp),
                         itemData(WDPRIconDown),
                         itemData(WDPRIconExpandGallery),
                         itemData(WDPRIcon360Video),
                         itemData(WDPRIconVolumeControl),
                         itemData(WDPRIconAppCardInformation),
                         itemData(WDPRIconAppCardFlip)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.media", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconMyMedia),
                         itemData(WDPRIconImages),
                         itemData(WDPRIconVideos),
                         itemData(WDPRIconPhotoPass2),
                         itemData(WDPRIconPhotoPass),
                         itemData(WDPRIconMediaFavorites),
                         itemData(WDPRIconPhotoFun),
                         itemData(WDPRIconScan),
                         itemData(WDPRIconDVD),
                         itemData(WDPRIconPhotoPassSHDR)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.helpsupport", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconAlert),
                         itemData(WDPRIconPlainCheckmark),
                         itemData(WDPRIconFAQs),
                         itemData(WDPRIconQuickAnswer),
                         itemData(WDPRIconDisneyParksBlog),
                         itemData(WDPRIconSMS),
                         itemData(WDPRIconPressCenter),
                         itemData(WDPRIconMomsPanel),
                         itemData(WDPRIconTimesGuide),
                         itemData(WDPRIconClock),
                         itemData(WDPRIconLock),
                         itemData(WDPRIconDocument),
                         itemData(WDPRIconWheelchair2),
                         itemData(WDPRIconPreArrivalTips),
                         itemData(WDPRIconReservations),
                         itemData(WDPRIconHollowSquareCheckmark),
                         itemData(WDPRIconHelp),
                         itemData(WDPRIconQuestionMark),
                         itemData(WDPRIconMail),
                         itemData(WDPRIconChat),
                         itemData(WDPRIconCall),
                         itemData(WDPRIconDaysNotice14),
                         itemData(WDPRIconDaysNotice6),
                         itemData(WDPRIconBlockOutDates),
                         itemData(WDPRIconDaysNotice3),
                         itemData(WDPRIconWebsiteSupport),
                         itemData(WDPRIconRestriction),
                         itemData(WDPRIconRecommendations),
                         itemData(WDPRIconDash),
                         itemData(WDPRIconMagicalMornings),
                         itemData(WDPRIconGlobalLanguages),
                         itemData(WDPRIconGoodNeighborHotel),
                         itemData(WDPRIconCheckInTimesLuggage),
                         itemData(WDPRIconTravelInfo),
                         itemData(WDPRIconVisitingWithGroups),
                         itemData(WDPRIconVisitingWithChildren),
                         itemData(WDPRIconBookByPhoneOrOnline),
                         itemData(WDPRIconEmergencyPhone),
                         itemData(WDPRIconDisneyLikeLight),
                         itemData(WDPRIconDisneyLikeDark),
                         itemData(WDPRIconWrittenAids),
                         itemData(WDPRIconGenerationsTravel),
                         itemData(WDPRIconEmptyChat),
                         itemData(WDPRIconFilledChat),
                         itemData(WDPRIconEmptyCheckbox),
                         itemData(WDPRIconSelectedSolidCheckbox),
                         itemData(WDPRIconSelectedDisabled),
                         itemData(WDPRIconIndeterminate),
                         itemData(WDPRIconTenCalendarDays)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.miscellaneous", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconGifts),
                         itemData(WDPRIconCharacterCalls),
                         itemData(WDPRIconPerformingArts),
                         itemData(WDPRIconEducation),
                         itemData(WDPRIconLock2),
                         itemData(WDPRIconFacebook),
                         itemData(WDPRIconTwitter),
                         itemData(WDPRIconYoutube),
                         itemData(WDPRIconInstagram),
                         itemData(WDPRIconPinterest),
                         itemData(WDPRIconGooglePlus),
                         itemData(WDPRIconDisneyCast),
                         itemData(WDPRIconDisneyResponse),
                         itemData(WDPRIconGenieLamp),
                         itemData(WDPRIconThrillServices),
                         itemData(WDPRIconCarthayCircleDCA),
                         itemData(WDPRIconDoll),
                         itemData(WDPRIconFrontDesk),
                         itemData(WDPRIconMovies),
                         itemData(WDPRIconUnlocked),
                         itemData(WDPRIconTumbler),
                         itemData(WDPRIconServices),
                         itemData(WDPRIconPhotoPassOld),
                         itemData(WDPRIconSinaWeiboHKDL),
                         itemData(WDPRIconBaiduTiebaHKDL),
                         itemData(WDPRIconWechatHKDL),
                         itemData(WDPRIconWildAboutSafety),
                         itemData(WDPRIconRomanticCelebration),
                         itemData(WDPRIconFacebookAlone),
                         itemData(WDPRIconTwitterAlone),
                         itemData(WDPRIconSnapchat),
                         itemData(WDPRIconPhotopassAttractionID)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.profile", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconMDX),
                         itemData(WDPRIconProfile),
                         itemData(WDPRIconFriends),
                         itemData(WDPRIconSettings),
                         itemData(WDPRIconMagicBand),
                         itemData(WDPRIconMagicCards),
                         itemData(WDPRIconPaymentCards),
                         itemData(WDPRIconCommPreferences),
                         itemData(WDPRIconFavorite),
                         itemData(WDPRIconLinkReservations),
                         itemData(WDPRIconModify),
                         itemData(WDPRIconBirthday),
                         itemData(WDPRIconMemoryMaker),
                         itemData(WDPRIconMemoryMaker2),
                         itemData(WDPRIconPassesMemberships)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.sportsrecreation", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconSportsRecreation),
                         itemData(WDPRIconCampfire),
                         itemData(WDPRIconSnorkeling),
                         itemData(WDPRIconSwimming),
                         itemData(WDPRIconBoating),
                         itemData(WDPRIconRunning),
                         itemData(WDPRIconFitnessRoom),
                         itemData(WDPRIconGames),
                         itemData(WDPRIconShuffleboard),
                         itemData(WDPRIconParasailing),
                         itemData(WDPRIconPlayground),
                         itemData(WDPRIconHorsebackRiding),
                         itemData(WDPRIconPoolTables),
                         itemData(WDPRIconFishing),
                         itemData(WDPRIconVolleyball),
                         itemData(WDPRIconBasketball),
                         itemData(WDPRIconCycling),
                         itemData(WDPRIconBinoculars),
                         itemData(WDPRIconRecreation),
                         itemData(WDPRIconBaseball),
                         itemData(WDPRIconCheerleading),
                         itemData(WDPRIconFieldHockey),
                         itemData(WDPRIconFootball),
                         itemData(WDPRIconGymnastics),
                         itemData(WDPRIconLacrosse),
                         itemData(WDPRIconCrossCountry),
                         itemData(WDPRIconSoccer),
                         itemData(WDPRIconSoftballFast),
                         itemData(WDPRIconSoftballSlow),
                         itemData(WDPRIconTimer),
                         itemData(WDPRIconTennisCourt),
                         itemData(WDPRIconGenericSports)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.transportation", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconMonorail),
                         itemData(WDPRIconBus),
                         itemData(WDPRIconCar),
                         itemData(WDPRIconBoat),
                         itemData(WDPRIconTaxi),
                         itemData(WDPRIconFlight),
                         itemData(WDPRIconFlightReturn),
                         itemData(WDPRIconWalking),
                         itemData(WDPRIconBusFree),
                         itemData(WDPRIconFlightDLP),
                         itemData(WDPRIconCarDLP),
                         itemData(WDPRIconTrain),
                         itemData(WDPRIconTrainRegional),
                         itemData(WDPRIconBusShuttle),
                         itemData(WDPRIconMTRResortLineHKDL)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.waltdisneyworld", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconWDW),
                         itemData(WDPRIconMK),
                         itemData(WDPRIconEpcot),
                         itemData(WDPRIconDAK),
                         itemData(WDPRIconDHS),
                         itemData(WDPRIconTyphoonLagoon),
                         itemData(WDPRIconBlizzardBeach),
                         itemData(WDPRIconDisneySprings),
                         itemData(WDPRIconESPNWideWorld),
                         itemData(WDPRIconResorts),
                         itemData(WDPRIconResortBuilding),
                         itemData(WDPRIconBeachResorts),
                         itemData(WDPRIconBoardwalk),
                         itemData(WDPRIconAllCategories),
                         itemData(WDPRIconCirqueDuSoleilLaNouba)
                         ]
                 },
             @{
                 WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.table.weather", WDPRCoreResourceBundleName, nil),
                 WDPRTableSectionItems :
                     @[
                         itemData(WDPRIconSunny),
                         itemData(WDPRIconSunnyMostly),
                         itemData(WDPRIconSunnyPartly),
                         itemData(WDPRIconCloudyPartly),
                         itemData(WDPRIconSunnyHazy),
                         itemData(WDPRIconCloudyMostly),
                         itemData(WDPRIconCloudy),
                         itemData(WDPRIconOvercast),
                         itemData(WDPRIconFog),
                         itemData(WDPRIconShowers),
                         itemData(WDPRIconCloudyShowers),
                         itemData(WDPRIconSunnyShowers),
                         itemData(WDPRIconThunder),
                         itemData(WDPRIconCloudyThunder),
                         itemData(WDPRIconSunnyThunder),
                         itemData(WDPRIconShowers2),
                         itemData(WDPRIconFlurries),
                         itemData(WDPRIconCloudyFlurries),
                         itemData(WDPRIconSunnyFlurries),
                         itemData(WDPRIconSnow),
                         itemData(WDPRIconCloudySnow),
                         itemData(WDPRIconIce),
                         itemData(WDPRIconSleet),
                         itemData(WDPRIconFreezingRain),
                         itemData(WDPRIconRainSnow),
                         itemData(WDPRIconHot),
                         itemData(WDPRIconCold),
                         itemData(WDPRIconWindy),
                         itemData(WDPRIconNightClear),
                         itemData(WDPRIconNightCloudy),
                         itemData(WDPRIconNightHazy),
                         itemData(WDPRIconNightCloudyMostly),
                         itemData(WDPRIconNightCloudyShowers),
                         itemData(WDPRIconNightCloudyThunder),
                         itemData(WDPRIconNightCloudyFlurries),
                         itemData(WDPRIconNightCloudySnow),
                         itemData(WDPRIconWinter),
                         itemData(WDPRIconSpring),
                         itemData(WDPRIconSummer),
                         itemData(WDPRIconAutumn),
                         itemData(WDPRIconPackForWeather)
                         ]
                 },
             ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.iconColor = UIColor.wdprBlueColor;
    self.title = WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.title", WDPRCoreResourceBundleName, nil);

    [self.dataDelegate 
     setTableView:self.tableView headerViewFromString:
     htmlify(WDPRLocalizedStringInBundle(@"com.wdprcore.wdpricon.header.message", WDPRCoreResourceBundleName, nil), NO)];
    
    self.dataDelegate.accessoryType = UITableViewCellAccessoryNone;
    self.dataDelegate.selectionStyle = UITableViewCellSelectionStyleNone;

    MAKE_WEAK(self);

    [self.navigationItem setRightBarButtonItem:
     [UIBarButtonItem buttonWithTitle:WDPRLocalizedStringInBundle(@"com.wdprcore.barbuttonitem.changecolor.title", WDPRCoreResourceBundleName, nil) block:
      ^{
          MAKE_STRONG(self);
          __block UIAlertView* alertView;

          void (^changeColor)(void) =
          ^{
              [strongself setIconColor:
               [UIColor colorWithHexString:
                [alertView textFieldAtIndex:0].text]];

              [strongself.tableView reloadData];
          };

          alertView = [UIAlertView showAlertWithTitle:WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewchangecolor.title", WDPRCoreResourceBundleName, nil)
                                              message:WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewchangecolor.message", WDPRCoreResourceBundleName, nil)
                            cancelButtonTitleAndBlock:@[WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewchangecolor.button.cancel", WDPRCoreResourceBundleName, nil)]
                           otherButtonTitlesAndBlocks:@[@[WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewchangecolor.button.ok", WDPRCoreResourceBundleName, nil), changeColor]]];

          alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

          UITextField* textField = [alertView textFieldAtIndex:0];

          textField.textAlignment = NSTextAlignmentCenter;
          textField.text = [UIColor hexValuesFromUIColor:strongself.iconColor];
      }]];
}

@end
