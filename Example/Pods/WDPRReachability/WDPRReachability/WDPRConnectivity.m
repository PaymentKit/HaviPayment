//
//  MdxConnectivity.m
//  Mdx
//
//  Created by Hutchinson, Jack X. -ND on 10/23/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRConnectivity.h"
#import "WDPRReachability.h"

// This is temporary until the buildphase supports frameworks
#if TARGET_OS_IOS
@import WDPRCore;
#else
#import <WDPRCore/WDPRFoundation.h>
#endif

#define SECONDS_BETWEEN_CASUAL_NO_CONNECT_MSGS (5*60)

@interface WDPRConnectivity ()

@property (nonatomic) NSDate* timestamp_LastNoConnectivityMsg;
@property (nonatomic) NSDate* timestamp_LastConnectivityRestoredMsg;
@property (nonatomic) NSDate* timestamp_LastSuccessfulConnection;

@property (nonatomic, assign) BOOL flag_SingleShot_NoInternetMessage;    // good for one time

@property (nonatomic, strong) WDPRReachability *internetReachability;
@property (nonatomic, assign) NetworkStatus lastNetworkStatus;

@property (nonatomic, strong) id<NSObject> referenceId;

@property (nonatomic, strong) NSHashTable *delegateTable;

@end

@implementation WDPRConnectivity

+ (WDPRConnectivity*) sharedInstance
{
    static dispatch_once_t onceToken;
    static WDPRConnectivity *instance = nil;
    dispatch_once(&onceToken,
    ^{
        instance = [WDPRConnectivity new];
        instance.delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    });
    return instance;
}

- (void)setUpBackgroundForegroundWatch
{
    void (^initializeItemsBlock)() =
    ^{
        self.internetReachability = [WDPRReachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        [self startListeningForReachability];


        [self startBackgroundWatchForNetworkConnection];
        [self startForegroundWatchForNetworkConnection];
    };
    executeOnlyOnce(initializeItemsBlock);
}


- (void)startBackgroundWatchForNetworkConnection
{
    MAKE_WEAK(self);
    
#if !TARGET_OS_IPHONE
    NSString *name = NSApplicationDidHideNotification;
#else
    NSString *name = UIApplicationDidEnterBackgroundNotification;
#endif
    [self observeNotificationName:name
                           object:nil
                            queue:[NSOperationQueue backgroundQueue]
                       usingBlock:^(NSNotification *note)
     {
         MAKE_STRONG(self);
         [[NSNotificationCenter defaultCenter] removeObserver:strongself.referenceId];
     }];
}

- (void)startForegroundWatchForNetworkConnection
{
    MAKE_WEAK(self);

#if !TARGET_OS_IPHONE
    NSString *name = NSApplicationWillBecomeActiveNotification;
#else
    NSString *name = UIApplicationWillEnterForegroundNotification;
#endif
    
    [self observeNotificationName:name
                           object:nil
                            queue:[NSOperationQueue backgroundQueue]
                       usingBlock:^(NSNotification *note)
     {
         MAKE_STRONG(self);
         [strongself startListeningForReachability];
         [strongself checkForNetworkConnection];
     }];
}

- (void)startListeningForReachability
{
    MAKE_WEAK(self);

    self.referenceId = [[NSNotificationCenter defaultCenter]
     addObserverForName:kWDPRReachabilityChangedNotification
     object:nil
     queue:[NSOperationQueue backgroundQueue]
     usingBlock:^(NSNotification *note)
     {
         MAKE_STRONG(self);
         [strongself reachabilityChanged:note];
     }];
}

- (void)checkForNetworkConnection
{
    [self reachabilityChanged:[NSNotification
                               notificationWithName:kWDPRReachabilityChangedNotification
                               object:self.internetReachability]];
}

-(void)reachabilityChanged:(NSNotification *)sender
{
    WDPRReachability *reachability = (WDPRReachability *)sender.object;
    
    if ( reachability == self.internetReachability )
    {
        self.lastNetworkStatus = [reachability currentReachabilityStatus];
        
        if ( self.lastNetworkStatus == NotReachable )
        {
            [self showNoInternetMessage];
        }
        else
        {
            [self showInternetRestoredMessage];
        }
    }
}

- (BOOL) isConnected:(NSError*)lastError
{
    BOOL bret= NO;
    
    WDPRReachability* reachability= [WDPRReachability reachabilityForInternetConnection];
    if (reachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        // TODO: is this best way to test connectivity?
        BOOL isConnected= !(netStatus == NotReachable);
        
        bret= isConnected;
    }
    
    // check error codes
    if (lastError)
    {
        if (lastError.code==errorCode_NoInternetConnection)    // -1009 error
            bret= NO;
    }
    
    return bret;
}

- (BOOL) hostIsReachable:(NSString*)path
{
    NSURL* url= [NSURL URLWithString:path];
    NSString* host= [url host];
    WDPRReachability* reachability= [WDPRReachability reachabilityWithHostName:host];
    if (reachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        return !(netStatus == NotReachable);
    }
    return NO;
}

- (void) showNoInternetMessage
{
    for (id<WDPRConnectivityDelegate> delegate in self.delegateTable)
    {
        if ([delegate respondsToSelector:@selector(didLoseConnectivity:)])
        {
            executeOnMainThread
            (^{
                [delegate didLoseConnectivity:self];
            });
        }
    }
}

- (void) showInternetRestoredMessage
{
    for (id<WDPRConnectivityDelegate> delegate in self.delegateTable)
    {
        if ([delegate respondsToSelector:@selector(didRestoreConnectivity:)])
        {
            executeOnMainThread
            (^{
                [delegate didRestoreConnectivity:self];
            });
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addDelegate:(id<WDPRConnectivityDelegate>)delegate
{
    if (delegate && ![self.delegateTable containsObject:delegate])
    {
        [self.delegateTable addObject:delegate];
    }

}

- (void)removeDelegate:(id<WDPRConnectivityDelegate>)delegate
{
    [self.delegateTable removeObject:delegate];
}

@end
