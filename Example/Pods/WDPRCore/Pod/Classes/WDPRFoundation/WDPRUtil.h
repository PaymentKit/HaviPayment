//
//  WDPRUtil.h
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDPRUtil : NSObject

+ (NSString *)appName;

+ (NSString *)deviceVersion;

@end // @interface WDPRUtil

// Helper methods to execute blocks on various threads
void executeOnMainThread(dispatch_block_t block);
void executeInBackground(dispatch_block_t block);
void executeOnNextRunLoop(dispatch_block_t block);
void executeOnServiceQueue(dispatch_block_t block);

void executeInBackgroundAndWait(dispatch_block_t block);
void executeOnMainThreadAndWait(dispatch_block_t block);

