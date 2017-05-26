//
//  WDPRLoader.h
//  loader
//
//  Created by John Uribe Mendoza on 17/03/15.
//  Copyright (c) 2015 John Uribe Mendoza. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^loaderCompletionHandler)(void);

@interface WDPRLoader : UIView

@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) BOOL hidesWhenStop;
@property (strong, nonatomic) UIImage *failureImage;
@property (assign, nonatomic) CGFloat distanceFromTop;
@property (assign, nonatomic) CGFloat distanceFromBottom;
@property (assign, nonatomic) CGFloat distanceBetweenLabelAndLoader;
@property (assign, nonatomic) float lineWidth;

//WDPR default loaders
+ (instancetype)showNonTransactionalLoaderInView:(UIView *)parentView;
+ (instancetype)showNonTransactionalLoaderWithLabel:(NSString *)text inView:(UIView *)parentView;
+ (instancetype)showTransactionalLoader;
+ (instancetype)showTransactionalLoaderWithLabel:(NSString *)text;
+ (instancetype)showTransactionalLoaderWithLabel:(NSString *)text inView:(UIView *)parentView;
- (instancetype)initWithParentView:(UIView *)parentView;

//Additional configuration methods
- (void)setCustomRadius:(float)radius;
- (void)setParentView:(UIView *)view;
- (void)setIsViewBlocking:(BOOL)isViewBlocking;
- (void)setIsViewBlocking:(BOOL)isViewBlocking useWhiteView:(BOOL)useWhiteView;
- (void)setAnimationDuration:(NSTimeInterval)duration;
- (void)setFont:(UIFont *)font;
- (void)setText:(NSString *)text;
- (void)setTextColor:(UIColor *)color;

//This methods are here for manually set x,y position

- (void)setImageXOffset:(float)xOffset;
- (void)setImageYOffset:(float)yOffset;
- (void)setLabelXOffset:(float)xOffset;
- (void)setLabelYOffset:(float)yOffset;

//Loader status methods
- (void)startAnimating;
- (void)stopAnimating;
- (void)stopAnimatingWithCompletionHandler:(loaderCompletionHandler)block;
- (void)stopAnimatingWithSuccess:(BOOL)success completionHandler:(loaderCompletionHandler)block;
- (void)stopAnimatingWithSuccess:(BOOL)success text:(NSString *)text completionHandler:(loaderCompletionHandler)block;
@end
