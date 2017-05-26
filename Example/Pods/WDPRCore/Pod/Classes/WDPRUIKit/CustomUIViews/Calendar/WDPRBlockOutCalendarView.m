//
//  WDPRBlockOutCalendarView.m
//  DLR
//
//  Created by Olson, Jason on 4/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRBlockOutCalendarView.h"
#import "WDPRDayCalendarCollectionViewCell.h"

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"
#import <WDPRCore/WDPRFoundation.h>

static const NSInteger kDefaultNumberOfDays = 40;

static const CGFloat kDefaultViewHeight = 143.0f;
static const CGFloat kDayViewHeight = 100.0f;
static const CGFloat kLabelTop = -15.0f;
static const CGFloat kLabelSpacing = 16.0f;
static const CGFloat kSeparatorSpacing = 16.0f;
static const CGFloat kLabelHeight = 30.0f;
static const CGFloat kDividerHeight = 1.0f;
static const CGFloat kZeroPad = 0.0f;

static const NSInteger kNumberOfSections = 1;
static const NSInteger kHoursInDay = 24;
static const NSInteger kMinutesInHour = 60;
static const NSInteger kSecondsInMinute = 60;
static const NSInteger kSecondsInDay = kHoursInDay * kMinutesInHour * kSecondsInMinute;
static const NSInteger kMaxFirstItemValue = NSIntegerMax;

static NSString *const kDaySelectionCell = @"daySelectionCell";

#pragma mark -

/**
 A simple helper object for our block out dates.
 */
@interface InternalCalendarDate : NSObject

@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL isBlockedOut;

@end

@implementation InternalCalendarDate

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isBlockedOut = NO;
    }
    return self;
}

@end

#pragma mark -

@interface WDPRBlockOutCalendarView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UILabel *monthYearLabel;
@property (strong, nonatomic) UIView *dividerView;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSDictionary *monthAttributes;
@property (strong, nonatomic) NSDictionary *yearAttributes;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) CGFloat contentOffSetXValue;
@property (strong, nonatomic) NSIndexPath *leftItemIndex;
@property (assign, nonatomic) CGFloat lastContentOffset;
@property (strong, nonatomic) NSMutableArray *displayDates;
@property (strong, nonatomic) NSDate *selectedDate;

@end

#pragma mark -

@implementation WDPRBlockOutCalendarView

+ (CGFloat)defaultViewHeight
{
    return kDefaultViewHeight;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    _allowsSelection = YES;
    _numberOfDaysToShow = kDefaultNumberOfDays;
    _controlColors = [[WDPRCaledarCellColors alloc] initWithType:WDPRCaledarCellColorsTypeBlockOut];
    
    NSDictionary *metrics = @{@"labelTop": @(kLabelTop),
                              @"labelSpacing": @(kLabelSpacing),
                              @"labelHeight": @(kLabelHeight),
                              @"dayViewHeight": @(kDayViewHeight),
                              @"zeroPad": @(kZeroPad),
                              @"separatorSpacing": @(kSeparatorSpacing)
                              };
    
    NSDictionary *constrainedViews = @{
                                       @"monthYearLabel": self.monthYearLabel,
                                       @"dividerView": self.dividerView,
                                       @"collectionView": self.collectionView,
                                       };
    
    NSArray *viewContraints = @[@"V:|-labelTop-[monthYearLabel(==labelHeight)]-1-[dividerView]-1-[collectionView(==dayViewHeight)]",
                                @"H:|-labelSpacing-[monthYearLabel]-labelSpacing-|",
                                @"H:|-separatorSpacing-[dividerView]-separatorSpacing-|",
                                @"H:|-zeroPad-[collectionView]-zeroPad-|",
                                ];
    
    [self addConstraintsForView:self contraints:viewContraints constrainedViews:constrainedViews metrics:metrics];
    
    _monthAttributes = @{NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
                         NSFontAttributeName: UIFont.wdprFontStyleB1,
                         };
    
    _yearAttributes = @{NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
                        NSFontAttributeName: UIFont.wdprFontStyleB2,
                        };
    
    [self generateDates];
    self.monthYearLabel.attributedText = [self attributedStringForMonthYearLabelWithDate:[NSDate date]];
}

- (void)addConstraintsForView:(UIView *)view contraints:(NSArray *)contraints constrainedViews:(NSDictionary *)constrainedViews metrics:(NSDictionary *)metrics
{
    for (NSString *constraintsString in contraints)
    {
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintsString options:0 metrics:metrics views:constrainedViews]];
    }
}

#pragma mark -

- (UILabel *)monthYearLabel
{
    if ( ! _monthYearLabel)
    {
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kLabelHeight)];
        [newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:newLabel];
        
        newLabel.textAlignment = NSTextAlignmentLeft;
        newLabel.font = UIFont.wdprFontStyleH1RDL;
        newLabel.textColor = UIColor.wdprDarkBlueColor;
        newLabel.backgroundColor = [UIColor clearColor];
        _monthYearLabel = newLabel;
    }
    
    return _monthYearLabel;
}

- (UIView *)dividerView
{
    if ( ! _dividerView)
    {
        UIView *divider = [UIView new];
        [divider setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:divider];
        [divider setBackgroundColor:[UIColor wdprHRLineColor]];
        
        [self addConstraintsForView:divider contraints:@[@"V:[divider(kDividerHeight)]"] constrainedViews:@{@"divider": divider} metrics:@{@"kDividerHeight": @(kDividerHeight)}];
        
        _dividerView = divider;
    }
    return _dividerView;
}

- (UICollectionView *)collectionView
{
    if ( ! _collectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = [WDPRDayCalendarCollectionViewCell minimumInteritemSpacing];
        flowLayout.minimumLineSpacing = [WDPRDayCalendarCollectionViewCell minimumLineSpacing];
        flowLayout.sectionInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
        flowLayout.itemSize = [WDPRDayCalendarCollectionViewCell cellSize];
        [flowLayout invalidateLayout];
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kDayViewHeight) collectionViewLayout:flowLayout];
        
        [collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView setContentOffset:CGPointMake(0.0, 0.0)];
        
        collectionView.allowsSelection = YES;
        collectionView.allowsMultipleSelection = NO;
        
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        
        [collectionView registerClass:[WDPRDayCalendarCollectionViewCell class] forCellWithReuseIdentifier:kDaySelectionCell];
        [self addSubview:collectionView];
        _collectionView = collectionView;
    }
    
    return _collectionView;
}

#pragma mark -

- (void)setControlColors:(WDPRCaledarCellColors *)controlColors
{
    _controlColors = controlColors;
    [self.collectionView reloadData];
}

- (void)setNumberOfDaysToShow:(NSInteger)numberOfDaysToShow
{
    _numberOfDaysToShow = numberOfDaysToShow;
    [self generateDates];
}

- (void)setBlockoutDates:(NSArray *)blockoutDates
{
    _blockoutDates = blockoutDates;
    [self updateBlockoutDates];
}

- (void)updateBlockoutDates
{
    NSDate *blockDate;
    NSInteger blockIndex = 0;
    
    // Pair block out dates with our current display array of dates.
    for (InternalCalendarDate *displayDate in self.displayDates)
    {
        displayDate.isBlockedOut = NO;
        for (; blockIndex < [self.blockoutDates count]; blockIndex++)
        {
            blockDate = self.blockoutDates[blockIndex];
            if ([displayDate.date isSameDateAs:blockDate])
            {
                displayDate.isBlockedOut = YES;
                // Our dates match, pop to outer loop.
                break;
            }
            
            if ([displayDate.date isEarlierThan:blockDate])
            {
                // 2/13 < 2/14 Skip to next day in outer loop.
                break;
            }
        }
    }
    
    [self.collectionView reloadData];
}

- (void)setAllowsSelection:(BOOL)allowsSelection
{
    _allowsSelection = allowsSelection;
    [self updateMonth];
}

#pragma mark -

- (void)generateDates
{
    NSDate *date = [NSDate date];
    self.displayDates = [NSMutableArray new];
    InternalCalendarDate *calendarDate;
    
    for (NSInteger index = 0; index < self.numberOfDaysToShow; index++)
    {
        calendarDate = [InternalCalendarDate new];
        calendarDate.date = [date dateByAddingTimeInterval:(index * kSecondsInDay)];
        if (calendarDate)
        {
            [self.displayDates addObject:calendarDate];
        }
    }
    
    if (self.blockoutDates)
    {
        [self updateBlockoutDates];
    }
}

- (void)loadItems
{
    [self.collectionView reloadData];
}

- (NSAttributedString *)attributedStringForMonthYearLabelWithDate:(NSDate *)date
{
    NSString *baseString = @"";

    if (self.allowsSelection)
    {
        if ([date isToday])
        {
            baseString = WDPRLocalizedStringInBundle(@"com.wdprcore.blockout.basestring.today", WDPRCoreResourceBundleName, nil);
            baseString = [NSString stringWithFormat:@"%@ ",baseString];
        }
        else if ([date isTomorrow])
        {
            baseString = WDPRLocalizedStringInBundle(@"com.wdprcore.blockout.basestring.tomorrow", WDPRCoreResourceBundleName, nil);
            baseString = [NSString stringWithFormat:@"%@ ",baseString];
        }
    }
    
    NSMutableAttributedString *monthYear = [[NSMutableAttributedString alloc]
                                            initWithString:[NSString stringWithFormat:@"%@%@ ",baseString, [date month]]
                                            attributes:self.monthAttributes];
    
    NSAttributedString *year = [[NSAttributedString alloc] initWithString:[date year] attributes:self.yearAttributes];
    [monthYear appendAttributedString:year];
    
    return monthYear;
}

- (void)updateMonth
{
    // Visible index paths are not in sorted order.
    // We need to find the lowest value to get the "first visible item"
    NSArray *visibleIndexes = [self.collectionView indexPathsForVisibleItems];

    if (visibleIndexes && [visibleIndexes count] > 0)
    {
        __block NSInteger firstItem = kMaxFirstItemValue;
        [visibleIndexes enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger index, BOOL *stop) {
            if (indexPath.item <  firstItem)
            {
                firstItem = indexPath.item;
            }
        }];
        
        self.monthYearLabel.attributedText = [self attributedStringForMonthYearLabelWithDate:[self.displayDates[firstItem] date]];
    }
    else
    {
        // We have not displayed any dates yet, reset month, year label.
        self.monthYearLabel.attributedText = [self attributedStringForMonthYearLabelWithDate:[NSDate date]];
    }
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [WDPRDayCalendarCollectionViewCell cellSize];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kNumberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfDaysToShow;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WDPRDayCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDaySelectionCell forIndexPath:indexPath];
    
    [cell setDisplayDate:[self.displayDates[indexPath.row] date]];
    [cell setControlColors:self.controlColors];
    [cell setBlockOutDate:[self.displayDates[indexPath.row] isBlockedOut]];
    [cell setTag:indexPath.row];
    
    if (self.allowsSelection)
    {
        if ([indexPath isEqual:self.selectedIndexPath])
        {
            [cell showSelectedStateAnimated:NO];
        }
        else
        {
            [cell showDeselectedStateAnimated:NO];
        }
    }
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsSelection;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsSelection;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ( ! self.allowsSelection)
    {
        return;
    }
    
    if ([self.selectedIndexPath isEqual:indexPath])
    {
        return;
    }
    
    if (self.selectedIndexPath)
    {
        WDPRDayCalendarCollectionViewCell *cell = (WDPRDayCalendarCollectionViewCell *)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        [cell showDeselectedStateAnimated:YES];
    }
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    WDPRDayCalendarCollectionViewCell *cell = (WDPRDayCalendarCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell showSelectedStateAnimated:YES];
    self.selectedDate = cell.displayDate;
    
    self.selectedIndexPath = indexPath;
    if (self.newDateSelectedBlock)
    {
        self.newDateSelectedBlock();
    }
}

#pragma mark -

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateMonth];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self updateMonth];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateMonth];
}

@end
