//
//  WDPRKeychainWrapper.m
//  WDPR
//
//  Created by Iván Camilo Fuertes on 15/09/15.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRKeychainWrapper.h"
#import <WDPRCore/WDPRFoundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

@implementation WDPRKeychainWrapper

+ (NSMutableDictionary *)setupSearchDirectoryForIdentifier:(NSString *)identifier
{
    // Setup dictionary to access keychain.
    // Use the app bundle identifier as the account identifier and the user provided identifier as the service identifier
    // AccountId and ServiceId unequivocally identifies an item on the keychain store
    NSMutableDictionary *searchDictionary =
    [@{
      (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
      (__bridge id) kSecAttrAccount: [[NSBundle mainBundle] bundleIdentifier],
      (__bridge id) kSecAttrService: identifier
      } mutableCopy];
    
    return searchDictionary; 
}

+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier authenticationPromptMessage:(NSString *)authenticationPromptMessage error:(NSError **)error
{
    
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    // Limit search results to one.
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	
    // Specify we want NSData/CFData returned.
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    // Set the authentication prompt to display
    if (authenticationPromptMessage && ![authenticationPromptMessage isEmpty])
    {
        // Using localized string for "Enter Passcode" for Touch ID.  If one isn't specified, Apple's default text is used.
        NSString *localizedKey = @"com.wdprcoreservices.touchid.enterpasscode";
        NSString *enterPasscodeText = WDPRLocalizedString(localizedKey, nil);
        
        // How to check if constant is available: http://stackoverflow.com/questions/3122177/check-if-constant-is-defined-at-runtime-in-obj-c
        // This is equivalent to checking if the device is on iOS 9 or later.
        if (enterPasscodeText != nil && ![enterPasscodeText isEqualToString:localizedKey] && &kSecUseAuthenticationContext != NULL)
        {
            LAContext *context = [[LAContext alloc] init];
            context.localizedFallbackTitle = enterPasscodeText;
            [searchDictionary setObject:context forKey:(__bridge id)kSecUseAuthenticationContext];
        }
        
        [searchDictionary setObject:authenticationPromptMessage forKey:(__bridge id)kSecUseOperationPrompt];
    }
	
    // Search.
    *error = nil;
    NSData *result = nil;   
    CFTypeRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    switch (status)
    {
        case noErr:
            result = CFGetTypeID(foundDict) == CFDataGetTypeID() ? (__bridge_transfer NSData *)foundDict : nil;
            break;
        default:
            [self error:error fromOSStatus:status];
            break;
    }
    
    return result;
}

+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier authenticationPromptMessage:(NSString *)authenticationPromptMessage error:(NSError **)error
{
    *error = nil;
    NSString *searchResult = nil;
    
    NSData *valueData = [self searchKeychainCopyMatchingIdentifier:identifier authenticationPromptMessage:authenticationPromptMessage error:error];
    if (valueData)
    {
        searchResult = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    }
    
    return searchResult;
}

+ (BOOL)storeKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier
{
    return [self storeKeychainValue:value forIdentifier:identifier secureUsingAccessControl:nil];
}

+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier 
{
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:valueData forKey:(__bridge id)kSecValueData];
	
    // Update.
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)updateDictionary);
	
    return status == errSecSuccess;
}

#pragma mark - ACL protected storing >>

+ (BOOL)storeKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier secureUsingAccessControl:(SecAccessControlRef)accessControl
{
    [WDPRKeychainWrapper deleteItemFromKeychainWithIdentifier:identifier];
    
    NSMutableDictionary *dictionary = [self setupSearchDirectoryForIdentifier:identifier];
    if (accessControl)
    {
        [dictionary setObject:(__bridge id)(accessControl) forKey:(__bridge id)(kSecAttrAccessControl)];
    }
    [dictionary setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
    
    // Add.
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    return status == errSecSuccess;
}

#pragma mark - deleting >>

+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier 
{
    NSMutableDictionary *searchDictionary = [self setupSearchDirectoryForIdentifier:identifier];
    
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

#pragma mark - private methods  >>

+ (void)error:(NSError **)error fromOSStatus:(OSStatus)status
{
    *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:status userInfo:nil];
}

@end
