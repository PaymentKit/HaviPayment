//
//  WDPRViewController.h
//  DLR
//
//  Created by Delafuente, Rob on 3/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MdxStyleAnalytics <NSObject>

@optional

// backwards compatability until all Mdx
// viewControllers migrate, or are replaced
// with implementation of trackState style

- (void)fireMdxStyleAnalytics:(NSTimeInterval)loadTime;

@property (nonatomic, readonly) NSString* viewTrackingName;
@property (nonatomic, readonly) NSDictionary* viewTrackingContext;

@end

@interface WDPRViewController : UIViewController<MdxStyleAnalytics>

/// If not nil, Voice Over will use this property to announce the screen name
/// when accesing the screen
@property (nonatomic) NSString* screenNameToAnnounce;

/// Add a title to a view controller with a default format
/// DO NOT ADD YOUR OWN PROPERTY CALLED titleLabel!!!!
- (void)setTitleLabel:(NSString*)title;

@end
