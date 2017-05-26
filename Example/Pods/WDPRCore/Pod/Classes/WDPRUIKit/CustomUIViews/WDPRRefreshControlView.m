//
//  WDPRRefreshControlView
//  WDPR
//
//  Created by Ricardo Contreras on 7/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRRefreshControlView.h"

#import <WDPRCore/WDPRUIKit.h>

// Circle Animation
static CGFloat      const kWDPRRCDefaultEndAngle         = M_PI * 1.5 + (M_PI * 2);
static CGFloat      const kWDPRRCDefaultStartAngle       = M_PI * 1.5;
static int          const kWDPRRCDefaultMaxPercent       = 100;
static int          const kWDPRRCDefaultPercentIncrement = 2.0f;
static float        const kWDPRRCAnimMinSize             = 15.5f;
static float        const kWDPRRCAnimMaxSize             = 50.0f;
static float        const kWDPRRCAnimGrowRate            = 0.18f;
static float        const kWDPRRCAnimCircleWidth         = 3.0f;
static float        const kWDPRRCAnimNoTextGrowRate      = 0.79f;
static float        const kWDPRRCAnimOffsetNoText        = 13.0f;
static float        const kWDPRRCAnimOffsetWithText      = 15.0f;
static float        const kWDPRRCWhiteCircleSize         = 0.2f;
static float        const kWDPRRCOffsetTolerance         = 5.0f;

// FadeOut
static float        const kWDPRRCFadeOutSizeRate         = 1.0f;
static float        const kWDPRRCFadeOutOpacityRate      = 0.5f;

// Spring
static float        const kWDPRRCSpringMaxSize           = 4.0f;
static float        const kWDPRRCSringRate               = 0.5f;

// Text Label
static float        const kWDPRRCStartTextAlpha          = 65.0f;
static float        const kWDPRRCTextAlphaRate           = 0.025f;
static float        const kWDPRRCATextOffset             = 32.0f;
static float        const kWDPRRCATextHeight             = 20.0f;

@interface WDPRRefreshControlView ()

@property (strong, nonatomic) CAShapeLayer *mainCircle;
@property (strong, nonatomic) CAShapeLayer *grayCircle;
@property (strong, nonatomic) CAShapeLayer *whiteCircle;
@property (nullable, strong, nonatomic) UILabel *label;
@property (assign, nonatomic) CGRect rect;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (assign, nonatomic) CGFloat percent;
@property (assign, nonatomic) float currentYPoint;
@property (assign, nonatomic) float spring;
@property (assign, nonatomic) BOOL isFilling;
@property (assign, nonatomic) BOOL springDecreasing;

@end

@implementation WDPRRefreshControlView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setUp];
    }

    return self;
}

#pragma mark - Public methods

- (void)scrollOffsetChanged:(CGPoint)offset withWidth:(float)width andCenter:(CGPoint)center
{
    float yOffset = offset.y;
    float invertedOffset = yOffset * - 1.0f;
    float halfOffset = yOffset / 2.0f;

    // Update label alpha
    self.label.alpha = (self.state == WDPRRefreshStateAnimating)
    ? 1.0f
    : (invertedOffset - kWDPRRCStartTextAlpha) * kWDPRRCTextAlphaRate;

    if (invertedOffset > kWDPRRCOffsetTolerance &&
        (self.state == WDPRRefreshStateDefault ||
         self.state == WDPRRefreshStateReleased))
    {

        [self showCircles];

        // Values acording to scrollView Y offset
        float labelWidth = width;
        float xPoint = center.x;
        float yPointText = halfOffset + kWDPRRCATextOffset;
        float yPointAnimation = (!self.label || [self.label.text isEqualToString:@""])
        ? (halfOffset - kWDPRRCAnimOffsetNoText) * kWDPRRCAnimNoTextGrowRate
        : halfOffset - kWDPRRCAnimOffsetWithText;
        float size = (invertedOffset * kWDPRRCAnimGrowRate) + kWDPRRCAnimMinSize;
        size = (size > kWDPRRCAnimMaxSize) ? kWDPRRCAnimMaxSize : size  + self.spring;

        // Update values
        self.currentYPoint = yPointAnimation;
        self.label.frame = CGRectMake(0.0f, yPointText, labelWidth, kWDPRRCATextHeight);
        self.rect = CGRectMake(xPoint, yPointAnimation, size, size);

        // Create animations from scrollOffsetChanged
        [self makeCirclesWithRect:self.rect];
            
    }
    else if (invertedOffset <= kWDPRRCOffsetTolerance)
    {
        [self makeCirclesWithRect:CGRectZero];
    }
}

- (void)setText:(nullable NSString *)text
{
    self.label.text = text;
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText
{
    self.label.attributedText = attributedText;
}

- (void)setMainColor:(UIColor *)mainColor
{
    _mainColor = mainColor;
    self.mainCircle.strokeColor = [_mainColor CGColor];;
}

#pragma mark - Private methods

- (void)setUp
{
    [self resetValues];
    self.state = WDPRRefreshStateDefault;

    self.mainCircle = [self makeShapeLayerWithColor:[UIColor wdprBlueColor]];
    self.grayCircle = [self makeShapeLayerWithColor:[UIColor wdprLightGrayColor]];
    self.whiteCircle = [self makeShapeLayerWithColor:[UIColor wdprWhiteColor]];

    self.label = [UILabel new];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.label applyStyle:WDPRTextStyleC2D];
    [self setText:@""];
    [self addSubview:self.label];

    [self configureRefresh];
}

- (void)configureRefresh
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(update)];

    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

- (void)makeCirclesWithRect:(CGRect)rect
{
    CGFloat currentAngle = [self currentAngleWithPercent:self.percent];

    CGFloat blueStart = kWDPRRCDefaultStartAngle;
    CGFloat blueEnd = kWDPRRCDefaultStartAngle;

    CGFloat whiteStart = kWDPRRCDefaultStartAngle;
    CGFloat whiteEnd = kWDPRRCDefaultStartAngle;

    if (self.state == WDPRRefreshStateAnimating ||
        self.state == WDPRRefreshStateFadeOut)
    {

        blueStart = kWDPRRCDefaultStartAngle;
        blueEnd = currentAngle;

        if (!self.isFilling)
        {
            blueStart = currentAngle;
            blueEnd = kWDPRRCDefaultStartAngle;
        }

        whiteStart = currentAngle - kWDPRRCWhiteCircleSize;
        whiteEnd = currentAngle;
    }

    self.grayCircle.path = [self makePathWithRect:rect
                                       startAngle:kWDPRRCDefaultStartAngle
                                         endAngle:kWDPRRCDefaultEndAngle
                            ].CGPath;

    [self.layer addSublayer:self.grayCircle];

    self.mainCircle.path = [self makePathWithRect:rect
                                       startAngle:blueStart
                                         endAngle:blueEnd
                            ].CGPath;

    [self.layer addSublayer:self.mainCircle];

    self.whiteCircle.path = [self makePathWithRect:rect
                                        startAngle:whiteStart
                                          endAngle:whiteEnd
                             ].CGPath;

    [self.layer addSublayer:self.whiteCircle];
}

- (void)update
{
    if (self.percent <= kWDPRRCDefaultMaxPercent - kWDPRRCDefaultPercentIncrement)
    {
        self.percent = self.percent + kWDPRRCDefaultPercentIncrement;
    }
    else
    {
        self.percent = kWDPRRCDefaultPercentIncrement;
        self.isFilling = !self.isFilling;
    }

    switch (self.state)
    {

        case WDPRRefreshStateFadeOut:
            // If on FadeOut state decrease size of rect for circle animations
            if (self.rect.size.width > 0)
            {

                if (self.spring  < kWDPRRCSpringMaxSize)
                {
                    self.spring = self.spring + kWDPRRCSringRate;
                }
                else
                {

                    CGRect fadeOutRect = CGRectMake(self.rect.origin.x,
                                                    self.currentYPoint,
                                                    self.rect.size.width - kWDPRRCFadeOutSizeRate,
                                                    self.rect.size.height -kWDPRRCFadeOutSizeRate);
                    self.rect = fadeOutRect;
                    self.grayCircle.opacity -= kWDPRRCFadeOutOpacityRate;
                    self.mainCircle.opacity -= kWDPRRCFadeOutOpacityRate;
                    self.whiteCircle.opacity -= kWDPRRCFadeOutOpacityRate;
                }
            }
            else
            {
                // Reached the end of FadeOut. Change state and restore values
                self.spring = 0.0f;
            }
            break;

        case WDPRRefreshStateSpringAction:
            // If on SpringAction state decrease or increase spring accordingly.
            if (self.springDecreasing)
            {
                self.spring = self.spring - kWDPRRCSringRate;
                if (self.spring < - kWDPRRCSpringMaxSize)
                {
                    self.springDecreasing = NO;
                }
            }
            else
            {
                self.spring = self.spring + kWDPRRCSringRate;
                if (self.spring >= 0.0f)
                {
                    [self resetValues];
                    self.state = WDPRRefreshStateAnimating;
                }
            }
            break;

        default:
            break;
    }

    if (self.state == WDPRRefreshStateAnimating   ||
        self.state == WDPRRefreshStateFadeOut     ||
        self.state == WDPRRefreshStateSpringAction)
    {
        
        // Create rect with with current size + spring size
        CGRect rect = CGRectMake(self.rect.origin.x,
                                 self.rect.origin.y,
                                 self.rect.size.width + self.spring,
                                 self.rect.size.height + self.spring);

        // Create animations from update
        [self makeCirclesWithRect:rect];
    }
}

- (void)resetValues
{
    self.percent = 0.0f;
    self.isFilling = YES;
    self.springDecreasing = YES;
}

- (void)showCircles
{
    self.grayCircle.opacity = 1.0f;
    self.mainCircle.opacity = 1.0f;
    self.whiteCircle.opacity = 1.0f;
}

#pragma mark - Helper methods

- (CAShapeLayer *)makeShapeLayerWithColor:(UIColor *)color
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = kWDPRRCAnimCircleWidth;
    layer.strokeColor = [color CGColor];
    layer.fillColor = [[UIColor clearColor] CGColor];
    return layer;
}

- (UIBezierPath *)makePathWithRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{

    CGFloat radius = rect.size.width/2.0f;
    UIBezierPath *path = [UIBezierPath
                          bezierPathWithArcCenter:CGPointMake(rect.origin.x, rect.origin.y)
                          radius:radius
                          startAngle:startAngle
                          endAngle:endAngle
                          clockwise:YES];

    return path;
}

- (CGFloat)currentAngleWithPercent:(CGFloat)percent
{
    return (kWDPRRCDefaultEndAngle - kWDPRRCDefaultStartAngle) * (percent/kWDPRRCDefaultMaxPercent) + kWDPRRCDefaultStartAngle;
}


@end
