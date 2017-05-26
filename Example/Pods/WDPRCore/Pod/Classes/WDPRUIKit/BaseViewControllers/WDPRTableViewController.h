//
//  WDPRTableViewController.h
//  Pods
//
//  Note: This is a temporary class so that the tableviews
//  in WDPRTableViews can leverage the accessibility work
//  in WDPRViewController.  Ideally, the accessibility work
//  should be extracted in a common protocol so any view
//  controller can leverage the accessibility work.  The MDX
//  analytics work was not copied over because that is obsolete.
//
//  Created by Nguyen, Kevin on 4/19/17.
//
//

#import <UIKit/UIKit.h>

@interface WDPRTableViewController : UITableViewController

/// If not nil, Voice Over will use this property to announce the screen name
/// when accesing the screen
@property (nonatomic) NSString* screenNameToAnnounce;

/// Add a title to a view controller with a default format
/// DO NOT ADD YOUR OWN PROPERTY CALLED titleLabel!!!!
- (void)setTitleLabel:(NSString*)title;

@end
