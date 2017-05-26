//
//  WDPRSampleTableController.m
//  WDPR
//
//  Created by Martin Uribe on 11/4/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRSampleTableController.h"

#import "WDPRUIKit.h"

@interface WDPRSampleTableController ()

@property (nonatomic) BOOL imageView;
@property (nonatomic) BOOL accessoryView;
@property (nonatomic) BOOL editableItems;

@property (nonatomic) NSUInteger tableStyle;
@property (nonatomic) BOOL leftAccessoryView;
@property (nonatomic) BOOL auxiliaryAccessoryView;

@property (nonatomic) UITableView* sampleTableView;
@property (nonatomic) WDPRTableDataDelegate * sampleData;

@end

#pragma mark -

@implementation WDPRSampleTableController

- (NSArray*)tableStyles
{
    return @[ @"Plain Style", 
              @"Grouped Style", 
              @"Grouped w/Bubbles"];
}

- (NSArray*)initialData
{
    MAKE_WEAK(self);
    
    NSAttributedString* (^blueBlueString)(NSString*) = ^(NSString* text)
    {
        return [NSAttributedString string:text attributes:
                @{ NSForegroundColorAttributeName : UIColor.wdprBlueColor }];
    };
    
    return 
    @[
      @{WDPRCellTitle : @"imageView",
              WDPRCellAccessoryType :
                @(!self.imageView ? 
                UITableViewCellAccessoryNone :
                UITableViewCellAccessoryCheckmark),
            },
      @{WDPRCellTitle : @"accessoryView",
              WDPRCellAccessoryType :
                @(!self.accessoryView ? 
                UITableViewCellAccessoryNone :
                UITableViewCellAccessoryCheckmark),
            },
      @{WDPRCellTitle : @"editableItems",
              WDPRCellAccessoryType :
                @(!self.editableItems ? 
                UITableViewCellAccessoryNone :
                UITableViewCellAccessoryCheckmark),
          },
      @{WDPRCellTitle : blueBlueString(@"leftAccessoryView"),
              WDPRCellAccessoryType :
                @(!self.leftAccessoryView ? 
                UITableViewCellAccessoryNone :
                UITableViewCellAccessoryCheckmark),
            },
      @{WDPRCellTitle : blueBlueString(@"auxiliaryAccessoryView"),
              WDPRCellAccessoryType :
                @(!self.auxiliaryAccessoryView ? 
                UITableViewCellAccessoryNone :
                UITableViewCellAccessoryCheckmark),
            },
      @{WDPRCellTitle : @"tableStyle",
              WDPRCellOptions : self.tableStyles,
              WDPRCellDetail : self.tableStyles[self.tableStyle],
              WDPRCellStyle : @(WDPRTableCellStyleLeftRightAligned),
              WDPRCellValueChangedBlock : ^(NSDictionary* item)
            {
                MAKE_STRONG(self);
                
                strongself.tableStyle = 
                [strongself.tableStyles 
                 indexOfObject:item[WDPRCellDetail]];
                
                [strongself.sampleData setIOS6StyleGroupBubbles:
                 (strongself.tableStyle > UITableViewStyleGrouped)];
                
                strongself.sampleTableView = nil;
                strongself.sampleData.items = self.sampleContent;
                [strongself.view addSubview:strongself.sampleTableView];
            }
            },
      ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController
     setNavigationBarHidden:YES];
    
    self.tableView.rowHeight = 30;
    self.tableView.scrollEnabled = YES;
    
    // eliminate trailing separator lines
    
    [self.tableView setContentOffset:CGPointZero];
    [self.tableView setContentSize:CGSizeZero];
    [self.tableView setFrame:CGRectMake(0,0,320,200)];
    
    [self.tableView setContentOffset:CGPointZero];
    [self.tableView setContentSize:CGSizeZero];

    [self.view addSubview:self.sampleTableView];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

#pragma mark -

- (WDPRTableDataDelegate *)sampleData
{
    if (!_sampleData)
    {
        _sampleData = [[WDPRTableDataDelegate alloc]
                       initWithArray:self.sampleContent];
        
        _sampleData.accessoryType = UITableViewCellAccessoryNone;
        
        _sampleData.selectionBlock = ^(UITableView* tv,
                                       NSIndexPath* ip,
                                       WDPRTableDataDelegate * dd){ };
    }
    
    return _sampleData;
}

- (NSArray *)sampleContent
{
    UIView* (^viewWithColor)(UIColor*) = ^(UIColor* color)
    {
        UIView* view = [[UIView alloc] 
                        initWithFrame:
                        CGRectMake(0, 0, 30, 30)];
        
        view.backgroundColor = color;
        
        return view;
    };
    
    NSDictionary* 
    (^sampleItem)(WDPRTableViewCellStyle, NSString*) =
    ^(WDPRTableViewCellStyle cellStyle, NSString* title)
    {
        NSMutableDictionary* item = 
        [NSMutableDictionary dictionaryWithDictionary:
         @{
                 WDPRCellTitle : title,
                 WDPRCellStyle : @(cellStyle),
           }];
        
        if (cellStyle != WDPRTableCellStyleDefault)
        {
            item[WDPRCellDetail] = @"detailText";
        }
        
        if (self.editableItems)
        {
            item[WDPRCellPlaceholder] = WDPRLocalizedStringInBundle(@"com.wdprcore.wdprsampletable.cellitem.placeholder", WDPRCoreResourceBundleName, nil);
        }
        
        if (self.imageView)
        {
            item[WDPRCellIcon] = viewWithColor(UIColor.wdprDarkBlueColor).imageOfSelf;
        }
        
        if (self.accessoryView)
        {
            item[WDPRCellAccessoryView] = viewWithColor(UIColor.wdprDarkBlueColor);
        }
        
        if (self.leftAccessoryView)
        {
            item[WDPRCellLeftAccessoryView] = viewWithColor(UIColor.wdprBlueColor);
        }
        
        if (self.auxiliaryAccessoryView)
        {
            item[WDPRCellAuxiliaryAccessoryView] = viewWithColor(UIColor.wdprBlueColor);
        }
        
        return item.copy;
    };
    
    NSDictionary* 
    (^basicItem)(WDPRTableViewCellStyle, NSString*) =
    ^(WDPRTableViewCellStyle cellStyle, NSString* title)
    {
        NSMutableDictionary* item = 
        sampleItem(cellStyle, title).mutableCopy;
        
        item[WDPRCellType] = UITableViewCell.class;
        return item.copy;
    };
    
    return 
    @[
      @{WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdprsampletable.headerunaltered.message", WDPRCoreResourceBundleName, nil),
              WDPRTableSectionItems :
             @[  basicItem(WDPRTableCellStyleDefault,              @"default"),
                 basicItem(WDPRTableCellStyleLeftRightAligned,     @"leftRight"),
                 basicItem(WDPRTableCellStyleRightLeftAligned,     @"rightLeft"),
                 basicItem(WDPRTableCellStyleSubtitleRightOfImage, @"subtitleRightOfImage"),
                 ]
         },
      
      @{WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdprsampletable.headerstandardcell.message", WDPRCoreResourceBundleName, nil),
              WDPRTableSectionItems :
             @[  sampleItem(WDPRTableCellStyleDefault,              @"default"),
                 sampleItem(WDPRTableCellStyleLeftRightAligned,     @"leftRight"),
                 sampleItem(WDPRTableCellStyleRightLeftAligned,     @"rightLeft"),
                 sampleItem(WDPRTableCellStyleSubtitleRightOfImage, @"subtitleRightOfImage"),
                 ]
         },
      
      @{WDPRTableSectionHeader : WDPRLocalizedStringInBundle(@"com.wdprcore.wdprsampletable.headercustomcell.message", WDPRCoreResourceBundleName, nil),
              WDPRTableSectionItems :
             @[  sampleItem(WDPRTableCellStyleLeftLeftAligned,      @"leftLeft"),
                 sampleItem(WDPRTableCellStyleLeftLeftAutoSized,    @"leftLeftAutoSized"),
                 sampleItem(WDPRTableCellStyleSubtitleBelowImage,   @"subtitleBelowImage"),
                 sampleItem(WDPRTableCellStyleWithBubble,           @"withBubble"),
                 sampleItem(WDPRTableCellStyleStandardButton,       @"standardButton"),
                 sampleItem(WDPRTableCellStylePlainButton,          @"plainButton"),
                 sampleItem(WDPRTableCellStyleDeleteButton,         @"deleteButton"),
                 sampleItem(WDPRTableCellStyleSolidGrayButton,      @"solidGrayButton"),
                 ]
         }
      ];
}

- (UITableView*)sampleTableView
{
    if (!_sampleTableView)
    {
        UITableViewStyle tableStyle = self.tableStyle;
        if (tableStyle > UITableViewStyleGrouped)
        {
            tableStyle = UITableViewStyleGrouped;
        }
        
        _sampleTableView = 
        [[UITableView alloc] initWithFrame:CGRectMake(0,120, 320,250)];
        
        _sampleTableView.delegate = self.sampleData;
        _sampleTableView.dataSource = self.sampleData;
    }
    
    return _sampleTableView;
}

#pragma mark -

- (UITableViewCell*)tableView:(UITableView *)tableView 
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView 
                       cellForRowAtIndexPath:indexPath];
    
    [cell setBackgroundColor:
     [UIColor.wdprBlueColor colorWithAlphaComponent:0.1]];
    
    return cell;
}

- (NSIndexPath*)tableView:(UITableView *)tableView 
 willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath; // always allow logical selection, despite lack of visual highlighting
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary* item = [self.dataDelegate itemAtIndexPath:indexPath];
    
    if (!item[WDPRCellOptions])
    {
        onExitFromScope
        (^{
            [self reloadItems];
            
            [self.sampleData 
             setItems:self.sampleContent];
            
            [self.sampleTableView reloadData];
        });
        
        NSString* propertyName = item[WDPRCellTitle];
        if ([propertyName isKindOfClass:NSAttributedString.class])
        {
            propertyName = ((NSAttributedString*)propertyName).string;
        }
        
        self[propertyName] = @(![self[propertyName] boolValue]);
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
