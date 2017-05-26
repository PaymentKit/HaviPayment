//
//  WDPRPullDownView.h
//  DLR
//
//  Created by Francisco Valbuena on 3/31/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

typedef NS_ENUM(NSUInteger, WDPRPullDownState)
{
    WDPRPullDownStateStatic,
    WDPRPullDownStateDragging,
    WDPRPullDownStateDropping,
    WDPRPullDownStateBouncing,
    WDPRPullDownStateDropped
};

@protocol WDPRPullDownViewDelegate;

@interface WDPRPullDownView : UIView

@property (nonatomic, readonly) WDPRPullDownState state;
@property (nonatomic, assign) CGFloat minDraggingFactorToDrop;
@property (nonatomic, strong) UIView *viewToPull;
@property (nonatomic, weak) id<WDPRPullDownViewDelegate> delegate;

@end

@protocol WDPRPullDownViewDelegate <NSObject>

@optional
- (void)pullDownViewWillStartDragging:(WDPRPullDownView *)pullDownView;
- (void)pullDownViewDidDrag:(WDPRPullDownView *)pullDownView;
- (void)pullDownViewDidDTap:(WDPRPullDownView *)pullDownView;
- (void)pullDownViewDidEndDragging:(WDPRPullDownView *)pullDownView willDrop:(BOOL)drop;
- (void)pullDownViewDidDrop:(WDPRPullDownView *)pullDownView;

@end
