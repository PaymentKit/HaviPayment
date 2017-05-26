//
//  WDPRFloatLabelFieldSampler.m
//  DLR
//
//  Created by Rodden, James on 12/10/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRFloatLabelFieldSampler.h"

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

@interface WDPRFloatLabelFieldSampler ()

@end

@implementation WDPRFloatLabelFieldSampler

- (NSArray*)initialData
{
    return 
    @[
      @{
              WDPRTableSectionHeader :
              htmlify(WDPRLocalizedStringInBundle(@"com.wdprcore.floatlabelfield.header.message", WDPRCoreResourceBundleName, nil), NO),

              WDPRTableSectionItems :
              @[
                  @{
                          WDPRCellRowID : @"Birthday",
                          WDPRCellOptions :
                          @{WDPRDatePickerMode : @(WDPRDatePickerModeDate) },
                          WDPRCellPlaceholder : WDPRLocalizedStringInBundle(@"com.wdprcore.floatlabelfield.bithday", WDPRCoreResourceBundleName, nil),
                      },
                  @{
                          WDPRCellRowID : @"FirstName",
                          WDPRCellPlaceholder : WDPRLocalizedStringInBundle(@"com.wdprcore.floatlabelfield.firstname", WDPRCoreResourceBundleName, nil),
                      },
                  @{
                          WDPRCellRowID : @"LastName",
                          WDPRCellPlaceholder : WDPRLocalizedStringInBundle(@"com.wdprcore.floatlabelfield.lastname", WDPRCoreResourceBundleName, nil),
                      },
                  @{
                          WDPRCellRowID : @"RoomNumber",
                          WDPRCellKeyboardType : @(UIKeyboardTypeNumberPad),
                          WDPRCellPlaceholder : WDPRLocalizedStringInBundle(@"com.wdprcore.floatlabelfield.stateroomnumber", WDPRCoreResourceBundleName, nil),
                      },
                  ]
          }
      ];
}

- (void)viewDidLoad
{
    MAKE_WEAK(self);
    [super viewDidLoad];
    
    self.title = WDPRLocalizedStringInBundle(@"com.wdprcore.floatlabelfield.title", WDPRCoreResourceBundleName, nil);
    
    self.tableView.scrollEnabled = NO;
    
    [self.navigationItem 
     setRightBarButtonItem:
     [UIBarButtonItem doneButtonItem:
      ^{
          MAKE_STRONG(self);
          NSMutableDictionary* data = [NSMutableDictionary new];
          
          [strongself.dataDelegate 
           enumerateObjectsUsingBlock:
           ^(NSDictionary* item, NSIndexPath *idx, BOOL *stop) 
          {
              data[item[WDPRCellRowID]] = item[WDPRCellDetail];
          }];
          
          NSString* message = [NSString stringWithFormat:@"%@", data];
          [UIAlertView showAlertWithTitle:nil message:message
                cancelButtonTitleAndBlock:@[@"OK"] otherButtonTitlesAndBlocks:nil];
      }]];
    
    self.dataDelegate.cellStyle = WDPRTableCellStyleFloatLabelField;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

@end
