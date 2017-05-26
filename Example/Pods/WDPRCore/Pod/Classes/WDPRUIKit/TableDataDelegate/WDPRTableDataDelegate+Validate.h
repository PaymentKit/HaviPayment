//
//  WDPRTableDataDelegate+DataValidate.h
//  WDPR
//
//  Created by Hutchinson, Jack X. -ND on 9/9/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRTableDataDelegate.h"

static NSString *const VALIDATE_REGEX_EMAIL = @"^(?!\\.)(?!.{201})([A-Z0-9a-z\\._%+-]{1,64}(?<!\\.)@([A-Za-z0-9-]+\\.)+(?!.*(@))[A-Za-z]+)$";

#define VALIDATE_REGEX_PHONE @"\\s?\\(?\\-?\\s?[0-9]{3}\\s?\\W?\\s?[0-9]{3}\\s?\\W?\\s?[0-9]{4}"

static NSString *const VALIDATE_REGEX_PASSWORD = @"^.{6,25}$";

static NSString *const VALIDATE_REGEX_NAME = @"^([A-Za-z- ']){2,28}$";

static NSString *const VALIDATE_REGEX_ALLOWED_NAME_CHARACTERS = @"^([A-Za-z- '])*$";

static NSString *const VALIDATE_REGEX_ALLOWED_NAME_LENGTH = @"^.{2,28}$";

static NSString *const VALIDATE_REGEX_NON_EMPTY = @"^.+$";

#define VALIDATE_REGEX_UP_TO_25CHARS @"^.{1,25}$"

static NSString *const VALIDATE_REGEX_SECURITY_ANSWER = @"^[a-zA-Z0-9_ ]{2,100}$";

static NSString *const VALIDATE_REGEX_NO_JAVASCRIPT_NAME = @"^(/w|/W|[^<>+?$%{}().&])+$";

#define VALIDATE_REGEX_POSTAL_CODE @"^[a-zA-Z0-9 ]{1,10}$"

//TODO: find a more reliable way of validating zip code
//this one just serves for US and Canada
#define VALIDATE_REGEX_ZIP_CODE @"^(\\d{5}(-\\d{4})?|[a-z]\\d[a-z][- ]*\\d[a-z]\\d)$"

//#define VALIDATE_REGEX_INTERNATIONAL_PROVINCE @"[a-zA-Z]{2,3}"
/*
Canadian postal code format verification. The format of a Canadian postal code is LDL DLD where L are alpha characters and D are numeric digits.
But there are some exceptions. The letters D, F, I, O, Q and U never appear in a postal code because of their visual similarity to 0, E, 1, 0, 0, and V respectively.
In addition to avoiding the six "forbidden" letters W and Z also do not appear as the first letter of a postal code (at least not at present).
 */
#define VALIDATE_REGEX_CANADIAN_POSTAL_CODE @"^([abceghjklmnprstvxyABCEGHJKLMNPRSTVXY]\\d[abceghjklmnprstvwxyzABCEGHJKLMNPRSTVWXYZ])\\ {0,1}(\\d[abceghjklmnprstvwxyzABCEGHJKLMNPRSTVWXYZ]\\d)$"

static NSString *const VALIDATE_REGEX_UK_POSTAL_CODE = @"((([a-z-[qvx]A-Z-[QVX]][0-9][0-9]?)|(([a-z-[qvx]A-Z-[QVX]][a-z-[ijz]A-Z-[IJZ]][0-9][0-9]?)|(([a-z-[qvx]A-Z-[QVX]][0-9][a-hjkstuwA-HJKSTUW])|([a-z-[qvx]A-Z-[QVX]][a-z-[ijz]A-Z-[IJZ]][0-9][abehmnprvwxyABEHMNPRVWXY])))) [0-9][a-z-[cikmov]A-Z-[CIKMOV]]{2})";

static NSString *const VALIDATE_REGEX_PHONE2 = @"[0-9]{10,20}";

// Found on http://www.regular-expressions.info/creditcard.html
#define VALIDATE_REGEX_VISA_CC_FORMAT @"^4[0-9]{12}(?:[0-9]{3})?$"
#define VALIDATE_REGEX_MASTERCARD_CC_FORMAT @"^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$"
#define VALIDATE_REGEX_AMEX_CC_FORMAT @"^3[47][0-9]{13}$"
#define VALIDATE_REGEX_DINERS_CLUB_CC_FORMAT @"^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
#define VALIDATE_REGEX_DISCOVER_CLUB_CC_FORMAT @"^6(?:011|5[0-9]{2})[0-9]{12}$"
#define VALIDATE_REGEX_JCB_CLUB_CC_FORMAT @"^(?:2131|1800|35\\d{3})\\d{11}$"
// Combination of all the available CC format regexs
#define VALIDATE_REGEX_ACCEPTED_CC_FORMATS @"^4[0-9]{12}(?:[0-9]{3})?|(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|6(?:011|5[0-9]{2})[0-9]{12}|(?:2131|1800|35\\d{3})\\d{11}$"
// Regex for Disney Visa Cards
#define VALIDATE_REGEX_DISNEY_VISA_CC_FORMAT @"^(?:434769|426690)[0-9]{7}(?:[0-9]{3})?$"

#define VALIDATE_REGEX_CVV @"[0-9]{3}"
#define VALIDATE_REGEX_CVV_AMEX @"[0-9]{4}"
#define VALIDATE_REGEX_CVV_UNKNOWN @"[0-9]{3,4}"

#define VALIDATE_REGEX_ADDRESS @"^[a-zA-Z0-9\\.,#%&~<>\\-\\(\\)\\ ]+$"

#define VALIDATE_REGEX_LETTERS_ONLY @"^[a-zA-Z ]+$"

@protocol WDPRRealTimeEnablementDelegate <NSObject>

- (void)controlStateChanged:(BOOL)isEnabled atIndexPath:(NSIndexPath*)indexPath;

@end

@class WDPRTableDataDelegate;

/// Set if the UITextField will need to be validated.
/// (NSString)
#define WDPRCellValidateRegex @"validationRegex"

// Set if the cell has a validation condition that
// extends beyond regular expression 
// (WDPRCellValidationBlockType)
#define WDPRCellValidateBlock @"validationBlock"
typedef BOOL (^WDPRCellValidationBlockType)(NSDictionary *item);

/// Set to an NSString's method if the UITextField will
// need to be converted before validated. Then implement
// that method in a category of NSString. It will be
// called by perform selector
/// (NSString)
#define WDPRCellValidationConversion @"validationConversion"

/// Set if the UITextField will need to be validated.
/// This field will become the error message that pops up.
/// (NSString)
#define WDPRCellValidateErrorMessage @"validationErrorMessage"

/// Set if the UITextField will need to be validated.
/// This field will become the error title that pops up.
/// (NSString)
#define WDPRCellValidateErrorTitle @"validationErrorTitle"

/// YES if the UITextField will avoid adding extra input characters
/// when the item is not valid.
/// (BOOL as NSNumber)
#define WDPRCellValidateAvoidExtraTextInput @"validationAvoidExtraTextInput"

/// Set this if you want a component to be validated in real time
/// (NSArray of dependent rows)
#define WDPRCellValidateRealTimeDependencies @"validationRealTimeDependencies"

/// Set if the UITextField will need to be show an inline error message when empty.
/// This field will become the error message that pops up.
/// (NSString)
#define WDPRCellEmptyErrorMessage @"emptyErrorMessage"

@interface WDPRTableDataDelegate (Validate)

/// does the specified item meet it's validation criteria
- (BOOL)isItemValid:(id)item;

/// does the specified item meet it's validation 
/// criteria for the specified overrideValue
- (BOOL)isItemValid:(id)item 
           forValue:(NSString *)overrideValue;

/// Method to perform validation on data entry cells. 
/// Each individual cell has its own validation criteria. 
/// All cells with a title that ends with '*' are considered 
/// required and are checked for emptiness. Returns YES
/// if all items pass validation requirements, NO otherwise.
- (BOOL) validateDataEntry;

/// Update the status of the invalidItems set. Useful when required fields
/// change based on the selection of one specific field.
- (void)updateCurrentValidationStatus;

/// Method to reset the formatting of all cell's title field.
- (void) resetValidationErrors;

/// Given an array of row IDs, highlights those cells in red
- (void)highlightRows:(NSArray *)cellRowIds;

/// Highlight the specified cell, with the given error message.
- (void)highlightRow:(id)cellRowId
        errorMessage:(NSString *)errorMessage;

/// Enables real-time validation of fields.
- (void)setRealTimeEnablementDelegate:(id<WDPRRealTimeEnablementDelegate>)delegate;

/// Returns a regex string to validate number of characters
+ (NSString*)validateRegexUpToNumChars:(NSInteger)numOfChars;

@end
