//
//  WDPRTableDataDelegate+TextField.h
//  DLR
//
//  Created by german stabile on 3/9/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@interface WDPRTableDataDelegate (TextField) < UITextFieldDelegate >

- (void)tableView:(UITableView *)tableView addTextFieldToRowAtIndexPath:(NSIndexPath*)indexPath;

@end
