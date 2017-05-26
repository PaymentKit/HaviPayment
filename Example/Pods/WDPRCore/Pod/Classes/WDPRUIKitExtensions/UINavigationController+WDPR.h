//
//  UINavigationController+WDPR.h
//  DLR
//
//  Created by Fuerle, Dmitri on 4/15/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (WDPR)

/**
 Iterates through the navigation stack and returns a view controller if its class is equal to the one passed as
 an argument
 @param vcClass The Class for the view controller being requested
 @discussion First view controller from bottom to top of the stack that meet requirements will be returned
 @return The first view controller found in the navigation stack that complies with the specified class, otherwise will return nil
 */
- (UIViewController*)controllerFromNavigationStackWithClass:(Class)vcClass;

@end
