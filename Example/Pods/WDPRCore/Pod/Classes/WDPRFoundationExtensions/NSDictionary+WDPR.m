//
//  NSDictionary+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 8/6/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"


@implementation NSDictionary (WDPR)

#pragma mark - Public Methods

+ (NSDictionary*)dictionaryFromPList:(NSString*)file
{
    NSDictionary *dictionaryResult;
    
#ifndef BUILDPHASECODE
    
    dictionaryResult = [self dictionaryDirectFromDataBundle:file];
    
    if (dictionaryResult)
    {
        NSDictionary *mainBundlePlist = [self dictionaryDirectFromMainBundle:file];
        
        if (mainBundlePlist)
        {
            dictionaryResult = [self recursiveDictionaryMerge:mainBundlePlist
                                                lowPrecedence:dictionaryResult];
        }
    }
    else
    {
        dictionaryResult = [self dictionaryDirectFromMainBundle:file];
    }

#else
    NSString *finalPath = [NSFileManager.
                           defaultManager.
                           currentDirectoryPath
                           stringByAppendingPathComponent:
                           [file stringByAppendingPathExtension:@"plist"]];
    dictionaryResult = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
#endif
    
    return dictionaryResult;
}

+ (NSDictionary*)dictionaryFromPList:(NSString *)file inBundleNamed:(NSString*)bundleName
{
    NSDictionary *dictionaryResult;
    
#ifndef BUILDPHASECODE
    
    /*
     When dictionaryDirectFromPlist:inBundle: is made private, return to this functionality.
     dictionaryResult = [self dictionaryDirectFromPlist:file
     inBundle:bundleName];*/ 
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *finalPath = [bundle pathForResource:file ofType:@"plist"];
    
    dictionaryResult = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    if (dictionaryResult)
    {
        NSDictionary *appPlist = [self dictionaryFromPList:file];
        
        if (appPlist)
        {
            dictionaryResult = [self recursiveDictionaryMerge:appPlist
                                                lowPrecedence:dictionaryResult];
        }
    }
    else
    {
        dictionaryResult = [self dictionaryFromPList:file];
    }
    
#else
    dictionaryResult = [self dictionaryFromPList:file];
    
#endif
    
    return dictionaryResult;
}

+ (NSDictionary*)dictionaryFromPList:(NSString *)file inBundle:(NSBundle *)bundle
{
    return [self dictionaryFromPList:file inBundle:bundle allowNewKeys:NO];
}

+ (NSDictionary*)dictionaryFromPList:(NSString *)file inBundle:(NSBundle *)bundle allowNewKeys:(BOOL)allowNewKeys
{
    NSDictionary *dictionaryResult = [self dictionaryDirectFromPlist:file inBundle:bundle];
    
    if (dictionaryResult)
    {
        NSDictionary *appPlist = [self dictionaryFromPList:file];
        
        if (appPlist)
        {
            dictionaryResult = [self recursiveDictionaryMerge:appPlist
                                                lowPrecedence:dictionaryResult
                                                 allowNewKeys:allowNewKeys];
        }
    }
    else
    {
        dictionaryResult = [self dictionaryFromPList:file];
    }
    
    return dictionaryResult;
}

+ (NSDictionary*)transform:(NSDictionary*)source withMappingPlist:(NSString*)file
{
    return [self transform:source
     withMappingDictionary:[self dictionaryFromPList:file]];
}

+ (NSDictionary*)transform:(NSDictionary*)source
     withMappingDictionary:(NSDictionary*)mapping
{
    NSMutableDictionary* result = [NSMutableDictionary new];

    [mapping enumerateKeysAndObjectsUsingBlock:
                     ^(NSString* key, NSString* keyPath, BOOL *stop)
                     {
                         result[key] = [source objectForKeyPath:keyPath] ?: @"";
                     }];

    return result.copy;
}

- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint
{
    NSError *error;
    NSJSONWritingOptions options = (prettyPrint ? NSJSONWritingPrettyPrinted : 0);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:options
                                                         error:&error];

    if (!jsonData)
    {
        WDPRLog(@"jsonStringWithPrettyPrint => error: %@", error.localizedDescription);
        return @"{}";
    }
    else
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

#pragma mark - Private Methods

+ (NSDictionary *)dictionaryDirectFromPlist:(NSString *)file inBundleNamed:(NSString*)bundleName
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName
                                                           ofType:@"bundle"];
    NSString *finalPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:file
                                                                         ofType:@"plist"];

    return [[NSDictionary alloc] initWithContentsOfFile:finalPath];
}

+ (NSDictionary *)dictionaryDirectFromPlist:(NSString *)file inBundle:(NSBundle *)bundle
{
    NSString *finalPath = [bundle pathForResource:file
                                           ofType:@"plist"];

    return [[NSDictionary alloc] initWithContentsOfFile:finalPath];
}

+ (NSDictionary *)dictionaryDirectFromMainBundle:(NSString *)file
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file
                                                         ofType:@"plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:filePath];
}

+ (NSDictionary *)dictionaryDirectFromDataBundle:(NSString *)file
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:file
                                                       ofType:@"plist"
                                                  inDirectory:@"Data.bundle"];
    
    return [[NSDictionary alloc] initWithContentsOfFile:filePath];
}

+ (NSDictionary *)recursiveDictionaryMerge:(NSDictionary *)highPrecedenceDict
                             lowPrecedence:(NSDictionary *)lowPrecedenceDict
{
    return [self recursiveDictionaryMerge:highPrecedenceDict lowPrecedence:lowPrecedenceDict allowNewKeys:NO];
}

+ (NSDictionary *)recursiveDictionaryMerge:(NSDictionary *)highPrecedenceDict
                             lowPrecedence:(NSDictionary *)lowPrecedenceDict
                              allowNewKeys:(BOOL)allowNewKeys
{
    NSMutableDictionary *dictionaryResult = [lowPrecedenceDict mutableCopy];
    
    for (id key in [lowPrecedenceDict allKeys])
    {
        id entry = highPrecedenceDict[key];
        id lowPrecendenceEntry = lowPrecedenceDict[key];
        
        if (entry)
        {
            if ([entry isA:[NSDictionary class]] &&
                [lowPrecendenceEntry isA:[NSDictionary class]])
            {
                NSDictionary *dict = [self recursiveDictionaryMerge:entry
                                                      lowPrecedence:lowPrecendenceEntry
                                                       allowNewKeys:allowNewKeys];
                dictionaryResult[key] = dict;
            }
            else
            {
                dictionaryResult[key] = [entry deepCopy];
            }
        }
    }
    
    if (allowNewKeys)
    {
        for (id key in [highPrecedenceDict allKeys])
        {
            if (!lowPrecedenceDict[key])
            {
                id highPrecedenceEntry = highPrecedenceDict[key];
                dictionaryResult[key] = [highPrecedenceEntry deepCopy];
            }
        }
    }
    
    return dictionaryResult;
}

+ (NSDictionary *)readDictionaryFromJSONFile:(NSString *)path
{
    NSDictionary *resultingDictionary = [NSDictionary new];
    
    NSString *jsonPath = [NSSearchPathForDirectoriesInDomains
            (NSCachesDirectory, NSUserDomainMask, YES)[0]
            stringByAppendingPathComponent:path];
    
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    
    if (data)
    {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data
                                                  options:kNilOptions
                                                    error:&error];
        if (json)
        {
            resultingDictionary = json;
        }
        else if (error)
        {
            WDPRLog(@"Error reading file: %@", error);
            resultingDictionary = nil;
        }
    }
    else
    {
        resultingDictionary = nil;
    }
    
    return resultingDictionary;
}

- (void)writeDictionaryToJSONFile:(NSString *)path
{
    @synchronized(self)
    {
        NSError *error = nil;
        Require(self, NSDictionary);
        NSString *jsonPath = [NSSearchPathForDirectoriesInDomains
                (NSCachesDirectory, NSUserDomainMask, YES)[0]
                stringByAppendingPathComponent:path];
        
        // Attempt to erase the file
        if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:jsonPath error:&error];
            
            if (error)
            {
                WDPRLog(@"Unable to read from file %@", error);
            }
        }
        
        // Create the file
        [[NSFileManager defaultManager] createFileAtPath:jsonPath contents:nil attributes:nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        
        if (error)
        {
            WDPRLog(@"Error: %@", error);
        }
        
        // Save the file
        [jsonData writeToFile:jsonPath atomically:NO];
    }
}

@end

#pragma mark -

@implementation NSMutableDictionary (WDPR)

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    @synchronized (self)
    {
        if (key)
        {
            if (obj)
            {
                [self setObject:obj
                         forKey:key];
            }
            else
            {
                [self removeObjectForKey:key];
            }
        }
    }
}

@end
