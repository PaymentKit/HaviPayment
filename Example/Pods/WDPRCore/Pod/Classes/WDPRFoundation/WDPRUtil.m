//
//  WDPRUtil.m
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"
#import <sys/sysctl.h>

@implementation WDPRUtil

+ (NSString *)appName
{
    NSString *appName = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    return (appName) ?: [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
}

+ (NSString *)deviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

@end

#pragma mark -

void executeInBackground(dispatch_block_t block) 
{
    dispatch_queue_priority_t priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
    
    dispatch_async(dispatch_get_global_queue(priority, 0), block);
}

void executeOnMainThread(dispatch_block_t block) 
{
    [NSOperationQueue.mainQueue addOperationWithBlock:block];
}

void executeOnNextRunLoop(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}

void executeOnServiceQueue(dispatch_block_t block) 
{
    [NSOperationQueue.serviceCallQueue addOperationWithBlock:block];
}

void executeInBackgroundAndWait(dispatch_block_t block) 
{
    dispatch_queue_priority_t priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
    
    dispatch_sync(dispatch_get_global_queue(priority, 0), block);
}

void executeOnMainThreadAndWait(dispatch_block_t block) 
{
    dispatch_sync(dispatch_get_main_queue(), block);
}
