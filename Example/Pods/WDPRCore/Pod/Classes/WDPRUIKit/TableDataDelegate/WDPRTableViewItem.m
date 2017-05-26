//
//  WDPRTableViewItem.m
//  DLR
//
//  Created by Rodden, James on 12/16/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@interface WDPRTableDynamicItem ()

@property (nonatomic) NSMutableDictionary* data;

@end // @interface WDPRTableDynamicItem ()

@implementation WDPRTableDynamicItem

- (NSString*)description
{
    return self.data.description;
}

- (id)objectForKeyedSubscript:(NSString*)key
{
    id object = (![self respondsToSelector:
                   NSSelectorFromString(key)] ? 
                 self.data[key] : [self valueForKey:key]);

    return ((![key isEqualToString:WDPRCellValueChangedBlock] &&
             ![key isEqualToString:WDPRCellConfigurationBlock] &&
             ![key isEqualToString:WDPRCellValidateBlock] &&
             ![key isEqualToString:WDPRCellKeyboardButtonTapped] &&
             ![key isEqualToString:WDPRPickerLostFocusBlock] &&
             [object isKindOfClass:NSClassFromString(@"NSBlock")]) ? 
            ((WDPRTableDynamicItemProperty)object)(self) : object);
}

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key
{
    self.data[key] = value;
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString*)key
{
    [self setValue:obj forKey:key];
}

+ (instancetype)tableDynamicItemWithData:(NSDictionary*)data
{
    WDPRTableDynamicItem * item = [self new];
    
    item.data = data.mutableCopy;
    
    return item;
}

@end // @implementation WDPRTableDynamicItem

#pragma mark -

@interface WDPRTableMultipleItems ()

@property (nonatomic) NSArray* items;

@end // @interface WDPRTableMultipleItems ()

@implementation WDPRTableMultipleItems

- (Class)cellType
{
    return WDPRTableViewCell.class;
}

- (NSUInteger)numItems
{
    return self.items.count;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return self.items[index];
}

- (id)objectForKeyedSubscript:(NSString*)key
{
    // self is proxy for 0th item
    return self.items[0][key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString*)key
{
    // self is proxy for 0th item
    self.items[0][key] = obj;
}

+ (instancetype)tableItemWithMultipleItems:(NSArray*)items
{
    WDPRTableMultipleItems * item = [self new];
    items = [NSMutableArray arrayWithArray:items];
    
    for (NSUInteger ii = 0; ii < items.count; ii++)
    {
        // convert dictionaries into dynamic items
        if ([items[ii] isKindOfClass:NSDictionary.class])
        {
            ((NSMutableArray*)items)[ii] = 
            [WDPRTableViewItem tableDynamicItemWithData:items[ii]];
        }
    }
    
    item.items = items.copy; // remove mutability
    
    return item;
}

@end // @implementation WDPRTableMultipleItems

#pragma mark -

@implementation WDPRTableDisclosureItem

@end // @implementation WDPRTableDisclosureItem

#pragma mark -

@implementation WDPRTableViewItem

+ (NSArray*)tableDisclosureItems:(NSDictionary*)data 
{
    enum
    {
        kImageSize = 10,
        kSeparator = 10,
    };
    CGRect imageBounds = CGRectMake(0, 0, kImageSize, kImageSize);
    
    WDPRTableDynamicItem * child =
    [WDPRTableDynamicItem tableDynamicItemWithData:data];
    
    WDPRTableDisclosureItem* parent = 
    [WDPRTableDisclosureItem tableDynamicItemWithData:data];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    child[WDPRCellTitle] = nil;
    parent[WDPRCellDetail] = nil;
#pragma clang diagnostic pop
    MAKE_WEAK(parent);
    
    child[WDPRCellRowHeight] = ^(id item)
    { 
        MAKE_STRONG(parent);
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        NSAttributedString *childTitle = ([item[WDPRCellDetail] isA:[NSAttributedString class]] ?
                                          item[WDPRCellDetail] :
                                          [NSAttributedString string:item[WDPRCellDetail]
                                                          attributes:[WDPRTheme textAttributes:
                                                                      WDPRTextStyleC1D]]);
        CGFloat childHeight = [childTitle heightWithBoundingWidth:
                               (screenWidth - kImageSize - 2 * kHorizontalInset)] + kSeparator;
        
        return (strongparent.expanded ? @(childHeight) : @(0));
    };
    
    parent[WDPRCellRowHeight] = ^(id item)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        NSAttributedString *title = ([item[WDPRCellTitle] isA:[NSAttributedString class]] ?
                                     item[WDPRCellTitle] :
                                     [NSAttributedString string:item[WDPRCellTitle]
                                                     attributes:[WDPRTheme textAttributes:
                                                                 WDPRTextStyleC1B]]);
        return @([title heightWithBoundingWidth:
                  (screenWidth - kImageSize - 2 * kHorizontalInset)] + kSeparator);
    };
    
    parent[WDPRCellIcon] = ^(id item)
    {
        MAKE_STRONG(parent);
        return [WDPRIcon imageOfIcon:
                (strongparent.expanded ? 
                 WDPRIconUpTriangle :
                 WDPRIconDownTriangle)
                           withColor:UIColor.wdprBlueColor 
                             andSize:CGSizeMake(8, 8)];
    };
    
    parent[WDPRCellConfigurationBlock] = ^(UITableViewCell* cell)
    {
        cell.accessibilityTraits = UIAccessibilityTraitButton;
        
        if (child[WDPRCellConfigurationBlock])
        {
            ((WDPRCellConfigurationBlockType)
             child[WDPRCellConfigurationBlock])(cell);
        }
    };
    
    child[WDPRCellStyle] = @(WDPRTableCellStyleSubtitleRightOfImage);
    parent[WDPRCellStyle] = @(WDPRTableCellStyleSubtitleRightOfImage);
    
    child[WDPRCellIconSize] = [NSValue valueWithCGSize:imageBounds.size];
    parent[WDPRCellIconSize] = [NSValue valueWithCGSize:imageBounds.size];
    
    child[WDPRCellSelectionStyle] = @(WDPRTableViewCellSelectionStyleNone);
    parent[WDPRCellSelectionStyle] = @(WDPRTableViewCellSelectionStyleLogicalOnly);
    
    child[WDPRCellIcon] = [[UIView alloc] initWithFrame:imageBounds].imageOfSelf;
    
    return @[parent, child];
}

+ (id)tableDynamicItemWithData:(NSDictionary*)data
{
    return [WDPRTableDynamicItem tableDynamicItemWithData:data];
}

+ (id)tableItemWithMultipleItems:(NSArray*)items
{
    return [WDPRTableMultipleItems tableItemWithMultipleItems:items];
}

+ (id)tableSeparatorItemWithHeight:(NSUInteger)height
{
    return [WDPRTableSeparator tableSeparatorItemWithHeight:height];
}

+ (id)emptyCellItemWithHeight:(CGFloat)height
                showSeparator:(BOOL)showSeparator
{
    NSDictionary *data = @{
                           WDPRCellRowHeight:@(height),
                           WDPRCellSelectionStyle:@(UITableViewCellSelectionStyleNone),
                           WDPRCellConfigurationBlock:^(WDPRTableViewCell *cell)
                           {
                               cell.accessibilityElementsHidden = YES;
                               if (!showSeparator)
                               {
                                   cell.layer.borderWidth = 2;
                                   cell.layer.borderColor = [[UIColor whiteColor] CGColor];
                               }
                           }
                           };
    
    return [WDPRTableViewItem tableDynamicItemWithData:data];
}

- (NSString*)errorMessage
{
    WDPRTableViewItem *item = self;
    NSString *prompt;
    if ([item[WDPRCellEmptyErrorMessage] length] && ![item[WDPRCellDetail] length])
    {
        prompt = item[WDPRCellEmptyErrorMessage];
    }
    else if ([item[WDPRCellValidateErrorMessage] length]) // specific error
    {
        prompt = item[WDPRCellValidateErrorMessage];
    }
    else // empty (required) field, or specific error message
    {
        prompt = [item[WDPRCellPlaceholder] lowercaseString];
        
        if ([prompt hasSuffix:@"*"])
        {
            prompt = [prompt substringToIndex:prompt.length-1];
        }
        
        prompt = [NSString stringWithFormat:
                  NSLocalizedString(@"Please enter a valid %@.", ), prompt];
    }
    return prompt;
}

@end // @implementation WDPRTableViewItem
