//
//  NSString+WDPR.h
//  WDPR
//
//  Created by Garvin, Cody on 8/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (WDPR)

// Return a hash the current string
- (NSString *)MD5Hash;

// Strip white space from a string
- (NSString *)stripWhiteSpace;

// Strip all newline characters
- (NSString *)stripNewlineCharacters;

/// Strip non alphanumeric characters.
- (NSString *)stripNonAlphaNumeric;

/// Strip trademark symbols ™ and ®.
- (NSString *)stripTrademarkSymbols;

// Returns YES, if this string is empty
- (BOOL)isEmpty;

// Returns YES, if this string is formatted as a valid email address.
- (BOOL)isValidEmailAddress;

// Returns YES if the string is alpha numeric.
- (BOOL)isAlphaNumeric;

// Returns YES if the string is alphabetic.
- (BOOL)isAlphabetic;

// Returns YES if the string is numeric.
- (BOOL)isNumeric;

// Remove any HTML from the string
- (NSString *)stripHTML;

- (NSString *)urlEncode;

- (BOOL)hasSubstring:(NSString *)aString;

- (NSString *)prettyPrintPhoneNumber;
- (NSString *)stripDecorationsOfPhoneNumber;
- (NSString *)lowercaseFirstLetter;
- (NSString *)uppercaseFirstLetter;

/**
 We're getting strings like "3.5" from the mobile service for prices, and we want to display things like
 "$3.50", so this is where we're formatting them.
 */
- (NSString*)formatPriceString;

/**
 case-insensitively compares this string with another, using a dictionary with arbitrary weights. ex. @{@"aString": @1, @"another": @2}
 Any string not in the list compared with a string in the list comes out NSOrderedDescending, two strings not
 in the list come out NSOrderedSame.
 
 We're using this to order facets and meal times.
 */
- (NSComparisonResult)compare:(NSString*)aString usingArbitraryOrdering:(NSDictionary*)ordering;

-(NSString *)stringByRemovingSubstrings:(NSArray *)substrings;

-(NSString *)stringByDeletingTextBetweenBraces;

// compares version strings (for example 1.2.3 -vs- 1.2)
- (BOOL)isGreaterThanOrEqualToVersion:(NSString*)version;

// Returns the substring between start and end string..
//e.g: [@"$$, (from 10 to 20)" stringBetweenString:@"(" andString:@")"]
//return -> @"from 10 to 20"
- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;

// Trim unneeded HTML tags and spaces from an HTML text
-(NSString *)stringWithoutHtmlCharacters;

@end
