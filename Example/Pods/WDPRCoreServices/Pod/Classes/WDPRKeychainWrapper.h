//
//  WDPRKeychainWrapper.h
//  WDPR
//
//  Provides a wrapper to interact with the Keychain.
//  Uses the application bundle identifier as the account identifier.
//  The service identifier to use is provided by the class user.
//  Account identifier and service identifier unequivocally identifies an entry on the keychain
//
//  This class is ARC compliant - any references to CF classes must be paired with a "__bridge"
//  statement to cast between Objective-C and Core Foundation Classes.  WWDC 2011 Video "Introduction to
//  Automatic Reference Counting" explains this.
//
//  This wrapper is an adaptation of the KeychainWrapper writed by Ray Wenderlich on
//  @see<a href="http://www.raywenderlich.com/6475/basic-security-in-ios-5-tutorial-part-1">Ray Wenderlich - Basic Security in iOS 5</a>
//
//  Created by Iván Camilo Fuertes on 15/09/15.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDPRKeychainWrapper : NSObject

//---------- storing and retrieving

/**
 *  Search the keychain for a given value. Limit one result per search.
 *
 *
 *  @param identifier                  identifies the item in the Keychain
 *  @param authenticationPromptMessage the message to display to the user in the prompt that requires his fingerprint/passcode
 *                                     set it to nil if you want to display the default message
 *  @param error                       if operation fails, the returned error contains as code the OSStatus result code
 *                                      @see SecBase.h for a list of OSStatus result codes
 *
 *  @return search result as NSString. If nothing found, nil is returned
 */
+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier authenticationPromptMessage:(NSString *)authenticationPromptMessage error:(NSError **)error;

/**
 *  Search the keychain for a given value. Limit one result per search.
 *
 *
 *  @param identifier                  identifies the item in the Keychain
 *  @param authenticationPromptMessage the message to display to the user in the prompt that requires his fingerprint/passcode
 *                                     set it to nil if you want to display the default message
 *  @param error                       if operation fails, the returned error contains as code the OSStatus result code
 *                                      @see SecBase.h for a list of OSStatus result codes
 *
 *  @return search result as NSString. If nothing found, nil is returned
 */
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier authenticationPromptMessage:(NSString *)authenticationPromptMessage error:(NSError **)error;

/**
 *  Stores an item in the keychain
 *  Any item with the same identifier is deleted first.
 *
 *  @param value      value to store
 *  @param identifier identifies the item in the Keychain
 *
 *  @return YES if storing was successful
 */
+ (BOOL)storeKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

/**
 *  Updates a value in the keychain
 *
 *  @param value      updated value of the item
 *  @param identifier identifies the item in the Keychain
 *
 *  @return YES if updating was successful.
 */
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

//---------- ACL protected storing

/**
 *  Stores an item using ACL (Access Control List) to define it's accessibility and authentication policy.
 *  Any item with the same identifier is deleted first.
 *
 *  @param value          value to store in the Keychain
 *  @param identifier     identifies the item in the Keychain
 *  @param accessControl  specifies the accessibility and the authentication policy to store this item
 *                        @see SecAccessControlCreateWithFlags to create a new access control object based on protection type and additional flags
 *
 *  @return YES if storing was successful
 */
+ (BOOL)storeKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier secureUsingAccessControl:(SecAccessControlRef)accessControl;

//---------- deleting

/**
 *  Deletes an item from the keychain
 *
 *  @param identifier identifies the item in the Keychain
 */
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;

@end
