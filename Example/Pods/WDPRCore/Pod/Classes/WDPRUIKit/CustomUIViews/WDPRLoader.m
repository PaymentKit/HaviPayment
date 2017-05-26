//
//  WDPRLoader.m
//  loader
//
//  Created by John Uribe Mendoza on 17/03/15.
//  Copyright (c) 2015 John Uribe Mendoza. All rights reserved.
//

#import "WDPRLoader.h"
#import "WDPRFoundation.h"

static CGFloat    const kWDPRDefaultComponentsDistance = 24;
static CGFloat    const kWDPRDefaultEndAngle = M_PI * 1.5 + (M_PI * 2);
static CGFloat    const kWDPRDefaultStartAngle = M_PI * 1.5;
static NSString*  const kWDPRDefaultFontName = @"Avenir-Book";
static CGFloat    const kWDPRDefaultFontSize = 16;
static int        const kWDPRDefaultMaxPercent = 100;
static int        const kWDPRDefaultMaxExitPercent = 40;
static int        const kWDPRDefaultPercentIncrement = 2;
static int        const kWDPRDefaultLineWidth = 4;
static float      const kWDPRDefaultSelectorWidth = 0.3;
static float      const kWDPRDefaultRadius = 20;
static float      const kWDPRWhiteViewAlpha = 0.85;

@interface WDPRLoader ()

@property (strong, nonatomic) NSString *failureText;
@property (strong, nonatomic) UIBezierPath *containerBezierPath;
@property (strong, nonatomic) UIBezierPath *progressBezierPath;
@property (strong, nonatomic) UIBezierPath *selectorBezierPath;
@property (strong, nonatomic) UIView *whiteView;
@property (weak, nonatomic) UIImageView *loaderImageView;
@property (weak, nonatomic) UILabel *loaderLabel;
@property (copy, nonatomic) loaderCompletionHandler block;

@property (assign, nonatomic) CGFloat percent;
@property (assign, nonatomic) CGFloat exitPercent;
@property (assign, nonatomic) NSInteger animationIndex;
@property (assign, nonatomic) CGFloat componentsDistance;
@property (assign, nonatomic) BOOL willStopAnimating;
@property (assign, nonatomic) float initialRadius;
@property (assign, nonatomic) float radius;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation WDPRLoader


#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self configureLoader];
        [self configureLabel];
    }
    return self;
}

- (instancetype)initWithParentView:(UIView *)parentView
{
    NSAssert(parentView, @"View must not be nil.");

    if (self = [self initWithFrame:parentView.frame])
    {
        [parentView addSubview:self];
    }

    return self;
}

- (UIView *)whiteView
{
    if (!_whiteView) {
        _whiteView = [UIView new];
        _whiteView.backgroundColor = [UIColor whiteColor];
        _whiteView.alpha = kWDPRWhiteViewAlpha;
    }
    
    return _whiteView;
}

#pragma mark - dealloc
- (void)dealloc
{
    [self resetProperties];
    [self.whiteView removeFromSuperview];
    [self removeFromSuperview];
    self.block = nil;
}

#pragma mark - default configuration methods

+ (NSArray *)exitAnimationScales
{
    static NSArray *_exitAnimationScales = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _exitAnimationScales = @[@1.01,@1.03,@1.04,@1.045,@1.05,@1.04,@1.0,@0.93,@0.82,@0.66,@0.45,@0.21,@0.0];
    });
    return _exitAnimationScales;
}

- (NSArray *)exitAnimationScales
{
    return [WDPRLoader exitAnimationScales];
}

- (void)configureLoader
{
    UIImageView *loaderImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];

    self.lineWidth = kWDPRDefaultLineWidth;
    self.radius = kWDPRDefaultRadius;
    self.initialRadius = kWDPRDefaultRadius;
    self.percent = 0;
    self.exitPercent = 0;
    self.animationIndex = 0;
    self.loaderImageView = loaderImage;
    self.loaderImageView.contentMode = UIViewContentModeCenter;
    self.loaderImageView.center = self.center;
    [self addSubview:self.loaderImageView];
    [self setHidesWhenStop:YES];
    [self setIsViewBlocking:NO];
}

- (void)configureLabel
{
    UILabel *loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];

    self.loaderLabel = loaderLabel;
    [self.loaderLabel setTextAlignment:NSTextAlignmentCenter];
    [self setTextColor:[UIColor colorWithRed:36/255.0f green:58/255.0f blue:85/255.0f alpha:1.0]];
    [self setFont:[UIFont fontWithName:kWDPRDefaultFontName size:kWDPRDefaultFontSize]];
    [self.loaderLabel setCenter:self.center];
    [self.loaderLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.loaderLabel setNumberOfLines:0];
    [self addSubview:self.loaderLabel];
    [self setDistanceBetweenLabelAndLoader:kWDPRDefaultComponentsDistance];
}

- (void)adjustedLabelFrame
{
    CGRect frame = self.loaderLabel.frame;
    frame.size.height = [self.loaderLabel sizeThatFits:frame.size].height;
    self.loaderLabel.frame = frame;
    [self setDistanceBetweenLabelAndLoader:self.componentsDistance];;
}

#pragma mark - WDPR default loaders methods

+ (instancetype)showNonTransactionalLoaderInView:(UIView *)parentView
{
    WDPRLoader *loader = [[WDPRLoader alloc] initWithFrame:parentView.bounds];
    [loader setParentView:parentView];
    [loader startAnimating];
    return loader;
}

+ (instancetype)showNonTransactionalLoaderWithLabel:(NSString *)text inView:(UIView *)parentView
{
    WDPRLoader *loader = [[WDPRLoader alloc] initWithFrame:parentView.bounds];
    [loader setParentView:parentView];
    [loader setText:text];
    [loader startAnimating];
    return loader;
}

+ (instancetype)showTransactionalLoader
{
    WDPRLoader *loader = [[WDPRLoader alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    [loader setIsViewBlocking:YES];
    [loader startAnimating];
    return loader;
}

+ (instancetype)showTransactionalLoaderWithLabel:(NSString *)text
{
    return [WDPRLoader showTransactionalLoaderWithLabel:text inView:[UIApplication sharedApplication].keyWindow];
}

+ (instancetype)showTransactionalLoaderWithLabel:(NSString *)text inView:(UIView *)parentView
{
    WDPRLoader *loader = [[WDPRLoader alloc] initWithFrame:parentView.bounds];
    [loader setIsViewBlocking:YES];
    [loader setText:text];
    [loader startAnimating];
    return loader;
}

#pragma mark - loader animation handler methods

- (void)drawRect:(CGRect)rect
{
    if(!self.isAnimating)
    {
        return;
    }

    [self initBezierPaths];

    if(self.willStopAnimating)
    {
        [self configureExitAnimation];
    }

    [self animateLoader];
    [super drawRect:rect];
}

- (void)initBezierPaths
{
    if (!self.containerBezierPath && !self.progressBezierPath && !self.selectorBezierPath)
    {
        self.containerBezierPath = [UIBezierPath bezierPath];
        self.progressBezierPath = [UIBezierPath bezierPath];
        self.selectorBezierPath = [UIBezierPath bezierPath];
    }
    else
    {
        [self.containerBezierPath removeAllPoints];
        [self.progressBezierPath removeAllPoints];
        [self.selectorBezierPath removeAllPoints];
    }
}

- (void)configureExitAnimation
{
    float scalesPercent = (kWDPRDefaultMaxExitPercent * 1.25) / [self.exitAnimationScales count];
    int scaleIndex = self.exitPercent / scalesPercent;

    if (scaleIndex < [self.exitAnimationScales count])
    {
        //All this calculation allows to replicate scale animation
        float scale = [self.exitAnimationScales[scaleIndex] floatValue];

        self.radius = self.initialRadius * scale;
        self.lineWidth = self.initialRadius * 0.2;

        if (self.exitPercent >= kWDPRDefaultMaxExitPercent || self.radius == 0)
        {
            [self didEndStopAnimation];
        }

        self.exitPercent++;
    }
}

- (void)drawBezierPath:(UIBezierPath *)bezierPath startAngle:(float)startAngle endAngle:(float)endAngle red:(int)red green:(int)green blue:(int)blue
{
    [bezierPath addArcWithCenter:self.loaderImageView.center
                          radius:self.radius
                      startAngle:startAngle
                        endAngle:endAngle
                       clockwise:YES];
    bezierPath.lineWidth = self.lineWidth;
    [[UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0] setStroke];
    [bezierPath stroke];
}

- (void)animateLoader
{
    CGFloat endAngle = [self endAngleWithPercent:self.percent];

    switch (self.animationIndex)
    {
        case 0:
        {
            //Container fills 1.5x faster
            [self drawBezierPath:self.containerBezierPath startAngle:kWDPRDefaultStartAngle endAngle:endAngle*1.5 red:189 green:196 blue:204];
            [self drawBezierPath:self.progressBezierPath startAngle:kWDPRDefaultStartAngle endAngle:endAngle red:36 green:148 blue:215];
        }
            break;
        case 1:
        {
            [self drawBezierPath:self.containerBezierPath startAngle:kWDPRDefaultStartAngle endAngle:kWDPRDefaultEndAngle red:189 green:196 blue:204];
            //This is inverted because thats what the animation is
            [self drawBezierPath:self.progressBezierPath startAngle:endAngle endAngle:kWDPRDefaultStartAngle red:36 green:148 blue:215];
        }
            break;
        case 2:
        {
            [self drawBezierPath:self.containerBezierPath startAngle:kWDPRDefaultStartAngle endAngle:kWDPRDefaultEndAngle red:189 green:196 blue:204];
            [self drawBezierPath:self.progressBezierPath startAngle:kWDPRDefaultStartAngle endAngle:endAngle red:36 green:148 blue:215];
        }
            break;
        default:
            break;
    }

    [self drawBezierPath:self.selectorBezierPath startAngle:endAngle - kWDPRDefaultSelectorWidth endAngle:endAngle red:255 green:255 blue:255];
}

- (CGFloat)endAngleWithPercent:(CGFloat)percent
{
    return (kWDPRDefaultEndAngle - kWDPRDefaultStartAngle) * (percent/kWDPRDefaultMaxPercent) + kWDPRDefaultStartAngle;
}

- (void)updatePercent
{
    if(self.percent <= kWDPRDefaultMaxPercent - kWDPRDefaultPercentIncrement)
    {
        self.percent = self.percent + kWDPRDefaultPercentIncrement;
    }
    else
    {
        self.percent = kWDPRDefaultPercentIncrement;
        //This allow to create the loop animation on loader
        self.animationIndex = self.animationIndex == 2 ? 1 : self.animationIndex + 1;
    }
    [self setNeedsDisplay];
}

#pragma mark - Additional configuration methods

- (void)setCustomRadius:(float)radius
{
    self.radius = radius;
    self.initialRadius = radius;
}

- (void)setParentView:(UIView *)view
{
    [view addSubview:self];
}

- (void)setIsViewBlocking:(BOOL)isViewBlocking
{
    [self setIsViewBlocking:isViewBlocking useWhiteView:NO];
}

- (void)setIsViewBlocking:(BOOL)isViewBlocking useWhiteView:(BOOL)useWhiteView;
{
    [self setUserInteractionEnabled:isViewBlocking];
    
    if(isViewBlocking)
    {
        CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
        
        if (useWhiteView) {
            [self.whiteView setFrame:frame];
            [[UIApplication sharedApplication].keyWindow addSubview:self.whiteView];
        }
        
        [self removeFromSuperview];
        [self setFrame:frame];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
}

- (void)setAnimationDuration:(NSTimeInterval)duration
{
    self.loaderImageView.animationDuration = duration;
}

- (void)setImageXOffset:(float)xOffset
{
    CGRect frame = self.loaderImageView.frame;

    frame.origin.x = frame.origin.x + xOffset;
    [self.loaderImageView setFrame:frame];
}

- (void)setImageYOffset:(float)yOffset
{
    CGRect frame = self.loaderImageView.frame;

    frame.origin.y = frame.origin.y + yOffset;
    [self.loaderImageView setFrame:frame];
}

- (void)setLabelXOffset:(float)xOffset
{
    CGRect frame = self.loaderLabel.frame;

    frame.origin.x = frame.origin.x + xOffset;
    [self.loaderLabel setFrame:frame];
}

- (void)setLabelYOffset:(float)yOffset
{
    CGRect frame = self.loaderLabel.frame;

    frame.origin.y = frame.origin.y + yOffset;
    [self.loaderLabel setFrame:frame];
}

- (CGFloat)distanceBetweenLabelAndLoader
{
    return self.loaderImageView.frame.origin.y - CGRectGetMaxY(self.loaderLabel.frame);
}

- (void)setDistanceBetweenLabelAndLoader:(CGFloat)distanceBetweenLabelAndLoader
{
    CGRect frame = self.loaderLabel.frame;

    self.componentsDistance = distanceBetweenLabelAndLoader;
    frame.origin.y = self.loaderImageView.frame.origin.y - distanceBetweenLabelAndLoader - self.loaderLabel.frame.size.height;
    self.loaderLabel.frame = frame;
    [self adjustComponentsIfNeeded];
}

- (void)adjustComponentsIfNeeded
{
    CGRect frame = self.loaderLabel.frame;
    
    if (frame.origin.y>=0) {
        return;
    }
    
    frame.origin.y = 0;
    self.loaderLabel.frame = frame;
    
    frame = self.loaderImageView.frame;
    frame.origin.y = self.loaderLabel.frame.size.height + self.componentsDistance;
    self.loaderImageView.frame = frame;
}

- (CGFloat)distanceFromTop
{
    return (self.loaderLabel.text.length > 0)?self.loaderLabel.frame.origin.y:self.loaderImageView.frame.origin.y;
}

- (void)setDistanceFromTop:(CGFloat)distanceFromTop
{
    float distanceBetweenElements = self.distanceBetweenLabelAndLoader;

    if (self.loaderImageView.frame.origin.y > self.loaderLabel.frame.origin.y)
    {
        if (self.loaderLabel.text.length > 0)
        {
            [self setDistanceFromTop:distanceFromTop forView:self.loaderLabel];
            [self setDistanceFromTop:distanceFromTop + self.loaderLabel.frame.size.height + distanceBetweenElements
                             forView:self.loaderImageView];
        }
        else
        {
            [self setDistanceFromTop:distanceFromTop
                             forView:self.loaderImageView];
        }
    }
    else
    {
        [self setDistanceFromTop:distanceFromTop
                         forView:self.loaderImageView];
        [self setDistanceFromTop:distanceFromTop + self.loaderImageView.frame.size.height + distanceBetweenElements
                         forView:self.loaderLabel];
    }

    [self refresh];
}

- (void)setDistanceFromTop:(CGFloat)distanceFromTop forView:(UIView *)view
{
    CGRect frame = view.frame;

    frame.origin.y = distanceFromTop;
    view.frame = frame;
}

- (CGFloat)distanceFromBottom
{
    if (CGRectGetMaxY(self.loaderImageView.frame) > CGRectGetMaxY(self.loaderLabel.frame))
    {
        return self.frame.size.height - CGRectGetMaxY(self.loaderImageView.frame);
    }
    else
    {
        return self.frame.size.height - CGRectGetMaxY(self.loaderLabel.frame);
    }
}

- (void)setDistanceFromBottom:(CGFloat)distanceFromBottom
{
    float distanceBetweenElements = self.distanceBetweenLabelAndLoader;

    if (CGRectGetMaxY(self.loaderImageView.frame) > CGRectGetMaxY(self.loaderLabel.frame))
    {
        [self setDistanceFromBottom:distanceFromBottom
                            forView:self.loaderImageView];
        [self setDistanceFromBottom:distanceFromBottom + distanceBetweenElements
                            forView:self.loaderLabel];
    }
    else
    {
        [self setDistanceFromBottom:distanceFromBottom
                            forView:self.loaderLabel];
        [self setDistanceFromBottom:distanceFromBottom + distanceBetweenElements
                            forView:self.loaderImageView];
    }

    [self refresh];
}

- (void)setDistanceFromBottom:(CGFloat)distanceFromBottom forView:(UIView *)view
{
    CGRect frame = view.frame;

    frame.origin.y = self.frame.size.height - (frame.size.height + distanceFromBottom);
    view.frame = frame;
}

- (void)setFont:(UIFont *)font
{
    [self.loaderLabel setFont:font];
    [self adjustedLabelFrame];
}

- (void)setText:(NSString *)text
{
    [self.loaderLabel setText:text];
    [self adjustedLabelFrame];
}

- (void)setTextColor:(UIColor *)color
{
    [self.loaderLabel setTextColor:color];
}

#pragma mark - Loader status methods

- (void)startAnimating
{
    if (!self.isAnimating)
    {
        [self resetProperties];
        [self configureRefresh];
        [self startRefreshing];
        self.isAnimating = YES;

        if (!self.superview)
        {
            WDPRLogWarning(@"[%@]: The loader is not added to any view and it won't be visible", [[self class] description]);
        }
    }
}

- (void)configureRefresh
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(updatePercent)];
    self.isRefreshing = NO;
}

- (void)startRefreshing
{
    if (!self.isRefreshing)
    {
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSRunLoopCommonModes];
        self.isRefreshing = YES;
    }
}

- (void)refresh
{
    [self setNeedsDisplay];
    [self.layer displayIfNeeded];
}

- (void)stopAnimating
{
    [self resetProperties];

    if (self.hidesWhenStop) {
        [self.whiteView removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (void)stopAnimatingWithCompletionHandler:(loaderCompletionHandler)block
{
    [self stopAnimatingWithSuccess:YES text:@"" completionHandler:block];
}

- (void)stopAnimatingWithSuccess:(BOOL)success completionHandler:(loaderCompletionHandler)block
{
    [self stopAnimatingWithSuccess:success text:@"" completionHandler:block];
}

- (void)stopAnimatingWithSuccess:(BOOL)success text:(NSString *)text completionHandler:(loaderCompletionHandler)block
{
    self.block = block;
    self.willStopAnimating = YES;
    self.hidesWhenStop = success;
    self.failureText = text;
}

- (void)didEndStopAnimation
{
    if (!self.hidesWhenStop)
    {
        [self setIsViewBlocking:NO];
        self.loaderImageView.image = self.failureImage ? self.failureImage
                                                       : [UIImage imageNamed:WDPRCoreAlertFailureImageName
                                                                    inBundle:[WDPRFoundation wdprCoreResourceBundle]
                                                                  compatibleWithTraitCollection:nil];
        [self setText:self.failureText];
    }

    [self stopAnimating];

    if (self.block)
    {
        self.block();
        self.block = nil;
    }
}

#pragma mark - properties reset method

- (void)resetProperties
{
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self.containerBezierPath removeAllPoints];
    [self.progressBezierPath removeAllPoints];
    [self.selectorBezierPath removeAllPoints];
    self.containerBezierPath = nil;
    self.progressBezierPath = nil;
    self.selectorBezierPath = nil;
    self.animationIndex = 0;
    self.isAnimating = NO;
    self.percent = 0;
    self.failureImage = nil;
    self.failureText = nil;
}

@end

