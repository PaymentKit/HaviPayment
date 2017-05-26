//
//  UIViewController+WDPR.h
//  DLR
//
//  Created by Rodden, James on 7/30/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDPRLoader;

typedef NS_ENUM(NSInteger, WDPRViewControllerActivityIndicatorAlignment)
{
    WDPRViewControllerActivityIndicatorAlignmentTop,
    WDPRViewControllerActivityIndicatorAlignmentBottom,
    WDPRViewControllerActivityIndicatorAlignmentCenter,
    WDPRViewControllerActivityIndicatorAlignmentNoAlignment
};

@interface UIViewController (WDPR)

- (void)displayActivityIndicator;
- (void)displayActivityIndicatorWithMessage:(NSString*)message;
- (void)displayActivityIndicatorTransactional;
- (void)displayActivityIndicatorTransactionalWithMessage:(NSString*)message;
- (void)displayActivityIndicatorTransactional:(BOOL)transactional message:(NSString*)message distanceFromTop:(CGFloat)distanceFromTop;
- (void)displayActivityIndicatorTransactional:(BOOL)transactional message:(NSString*)message inView:(UIView *)inView;
- (void)displayActivityIndicatorTransactional:(BOOL)transactional
                                      message:(NSString*)message
                                     alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment;
- (void)updateActivityIndicatorWithMessage:(NSString*)message;
- (void)dismissActivityIndicator;

- (WDPRLoader *)showNonTransactionalActivityIndicatorInView:(UIView*)view
                                                      label:(NSString *)text
                                                  alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment;

- (WDPRLoader *)showNonTransactionalActivityIndicatorWithLabel:(NSString *)text
                                                     alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment;

- (WDPRLoader *)showTransactionalActivityIndicatorWithLabel:(NSString *)text
                                                  alignment:(WDPRViewControllerActivityIndicatorAlignment)alignment;

- (void)removeActivityIndicator:(WDPRLoader *)activityIndicator completion:(void (^)())completion;

#pragma mark -

- (void)setupRuleUnderHeader;

- (UIButton*)addCallToAction:(NSString*)title
                       block:(void (^)(void))block;

@property (nonatomic, readonly) BOOL isModal;

- (void)presentModally:(UIViewController*)vc;
- (void)presentModally:(UIViewController*)vc
  withLeftCancelButton:(BOOL)leftCancelButton;

- (void)presentModally:(UIViewController*)vc
  withLeftCancelButton:(BOOL)leftCancelButton
            completion:(void (^)(void))completion;

- (void)pushViewController:(UIViewController*)vc;

- (void)dismissViewController;

- (void)dismissViewControllerCompletion:(void (^)(void))completion;
- (void)dismissViewControllerCompletion:(void (^)(void))completion animated:(BOOL)animated;

- (void)addChildViewControllerFullScreen:(UIViewController *)childController;
- (void)addChildViewController:(UIViewController *)childController withFrame:(CGRect)frame;

- (void)presentChildControllerAsModal:(UIViewController *)viewController animated:(BOOL)animated;
- (void)presentChildControllerAsModal:(UIViewController *)viewController withHeight:(CGFloat)height animated:(BOOL)animated;
- (void)dismissModalChildController:(BOOL)animated completion:(void (^)(void))completion;

@end
