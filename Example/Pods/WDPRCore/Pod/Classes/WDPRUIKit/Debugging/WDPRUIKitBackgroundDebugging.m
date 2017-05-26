//
//  WDPRUIKitBackgroundDebugging.m
//  DLR
//
//  Created by Jeremias Nuñez on 5/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//
// ==========================================================================================================
// Taken from the commercial iOS PDF framework http://pspdfkit.com.
// Copyright (c) 2014 Peter Steinberger, PSPDFKit GmbH. All rights reserved.
// Licensed under MIT (http://opensource.org/licenses/MIT)
//
// You should only use this in debug builds. It doesn't use private API, but I wouldn't ship it.
// ==========================================================================================================

// This class will trigger an assert everytime one of these methods is called in a background thread:
// setNeedsLayout, setNeedsDisplay, setNeedsDisplayInRect:
//
// These methods are called internally by a lot of UIKit methods at some point. This class
// should only be used in DEBUG builds
#if DEBUG

#import "WDPRLog.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

// Compile-time selector checks.
#define PROPERTY(propName) NSStringFromSelector(@selector(propName))

#define PSPDFAssert(expression, ...) \
do { if(!(expression)) { \
WDPRLog(@"%@", [NSString stringWithFormat: @"Assertion failure: %s in %s on line %s:%d. %@", #expression, __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:@"" __VA_ARGS__]]); \
abort(); }} while(0)

// http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html
BOOL PSPDFReplaceMethodWithBlock(Class c, SEL origSEL, SEL newSEL, id block)
{
    PSPDFAssert(c && origSEL && newSEL && block);
    if ([c instancesRespondToSelector:newSEL]) return YES; // Selector already implemented, skip silently.
    
    Method origMethod = class_getInstanceMethod(c, origSEL);
    
    // Add the new method.
    IMP impl = imp_implementationWithBlock(block);
    if (!class_addMethod(c, newSEL, impl, method_getTypeEncoding(origMethod)))
    {
        WDPRLogWarning(@"Failed to add method: %@ on %@", NSStringFromSelector(newSEL), c);
        return NO;
    }
    else
    {
        Method newMethod = class_getInstanceMethod(c, newSEL);
        
        // If original doesn't implement the method we want to swizzle, create it.
        if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(origMethod)))
        {
            class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(newMethod));
        }
        else
        {
            method_exchangeImplementations(origMethod, newMethod);
        }
    }
    
    return YES;
}

SEL _PSPDFPrefixedSelector(SEL selector)
{
    return NSSelectorFromString([NSString stringWithFormat:@"pspdf_%@", NSStringFromSelector(selector)]);
}

void PSPDFAssertIfNotMainThread(void)
{
    PSPDFAssert(NSThread.isMainThread, @"\nERROR: All calls to UIKit need to happen on the main thread. You have a bug in your code. Use dispatch_async(dispatch_get_main_queue(), ^{ ... }); if you're unsure what thread you're in.\n\nThe calling thread is: %@.\n\nStacktrace: %@", [NSThread currentThread], NSThread.callStackSymbols);
}

__attribute__((constructor)) static void PSPDFUIKitMainThreadGuard(void)
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"debugUIKitBackgroundThreadCalls"])
    {
        return;
    }
    
    @autoreleasepool
    {
        for (NSString *selStr in @[PROPERTY(setNeedsLayout), PROPERTY(setNeedsDisplay), PROPERTY(setNeedsDisplayInRect:)])
        {
            SEL selector = NSSelectorFromString(selStr);
            SEL newSelector = NSSelectorFromString([NSString stringWithFormat:@"pspdf_%@", selStr]);
            
            if ([selStr hasSuffix:@":"])
            {
                PSPDFReplaceMethodWithBlock(UIView.class,
                                            selector,
                                            newSelector,
                                            ^(__unsafe_unretained UIView *_self, CGRect r)
                                            {
                                                PSPDFAssertIfNotMainThread();
                                                ((void ( *)(id, SEL, CGRect))objc_msgSend)(_self, newSelector, r);
                                            });
            }
            else
            {
                PSPDFReplaceMethodWithBlock(UIView.class,
                                            selector,
                                            newSelector,
                                            ^(__unsafe_unretained UIView *_self)
                                            {
                                                if (!NSThread.isMainThread)
                                                {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                                                    dispatch_queue_t queue = dispatch_get_current_queue();
#pragma clang diagnostic pop
                                                    // iOS 8 layouts the MFMailComposeController in a background thread on an UIKit queue.
                                                    // https://github.com/PSPDFKit/PSPDFKit/issues/1423
                                                    if (!queue || !strstr(dispatch_queue_get_label(queue), "UIKit"))
                                                    {
                                                        PSPDFAssertIfNotMainThread();
                                                    }
                                                }
                                                ((void ( *)(id, SEL))objc_msgSend)(_self, newSelector);
                                            });
            }
        }
    }
}

#endif