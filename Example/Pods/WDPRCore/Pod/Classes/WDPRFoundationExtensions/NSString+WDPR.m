//
//  NSString+WDPR.m
//  WDPR
//
//  Created by Garvin, Cody on 8/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "WDPRFoundation.h"

@implementation NSString (WDPR)

- (BOOL)isEmpty
{
    return [self isEqual:[NSNull null]] || [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0;
}

- (BOOL)isValidEmailAddress
{
    BOOL returnVal = YES;
    
    if (self.length == 0)
    {
        returnVal = NO;
    }
    else
    {
        NSString *emailRegEx =
        @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[A-Za-"
        @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if (![regExPredicate evaluateWithObject:self])
        {
            returnVal = NO;
        }
    }
    
    return returnVal;
}

- (BOOL)isAlphaNumeric
{
    BOOL returnVal = YES;
    
    if (self.length == 0)
    {
        returnVal = NO;
    }
    else
    {
        NSCharacterSet *nonAlphaNumericCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        
        if ([self rangeOfCharacterFromSet:nonAlphaNumericCharacters].location != NSNotFound)
        {
            returnVal = NO;
        }
    }
    
    return returnVal;
}

- (BOOL)isAlphabetic
{
    BOOL returnVal = YES;
    
    if (self.length == 0)
    {
        returnVal = NO;
    }
    else
    {
        NSCharacterSet *nonAlphabeticCharacters = [[NSCharacterSet letterCharacterSet] invertedSet];
        
        if ([self rangeOfCharacterFromSet:nonAlphabeticCharacters].location != NSNotFound)
        {
            returnVal = NO;
        }
    }
    
    return returnVal;
}

- (BOOL)isNumeric
{
    BOOL returnVal = YES;
    
    if (self.length == 0)
    {
        returnVal = NO;
    }
    else
    {
        NSCharacterSet *nonNumericCharacters = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        if ([self rangeOfCharacterFromSet:nonNumericCharacters].location != NSNotFound)
        {
            returnVal = NO;
        }
    }
    
    return returnVal;
}

- (NSString *)MD5Hash
{
	CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	CC_MD5_Update (&md5, [self UTF8String], (CC_LONG)[self length]);
	
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				digest[0],  digest[1], 
				digest[2],  digest[3],
				digest[4],  digest[5],
				digest[6],  digest[7],
				digest[8],  digest[9],
				digest[10], digest[11],
				digest[12], digest[13],
				digest[14], digest[15]];
	
	return s;
}

- (NSString *)stripWhiteSpace
{
    NSString *afterWhatSpaceString =
        [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    afterWhatSpaceString =
        [afterWhatSpaceString stringByReplacingOccurrencesOfString:@"\r"
                                                        withString:@""];

    return afterWhatSpaceString;
}

- (NSString *)stripNewlineCharacters
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (NSString *)stripNonAlphaNumeric
{
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return [[self componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
}

- (NSString *)stripTrademarkSymbols
{
    NSString *string = [self stringByReplacingOccurrencesOfString:@"™" withString:@""];
    return [string stringByReplacingOccurrencesOfString:@"®" withString:@""];
}

- (NSString *)stripHTML
{
    NSRange stringRange;
    NSString *newString = [self copy];
    while ((stringRange = [newString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        newString = [newString stringByReplacingCharactersInRange:stringRange withString:@""];
    return newString;
}

- (BOOL)hasSubstring:(NSString *)aString
{
    return ([self rangeOfString:aString].location != NSNotFound);
}

- (NSString *)urlEncode
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"-.!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}

- (NSString *)prettyPrintPhoneNumber
{
    // first strip out any prior formatting characters
    NSString *prettyString = self.stripDecorationsOfPhoneNumber;

    // This is a very simple phone number formatter to serve our immediate needs during the crunch of December 2013
    // When there is time to relax and a need to properly support all international numbers, mobile variants, etc.,
    // this helper method would be extended as needed
    //
    // Accepts any character, not just digits
    // Very simple formatting rules. Given most numbers entered will be 10 digit North American numbers, we are formatting:
    // 10 digit numbers as: (212) 555-1212
    // 7 digit numbers as: 555-1212
    // Longer international numbers as 449 123 123 1234
    // Anything shorter than 7, and 8 or 9 digits *as is*

    switch (prettyString.length)
    {
        case 10:        // Properly formatted 10 digit North American number (xxx) xxx-xxxx
        {   prettyString = 
            [NSString stringWithFormat:@"(%@) %@-%@",
             [prettyString substringWithRange:NSMakeRange(0, 3)],
             [prettyString substringWithRange:NSMakeRange(3, 3)],
             [prettyString substringWithRange:NSMakeRange(6, 4)]];
        }   break;
            
        case 7:        // Properly formatted 7 digit (North American?) number xxx-xxxx
        {   prettyString = 
            [NSString stringWithFormat:@"%@-%@",
             [prettyString substringWithRange:NSMakeRange(0, 3)],
             [prettyString substringWithRange:NSMakeRange(3, 4)]];
        }    break;
            
        default:
        { 
            if (prettyString.length > 10)     // Possibly an international number xxxxxxxxx? xxx xxx xxxx
            {
                prettyString = 
                [NSString stringWithFormat:@"%@ %@ %@ %@",
                 [prettyString substringWithRange:NSMakeRange(0, prettyString.length-10)],
                 [prettyString substringWithRange:NSMakeRange(prettyString.length-10, 3)],
                 [prettyString substringWithRange:NSMakeRange(prettyString.length-7,  3)],
                 [prettyString substringWithRange:NSMakeRange(prettyString.length-4,  4)]];
            }
        }    break;
    }
    
    return prettyString;
}

- (NSString *)stripDecorationsOfPhoneNumber
{
    NSRegularExpression *matchNonDigits = [NSRegularExpression
                                           regularExpressionWithPattern:@"[^+?\\d+0-9A-Za-z]"
                                           options:0
                                           error:nil];
     
    return [matchNonDigits stringByReplacingMatchesInString:self
                                                    options:0
                                                      range:NSMakeRange(0, self.length)
                                               withTemplate:@""];
}

- (NSComparisonResult)compare:(NSString*)aString usingArbitraryOrdering:(NSDictionary*)ordering
{
    NSNumber* value0 = (NSNumber*)ordering[[self lowercaseString]];
    NSNumber* value1 = (NSNumber*)ordering[[aString lowercaseString]];
    int result = [value0 intValue] - [value1 intValue];
    if (result < 0)
    {
        return NSOrderedAscending;
    }
    else if (result > 0)
    {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (NSString*)formatPriceString
{
    NSString* result = nil;
    if (self.length > 0)
    {
        double priceValue = [self doubleValue];
        if (priceValue > 0)
        {
            result = [NSString stringWithFormat:@"$%.2f", priceValue];
        }
    }
    
    return result;
}

- (NSString *)lowercaseFirstLetter
{
    if (self.length == 0)
    {
        return self;
    }
    
    NSString *first = [[self substringToIndex:1] lowercaseString];
    return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                         withString:first];
}

- (NSString *)uppercaseFirstLetter
{
    if (self.length == 0)
    {
        return self;
    }
    
    NSString *first = [[self substringToIndex:1] uppercaseString];
    return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                         withString:first];
}

- (NSString *)stringByRemovingSubstrings:(NSArray *)substrings
{
    NSString *string = self;
    Require(substrings ?: @[], NSArray);
    for ( NSString *subStr in substrings) //Remove characters in this array
    {
        string = [string stringByReplacingOccurrencesOfString:subStr withString:@""];
    }
    
    return string;
}

- (NSString*)stringByDeletingTextBetweenBraces
{
    NSMutableString* newString = [NSMutableString stringWithString:self];
    while (YES)
    {
        NSRange leadingBrace = [newString rangeOfString:@"{"];
        NSRange trailingBrace = [newString rangeOfString:@"}"];
        
        if (!leadingBrace.length || !trailingBrace.length) {
            break;
        }
        
        NSRange fullPlaceholder = NSMakeRange(leadingBrace.location, trailingBrace.length -
                                              leadingBrace.location + trailingBrace.location);
        [newString deleteCharactersInRange:fullPlaceholder];
    }
    return [NSString stringWithString:newString];
}

#pragma mark -

NSComparisonResult CompareVersionStrings(NSString *versionA, NSString *versionB)
{
    NSString *versionComponentSeparator = @".";
    NSArray *componentsOfVersionA = [versionA componentsSeparatedByString:versionComponentSeparator];
    NSArray *componentsOfVersionB = [versionB componentsSeparatedByString:versionComponentSeparator];
    
    NSInteger precisionOfVersionA = componentsOfVersionA.count;
    NSInteger precisionOfVersionB = componentsOfVersionB.count;
    NSInteger maxPrecision = MAX(precisionOfVersionA, precisionOfVersionB);
    
    // Prior to comparing the components of each array, make the count of each array the same by padding the shorter one with "0"s
    // to allow comparison of all levels of precision without raising an out of bounds exception.
    
    for (NSInteger i = precisionOfVersionA; i < maxPrecision; i++)
    {
        componentsOfVersionA = [componentsOfVersionA arrayByAddingObject:@"0"];
    }
    
    for (NSInteger i = precisionOfVersionB; i < maxPrecision; i++)
    {
        componentsOfVersionB = [componentsOfVersionB arrayByAddingObject:@"0"];
    }
    
    NSComparisonResult comparisonResult = NSOrderedSame;
    for (NSInteger i = 0; i < maxPrecision; i++)
    {
        NSInteger integerA = [componentsOfVersionA[i] integerValue];
        NSInteger integerB = [componentsOfVersionB[i] integerValue];
        
        if (integerA < integerB)
        {
            comparisonResult = NSOrderedAscending;
            break;
        }
        if (integerA > integerB)
        {
            comparisonResult = NSOrderedDescending;
            break;
        }
    }
    return comparisonResult;
}

- (BOOL)isGreaterThanOrEqualToVersion:(NSString*)version
{
    NSComparisonResult result = CompareVersionStrings(self, version);
    return (result == NSOrderedDescending) || (result == NSOrderedSame);
}

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end
{
    NSScanner* scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL])
    {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result])
        {
            return result;
        }
    }
    return nil;
}

-(NSString *)stringWithoutHtmlCharacters
{
    NSRange range;
    NSMutableString * cleanString = [NSMutableString stringWithString:self];
    
    while ((range = [cleanString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        [cleanString setString:[[cleanString stringByReplacingCharactersInRange:range withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    return [NSString stringWithString:cleanString];
}

@end
