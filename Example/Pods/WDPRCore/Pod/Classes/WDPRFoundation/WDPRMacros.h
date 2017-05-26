//
//  WDPRMacros.h
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !defined(__IPHONE_7_0) || !defined(__MAC_10_10)
#error "This project uses features only available in iOS SDK 7.0 or MacOS X 10.10 and later."
#endif

#define onExitFromScope(block) \
    __strong NSObject* exitBlock = [NSObject new]; \
    [exitBlock addDeallocBlock:block]

#define executeOnlyOnce(block) \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, block)

#pragma mark -

// use these macros to quickly define the getter and setter for a
// property that exposes a same-named property of a data member

#define PassthroughGetter(type, getter, delegate) \
- (type)getter { return [delegate getter]; }

#define PassthroughSetter(type, setter, delegate) \
- (void)setter:(type)value { [delegate setter:value]; }

#define PassthroughProperty(type, getter, setter, delegate) \
    PassthroughGetter(type, getter, delegate)               \
    PassthroughSetter(type, setter, delegate)

#define DictionaryGetter(type, getter, delegate) \
- (type*)getter { return SAFE_CAST(delegate[@""#getter], type); }

#define DictionaryPrimitiveGetter(type, getter, delegate) \
- (type)getter { return [SAFE_CAST(delegate[@""#getter], NSNumber) type##Value]; }

#define PassthroughDictionaryProperty(type, dictionary, getter, setter, key) \
- (type *)getter { return [dictionary objectForKey:key]; }                   \
                                                                             \
- (void)setter:(type *)s                                                     \
{                                                                            \
    if (s) { [dictionary setObject:s forKey:key];}                           \
    else { [dictionary removeObjectForKey:key]; }                            \
}                                                                            \

#pragma mark -

#define Require(data, type) \
    NSAssert([(data) isKindOfClass:type.class], @"precondition violation")

#define SAFE_CAST(x, type) (type *)([(x) isKindOfClass:type.class] ? (x) : nil)
#define SAFE_CALLBACK(block,...) if (block) { block(__VA_ARGS__); }

#define MAP_DEFINE_CONSTANT_ENTRY(x) @#x: @(x)
#define MAP_DEFINE_SECTION_ENTRY(x) @(x) : @#x

#define MAKE_WEAK(self) __weak typeof(self) weak##self = self
#define MAKE_STRONG(self) __strong typeof(weak##self) strong##self = weak##self

#pragma mark -

#define THIS_MUST_BE_IPAD_ONLY NSAssert(IS_IPAD, @"");
#define THIS_MUST_BE_IPHONE_ONLY NSAssert(IS_IPHONE, @"");

#define THIS_MUST_BE_IN_BACKGROUND NSAssert(!NSThread.isMainThread, @"");
#define THIS_MUST_BE_ON_MAIN_THREAD NSAssert(NSThread.isMainThread, @"");

#pragma mark -

// TODO: the following should move to a WDPRUIKit-specific macros header

#define IS_IPAD   ((BOOL)(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
#define IS_IPHONE ((BOOL)(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))

#define SCREEN_WIDTH (UIScreen.mainScreen.bounds.size.width)
#define SCREEN_HEIGHT (UIScreen.mainScreen.bounds.size.height)
#define SCREEN_FRAME CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

#define IS_PORTRAIT UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation)
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)

#define IS_35INCHSCREEN (UIScreen.mainScreen.bounds.size.height < 568) // hacky, but works
#define IS_VERSION_8_OR_LATER (UIDevice.currentDevice.systemVersion.integerValue >= 8)
#define IS_VERSION_10_OR_LATER (UIDevice.currentDevice.systemVersion.integerValue >= 10)

#pragma mark -
//recieves a property name, returns as a string the last component of the separation by '.'
#define propertyKeyPathLastComponent(property) [[(@""#property) componentsSeparatedByString:@"."] lastObject]

@interface WDPRMacros : NSObject

@end
