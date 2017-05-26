//
//  NSArray+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 8/6/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (WDPR)

#if TARGET_OS_MAC
- (id)firstObject;
#endif

/*
 This method will first check the Main.bundle for this plist, if this does not exist, will
 check the Data.bundle. This function is for the ability to override the plist.
 */
+ (NSArray*)arrayFromPList:(NSString*)file;

/*
 This method will first check the Main.bundle for this plist, if this does not exist, will
 check the Data.bundle. Then will finally fall back on the finding in the specified bundle which
 is looked for in the mainBundle.
 This function is for the ability to override the plist.
 */
+ (NSArray*)arrayFromPList:(NSString *)file inBundleNamed:(NSString*)bundleName;

/*
 This method will first check the Main.bundle for this plist, if this does not exist, will
 check the Data.bundle. Then will finally fall back on looking in the provided bundle.
 This function is for the ability to override the plist.
 */
+ (NSArray*)arrayFromPList:(NSString *)file inBundle:(NSBundle *)bundle;

- (NSArray *)subarrayFromIndex:(NSInteger)index;

- (NSArray *)nonNullValuesForKeyPath:(NSString *)keyPath;
- (NSArray *)nonNullValuesForSelector:(SEL)selector;
@end
