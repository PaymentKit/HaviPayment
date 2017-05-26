// AFOAuthCredential.h
//
// Copyright (c) 2013 AFNetworking (http://afnetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFOAuthCredential.h"

#ifdef _SECURITY_SECITEM_H_
NSString * const kAFOAuth2CredentialServiceName = @"AFOAuthCredentialService";

static NSMutableDictionary * AFKeychainQueryDictionaryWithIdentifier(NSString *identifier) {
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword, kSecClass, kAFOAuth2CredentialServiceName, kSecAttrService, nil];
    [queryDictionary setValue:identifier forKey:(__bridge id)kSecAttrAccount];

    return queryDictionary;
}
#endif


@interface AFOAuthCredential ()
@property (readwrite, nonatomic) NSString *accessToken;
@property (readwrite, nonatomic) NSString *tokenType;
@property (readwrite, nonatomic) NSString *refreshToken;
@property (readwrite, nonatomic) NSDate *expiration;
@end

@implementation AFOAuthCredential
@synthesize accessToken = _accessToken;
@synthesize tokenType = _tokenType;
@synthesize refreshToken = _refreshToken;
@synthesize expiration = _expiration;
@synthesize highTrustExpiration = _highTrustExpiration;
@dynamic expired;
@dynamic highTrustExpired;

#pragma mark -

+ (instancetype)credentialWithOAuthToken:(NSString *)token
                               tokenType:(NSString *)type
{
    return [[self alloc] initWithOAuthToken:token tokenType:type];
}

- (id)initWithOAuthToken:(NSString *)token
               tokenType:(NSString *)type
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.accessToken = token;
    self.tokenType = type;

    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ clientID:\"%@\" accessToken:\"%@\" tokenType:\"%@\" refreshToken:\"%@\" expiration:\"%@\" highTrustExpiration:\"%@\" swid:\"%@\" xid:\"%@\">",
            [self class], self.clientID, self.accessToken, self.tokenType, self.refreshToken, self.expiration, self.highTrustExpiration, self.swid, self.xid];
}

- (void)setRefreshToken:(NSString *)refreshToken
             expiration:(NSDate *)expiration
{
    if (refreshToken)
    {
        self.refreshToken = refreshToken;
    }
    
    if (expiration)
    {
        self.expiration = expiration;
    }
}

- (BOOL)isExpired {
    return [self.expiration compare:[NSDate date]] == NSOrderedAscending;
}

- (void)setHighTrustExpiration:(NSDate *)expiration
{
    if (!expiration) {
        return;
    }
    
    _highTrustExpiration = expiration;
}

- (BOOL)isHighTrustExpired
{
    return [self.highTrustExpiration compare:[NSDate date]] == NSOrderedAscending;
}

#pragma mark Keychain

#ifdef _SECURITY_SECITEM_H_

+ (BOOL)storeCredential:(AFOAuthCredential *)credential withIdentifier:(NSString *)identifier {
    return [self storeCredential:credential withIdentifier:identifier useICloud:NO];
}

+ (BOOL)storeCredential:(AFOAuthCredential *)credential withIdentifier:(NSString *)identifier useICloud:(BOOL)shouldUseICloud {
    id securityAccessibility;
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 43000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)
    securityAccessibility = (__bridge id)kSecAttrAccessibleWhenUnlocked;
#endif
    return [self storeCredential:credential withIdentifier:identifier withAccessibility:securityAccessibility useICloud:shouldUseICloud];
}

+ (BOOL)storeCredential:(AFOAuthCredential *)credential
         withIdentifier:(NSString *)identifier withAccessibility:(id)securityAccessibility useICloud:(BOOL)shouldUseICloud {
    NSMutableDictionary *queryDictionary = AFKeychainQueryDictionaryWithIdentifier(identifier);

    if (!credential) {
        return [self deleteCredentialWithIdentifier:identifier useICloud:shouldUseICloud];
    }

    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:credential];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
    if (securityAccessibility) {
        [updateDictionary setObject:securityAccessibility forKey:(__bridge id)kSecAttrAccessible];
    }

    if (shouldUseICloud) {
        [queryDictionary setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
        [updateDictionary setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
    }

    OSStatus status;
    BOOL exists = ([self retrieveCredentialWithIdentifier:identifier] != nil);

    if (exists) {
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
    } else {
        [queryDictionary addEntriesFromDictionary:updateDictionary];
        status = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL);
    }

    if (status != errSecSuccess) {
        NSLog(@"Unable to %@ credential with identifier \"%@\" (Error %li)", exists ? @"update" : @"add", identifier, (long int)status);
    }

    return (status == errSecSuccess);
}

+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier {
    return [self deleteCredentialWithIdentifier:identifier useICloud:NO];
}

+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier useICloud:(BOOL)shouldUseICloud {
    NSMutableDictionary *queryDictionary = AFKeychainQueryDictionaryWithIdentifier(identifier);

    if (shouldUseICloud) {
        [queryDictionary setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
    }

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);

    if (status != errSecSuccess) {
        NSLog(@"Unable to delete credential with identifier \"%@\" (Error %li)", identifier, (long int)status);
    }

    return (status == errSecSuccess);
}

+ (AFOAuthCredential *)retrieveCredentialWithIdentifier:(NSString *)identifier {
    return [self retrieveCredentialWithIdentifier:identifier useICloud:NO];
}

+ (AFOAuthCredential *)retrieveCredentialWithIdentifier:(NSString *)identifier useICloud:(BOOL)shouldUseICloud {
    NSMutableDictionary *queryDictionary = AFKeychainQueryDictionaryWithIdentifier(identifier);
    [queryDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [queryDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    if (shouldUseICloud) {
        [queryDictionary setObject:@YES forKey:(__bridge id)kSecAttrSynchronizable];
    }

    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&result);

    if (status != errSecSuccess) {
        NSLog(@"Unable to fetch credential with identifier \"%@\" (Error %li)", identifier, (long int)status);
        return nil;
    }

    NSData *data = (__bridge_transfer NSData *)result;
    AFOAuthCredential *credential = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    return credential;
}

#endif

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    self.clientID = [decoder decodeObjectForKey:@"clientID"];
    self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
    self.tokenType = [decoder decodeObjectForKey:@"tokenType"];
    self.refreshToken = [decoder decodeObjectForKey:@"refreshToken"];
    self.expiration = [decoder decodeObjectForKey:@"expiration"];
    self.highTrustExpiration = [decoder decodeObjectForKey:@"highTrustExpiration"];
    self.swid = [decoder decodeObjectForKey:@"swid"];
    self.xid = [decoder decodeObjectForKey:@"xid"];
    self.firstName = [decoder decodeObjectForKey:@"firstName"];
    self.lastName = [decoder decodeObjectForKey:@"lastName"];
    self.avatar = [decoder decodeObjectForKey:@"avatar"];
    self.legalDocuments = [decoder decodeObjectForKey:@"legalDocuments"];
    self.countryCode = [decoder decodeObjectForKey:@"countryCode"];
    self.ageBand = [decoder decodeObjectForKey:@"ageBand"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.clientID forKey:@"clientID"];
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.tokenType forKey:@"tokenType"];
    [encoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [encoder encodeObject:self.expiration forKey:@"expiration"];
    [encoder encodeObject:self.highTrustExpiration forKey:@"highTrustExpiration"];
    [encoder encodeObject:self.swid forKey:@"swid"];
    [encoder encodeObject:self.xid forKey:@"xid"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.avatar forKey:@"avatar"];
    [encoder encodeObject:self.legalDocuments forKey:@"legalDocuments"];
    [encoder encodeObject:self.countryCode forKey:@"countryCode"];
    [encoder encodeObject:self.ageBand forKey:@"ageBand"];
}

@end
