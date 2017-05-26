//
//  WDPRActivityIndicator.m
//  WDPR
//
//  Created by Thompson, Greg X. -ND on 5/6/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRActivityIndicator.h"

#import "UIFont+WDPR.h"

@implementation WDPRActivityIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (instancetype)createActivityIndicatorWithTitle:(NSString*)title
                                         message:(NSString*)message
                                      andSpinner:(BOOL)withSpinner {

    UIView *animationView;
    UILabel *titleView, *messageView;
    
	WDPRActivityIndicator *activityIndicator = [WDPRActivityIndicator new];
    
    UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    CGRect bounds = [topView bounds];

	activityIndicator.alpha = 0.0;
	activityIndicator.layer.cornerRadius = 10;
	activityIndicator.userInteractionEnabled = NO;
	
    activityIndicator.backgroundColor =
    [UIColor.blackColor colorWithAlphaComponent:0.75];
    
	// TitleView and messageView in go into activityIndicator.
	[activityIndicator addSubview:titleView =
     [[UILabel alloc] initWithFrame:CGRectZero]];
	
    [activityIndicator addSubview:messageView =
     [[UILabel alloc] initWithFrame:CGRectZero]];
	
    if (withSpinner)
    {
#if 1 // use OS activityIndicator
        UIActivityIndicatorViewStyle style =
        (title.length ? UIActivityIndicatorViewStyleWhite :
                        UIActivityIndicatorViewStyleWhiteLarge);
        
        animationView = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:style];

#else   // use our custom activityIndicator
        animationView = [WDPRActivityAnimationView
                         largeActivityIndicator:
                         WDPRActivityAnimationViewTypeSpinning];
#endif
        
        // Embed animationView into titleView.
        [titleView addSubview:animationView];
    }
	
	titleView.text = title;
	messageView.text = message;
	
    titleView.numberOfLines = 0;
    messageView.numberOfLines = 0;
    
	titleView.textColor = UIColor.whiteColor;
	messageView.textColor = UIColor.whiteColor;
	
	titleView.font = [UIFont wdprFontStyleB2];
	messageView.font = [UIFont wdprFontStyleC2];
    
	titleView.backgroundColor = UIColor.clearColor;
	messageView.backgroundColor = UIColor.clearColor;
	
	titleView.textAlignment = NSTextAlignmentCenter;
	messageView.textAlignment = NSTextAlignmentCenter;
	
	titleView.lineBreakMode = NSLineBreakByTruncatingMiddle;
	messageView.lineBreakMode = NSLineBreakByTruncatingMiddle;
	
	// Position messageView below titleView.
	enum { yInset = 10, yOffset = 15, xOffset = 10, xInset = 30 };
    const CGRect maxFrame = CGRectInset(bounds, 20, 10);
    const CGSize titleSize = [titleView sizeThatFits:
                              CGSizeMake(maxFrame.size.width,
                                         maxFrame.size.height)];
    
    const CGSize msgSize = [messageView sizeThatFits:
                            CGSizeMake(maxFrame.size.width,
                                       maxFrame.size.height -
                                       titleSize.height - yOffset)];
    
    titleView.frame = CGRectMake(0, 0, titleSize.width, titleSize.height);
	messageView.frame = CGRectMake(0, 0,  msgSize.width, msgSize.height);
	
    if (animationView)
    {
        CGRect titleFrame = titleView.frame;
        titleView.textAlignment = NSTextAlignmentRight;
        
        titleFrame.size.width += ((title.length ? xOffset : 0) +
                                  animationView.frame.size.width);
        
        titleFrame.size.height = MAX(titleFrame.size.height,
                                     animationView.frame.size.height);
        
        titleView.frame = titleFrame;
        
        // Vertically center, horizontally left align, animationView.
        animationView.center = titleView.center;
        animationView.frame = CGRectOffset(animationView.frame,
                                               -animationView.frame.origin.x,
                                               -animationView.frame.origin.y);
    }
    
	titleView.frame = CGRectOffset(titleView.frame, 0, yInset);
	messageView.frame = CGRectOffset(messageView.frame, 0,
									 CGRectGetMaxY(titleView.bounds) + yOffset);
	
	// Size activityIndicator to encompase titleView and messageView.
	activityIndicator.frame = CGRectInset(CGRectUnion(titleView.frame,
                                               messageView.frame), -xInset, -yInset);
	
	// Center activityIndicator in bounds, then position about 1/3rd from the top of superView.
	activityIndicator.frame = CGRectOffset(activityIndicator.bounds,
                                    (bounds.size.width -
                                     activityIndicator.bounds.size.width)/2,
                                    (bounds.size.height -
                                     activityIndicator.bounds.size.width)/2);
    
	activityIndicator.frame = CGRectOffset(activityIndicator.frame, 0,
                                    -(CGRectGetMinY(activityIndicator.frame) -
                                      1.0/3.3*CGRectGetHeight(bounds)));
	
	// Make sure the activityIndicator doesn't extend beyond the width of bounds.
	if (CGRectGetMinX(activityIndicator.frame) < (CGRectGetMinX(bounds) + yInset))
	{
		activityIndicator.frame = CGRectInset(activityIndicator.frame,
                                       (CGRectGetMinX(bounds) + yInset) -
                                       CGRectGetMinX(activityIndicator.frame), 0);
		
		if (CGRectGetWidth(titleView.bounds) > (CGRectGetWidth(activityIndicator.bounds) + yInset))
		{
			titleView.frame = CGRectInset(titleView.frame,
										  CGRectGetWidth(titleView.bounds) -
										  (CGRectGetWidth(activityIndicator.bounds) + yInset), 0);
		}
		
		if (CGRectGetWidth(messageView.bounds) > (CGRectGetWidth(activityIndicator.bounds) + yInset))
		{
			messageView.frame = CGRectInset(messageView.frame,
											CGRectGetWidth(messageView.bounds) -
											(CGRectGetWidth(activityIndicator.bounds) + yInset), 0);
		}
	}
	
	// Horizontally center titleView and messageView.
	titleView.frame = CGRectIntegral(CGRectOffset(titleView.frame,
                                                  (activityIndicator.frame.size.width -
                                                   titleView.frame.size.width)/2
                                                  -titleView.frame.origin.x, 0));
    
    messageView.frame = CGRectIntegral(CGRectOffset(messageView.frame,
                                                    (activityIndicator.frame.size.width -
                                                     messageView.frame.size.width)/2
                                                    -messageView.frame.origin.x, 0));
    
    // Fade into view.
    [animationView performSelector:@selector(startAnimating)];
    
    [UIView animateWithDuration:0.2
					 animations:^{ activityIndicator.alpha = 1.0; } completion:^(BOOL finished){ }];
    
    return activityIndicator;
}

+ (void)dismissActivityIndicator:(WDPRActivityIndicator*)indicator
                        animated:(BOOL)animated {
    if (!indicator) {
        return;
    }
    
    if (!animated)
    {
        [indicator removeFromSuperview];
    }
    else
    {
        [UIView animateWithDuration:0.2
                         animations:^{ indicator.alpha = 0; }
                         completion:^(BOOL finished)
         {
             [indicator removeFromSuperview];
         }];
    }
}

@end
