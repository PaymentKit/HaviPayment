//
// Created by Clark, Daniel on 7/20/15.
//

#import <Foundation/Foundation.h>


#define WDPRDefaultEnvironment @"default"
#define WDPRChosenEnvironment @"Environment"
#define WDPREnvironmentChangedNotification @"MdxEnvironmentChanged"

@protocol WDPREnvironment <NSObject>

- (NSString *)name;
- (NSDictionary *)details;
- (BOOL)useSoftLaunchEnvironment; // (calls class method)
+ (BOOL)useSoftLaunchEnvironment; // (base implementation)

- (id)valueForKey:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString*)key;

- (id)valueForKey:(NSString *)key withTokens:(NSDictionary *)args;
- (id)valueForKey:(NSString *)key withTokens:(NSDictionary *)args removePlaceholders:(BOOL)removePlaceholders;
- (id)valueForPath:(NSString*)path withTokens:(NSDictionary *)args;
- (id)valueForPath:(NSString*)path withTokens:(NSDictionary *)args removePlaceholders:(BOOL)removePlaceholders;

- (NSURL *)urlForService:(NSString *)service withTokens:(NSDictionary *)args;

- (void) setValue:(id)value forKey:(NSString *)key;

@end  // @protocol WDPREnvironment

@interface WDPREnvironment : NSObject< WDPREnvironment>

@end