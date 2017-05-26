//
//  DynamicTextDemo.m
//  DLR
//
//  Created by Rodden, James on 12/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "DynamicTextDemo.h"

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

@interface DynamicTextDemo ()

@end

@implementation DynamicTextDemo

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = WDPRLocalizedStringInBundle(@"com.wdprcore.dynamictext.title", WDPRCoreResourceBundleName, nil);
    
    MAKE_WEAK(self);
    [self observeNotificationName:
     UIContentSizeCategoryDidChangeNotification object:nil 
                            queue:NSOperationQueue.mainQueue 
                       usingBlock:^(NSNotification *note) 
     {
         executeOnNextRunLoop
         (^{ 
             MAKE_STRONG(self);
             [strongself reloadItems]; 
         });
     }];
    
    self.dataDelegate.iOS6StyleGroupBubbles = YES;
    self.dataDelegate.accessoryType = UITableViewCellAccessoryNone;
    self.dataDelegate.cellStyle = WDPRTableCellStyleSubtitleRightOfImage;
    self.dataDelegate.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSArray*)initialData
{
    NSMutableArray* initialData = [NSMutableArray new];
    
    for (NSString* textStyle in 
         @[UIFontTextStyleHeadline, UIFontTextStyleBody, 
           UIFontTextStyleSubheadline, UIFontTextStyleFootnote, 
           UIFontTextStyleCaption1, UIFontTextStyleCaption2])
    {
        UIFont* font = [UIFont preferredFontForTextStyle:textStyle];
        
        [initialData addObject:
         @{
                 WDPRCellTitle : [NSAttributedString
                           string:textStyle 
                           attributes:@{ NSFontAttributeName : font }],

                 WDPRCellDetail : [NSString stringWithFormat:
                            @"%@ %d", font.fontName, (int)font.pointSize],
           }];
    }
    
    return @[@{
            WDPRTableSectionHeader :
                     htmlify(WDPRLocalizedStringInBundle(@"com.wdprcore.dynamictext.header.message", WDPRCoreResourceBundleName, nil), NO),
            WDPRTableSectionItems : initialData.copy
                 }];
}

@end
