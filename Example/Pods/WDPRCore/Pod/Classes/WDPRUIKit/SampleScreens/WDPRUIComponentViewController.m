//
//  WDPRUIComponentViewController.m
//  DLR
//
//  Created by Pierce, Owen on 12/9/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRUIComponentViewController.h"
#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

enum
{   // integer constants

    // section IDs
    kStyleSection,
    kColorSection,
    kFontSection,
};

@interface WDPRUIComponentViewController ()

@end

@implementation WDPRUIComponentViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];

    if (self)
    {
        self.title = WDPRLocalizedStringInBundle(@"com.wdprcore.componentviewcontroller.title", WDPRCoreResourceBundleName, nil);
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.dataDelegate.iOS6StyleGroupBubbles = YES;
    self.dataDelegate.accessoryType = UITableViewCellAccessoryNone;
    self.dataDelegate.cellStyle = WDPRTableCellStyleLeftRightAligned;
    self.dataDelegate.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Table Data

- (NSArray *)filterFontMethods:(NSArray *)methods
{
    NSMutableArray *fontMethods = [NSMutableArray new];

    for (NSString *methodName in methods)
    {
        //WDPRLog(@"Checking method: %@", methodName);
        
        if (![methodName hasSuffix:@":"] &&
            ([methodName hasPrefix:@"standard"] ||
             [methodName hasPrefix:@"emphasis"]))
        {
            [fontMethods addObject:methodName];
        }
    }

    // sort fonts by size
    return [fontMethods sortedArrayUsingComparator:
            ^(NSString *key1, NSString *key2) 
            {
                UIFont *font1 = [UIFont valueForKey:key1];
                UIFont *font2 = [UIFont valueForKey:key2];
                
                return [@(font1.pointSize) compare:@(font2.pointSize)];
            }];
}

- (NSArray *)fontCellData
{
    NSMutableArray *fontCells = [NSMutableArray new];

    for (NSString *fontName in 
         [self filterFontMethods:UIFont.classMethods])
    {
        UIFont *font = [UIFont valueForKey:fontName];

        NSDictionary *fontDetail = 
        @{
                WDPRCellRowID : fontName,
                WDPRCellTitle : fontName,
                WDPRCellDetail : [NSString stringWithFormat:@"%@ %d",
                           font.fontName, (int)font.pointSize],

                WDPRCellStyle : @(WDPRTableCellStyleLeftRightAligned),
                WDPRCellConfigurationBlock : ^(UITableViewCell* cell)
          {
              cell.textLabel.font = font;
          }
          };

        [fontCells addObject:fontDetail];
    }
    
    return fontCells;
}

- (NSArray *)filterColorMethods:(NSArray *)methods
{
    NSMutableArray *colorMethods = [NSMutableArray new];
    
    for (NSString *methodName in methods)
    {
        if ([methodName hasPrefix:@"wdpr"])
        {
            [colorMethods addObject:methodName];
        }
    }

    return colorMethods.copy;
}

- (NSArray *)colorCellData:(NSArray*)colorMethods
{
    NSMutableArray *colorCells = [NSMutableArray new];

    for (NSString *colorName in 
         [colorMethods sortedArrayUsingSelector:@selector(compare:)])
    {
        UIView *colorSwatch = [[UIView alloc] initWithFrame:
                             CGRectWithSize(CGSizeMake(30, 30))];
        colorSwatch.backgroundColor = [UIColor valueForKey:colorName];

        NSString* colorDescription = 
        [NSString stringWithFormat:@"0x%@", 
         [UIColor hexValuesFromUIColor:colorSwatch.backgroundColor]];

        NSString* shortenedColorName = 
        [colorName stringByRemovingSubstrings:@[@"wdpr", @"Color"]];
        
        [colorCells addObject:@{WDPRCellRowID : shortenedColorName,
                WDPRCellTitle : shortenedColorName,
                WDPRCellIcon : colorSwatch.imageOfSelf,
                WDPRCellDetail : colorDescription,
                                 }];
    }

    return colorCells;
}

- (NSArray*)styleData
{
    NSMutableArray* styleData = [NSMutableArray new];
    
    [WDPRTheme.allTextStyles enumerateKeysAndObjectsUsingBlock:
     ^(NSNumber* textStyleID, NSDictionary* styleInfo, BOOL *stop) 
     {
         UIFont* font = styleInfo[NSFontAttributeName];
         UIColor* color = styleInfo[NSForegroundColorAttributeName];
         
         [styleData addObject:
          @{
            NSFontAttributeName : font,

                  WDPRCellTitle : [NSString stringWithFormat:
                            @"%@-%@-%d", styleInfo[WDPRCellTitle],
                            font.fontName, (int)font.pointSize],

                  WDPRCellDetail : [NSString stringWithFormat:@"0x%@",
                            [UIColor hexValuesFromUIColor:color]],

                  WDPRCellConfigurationBlock : ^(UITableViewCell* cell)
            {
             [cell.textLabel applyStyle:textStyleID.integerValue];
             
             [cell.textLabel setBackgroundColor:
              (![cell.textLabel.textColor 
                 isEqual:UIColor.whiteColor] ? 
               UIColor.whiteColor : UIColor.wdprBlueColor)];
            }
            }];
     }];
    
    return [styleData sortedArrayUsingComparator:
            ^(NSDictionary *item1, NSDictionary *item2) 
            {
                UIFont *font1 = item1[NSFontAttributeName];
                UIFont *font2 = item2[NSFontAttributeName];
                
                NSComparisonResult result = 
                [@(font1.pointSize) compare:@(font2.pointSize)];
                
                if (result == NSOrderedSame)
                {
                    result = [item1[WDPRCellTitle]
                              compare:item2[WDPRCellTitle]];
                }
                
                return result;
            }];
}

- (NSArray *)initialData
{
    NSArray* ourColors = [self filterColorMethods:UIColor.classMethods];
    
    NSMutableArray *initialData = 
    [NSMutableArray arrayWithArray:
     @[
       @{WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.componentviewcontroller.table.headerstandardstyles", WDPRCoreResourceBundleName, nil),
               WDPRTableSectionItems : self.styleData,
          },
       @{WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.componentviewcontroller.table.headerstandardcolors", WDPRCoreResourceBundleName, nil),
               WDPRTableSectionItems :
              [[self colorCellData:ourColors] arrayByAddingObject:
               @{
                       WDPRCellTitle : WDPRLocalizedStringInBundle(@"com.wdprcore.componentviewcontroller.table.titleviewother", WDPRCoreResourceBundleName, nil),
                       WDPRCellSelectionStyle : @(UITableViewCellSelectionStyleDefault),
                       WDPRCellAccessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
                 }],
          },
       @{
               WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.componentviewcontroller.table.headerstandardfonts", WDPRCoreResourceBundleName, nil),
               WDPRTableSectionItems : self.fontCellData
           }
       
       ]];
    
    return initialData;
}

#pragma mark - Table Actions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == kColorSection) && // last row in kColorSection?
        (indexPath.row == ([tableView numberOfRowsInSection:kColorSection]-1)))
    {
        [self setRemoveActivityIndicatorBlock:
         [tableView addActivityIndicatorToRowAtIndexPath:indexPath]];
        
        NSMutableArray* systemColors = 
        [UIColor.classMethods filteredArrayUsingPredicate:
         [NSPredicate predicateWithFormat:
          @"!(self ENDSWITH ':') && (self CONTAINS 'Color')"]].mutableCopy;
         
        [systemColors removeObjectsInArray:[self filterColorMethods:systemColors]];
        
        WDPRTableController * systemColorsVC = [WDPRTableController new];
        systemColorsVC.dataDelegate = [[WDPRTableDataDelegate alloc]
                                       initWithArray:[self colorCellData:systemColors]];
    
        systemColorsVC.title = WDPRLocalizedStringInBundle(@"com.wdprcore.systemcolorscontroller.title", WDPRCoreResourceBundleName, nil);
        systemColorsVC.dataDelegate.accessoryType = UITableViewCellAccessoryNone;
        systemColorsVC.dataDelegate.cellStyle = WDPRTableCellStyleLeftRightAligned;
        systemColorsVC.dataDelegate.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self pushViewController:systemColorsVC];
    }
}

@end
