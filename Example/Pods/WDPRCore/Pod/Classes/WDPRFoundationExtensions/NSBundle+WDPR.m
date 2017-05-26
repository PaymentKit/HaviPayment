//
//  NSBundle+WDPR.m
//  Pods
//
//  Created by Delafuente, Rob on 6/23/15.
//
//

#import "NSBundle+WDPR.h"

@implementation NSBundle (WDPR)

+ (NSBundle *)bundleFromMainBundleOrFramework:(NSString *)frameworkName bundleName:(NSString *)bundleName
{
    NSBundle *bundle = [NSBundle bundleFromFramework:frameworkName
                                          bundleName:bundleName];
    if (!bundle)
    {
        bundle = [NSBundle bundleWithName:bundleName];
    }
    return bundle;
}

+ (NSBundle *)mainBundleOrFrameworkBundle:(NSString *)frameworkName
{
    NSBundle *bundle = [self mainBundle];
    if (frameworkName)
    {
        for(NSBundle * frameworkBundle in [NSBundle allFrameworks])
        {
            if ([frameworkBundle.bundleIdentifier hasSuffix:frameworkName])
            {
                bundle = frameworkBundle;
                break;
            }
        }
    }
    return bundle;
}

+ (NSBundle *)bundleWithName:(NSString *)bundleName
{
    NSBundle *bundle;
    
    if (bundleName)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName
                                                               ofType:@"bundle"];
        bundle =  [NSBundle bundleWithPath:bundlePath];
    }

    return bundle;
}

+ (NSBundle *)bundleFromFramework:(NSString *)frameworkName bundleName:(NSString *)bundleName
{
    NSBundle *bundle;

    if (frameworkName)
    {
        NSBundle *foundFrameworkBundle;
        for (NSBundle * frameworkBundle in [NSBundle allFrameworks])
        {
            if ([frameworkBundle.bundleIdentifier hasSuffix:frameworkName])
            {
                foundFrameworkBundle = frameworkBundle;
                break;
            }
        }

        if (foundFrameworkBundle)
        {
            NSString *innerBundlePath = [foundFrameworkBundle pathForResource:bundleName
                                                                       ofType:@"bundle"];
            bundle = [NSBundle bundleWithPath:innerBundlePath];
        }
        else
        {
            // Try to get it from the identifier
            bundle = [NSBundle bundleWithIdentifier:[NSString stringWithFormat:@"org.cocoapods.%@",bundleName]];
        }
    }

    return bundle;
}

+ (id)findBundleWithResource:(NSString *)resourceName ofType:(NSString *)type
{
    for (NSBundle *frameworkBundle in [NSBundle allFrameworks])
    {
        // Check Framework bundle itself for the resource
        id item = [frameworkBundle pathForResource:resourceName
                                            ofType:type];
        if (item)
        {
            return frameworkBundle;
        }
        else // Check to see if there is bundle named after the framework inside and then check it for the resource
        {
            NSString *innerBundleName = [[frameworkBundle.bundleIdentifier componentsSeparatedByString:@"."] lastObject];
            NSString *innerBundlePath = [frameworkBundle pathForResource:innerBundleName
                                                                  ofType:@"bundle"];
            NSBundle *innerBundle = [NSBundle bundleWithPath:innerBundlePath];
            
            // Check the inner bundle for the resource
            item = [innerBundle pathForResource:resourceName
                                         ofType:type];
            if (item)
            {
                return innerBundle;
            }
        }
    }
    
    // Finally check the main bundle for the resource
    NSBundle *bundle = [self mainBundle];
    if ([bundle pathForResource:resourceName ofType:type])
    {
        return bundle;
    }
    return nil;
}

@end
