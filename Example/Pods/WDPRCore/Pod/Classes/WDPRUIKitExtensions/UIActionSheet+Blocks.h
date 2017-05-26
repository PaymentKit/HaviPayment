#import "WDPRFoundation.h"

typedef void (^WDPRActionSheetBlock)(UIActionSheet *actionSheet);
typedef void (^WDPRActionSheetButtonBlock)(UIActionSheet *actionSheet, NSInteger index);

@interface UIActionSheet (Blocks)

@property (nonatomic, copy) WDPRActionSheetBlock onCancel;
@property (nonatomic, copy) WDPRActionSheetBlock onWillPresent;
@property (nonatomic, copy) WDPRActionSheetBlock onDidPresent;

@property (nonatomic, copy) WDPRActionSheetButtonBlock onClickedButton;
@property (nonatomic, copy) WDPRActionSheetButtonBlock onWillDismissWithButton;
@property (nonatomic, copy) WDPRActionSheetButtonBlock onDidDismissWithButton;


+ (instancetype)actionWithTitle:(NSString *)title
              cancelButtonTitle:(NSString *)cancelTitle
         destructiveButtonTitle:(NSString *)destructiveTitle
              otherButtonTitles:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;

@end
