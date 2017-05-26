//
//  NSBundle+WDPR.h
//  Pods
//
//  Created by Delafuente, Rob on 6/23/15.
//
//

#import <Foundation/Foundation.h>

@interface NSBundle (WDPR)

/**
* Checks the Main bundle for a bundle with the given name
* @param bundleName The name of the bundle to find in the main bundle
* @returns The found bundle or nil
*/
+ (NSBundle *) bundleWithName:(NSString *)bundleName;

/**
* Checks for a framework with the given name and then looks inside the
* framework bundle for the given bundle name
* @param frameworkName The name of the framework to find in the privateFrameworks path
* @param bundleName The name of the bundle to find in the framework bundle
* @returns The found bundle or nil
*/
+ (NSBundle *) bundleFromFramework:(NSString *)frameworkName bundleName:(NSString *)bundleName;

/**
* Checks for a framework with the given name and then looks inside the
* framework bundle for the given bundle name if it is not there checks the main bundle
* @param frameworkName The name of the framework to find in the privateFrameworks path
* @param bundleName The name of the bundle to find in the framework bundle
* @returns The found bundle or nil
*/
+ (NSBundle *) bundleFromMainBundleOrFramework:(NSString *)frameworkName bundleName:(NSString *)bundleName;

/**
* Gets either the mainBundle or the framework bundle if it exists with the given name
* @param frameworkName The name of the framework to find in the privateFrameworks path
* @returns The framework bundle or the mainBundle
*/
+ (NSBundle *) mainBundleOrFrameworkBundle:(NSString *)frameworkName;

/**
 * Finds the bundle that contains the named resource with that type. It will look in all framework bundles
 * and look for a bundle in the framework as well that is the same name as the framework name.
 * @param resourceName The name of the resource to find
 * @param type The type of the resource to find such as 'plist','json','storyboardc', etc...
 * @returns The containing bundle or nil
 */
+ (id) findBundleWithResource:(NSString *)resourceName ofType:(NSString *)type;
@end
