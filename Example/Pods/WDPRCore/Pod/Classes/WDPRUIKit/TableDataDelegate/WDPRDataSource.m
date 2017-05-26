//
//  WDPRTableViewDataSource.m
//  Pods
//
//  Created by J.Rodden on 8/29/15.
//
//

#import "WDPRUIKit.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define WDPRAccessibilityDropdownIndexWhenRequired 2
#define WDPRAccessibilityDropdownIndexWhenNotRequired 1

static void logWarning(NSIndexPath* indexPath, NSString* message)
{
    [WDPRLog logWarning:[NSString stringWithFormat:
                         [@"[item at (%d,%d)]: "
                          stringByAppendingString:message],
                         indexPath.section, indexPath.row]];
}

#pragma mark -

@protocol WDPRCellProxy <NSObject>

@property (nonatomic, readonly) UILabel *primaryTextLabel;
@property (nonatomic, readonly) UILabel *secondaryTextLabel;

@end // @protocol WDPRCellProxy

@interface UITableViewCell () <WDPRCellProxy>
@end // @interface UITableViewCell () <WDPRCellProxy>

#pragma mark -

@interface WDPRTableEmbeddedItem : NSObject<WDPRCellProxy>

@property (nonatomic, retain) UILabel     *primaryTextLabel;
@property (nonatomic, retain) UILabel     *secondaryTextLabel;

@end // @interface WDPRTableEmbeddedItem

@implementation WDPRTableEmbeddedItem
@end // @implementation WDPRTableEmbeddedItem

#pragma mark -

@implementation NSIndexPath (WDPRIndexPath)

@dynamic subItemIndex;

- (NSUInteger)subItemIndex
{
    return 0;
}

- (WDPRIndexPath *)indexPathWithSubItemIndex:(NSUInteger)index
{
    WDPRIndexPath *indexPath =
    [WDPRIndexPath indexPathForRow:self.row
                         inSection:self.section];
    
    indexPath.subItemIndex = index;
    
    return indexPath;
}

@end // @implementation NSIndexPath (WDPRIndexPath)

#pragma mark -

@implementation WDPRIndexPath

- (BOOL)isEqual:(NSIndexPath*)indexPath
{
    if (!self.subItemIndex &&
        !indexPath.subItemIndex)
    {
        return [super isEqual:indexPath];
    }
    else
    {
        return ([super isEqual:indexPath] &&
                [indexPath isKindOfClass:self.class] &&
                (self.subItemIndex == indexPath.subItemIndex));
    }
}

+ (instancetype)indexPath:(NSIndexPath*)indexPath
{
    return ([indexPath isKindOfClass:self] ? 
            (WDPRIndexPath *)indexPath :
            [indexPath indexPathWithSubItemIndex:0]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%ld, %ld, %lu)",
            (long)self.section, (long)self.row, (unsigned long)self.subItemIndex];
}


@end // @implementation WDPRIndexPath

#pragma mark -

@implementation WDPRDataSource

- (id)init
{
    return [self initWithArray:@[]];
}

- (id)initWithPlist:(NSString *)fileName
{
    return [self initWithArray:
            [NSArray arrayFromPList:fileName]];
}

- (id)initWithArray:(NSArray *)array
{
    return [self initWithArray:array
                sectionHeaders:nil
                sectionFooters:nil];
}

- (id)initWithArray:(NSArray *)array
     sectionHeaders:(NSArray *)headers
{
    return [self initWithArray:array 
                sectionHeaders:headers 
                sectionFooters:nil];
}

- (id)initWithArray:(NSArray *)array
     sectionHeaders:(NSArray *)headers
     sectionFooters:(NSArray *)footers
{
    self = [super init];
    
    if (self)
    {
        self.items = array;
        
        _headers = headers ?: _headers;
        _footers = footers ?: _footers;
        
        _cellType = WDPRTableViewCell.class;
        _cellStyle = WDPRTableCellStyleLeftLeftAligned;
        _selectionStyle = UITableViewCellSelectionStyleBlue;
        _accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

#pragma mark - getters and setters

- (void)setCellType:(Class)cellType
{
    NSAssert([cellType isSubclassOfClass:
              UITableViewCell.class], @"invalid input");
    
    _cellType = cellType;
}

- (UITextField*)focusedTextField
{
    return nil;
}

- (NSIndexPath*)focusedIndexPath
{
    return nil;
}

#pragma mark - item access

- (void)setItems:(NSArray *)items
{
    // this is called by initializer, so be careful!!
    
    if ([_items isEqual:items])
    {
        _items = items;
    }
    else
    {
        _items = nil;
        Require(items ?: @[], NSArray);
        NSMutableArray *headers, *footers;
        NSMutableArray *newItems = items.mutableCopy;
        for (NSUInteger ii = 0; ii < newItems.count; ii++)
        {
            id newItem = newItems[ii];
            
            if ([newItem isKindOfClass:NSArray.class])
            {
                newItems[ii] = [[NSMutableArray alloc] 
                                initWithCapacity:[newItem count]];
                
                for (id nestedItem in newItem)
                {
                    [newItems[ii] addObject:
                     (![nestedItem isA:NSDictionary.class] ? nestedItem : 
                      [WDPRTableViewItem tableDynamicItemWithData:nestedItem])];
                }
            }
            else if ([newItem isKindOfClass:NSDictionary.class])
            {
                if (!newItem[WDPRTableSectionItems])
                {
                    newItems[ii] = [WDPRTableViewItem
                                    tableDynamicItemWithData:newItem];
                }
                else 
                {
                    NSArray* sectionItems = newItem[WDPRTableSectionItems];
                    
                    Require(sectionItems, NSArray);
                    newItems[ii] = [[NSMutableArray alloc] 
                                    initWithCapacity:sectionItems.count];
                    
                    for (id nestedItem in sectionItems)
                    {
                        [newItems[ii] addObject:
                         (![nestedItem isA:NSDictionary.class] ? nestedItem : 
                          [WDPRTableViewItem tableDynamicItemWithData:nestedItem])];
                    }
                }
            }
            
            void (^addHeaderOrFooter)(NSMutableArray**, NSString*) = 
            ^(NSMutableArray** array, NSString* tag)
            {
                if (newItem[tag])
                {
                    *array = *array ?: [NSMutableArray new];
                    
                    while ((*array).count < ii) 
                    {
                        [*array addObject:@""];
                    }
                    
                    [*array addObject:newItem[tag]];
                }
            };
            
            addHeaderOrFooter(&headers, WDPRTableSectionHeader);
            addHeaderOrFooter(&footers, WDPRTableSectionFooter);
        }
        
        _items = newItems.copy;
        [self setHeaders:(headers.count ? headers.copy : self.headers)];
        [self setFooters:(footers.count ? footers.copy : self.footers)];
    }
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath)
    {
        return nil;
    }
    
    id item = ([self.items[indexPath.section] isKindOfClass:NSArray.class] ?
               self.items[indexPath.section][indexPath.row] : self.items[indexPath.row]);
    
    if ((indexPath.subItemIndex > 0) && 
        [item isKindOfClass:WDPRTableMultipleItems.class])
    {   
        item = [(WDPRTableMultipleItems *)
                item objectAtIndexedSubscript:indexPath.subItemIndex];
    }
    
    return item;
}

- (NSIndexPath *)indexPathForRowID:(id)rowID
{
    return [self indexPathsForRowIDs:@[rowID]][rowID];
}

- (NSDictionary*)indexPathsForRowIDs:(NSArray*)rowIDArray
{
    NSSet* rowIDs = [NSSet setWithArray:rowIDArray];
    
    NSMutableDictionary *results = 
    [NSMutableDictionary dictionaryWithCapacity:rowIDs.count];
    
    [self enumerateObjectsUsingBlock:
     ^(NSDictionary *item, WDPRIndexPath *indexPath, BOOL *stop)
     {
         if ([rowIDs containsObject:item[WDPRCellRowID]])
         {
             results[item[WDPRCellRowID]] = indexPath;
         }
     }];
    
    return results;
}

- (void)enumerateObjectsUsingBlock:
(void (^)(id item, WDPRIndexPath * idx, BOOL *stop))block
{
    if (block)
    {
        __block BOOL stopEnumerating = NO;
        
        void (^visit)(id, NSIndexPath*, BOOL*) = 
        ^(id obj, NSIndexPath* idx, BOOL *stop)
        {
            if (![obj isKindOfClass:
                  WDPRTableMultipleItems.class])
            {
                block(obj, [idx indexPathWithSubItemIndex:0], stop);
            }
            else for (NSUInteger ii = 0; 
                      !(*stop) && ii < [obj numItems]; ii++)
            {
                block(obj[ii], [idx indexPathWithSubItemIndex:ii], stop);
            }
        };
        
        [self.items enumerateObjectsUsingBlock:
         ^(id obj, NSUInteger idx, BOOL *stop1)
         {
             if (![obj isKindOfClass:NSArray.class])
             {
                 NSIndexPath* indexPath =
                 [NSIndexPath indexPathForRow:idx
                                    inSection:0];
                 
                 visit(obj, indexPath, 
                       &stopEnumerating);
                 *stop1 = stopEnumerating;
             }
             else
             {
                 [obj enumerateObjectsUsingBlock:
                  ^(id obj, NSUInteger row, BOOL *stop2)
                  {
                      NSIndexPath* indexPath =
                      [NSIndexPath indexPathForRow:row
                                         inSection:idx];
                      
                      visit(obj, indexPath, 
                            &stopEnumerating);
                      *stop1 = *stop2 = stopEnumerating;
                  }];
             }
             
         }];
    }
}

#pragma mark -

static NSString* reuseIdentifier(id item, Class cellClass,
                                 WDPRTableViewCellStyle cellStyle)
{
    NSString* reuseID = NSStringFromClass(cellClass);
    
    if (SAFE_CAST(item[WDPRCellReuseIdentifier], NSString))
    {
        return item[WDPRCellReuseIdentifier];
    }
    else if (!item[WDPRCellOptions] && item[WDPRCellPlaceholder])
    {
        reuseID = [reuseID stringByAppendingString:@"_textEditCell"];
    }
    
    switch ((NSInteger)cellStyle)
    {   // is the cellStyle implemented
            // by our private class cluster?
        case WDPRTableCellStylePlainButton:
        case WDPRTableCellStyleDeleteButton:
        case WDPRTableCellStyleStandardButton:
        case WDPRTableCellStyleSolidGrayButton:
        case WDPRTableCellStylePrimaryButton:
        case WDPRTableCellStyleSecondaryButton:
        case WDPRTableCellStyleTertiaryButton:
        {   reuseID = [reuseID stringByAppendingString:ButtonCellReuseID];
        }   break;
            
        case WDPRTableCellStyleWithBubble:
        {   reuseID = [reuseID stringByAppendingString:@"_bubbleCell"];
        }   break;
    }
    
    return [NSString stringWithFormat:@"%@-%@-%d",
            NSStringFromClass(cellClass), reuseID, (int)cellStyle];
}

- (NSInteger)numberOfSections
{
    NSInteger numSections = ((self.items.count &&
                              [self.items[0] isKindOfClass:
                               NSArray.class]) ? self.items.count : 1);
    return numSections;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    return (((section < self.items.count) &&
             [self.items[section] isKindOfClass:NSArray.class]) ?
            ((NSArray *)self.items[section]).count : self.items.count);
}

- (NSString*)reuseID:(id)item 
           cellClass:(Class*)tableCellClass
           cellStyle:(WDPRTableViewCellStyle*)tableCellStyle
{
    WDPRTableViewCellStyle cellStyle = 
    [(item[WDPRCellStyle] ?: @(self.cellStyle)) intValue];
    
    const Class cellClass = ([item[WDPRCellType]
                              isSubclassOfClass:
                              UITableViewCell.class] ? 
                             item[WDPRCellType] : self.cellType);
    
    if (tableCellClass) *tableCellClass = cellClass;
    if (tableCellStyle) *tableCellStyle = cellStyle;
    return reuseIdentifier(item, cellClass, cellStyle);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class cellClass;
    UITableViewCell* cell;
    WDPRTableViewCellStyle cellStyle;
    
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    
    NSString* reuseID = [self reuseID:item 
                            cellClass:&cellClass 
                            cellStyle:&cellStyle];
    
    WDPRTableViewCellBubble bubbleType = WDPRTableViewCellBubbleNone;

    // MDX is the only client that uses iOS6StyleGroupBubbles,
    // once it no longer needs that, this block can be removed
    if (self.iOS6StyleGroupBubbles &&
        ![reuseID hasSubstring:ButtonCellReuseID] && 
        (tableView.style == UITableViewStyleGrouped) &&
        [cellClass isSubclassOfClass:WDPRTableViewCell.class])
    {
        bubbleType = WDPRTableViewCellBubbleMiddle;
        
        if (indexPath.row == 0)
        {
            bubbleType |= WDPRTableViewCellBubbleTop;
        }
        
        if ((indexPath.row + 1) ==
            [tableView numberOfRowsInSection:indexPath.section])
        {
            bubbleType |= WDPRTableViewCellBubbleBottom;
        }
        
        reuseID = [reuseID stringByAppendingFormat:@"-%ld", (long) bubbleType];
    }
    
    if ((![@[UITableViewCell.class, 
             WDPRTableViewCell.class] 
           containsObject:cellClass] ||
         (cellStyle == UITableViewCellStyleDefault)) &&
        (bubbleType == WDPRTableViewCellBubbleNone))
    {
        @try
        {   // first attempt "modern" dequeuing, which requires client code to 
            // have registered a class or nib, but catch the exception if not
            cell = [tableView dequeueReusableCellWithIdentifier:reuseID 
                                                   forIndexPath:indexPath];
        }
        @catch (id error) {} // just catch the error so we can continue
    }
    
    if (!cell)
    {   // unable to dequeue a cell, use "old-school" approach instead
        
        // ensure client code isn't expecting unsupported behavior
        if ((cellStyle == WDPRTableCellStyleDefault) &&
            (item[WDPRCellDetail] || item[WDPRCellOptions] || item[WDPRCellPlaceholder]))
        {
            // bad coder, no biscuit (invalid config)
            cellStyle = WDPRTableCellStyleLeftLeftAligned;
            
            logWarning(indexPath, 
                       @"WDPRTableCellStyleDefault does not support detailText. "
                       "CellStyle changed to WDPRTableCellStyleLeftLeftAligned.");
        }
        
        cell = ([tableView dequeueReusableCellWithIdentifier:reuseID] ?:
                [[cellClass alloc] initWithStyle:
                 (UITableViewCellStyle)cellStyle reuseIdentifier:reuseID]);
    }
    
    if ([cell isKindOfClass:WDPRTableViewCell.class])
    {
        [(WDPRTableViewCell *)cell removeExtraLabels];
    }
    
    if (bubbleType)
    {
        ((WDPRTableViewCell *)cell).bubbleType = bubbleType;
    }
    
    return [self configureCell:cell forItem:item atIndexPath:indexPath inTable:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = self.headers[section];
    
    return ([title isKindOfClass:NSString.class] ? title : nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString* title = self.footers[section];
    
    return ([title isKindOfClass:NSString.class] ? title : nil);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return [self numberOfSections];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView 
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Not yet implemented at this layer");
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfRowsInSection:section];
}

#pragma mark - Cell Configuration

- (void)registerCellsForReuse:(UITableView*)tableView
{
    [self enumerateObjectsUsingBlock:
     ^(id item, WDPRIndexPath *idx, BOOL *stop) 
    {
        Class cellClass;
        WDPRTableViewCellStyle cellStyle;
        NSString* reuseID = [self reuseID:item 
                                cellClass:&cellClass cellStyle:&cellStyle];
        
        if (![@[UITableViewCell.class, 
                WDPRTableViewCell.class] 
              containsObject:cellClass] ||
            (cellStyle == UITableViewCellStyleDefault))
        {
            [tableView registerClass:cellClass forCellReuseIdentifier:reuseID];
        }
    }];
}

- (void)configureCellIcon:(UITableViewCell*)cell 
                  forItem:(id)item inTable:(UITableView*)tableView
{
    NSAssert([item isMultiValueTableItem], @"");
    
    id iconInfo = item[WDPRCellIcon];
    id iconID = item[WDPRCellIconID];
    
    UIColor* iconColor = cell.primaryTextLabel.textColor;
    
    if (!iconID)
    {
        iconID = ([iconInfo isA:NSNumber.class] ? iconInfo : nil);
    }
    
    id iconSizeInfo = item[WDPRCellIconSize] ?: iconInfo[WDPRCellIconSize] ?: nil;
    
    // Check for a default size added to the dictionaries
    CGSize defaultSize = CGSizeMake(30, 30);
    if (iconSizeInfo && [iconSizeInfo isKindOfClass:[NSValue class]])
    {
        defaultSize = [(NSValue *)iconSizeInfo CGSizeValue];
    }
    
    void (^setImageFromString)(NSString*) = ^(NSString* imageName)
    {
        unsigned glyphCode = 0; // attempt to parse as iconID hexCode
        if ([imageName hasPrefix:@"0x"] || [imageName hasPrefix:@"x"] ||
            [imageName hasPrefix:@"0X"] || [imageName hasPrefix:@"X"])
        {
            [[NSScanner scannerWithString:imageName] scanHexInt:&glyphCode];
        }
        
        [cell.mainImageView setImage:
         !glyphCode ? [[UIImage imageNamed:imageName] sizedTo:defaultSize] :
         [WDPRIcon imageOfIcon:glyphCode withColor:iconColor andSize:defaultSize]];
    };
    
    if ([iconInfo isKindOfClass:UIImage.class])
    {
        [cell.mainImageView setImage:
         [iconInfo sizedTo:defaultSize]];
    }
    else if ([iconID isKindOfClass:NSString.class])
    {
        unsigned glyphCode = 0;
        [[NSScanner scannerWithString:
          iconID] scanHexInt:&glyphCode];
        
        [cell.mainImageView setImage:
         [WDPRIcon imageOfIcon:glyphCode 
                     withColor:iconColor 
                       andSize:defaultSize]];
    }
    else if ([iconID isKindOfClass:
              NSNumber.class] && [iconID intValue])
    {
        unichar glyphCode = [iconID intValue];
        
        [cell.mainImageView setImage:
         [WDPRIcon imageOfIcon:glyphCode 
                     withColor:iconColor 
                       andSize:defaultSize]];
    }
    else if ([iconInfo isKindOfClass:NSString.class])
    {
        setImageFromString(iconInfo);
    }
    else if ([iconInfo isKindOfClass:NSURL.class])
    {
        [self fetchImage:iconInfo forCell:cell inTable:tableView
         withDefaultSize:defaultSize andOriginalInfo:iconInfo];
    }
    else if ([iconInfo isKindOfClass:NSDictionary.class])
    {
        id placeholder = iconInfo[WDPRCellPlaceholder];
        
        if ([placeholder isKindOfClass:NSString.class])
        {
            setImageFromString(placeholder);
        }
        else if ([placeholder isKindOfClass:UIImage.class])
        {
            [cell.mainImageView setImage:
             [placeholder sizedTo:defaultSize]];
        }
        else if ([placeholder isKindOfClass:NSNumber.class])
        {
            if ([placeholder intValue])
            {
                unichar glyphCode = [iconID intValue];
                
                [cell.mainImageView setImage:
                 [WDPRIcon imageOfIcon:glyphCode 
                             withColor:iconColor 
                               andSize:defaultSize]];
            }
        }
        
        if ([iconInfo[WDPRCellIcon] isKindOfClass:NSURL.class])
        {
            [self fetchImage:iconInfo[WDPRCellIcon] 
                     forCell:cell inTable:tableView
             withDefaultSize:defaultSize andOriginalInfo:iconInfo];
        }
    }
    else if ([iconInfo isKindOfClass:UIImageView.class])
    {
        UIImageView* imageView = (UIImageView*)iconInfo;
        
        // (this should probably be depricated)
        // kinda hacky, but eh....it works and kinda makes sense
        cell.mainImageView.image = [imageView.image 
                                sizedTo:imageView.frame.size];
        cell.mainImageView.highlightedImage = imageView.highlightedImage;
    }
}

- (void)configureCellDetail:(id<WDPRCellProxy>)cellProxy forItem:(id)item
                    atIndex:(NSIndexPath *)indexPath inTable:(UITableView*)tableView
{
    id itemDetail = item[WDPRCellDetail];
    cellProxy.secondaryTextLabel.hidden = NO;
    
    if (([itemDetail isKindOfClass:NSDate.class] &&
        (item[WDPRCellDateFormat] || item[WDPRCellTimeFormat])) ||
        ((!itemDetail || [itemDetail isKindOfClass:NSDate.class]) &&
        [item[WDPRCellOptions] isKindOfClass:NSDictionary.class]))
    {
        [cellProxy.secondaryTextLabel setText:[self dateStringForItem:item]];
    }
    else if (itemDetail && ![itemDetail isEqual:@""])
    {
        if ([item[WDPRCellObscureText] boolValue])
        {
            cellProxy.secondaryTextLabel.text = @"••••••••"; // keep text obscured
        }
        else if ([itemDetail isKindOfClass:NSAttributedString.class])
        {
            cellProxy.secondaryTextLabel.attributedText = itemDetail;
        }
        else
        {
            [cellProxy.secondaryTextLabel
             setTextOrAttributedText:[itemDetail formattedDescription]];
        }
    }
    else if (item[WDPRCellPlaceholder])
    {   // always set at least the placeholder to a non-empty string
        // so that the detailsTextLabel is assigned a frame, which is
        // later used as the intial frame for the UITextField
        cellProxy.secondaryTextLabel.textColor = UIColor.wdprGrayColor;
        [cellProxy.secondaryTextLabel setTextOrAttributedText:
         [item[WDPRCellPlaceholder] length] ? item[WDPRCellPlaceholder] : @" "];
    }
    
    // WDPRTableCellStyleFloatLabelField-specific formatting && error messaging
    if (item[WDPRCellPlaceholder] && [(item[WDPRCellStyle] ?: @(self.cellStyle))
                                      isEqual:@(WDPRTableCellStyleFloatLabelField)])
    {
        [cellProxy.primaryTextLabel applyStyle:WDPRTextStyleC2L];
        [cellProxy.secondaryTextLabel applyStyle:WDPRTextStyleB2D];

        cellProxy.primaryTextLabel.text = item[WDPRCellPlaceholder];
        
        if (![item[WDPRCellErrorState] boolValue] ||
            [self.focusedIndexPath isEqual:indexPath])
        {
            cellProxy.primaryTextLabel.textColor = UIColor.wdprGrayColor;
            
            cellProxy.primaryTextLabel.hidden = [cellProxy.secondaryTextLabel.text 
                                                 isEqual:item[WDPRCellPlaceholder]];
            
            if (cellProxy.primaryTextLabel.hidden)
            {
                // secondaryTextLabel has placeholder text
                cellProxy.secondaryTextLabel.textColor = UIColor.wdprGrayColor;
            }
            else
            {
                cellProxy.secondaryTextLabel.textColor = UIColor.wdprDarkBlueColor;
            }
        }
        else
        {
            cellProxy.primaryTextLabel.hidden = NO;
            
            if ([item[WDPRCellDisabled] boolValue])
            {
                cellProxy.primaryTextLabel.textColor = UIColor.wdprGrayColor;
                cellProxy.secondaryTextLabel.textColor = UIColor.wdprGrayColor;
            }
            
            cellProxy.primaryTextLabel.text = [item errorMessage];
            cellProxy.primaryTextLabel.textColor = UIColor.wdprOrangeColor;
        }
    }
}

- (UITableViewCell*)configureCell:(UITableViewCell*)cell forItem:(id)item 
                      atIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView
{
    [cell.asWDPRTableViewCell 
     setUseAutolayout:self.useAutolayout];
    
    cell.separatorInset = tableView.separatorInset;
    
    cell.mainImageView.image = nil;
    cell.secondaryTextLabel.text = nil;
    
    cell.selectionStyle = self.selectionStyle;
    
    item = (item ?: [self itemAtIndexPath:indexPath]);
    
    // configure textLabels
    cell.primaryTextLabel.numberOfLines = 0;
    cell.secondaryTextLabel.numberOfLines = 0;
    
    [cell.primaryTextLabel applyStyle:WDPRTextStyleB2D];
    [cell.secondaryTextLabel applyStyle:WDPRTextStyleC1D];
    
    cell.primaryTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.secondaryTextLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.backgroundColor = (item[WDPRCellBGColor] ?: UIColor.clearColor);
    
    cell.primaryTextLabel.textOrAttributedText = (item[WDPRCellTitle] ?: item);
    
    if (!([(item[WDPRCellStyle] ?: @(self.cellStyle))
          isEqual:@(WDPRTableCellStyleFloatLabelField)] || item[WDPRCellKeyboardType]))
    {
        // Non-Keyboard input types can assign isAccessibilityElement, since keyboard types need to be handled
        // separately due to the fact they are composed of a textfield and a clear button that changes dynamically
        cell.isAccessibilityElement = item[WDPRCellPlaceholder] != nil;
    }
    
    if (item[WDPRCellPlaceholder] != nil)
    {
        cell = [self configureAccessibilityForCell:cell
                                              item:item];
        if(item[WDPRCellUsesExtendedAccessibility]) {
            ((WDPRTableViewCell *) cell).shouldSetAccessibilityValue = NO;
        }
        else {
            ((WDPRTableViewCell *) cell).shouldSetAccessibilityValue = YES;
        }
    }
    
    if ([item[WDPRCellErrorState] boolValue])
    {
        cell.primaryTextLabel.textColor = UIColor.wdprOrangeColor;
    }
    else if ([item[WDPRCellDisabled] boolValue])
    {
        cell.primaryTextLabel.textColor = UIColor.wdprGrayColor;
        cell.secondaryTextLabel.textColor = UIColor.wdprGrayColor;
    }
    
    // set accessoryType - none, checkmark, or disclosure
    if (!self.checkmarkedItem)
    {
        cell.accessoryView = nil;
        cell.accessoryType = self.accessoryType;
    }
    else if (![indexPath isEqual:self.checkmarkedItem])
    {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //TODO: Use Peptasia Icon if available -- This is for reference when we migrate to using non-system checkmarks
//        [cell setAccessoryView:
//         [[UIImageView alloc] // SLING-1729 & SLING-2538
//          initWithImage:[UIImage imageNamed:@"button_checkmark_blue"]
//          highlightedImage:[UIImage imageNamed:@"button_checkmark_white"]]];
    }
    
    if ([cell respondsToSelector:@selector(setLeftAccessoryView:)])
    {
        cell[@"leftAccessoryView"] = item[WDPRCellLeftAccessoryView];
    }
    
    if (item[WDPRCellAuxiliaryAccessoryText] &&
        [cell respondsToSelector:
         @selector(auxiliaryAccessoryLabel)])
    {
        id text = item[WDPRCellAuxiliaryAccessoryText];
        [((WDPRTableViewCell *)cell).
         auxiliaryAccessoryLabel setTextOrAttributedText:text];
    }
    else if ([cell respondsToSelector:@selector(setAuxiliaryAccessoryView:)])
    {
        cell[@"auxiliaryAccessoryView"] = item[WDPRCellAuxiliaryAccessoryView];
    }
    
    if ([item isMultiValueTableItem])
    {
        [self configureCellIcon:cell forItem:item inTable:tableView];
        
        const BOOL isTextFieldCell = 
        (!item[WDPRCellOptions] && item[WDPRCellPlaceholder]);
        
        // set accessoryType
        if (!self.checkmarkedItem)
        {
            if ([item[WDPRCellAccessoryView] isKindOfClass:UIView.class])
            {
                cell.accessoryView = item[WDPRCellAccessoryView];
            }
            else if ([item[WDPRCellAccessoryView] isKindOfClass:NSString.class])
            {
                [cell setAccessoryView:
                 [[UIImageView alloc] initWithImage:
                  [UIImage imageNamed:item[WDPRCellAccessoryView]]]];
            }
            else if (item[WDPRCellAccessoryType])
            {
                cell.accessoryType = [item[WDPRCellAccessoryType] intValue];
            }
        }
        
        // set selectionStyle
        if (!isTextFieldCell)
        {
            if (item[WDPRCellSelectionStyle])
            {
                cell.selectionStyle = [item[WDPRCellSelectionStyle] intValue];
            }
            
            if ([cell.reuseIdentifier hasSubstring:ButtonCellReuseID] &&
                (cell.selectionStyle != UITableViewCellSelectionStyleNone))
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if (item[WDPRCellSelectionStyle])
                {
                    logWarning(indexPath,
                               @"WDPRTableCellStyleXXButton cells must not "
                               "be selectable. SelectionStyle changed.");
                }
            }
        }
        else
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (item[WDPRCellSelectionStyle])
            {
                logWarning(indexPath,
                           @"UITextField and empty cells only support "
                           "UITableViewCellSelectionStyleNone. SelectionStyle "
                           "changed to UITableViewCellSelectionStyleNone.");
            }
        }
        
        // error check the accessoryType
        if ((isTextFieldCell || item[WDPRCellOptions]) &&
            (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator))
        {
            // bad coder, no biscuit (invalid config)
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            logWarning(indexPath,
                       @"UITextField and UIPickerView/UIDatePicker cells "
                       "do not support UITableViewCellAccessoryDisclosureIndicator. "
                       "AccessoryType changed to UITableViewCellAccessoryNone.");
        }
        
        if (![cell isKindOfClass:WDPRTableViewCell.class] ||
            ![item isKindOfClass:WDPRTableMultipleItems.class])
        {
            [self configureCellDetail:cell forItem:item 
                              atIndex:indexPath inTable:tableView];
            
            [cell.secondaryTextLabel setHidden:
             (isTextFieldCell && [self.focusedIndexPath isEqual:indexPath])];
        }
        else  
        {   // accomodate multiple items in the cell
            WDPRTableMultipleItems * multipleItems = (id)item;
            NSMutableArray *accessibilityItems = [NSMutableArray new];
            for (NSUInteger subItemIndex = 0;
                 subItemIndex < multipleItems.numItems; subItemIndex++)
            {
                WDPRTableViewItem *subItem = multipleItems[subItemIndex];
                NSIndexPath* embeddedItemIndexPath =
                [indexPath indexPathWithSubItemIndex:subItemIndex];
                
                WDPRTableEmbeddedItem *proxy = [WDPRTableEmbeddedItem new];
                
                [proxy setPrimaryTextLabel:
                 [(WDPRTableViewCell *)cell textLabelAtIndex:subItemIndex]];
                
                [proxy setSecondaryTextLabel:
                 [(WDPRTableViewCell *)cell detailTextLabelAtIndex:subItemIndex]];
                
                [self configureCellDetail:proxy forItem:subItem
                                  atIndex:embeddedItemIndexPath inTable:tableView];
                
                if (isTextFieldCell &&
                    (indexPath.row == self.focusedIndexPath.row) &&
                    (indexPath.section == self.focusedIndexPath.section) &&
                    (subItemIndex == self.focusedIndexPath.subItemIndex))
                {
                    proxy.secondaryTextLabel.hidden = YES; // during editing
                }
                proxy.secondaryTextLabel.accessibilityLabel = [self accessibilityLabelForItem:
                                                               subItem];
                [accessibilityItems addObject:proxy.secondaryTextLabel];
            }
            cell.isAccessibilityElement = NO;
            cell.accessibilityElements = accessibilityItems.copy;
        }
        
        if ([cell isKindOfClass:WDPRExpandableCell.class])
        {
            ((WDPRExpandableCell*)cell).expanded = [item[WDPRCellExpanded] boolValue];
        }
        
        if (item[WDPRCellConfigurationBlock])
        {
            ((WDPRCellConfigurationBlockType)item[WDPRCellConfigurationBlock])(cell);
        }
    }
    
    return cell;
}

/*
 Example: Accessbility configuration of a password text field
 @{
 {
     WDPRCellUsesExtendedAccessibility : @YES,
     WDPRCellAccessibilityLabel : @"Password required",
     WDPRCellAccessibilityHint : @"Please enter a password",
     ...
 }
 **/

-(UITableViewCell *) configureAccessibilityForCell:(UITableViewCell*) cell
                                              item:(WDPRTableViewItem*) item {
    
    if ([item isKindOfClass:WDPRTableMultipleItems.class])
    {
        return cell; // Accessibility will be handled alongside the configuration of sub items.
    }
    
    cell.accessibilityLabel = [self accessibilityLabelForItem:item];
    //accessibilityHint
    NSString *accessibilityHint = item[WDPRCellAccessibilityHint];
    cell.accessibilityHint = accessibilityHint.length > 0 ? accessibilityHint : cell.accessibilityHint ;
    
    return cell;
}

-(NSString *) accessibilityLabelForItem:(WDPRTableViewItem*) item {
    if(item[WDPRCellUsesExtendedAccessibility])
    {
        
        NSMutableArray *elements = [NSMutableArray new];
        
        //accessibilityLabel
        NSString *accessibilityLabel = item[WDPRCellAccessibilityLabel];
        accessibilityLabel = accessibilityLabel.length > 0 ? accessibilityLabel : (item[WDPRCellPlaceholder] ?: @"");
        
        accessibilityLabel = [accessibilityLabel isA:[NSAttributedString class]] ?
        [((NSAttributedString *)accessibilityLabel) string] : accessibilityLabel;
        [elements addObject:accessibilityLabel];
        
        BOOL isRequired = NO;
        if([accessibilityLabel hasSuffix:@"*"])
        {
            [elements addObject:WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.accessibility.required",
                                                            WDPRCoreResourceBundleName, nil)];
            isRequired = YES;
        }
        
        if([item[WDPRCellErrorState] boolValue])
        {
            NSString *format = WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.error.alerterror",
                                                           WDPRCoreResourceBundleName, nil);
            NSString *alert = [NSString stringWithFormat:format, [item errorMessage]];
            [elements addObject:alert];
        }
        
        NSString *accessibilityValue = item[WDPRCellDetail];
        
        if (item[WDPRCellObscureText] && accessibilityValue.length > 0)
        {
            accessibilityValue = WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.accessibility.obscured",
                                                WDPRCoreResourceBundleName, nil);
        }
        else if([accessibilityValue respondsToSelector:@selector(formattedDescription)])
        {
            accessibilityValue = [accessibilityValue formattedDescription];
        }
        
        BOOL isDate = [item[WDPRCellDetail] isKindOfClass:NSDate.class];
        if (isDate)
        {
            accessibilityValue = [self dateStringForItem:item];
        }
        
        if(accessibilityValue.length > 0)
        {
            [elements addObject:accessibilityValue];
        }
        
        //TODO: Add more general logic to support either case
        BOOL hasOptions = item[WDPRCellOptions] != nil;
        
        if(hasOptions || isDate)
        {
            [elements insertObject:
             WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.accessibility.dropdown",
                                                            WDPRCoreResourceBundleName, nil)
                           atIndex:isRequired ? WDPRAccessibilityDropdownIndexWhenRequired :
             WDPRAccessibilityDropdownIndexWhenNotRequired];
        }
        else
        {
            [elements addObject:WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.accessibility.textfield",
                                                            WDPRCoreResourceBundleName, nil)];
        }
        
        accessibilityLabel = [elements componentsJoinedByString:WDPRAccessibilitySeparator];
        
        return [accessibilityLabel stringByReplacingOccurrencesOfString:@"*"
                                                             withString:@""];
    }
    else
    {
        NSString *accessibilityLabel =
        (item[WDPRCellPlaceholder] ?: @"");
        
        accessibilityLabel = [accessibilityLabel isA:[NSAttributedString class]] ?
        [((NSAttributedString *)accessibilityLabel) string] : accessibilityLabel;
        
        return [accessibilityLabel stringByReplacingOccurrencesOfString:@"*"
                                                      withString:@""];
    }
}

-(NSString*) dateStringForItem:(WDPRTableViewItem*) item{
    id itemDetail = item[WDPRCellDetail];
    NSString *dateString = @"";
    if ([itemDetail isKindOfClass:NSDate.class] &&
        (item[WDPRCellDateFormat] || item[WDPRCellTimeFormat]))
    {
        // format NSDate based on specified NSDateFormatterStyle
        dateString = [NSDateFormatter
                      localizedStringFromDate:itemDetail
                      dateStyle:[item[WDPRCellDateFormat] intValue]
                      timeStyle:[item[WDPRCellTimeFormat] intValue]];
    }
    else if ((!itemDetail || [itemDetail isKindOfClass:NSDate.class]) &&
             [item[WDPRCellOptions] isKindOfClass:NSDictionary.class])
    {
        // format NSDate based on specified UIDatePickerMode
        NSDictionary* options = item[WDPRCellOptions];
        WDPRDatePickerModeType mode = [options[WDPRDatePickerMode] intValue];
        
        BOOL showDate = ((mode == WDPRDatePickerModeDate) ||
                         (mode == WDPRDatePickerModeMonthYear) ||
                         (mode == WDPRDatePickerModeDateAndTime));
        
        BOOL showTime = ((mode == WDPRDatePickerModeTime) ||
                         (mode == WDPRDatePickerModeDateAndTime));
        
        dateString =
        [NSDateFormatter localizedStringFromDate:itemDetail
                                       dateStyle:(!showDate ?
                                                  NSDateFormatterNoStyle :
                                                  NSDateFormatterMediumStyle)
                                       timeStyle:(!showTime ?
                                                  NSDateFormatterNoStyle :
                                                  NSDateFormatterMediumStyle)];
        if (mode == WDPRDatePickerModeMonthYear)
        {
            dateString = [[NSDateFormatter userFormatterWithFormat:@"MMM yyyy"]
                          stringFromDate:itemDetail];
        }
    }
    return dateString;
}

- (void)fetchImage:(NSURL*)imageURL
           forCell:(UITableViewCell*)cell
           inTable:(UITableView*)tableView
   withDefaultSize:(CGSize)defaultSize andOriginalInfo:(id)iconInfo
{
    Require(imageURL, NSURL.class);
    
    SDWebImageManager* imageMgr = 
    SDWebImageManager.sharedManager;
    
    NSString* cacheKey = (!imageMgr.cacheKeyFilter ?
                          imageURL.absoluteString : 
                          imageMgr.cacheKeyFilter(imageURL));
    
    UIImage* cachedImage = [imageMgr.imageCache 
                            imageFromDiskCacheForKey:cacheKey];
    
    if (cachedImage)
    {
        [cell.mainImageView setImage:
         [cachedImage sizedTo:defaultSize]];
    }
    else
    {
        MAKE_WEAK(self);
        MAKE_WEAK(tableView);
        
        //id<SDWebImageOperation> op = 
        [SDWebImageManager.sharedManager 
         downloadImageWithURL:imageURL options:(SDWebImageRetryFailed | SDWebImageRefreshCached)
         progress:nil completed:^(UIImage *img, NSError *error, 
                                  SDImageCacheType cacheType, BOOL finished, NSURL*imageURL)
         {
             MAKE_STRONG(self);
             if (!strongself || !img) return;
             UIImage* image = [img sizedTo:defaultSize];
             
             executeOnMainThread
             (^{
                 MAKE_STRONG(self);
                 [strongself enumerateObjectsUsingBlock:
                  ^(id obj, NSIndexPath *idx, BOOL *stop) 
                  {
                      if ([obj isMultiValueTableItem] && 
                          [obj[WDPRCellIcon] isEqual:iconInfo])
                      {
                          *stop = YES;
                          obj[WDPRCellIcon] = image;
                          
                          MAKE_STRONG(tableView);
                          UITableViewCell* cell = [strongtableView 
                                                   cellForRowAtIndexPath:idx];
                          
                          cell.mainImageView.image = image;
                          cell.mainImageView.highlightedImage = nil;
                          
                          [cell.mainImageView setBounds:
                           CGRectMake(0, 0, defaultSize.width, defaultSize.height)];
                      }
                  }];
             });
         }];
        
        // TODO: keep track of fetch operation 
        // so it can be cancelled when appropriate
        //        objc_setAssociatedObject(self, &operationKey, op, 
        //                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
    }
}

@end

#pragma mark -

@implementation NSObject (WDPRTableItem)

- (BOOL)isMultiValueTableItem
{
    return YES;
}

@end

@implementation NSString (WDPRTableItem)

- (BOOL)isMultiValueTableItem
{
    return NO;
}

@end

@implementation NSAttributedString (WDPRTableItem)

- (BOOL)isMultiValueTableItem
{
    return NO;
}

@end

