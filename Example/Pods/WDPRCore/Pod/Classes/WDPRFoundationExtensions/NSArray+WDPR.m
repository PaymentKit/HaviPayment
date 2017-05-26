//
//  NSArray+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 8/6/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"

@implementation NSArray (WDPR)



#if TARGET_OS_MAC
- (id)firstObject
{
    return self[0];
}
#endif

+ (NSArray*)arrayFromPList:(NSString*)file
{
    NSArray *arrayResult = [self arrayDirectFromMainBundle:file];
    
#ifndef BUILDPHASECODE
    if (!arrayResult)
    {
        arrayResult = [self arrayDirectFromDataBundle:file];
    }
#else
    NSString *finalPath = [NSFileManager.
                           defaultManager.
                           currentDirectoryPath
                           stringByAppendingPathComponent:
                           [file stringByAppendingPathExtension:@"plist"]];
    
    arrayResult = [[NSArray alloc] initWithContentsOfFile:finalPath];
#endif
    
    return arrayResult;
}

+ (NSArray*)arrayFromPList:(NSString *)file inBundleNamed:(NSString*)bundleName
{
    NSArray *arrayResult;

#ifndef BUILDPHASECODE
    arrayResult = ([self arrayDirectFromMainBundle:file] ?:
                   [self arrayDirectFromDataBundle:file] ?:
                   [self arrayDirectFromPlist:file inBundleNamed:bundleName]);
#else
    NSString *path = [NSString stringWithFormat:
                      @"%@.bundle/%@.plist", bundleName, file];
    NSString *finalPath = [NSFileManager.
                           defaultManager.currentDirectoryPath
                           stringByAppendingPathComponent:path];
    
    arrayResult = [[NSArray alloc] initWithContentsOfFile:finalPath];
#endif
    
    return arrayResult;
}

+ (NSArray*)arrayFromPList:(NSString *)file inBundle:(NSBundle *)bundle
{
    NSArray *arrayResult = [self arrayDirectFromMainBundle:file];
    
    if (!arrayResult)
    {
        arrayResult = [self arrayDirectFromDataBundle:file];
        
        if (!arrayResult)
        {
            arrayResult = [self arrayDirectFromPlist:file
                                            inBundle:bundle];
        }
    }

    return arrayResult;
}

#pragma mark - Private Methods

+ (NSArray *)arrayDirectFromMainBundle:(NSString *)file
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file
                                                         ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:filePath];
}

+ (NSArray *)arrayDirectFromDataBundle:(NSString *)file
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:file
                                                       ofType:@"plist"
                                                  inDirectory:@"Data.bundle"];
    
    return [[NSArray alloc] initWithContentsOfFile:filePath];
}

+ (NSArray *)arrayDirectFromPlist:(NSString *)file inBundleNamed:(NSString*)bundleName
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName
                                                           ofType:@"bundle"];
    NSString *finalPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:file
                                                                         ofType:@"plist"];
    
    return [[NSArray alloc] initWithContentsOfFile:finalPath];
}

+ (NSArray *)arrayDirectFromPlist:(NSString *)file inBundle:(NSBundle *)bundle
{
    NSString *finalPath = [bundle pathForResource:file
                                           ofType:@"plist"];
    
    return [[NSArray alloc] initWithContentsOfFile:finalPath];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return ((idx < self.count) ?
            [self objectAtIndex:idx] : nil);
}

- (NSArray *)subarrayFromIndex:(NSInteger)index
{
    if (self.count == 0 || index < 0 || index >= self.count )
    {
        return nil;
    }
    
    return [self subarrayWithRange:NSMakeRange(index, self.count - index)];
}

- (NSArray *)nonNullValuesForKeyPath:(NSString *)keyPath
{
    NSArray *values = [self valueForKeyPath:keyPath];
    
    return [values reject:^BOOL(id obj) {
        return [obj isKindOfClass:NSNull.class];
    }];
}

- (NSArray *)nonNullValuesForSelector:(SEL)selector
{
    return [self nonNullValuesForKeyPath:NSStringFromSelector(selector)];
}
@end

#pragma mark -

@implementation NSMutableArray (WDPR)

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    if (obj)
    {
        if (idx == self.count)
        {
            [self addObject:obj];
        }
        else if (idx < self.count)
        {
            [self replaceObjectAtIndex:idx withObject:obj];
        }
    }
}

@end
