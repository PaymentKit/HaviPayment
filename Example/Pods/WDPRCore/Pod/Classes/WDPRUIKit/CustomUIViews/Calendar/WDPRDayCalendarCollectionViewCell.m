//
//  WDPRDayCalendarCollectionViewCell.m
//  DLR
//
//  Created by Olson, Jason on 4/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRDayCalendarCollectionViewCell.h"
#import "WDPRCalendarDateHelper.h"

#import "WDPRUIKit.h"

static const CGFloat kCircleDiameter = 56.0f;
static const CGFloat kCircleBoundsXY = 0.0f;

static const CGFloat kDayOfWeekWidth = 56.0f;
static const CGFloat kDayOfWeekHeight = 20.0f;

static const CGFloat kCellWidth = 56.0f;
static const CGFloat kCellHeight = 79.0f;
static const CGFloat kMinimumInteritemSpacing = 20.0f;
static const CGFloat kMinimumInterLineSpacing = 12.0f;

static const CGFloat kVPadding = 1.0f;
static const CGFloat kVSpacingTopBottom = 1.0f;
static const CGFloat kWeekDayPadding = 0.0f;
static const CGFloat kDayNumberPadding = 0.0f;
static const CGFloat kSelectedDayNumberTop = kDayOfWeekHeight + kVSpacingTopBottom + kVPadding;

static NSString *const kTransformScale = @"transform.scale";

@interface WDPRDayCalendarCollectionViewCell ()

@property (strong, nonatomic) CAShapeLayer *circleLayer;

@end

#pragma mark -

@implementation WDPRDayCalendarCollectionViewCell

+ (CGSize)cellSize
{
    return CGSizeMake(kCellWidth, kCellHeight);
}

+ (CGFloat)minimumInteritemSpacing
{
    return kMinimumInteritemSpacing;
}

+ (CGFloat)minimumLineSpacing
{
    return kMinimumInterLineSpacing;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _blockOutDate = NO;
        
        NSDictionary *metrics = @{@"dayOfWeekHeight": @(kDayOfWeekHeight),
                                  @"dayLabelHeight": @(kCircleDiameter),
                                  @"dayOfWeekWidth": @(kDayOfWeekWidth),
                                  @"dayLabelWidth": @(kCircleDiameter),
                                  @"vPadding": @(kVPadding),
                                  @"vSpacing": @(kVSpacingTopBottom),
                                  @"weekDayPadding": @(kWeekDayPadding),
                                  @"dayNumPadding": @(kDayNumberPadding),
                                  @"selectedDayNumberTop": @(kSelectedDayNumberTop)
                                  };
        
        NSDictionary *constrainedViews = @{
                                           @"dayOfWeekLabel": self.dayOfWeekLabel,
                                           @"dayLabel": self.dayLabel,
                                           };
        
        NSArray *viewContraints = @[@"V:|-vSpacing-[dayOfWeekLabel(==dayOfWeekHeight)]-vPadding-[dayLabel(==dayLabelHeight)]-vSpacing-|",
                                    @"H:|-weekDayPadding-[dayOfWeekLabel(==dayOfWeekWidth)]-weekDayPadding-|",
                                    @"H:|-dayNumPadding-[dayLabel(==dayLabelWidth)]-dayNumPadding-|"
                                    ];
        [self addConstraintsForView:self contraints:viewContraints constrainedViews:constrainedViews metrics:metrics];

        // Set background selected view to draw our circle in.
        // This will keep the flashing circle while scrolling from happening.
        UIView *selectedBGView = [[UIView alloc] initWithFrame:self.bounds];
        [selectedBGView setTranslatesAutoresizingMaskIntoConstraints:NO];
        selectedBGView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedBGView;
        [self.selectedBackgroundView addSubview:self.dayLabelSelected];
        
        NSDictionary *selectedConstrainedViews = @{ @"dayLabelSelected": self.dayLabelSelected};
        
        NSArray *selectedViewContraints = @[@"V:|-selectedDayNumberTop-[dayLabelSelected(==dayLabelHeight)]-vSpacing-|",
                                   @"H:|-dayNumPadding-[dayLabelSelected(==dayLabelWidth)]-dayNumPadding-|"];
        
        [self addConstraintsForView:self.selectedBackgroundView contraints:selectedViewContraints constrainedViews:selectedConstrainedViews metrics:metrics];

        
        self.dayLabelSelected.layer.mask = [self circleLayer];
        self.dayLabelSelected.layer.position = self.dayLabelSelected.center;
    }
    
    return self;
}

- (void)addConstraintsForView:(UIView *)view contraints:(NSArray *)contraints constrainedViews:(NSDictionary *)constrainedViews metrics:(NSDictionary *)metrics
{
    for (NSString *constraintsString in contraints)
    {
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintsString options:0 metrics:metrics views:constrainedViews]];
    }
}

#pragma mark -

- (void)setDisplayDate:(NSDate *)displayDate
{
    WDPRCalendarDateHelper *dateHelper = [WDPRCalendarDateHelper dateCellInfoForDate:displayDate];
    
    self.dayOfWeekLabel.text = dateHelper.dayOfWeekText;
    self.dayLabel.text = dateHelper.dayNumberAsText;
}

- (void)setBlockOutDate:(BOOL)blockOutDate
{
    _blockOutDate = blockOutDate;
    
    self.dayLabelSelected.backgroundColor = [self circleColor];
    self.dayLabel.textColor = [self dayLabelColor];
    self.dayLabelSelected.backgroundColor = [self circleColor];
}

- (void)setControlColors:(WDPRCaledarCellColors *)colors
{
    _controlColors = colors;
    
    // set colors for cell.
    self.circleLayer.fillColor = [self circleColor].CGColor;
    self.dayLabel.textColor = [self dayLabelColor];
    self.dayOfWeekLabel.textColor = self.controlColors.dayOfWeekTextColor;
    self.dayLabelSelected.backgroundColor = [self circleColor];
}

- (UIColor *)dayLabelColor
{
    if (self.blockOutDate)
    {
        return self.controlColors.disabledDayTextColor;
    }
    
    return self.controlColors.enabledDayTextColor;
}

- (UIColor *)circleColor
{
    if (self.blockOutDate)
    {
        return self.controlColors.selectedDayBlockedCircleColor;
    }
    
    return self.controlColors.selectedDayCircleColor;
}

#pragma mark -

- (UIView *)dayLabelSelected
{
    if ( ! _dayLabelSelected)
    {
        UIView *newLabel = [[UIView alloc] initWithFrame:self.bounds];
        [newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [newLabel setBackgroundColor:[UIColor redColor]];
        _dayLabelSelected = newLabel;
    }
    return _dayLabelSelected;

}

- (CAShapeLayer *)circleLayer
{
    if ( ! _circleLayer)
    {
        CAShapeLayer *shape = [CAShapeLayer layer];
        CGRect circleBounds = CGRectMake(kCircleBoundsXY, kCircleBoundsXY, kCircleDiameter, kCircleDiameter);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleBounds];
        
        shape.path = path.CGPath;
        _circleLayer = shape;
    }
    
    return _circleLayer;
}

- (UILabel *)dayOfWeekLabel
{
    if ( ! _dayOfWeekLabel)
    {
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:newLabel];
        
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.backgroundColor = [UIColor clearColor];
        
        newLabel.font = [UIFont wdprFontStyleC2];
        
        _dayOfWeekLabel = newLabel;
    }
    return _dayOfWeekLabel;
}

- (UILabel *)dayLabel
{
    if ( ! _dayLabel)
    {
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:newLabel];
        
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.font = UIFont.wdprFontStyleH1RDL;
        newLabel.backgroundColor = [UIColor clearColor];
        _dayLabel = newLabel;
    }
    
    return _dayLabel;
}

#pragma mark - View Actions

- (void)showSelectedStateAnimated:(BOOL)animated
{
    
    self.dayLabel.textColor = [UIColor whiteColor];
    self.dayLabelSelected.backgroundColor = [self circleColor];
    
    [self setSelected:YES];
}

- (void)showDeselectedStateAnimated:(BOOL)animated
{
    self.dayLabel.textColor = [self dayLabelColor];
    self.dayLabelSelected.backgroundColor = [self circleColor];
    
    [self setSelected:NO];
}

@end
