//
//  WDPRConnectivity.h

#import <Foundation/Foundation.h>

#define errorCode_NoInternetConnection (-1009)

@class WDPRConnectivity;

@protocol WDPRConnectivityDelegate <NSObject>

@optional
- (void)didLoseConnectivity:(WDPRConnectivity *)connectivity;
- (void)didRestoreConnectivity:(WDPRConnectivity *)connectivity;

@end

@interface WDPRConnectivity : NSObject

+ (WDPRConnectivity*) sharedInstance;

/// return YES if connected
- (BOOL) isConnected:(NSError*)lastError;

/// return YES if host is reachable
- (BOOL) hostIsReachable:(NSString*)host;

// Will force check network connection(Reachability). Calls delegate method didLoseConnectivity: if none.
- (void)checkForNetworkConnection;

- (void)setUpBackgroundForegroundWatch;

- (void)addDelegate:(id<WDPRConnectivityDelegate>)delegate;
- (void)removeDelegate:(id<WDPRConnectivityDelegate>)delegate;

@end
