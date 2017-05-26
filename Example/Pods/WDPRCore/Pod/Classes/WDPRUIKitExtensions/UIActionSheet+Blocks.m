#import "UIActionSheet+Blocks.h"
#import <objc/runtime.h>

#define ACTION_SHEET_BLOCK_PROPERTY(type, getter, setter)                                       \
- (type)getter                                                                                  \
{                                                                                               \
    return objc_getAssociatedObject(self, @selector(getter));									\
}                                                                                               \
                                                                                                \
- (void)setter:(type)block                                                                      \
{                                                                                               \
    self.delegate = [ActionSheetDelegate instance];                                             \
    objc_setAssociatedObject(self, @selector(getter), block, OBJC_ASSOCIATION_COPY_NONATOMIC);	\
}

@interface ActionSheetDelegate : NSObject <UIActionSheetDelegate>
+ (ActionSheetDelegate *)instance;
@end

@implementation UIActionSheet (Blocks)

ACTION_SHEET_BLOCK_PROPERTY(WDPRActionSheetBlock, onWillPresent, setOnWillPresent)
ACTION_SHEET_BLOCK_PROPERTY(WDPRActionSheetBlock, onDidPresent, setOnDidPresent)
ACTION_SHEET_BLOCK_PROPERTY(WDPRActionSheetBlock, onCancel, setOnCancel)
ACTION_SHEET_BLOCK_PROPERTY(WDPRActionSheetButtonBlock, onClickedButton, setOnClickedButton)
ACTION_SHEET_BLOCK_PROPERTY(WDPRActionSheetButtonBlock, onWillDismissWithButton, setOnWillDismissWithButton)
ACTION_SHEET_BLOCK_PROPERTY(WDPRActionSheetButtonBlock, onDidDismissWithButton, setOnDidDismissWithButton)

+ (instancetype)actionWithTitle:(NSString *)title
              cancelButtonTitle:(NSString *)cancelTitle
         destructiveButtonTitle:(NSString *)destructiveTitle
              otherButtonTitles:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION
{
    
    
    ActionSheetDelegate *delegate = [ActionSheetDelegate instance];
    UIActionSheet *actionSheet = [[self alloc] initWithTitle:title
                                                    delegate:delegate
                                           cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:destructiveTitle
                                           otherButtonTitles:nil];
    if (first)
    {
        [actionSheet addButtonWithTitle:first];
        va_list args;
        id eachObject;
        
        va_start(args, first);
        while ((eachObject = va_arg(args, id)))
        {
            if ([eachObject isKindOfClass:NSString.class])
            {
                [actionSheet addButtonWithTitle:eachObject];
            }
        }
        va_end(args);
    }
    return actionSheet;
}
@end

@implementation ActionSheetDelegate

+ (ActionSheetDelegate *)instance
{
    static dispatch_once_t onceToken;
    static ActionSheetDelegate *s_delegate;
    
    dispatch_once(&onceToken, ^{
         s_delegate = [self new];
    });

    return s_delegate;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    SAFE_CALLBACK(actionSheet.onCancel,actionSheet);
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    SAFE_CALLBACK(actionSheet.onWillPresent,actionSheet);
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    SAFE_CALLBACK(actionSheet.onDidPresent,actionSheet);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SAFE_CALLBACK(actionSheet.onClickedButton,actionSheet,buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    SAFE_CALLBACK(actionSheet.onWillDismissWithButton,actionSheet,buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    SAFE_CALLBACK(actionSheet.onDidDismissWithButton,actionSheet,buttonIndex);
}

@end
