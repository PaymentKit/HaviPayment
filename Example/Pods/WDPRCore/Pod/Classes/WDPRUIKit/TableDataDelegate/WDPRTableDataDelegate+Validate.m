//
//  WDPRTableDataDelegate+DataValidate.m
//  WDPR
//
//  Created by Hutchinson, Jack X. -ND on 9/9/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

@implementation WDPRTableDataDelegate (Validate)

#define kKeyFocusedIndexPath @"focusedIndexPath"
#define kKeyFocusedTextField @"focusedTextField"

#define VALIDATE_REGEX_PREDICATE_CONDITION @"SELF MATCHES %@"

__weak id<WDPRRealTimeEnablementDelegate> enablementDelegate;

NSMutableDictionary *fieldToControlMap, *controlToFieldMap, *controlState;

#pragma mark Real Time Validation
// Enabled real time validation of fields
- (void)setRealTimeEnablementDelegate:(id<WDPRRealTimeEnablementDelegate>)delegate
{
    enablementDelegate = delegate;
    
    controlState = [NSMutableDictionary new];
    controlToFieldMap = [NSMutableDictionary new];
    fieldToControlMap = [NSMutableDictionary new];
    
    [self enumerateObjectsUsingBlock:
     ^(NSDictionary* item, NSIndexPath* indexPath, BOOL* stop) 
    {
        NSArray *dependencies = item[WDPRCellValidateRealTimeDependencies];
        
         if (dependencies.count) 
         {
             controlState[indexPath] = @(YES);

             controlToFieldMap[item[WDPRCellRowID]] = dependencies;
             
             [self enumerateObjectsUsingBlock:
              ^(NSDictionary* dependency, NSIndexPath* indexPath, BOOL* stop)
              {
                 if ([dependencies containsObject:dependency[WDPRCellRowID]])
                 {
                     fieldToControlMap[dependency[WDPRCellRowID]] = item[WDPRCellRowID];
                 }
             }];
         }
     }];
    
    MAKE_WEAK(self);
    [self addObserver:self keyPath:kKeyFocusedIndexPath 
              options:(NSKeyValueObservingOptionOld | 
                       NSKeyValueObservingOptionNew) block:
     ^(id object, NSString *keyPath, NSDictionary *change) 
     {
         MAKE_STRONG(self);
         
         // Focus changed
         [strongself enumerateObjectsUsingBlock:
          ^(NSDictionary* item, NSIndexPath* indexPath, BOOL *stop) 
          {
              if (item[WDPRCellValidateRealTimeDependencies])
              {
                  [strongself updateControlState:indexPath];
              }
          }];
     }];
    
    [self addObserver:self keyPath:kKeyFocusedTextField 
              options:(NSKeyValueObservingOptionOld | 
                       NSKeyValueObservingOptionNew) block:
     ^(id object, NSString *keyPath, NSDictionary *change) 
     {
         MAKE_STRONG(self);
         
         // Focused text field changed
         [strongself.focusedTextField addTarget:strongself 
                                         action:@selector(focusedTextFieldTextChanged) 
                               forControlEvents:UIControlEventEditingChanged];
     }];
    
    [self updateControlState];
}

- (void)focusedTextFieldTextChanged 
{
    NSDictionary *field = [self itemAtIndexPath:self.focusedIndexPath];
    id controlId = [fieldToControlMap objectForKey:field[WDPRCellRowID]];
    
    if (controlId) 
    {
        [self enumerateObjectsUsingBlock:
         ^(NSDictionary* item, NSIndexPath* indexPath, BOOL* stop) 
        {
            if ([item[WDPRCellRowID] isEqual:controlId])
            {
                [self updateControlState:indexPath];
            }
        }];
    }
}

- (void)updateControlState:(NSIndexPath*)controlIndexPath 
{
    __block BOOL passedValidation = YES;
    NSDictionary *controlItem = [self itemAtIndexPath:controlIndexPath];
    NSArray *dependencies = [controlToFieldMap objectForKey:controlItem[WDPRCellRowID]];
    
    [self enumerateObjectsUsingBlock:
     ^(NSDictionary* item, NSIndexPath* indexPath, BOOL* stop) 
    {
        id itemRowId = item[WDPRCellRowID];
        if ([dependencies containsObject:itemRowId]) 
        {
            NSString* valueToTest;
            if (item[WDPRCellPlaceholder] &&
                [self.focusedIndexPath isEqual:indexPath]) 
            {
                valueToTest = self.focusedTextField.text;
            } 
            
            passedValidation = (passedValidation && 
                                [self isItemValid:item 
                                         forValue:valueToTest]);
        }
    }];
    
    [enablementDelegate controlStateChanged:passedValidation 
                                atIndexPath:controlIndexPath];
    [controlState setObject:@(passedValidation) forKey:controlIndexPath];
}

- (void)updateControlState 
{
    for (NSIndexPath *controlPath in [controlState allKeys]) 
    {
        [self updateControlState:controlPath];
    }
}

- (BOOL)isControlEnabled:(NSIndexPath*)path 
{
    if ([controlState objectForKey:path]) 
    {
        return [[controlState objectForKey:path] boolValue];
    }
    
    return YES;
}

#pragma mark - Manual Validation

- (BOOL)validateDataEntry
{
    // commit any edit in progress, and stop the edit session
    self.focusedIndexPath = nil;
    
    NSMutableArray* errors = [NSMutableArray new];
    NSString* errorTitle = [self updateCells:YES errors:errors];
        
    if (errorTitle)
    {
        [UIAlertView showAlertWithTitle:errorTitle
                                message:[errors 
                                         componentsJoinedByString:@"\n"]
              cancelButtonTitleAndBlock:nil 
             otherButtonTitlesAndBlocks:@[@[WDPRLocalizedStringInBundle(@"com.wdprcore.alerttabledatadelegate.ok", WDPRCoreResourceBundleName, nil)]]];

        return NO;
    }

    return YES;
}

- (void)updateCurrentValidationStatus
{
    self.invalidItems = [NSSet new];
    
    [self enumerateObjectsUsingBlock:
     ^(id item, NSIndexPath *idx, BOOL *stop)
     {
         if (![self isItemValid:item])
         {
             [self addToInvalidItems:idx];
         }
     }];
}

- (void)resetValidationErrors
{
    self.invalidItems = [NSSet new];
    [self updateCells:NO errors:nil];
}

- (NSString*)updateCells:(BOOL)checkValidity 
                  errors:(NSMutableArray*)errors
{
    // reset title formatting
    __block BOOL invalidInfo = NO;
    __block BOOL missingInfo = NO;
    __block NSString *errorTitle;
    __block NSMutableArray *rowsToReload;
    __block NSMutableArray *itemsToReplace;

    [self enumerateObjectsUsingBlock:
     ^(WDPRTableViewItem * item, NSIndexPath* indexPath, BOOL* stop)
     {
         if (item.isMultiValueTableItem) 
         {
             BOOL isValid = (!checkValidity || [self isItemValid:item]);

             if (isValid == [item[WDPRCellErrorState] boolValue]) // opposite semantics
             {
                 if ([item isKindOfClass:NSMutableDictionary.class] || 
                     [item conformsToProtocol:@protocol(WDPRTableViewItem)])
                 {
                     item[WDPRCellErrorState] = @(!isValid);
                     
                     if (![rowsToReload containsObject:indexPath])
                     {
                         [(rowsToReload = rowsToReload ?: 
                           [NSMutableArray new]) addObject:indexPath];
                     }
                 }
                 else
                 {
                     NSMutableDictionary *replacementItem = [item mutableCopy];
                     
                     replacementItem[WDPRCellErrorState] = @(!isValid);
                     if (![item isEqual:replacementItem]) 
                     {
                         itemsToReplace = itemsToReplace ?: [NSMutableArray new];
                         [itemsToReplace addObject:@[item, replacementItem]];
                     }
                 }
             }
             
             if (checkValidity && !isValid)
             {
                 invalidInfo = YES;
                 BOOL hasDetail =
                 [item[WDPRCellDetail] isA:[NSDate class]] ?
                 YES : [item[WDPRCellDetail] length];
                 
                 missingInfo |= (!hasDetail &&
                                ([item[WDPRCellTitle] hasSuffix:@"*"] ||
                                [item[WDPRCellPlaceholder] hasSuffix:@"*"]));
                 
                 NSString *itemTitle = item[WDPRCellValidateErrorTitle];
                 NSString *itemMessage = item[WDPRCellValidateErrorMessage];
                 
                 if (itemMessage.length && 
                     ![errors containsObject:itemMessage])
                 {
                     [errors addObject:itemMessage];
                 }
                 
                 if (itemTitle.length)
                 {
                     errorTitle = (!errorTitle ? itemTitle :
                                   WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.errortitle.invalidtitle", WDPRCoreResourceBundleName, nil));
                 }
             }
         }
     }];
    
    if (missingInfo) 
    {
        errorTitle = (!errorTitle ? 
                      WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.errortitle.missingtitle", WDPRCoreResourceBundleName, nil) :
                      WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.errortitle.missingorinvalidtitle", WDPRCoreResourceBundleName, nil));
        
        [errors insertObject:
         WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.error.fillfields", WDPRCoreResourceBundleName, nil) atIndex:0];
    }
    else if (invalidInfo && !errorTitle)
    {
        errorTitle = (errors.count ?
                      WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.errortitle.sorry", WDPRCoreResourceBundleName, nil) :
                      WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.errortitle.missinginformation", WDPRCoreResourceBundleName, nil));

        [errors addObject: WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.error.invalidinformation", WDPRCoreResourceBundleName, nil)];
    }

    for (NSArray *replacements in itemsToReplace) 
    {
        [self replaceItem:replacements[0] with:replacements[1]];
    }
    
    if (rowsToReload)
    {
        executeOnNextRunLoop(^{
            // give the responder time to resign
            [self.tableView reloadRowsAtIndexPaths:rowsToReload
                                  withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    
    return errorTitle;
}

- (void)highlightRows:(NSArray *)cellRowIds 
{
    NSDictionary *indexPaths = [self indexPathsForRowIDs:cellRowIds];
    
    [indexPaths enumerateKeysAndObjectsUsingBlock:
     ^(id rowID, NSIndexPath* indexPath, BOOL *stop) 
     {
         [self itemAtIndexPath:indexPath][WDPRCellErrorState] = @YES;
     }];
    
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths.allValues 
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)highlightRow:(id)cellRowId
        errorMessage:(NSString *)errorMessage
{
    NSIndexPath *indexPath = [self indexPathForRowID:cellRowId];
    id item = [self itemAtIndexPath:indexPath];
    
    __block NSString *prevErroMessge = item[WDPRCellValidateErrorMessage];
    __block WDPRCellValueChangedBlockType prevChangeBlock = item[WDPRCellValueChangedBlock];
    
    item[WDPRCellErrorState] = @YES;
    item[WDPRCellValidateErrorMessage] = errorMessage;
    item[WDPRCellValueChangedBlock] = ^(NSDictionary* changeItem)
    {
        changeItem[WDPRCellValidateErrorMessage] = prevErroMessge;
        changeItem[WDPRCellValueChangedBlock] = prevChangeBlock;
    };
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -

- (BOOL)isItemValid:(id)item
{
    return [self isItemValid:item forValue:nil];
}

- (BOOL)isItemValid:(id)item forValue:(NSString *)overrideValue
{
    BOOL itemIsValid = YES;

    // If this isn't an edit cell, ignore
    if (item[WDPRCellPlaceholder] || item[WDPRCellOptions])
    {
        // Check if there's a regex validation string specified for this field.
        NSString *regexString = item[WDPRCellValidateRegex];
        NSString *value = overrideValue ?: [item[WDPRCellDetail]
                                            formattedDescription];
        NSString *valueConversion = item[WDPRCellValidationConversion];
        
        if ( valueConversion.length )
        {
            if ([value respondsToSelector:
                 NSSelectorFromString(valueConversion)]) 
            {
                value = [value valueForKey:valueConversion];
            }
        }
        
        // if there's a value, and if that value is a string, it has length
        if (value && (![value isKindOfClass:NSString.class] || value.length))
        {
            if (!regexString)
            {
                itemIsValid = ![item[WDPRCellErrorState] boolValue];
            }
            else
            {
                itemIsValid = (!regexString.length ||
                               [[NSPredicate predicateWithFormat:
                                 VALIDATE_REGEX_PREDICATE_CONDITION,
                                 regexString] evaluateWithObject:value]);
            }
        }
        else
        {    // Check if the field is required.
            NSString *title = item[WDPRCellTitle];
            NSString *placeholder = item[WDPRCellPlaceholder];
            
            if ([title isKindOfClass:NSAttributedString.class])
            {
                title = ((NSAttributedString *)title).string;
            }
            
            if ([placeholder isKindOfClass:NSAttributedString.class])
            {
                placeholder = ((NSAttributedString *)placeholder).string;
            }
            
            itemIsValid = (![title hasSuffix:@"*"] && ![placeholder hasSuffix:@"*"]);
        }
    }
    
    NSIndexPath *indexPath = (item[WDPRCellRowID] ?
                              [self indexPathForRowID:item[WDPRCellRowID]] : nil);

    // configurable validation requirements
    if (item[WDPRCellValidateBlock] && ![self.focusedIndexPath isEqual:indexPath])
    {
        // we must not throw away the validation already performed
        // i.e. both tests must pass
        WDPRCellValidationBlockType validateBlock = item[WDPRCellValidateBlock];
        BOOL validateBlockResult = validateBlock(item);
        itemIsValid = itemIsValid && validateBlockResult;
    }

    return itemIsValid;
}

+ (NSString*)validateRegexUpToNumChars:(NSInteger)numOfChars
{
    return [NSString stringWithFormat:@"^.{1,%lu}$", (long)numOfChars];
}

@end
