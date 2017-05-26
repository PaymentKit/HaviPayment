//
//  WDPRUserDefaults.m
//  Pods
//
//  Created by Hart, Nick on 8/3/15.
//
//

#import "WDPRUserDefaults.h"
#import "NSDictionary+WDPR.h"

static NSString * const kWDPRUserDefaultsConfig = @"WDPRUserDefaults";
static NSString * const kPermanentStoreKeys = @"permanentStoreKeys";
static NSString * const kNoStoreKeys = @"noStoreKeys";

@interface WDPRUserDefaults ()
@property (nonatomic, strong) NSMutableDictionary *inMemoryCache;
@property (nonatomic, strong) NSSet *permanentStoreKeys;
@property (nonatomic, strong) NSSet *noStoreKeys;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@end

@implementation WDPRUserDefaults

#pragma mark - lifecycle methods

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

#pragma mark - internal methods

- (void)setup
{
    self.inMemoryCache = [NSMutableDictionary new];

    // initialize our permanent store and "no store" keys
    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:kWDPRUserDefaultsConfig withExtension:@"plist"];
    if (plistURL)
    {
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfURL:plistURL];
        if (dictionary)
        {
            self.permanentStoreKeys = [self setForKey:kPermanentStoreKeys fromDictionary:dictionary];
            self.noStoreKeys = [self setForKey:kNoStoreKeys fromDictionary:dictionary];
        }
    }
}

- (void)addPermanentStoreKeysFromPlist:(NSString *)plist
{
    NSDictionary *dictionary = [NSDictionary dictionaryFromPList:plist];
    if (dictionary)
    {
        NSSet *settingsKeys = [self setFromSettingsDictionary:dictionary];
        if (settingsKeys)
        {
            self.permanentStoreKeys = [settingsKeys setByAddingObjectsFromSet:self.permanentStoreKeys];
        }
    }
}

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

- (void)notifyChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSUserDefaultsDidChangeNotification object:self];
}

- (BOOL)isPermanentStoreKey:(NSString *)key
{
    return [self.permanentStoreKeys containsObject:key];
}

- (BOOL)isNoStoreKey:(NSString *)key
{
    return [self.noStoreKeys containsObject:key];
}

- (NSSet *)setForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary
{
    NSSet *result;
    NSArray *keys = [dictionary objectForKey:key];
    if ([keys isKindOfClass:[NSArray class]])
    {
        NSMutableSet *mutableSet = [NSMutableSet new];
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[NSString class]])
             {
                 [mutableSet addObject:obj];
             }
         }];
        result = mutableSet.count ? [mutableSet copy] : nil;
    }
    return result;
}

- (NSSet *)setFromSettingsDictionary:(NSDictionary *)dictionary
{
    NSMutableSet *mutableSet = [NSMutableSet new];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
            {
                if ([key isKindOfClass:[NSString class]])
                {
                    [mutableSet addObject:key];
                }
            }];
        }
    }];
    return mutableSet.count ? [mutableSet copy] : nil;
}

- (void)cacheSetObject:(id)object forKey:(NSString *)key
{
    @synchronized(self.inMemoryCache)
    {
        if (object)
        {
            [self.inMemoryCache setObject:object forKey:key];
        }
        else
        {
            // this is how NSUserDefaults behaves if the key is nil
            [self.inMemoryCache removeObjectForKey:key];
        }
    }
    [self notifyChanged];
}

- (id)cacheObjectForKey:(NSString *) key
{
    @synchronized(self.inMemoryCache)
    {
        return [self.inMemoryCache objectForKey:key];
    }
}

- (void)cacheRemoveObjectForKey:(NSString *)key
{
    @synchronized(self.inMemoryCache)
    {
        [self.inMemoryCache removeObjectForKey:key];
    }
    [self notifyChanged];
}

- (id)objectForKey:(NSString *)key requireClass:(Class)class
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:class])
    {
        return object;
    }
    return nil;
}

- (id)numberOrStringForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]])
    {
        return object;
    }
    return nil;
}

#pragma mark - NSUserDefaults overrides

- (void)setObject:(id)value forKey:(NSString *)key
{
    if ([self isPermanentStoreKey:key])
    {
        [self.userDefaults setObject:value forKey:key];
    }
    else if (![self isNoStoreKey:key])
    {
        [self cacheSetObject:value forKey:key];
    }
}

- (id)objectForKey:(NSString *)key
{
    id result;
    if ([self isPermanentStoreKey:key])
    {
        result = [self.userDefaults objectForKey:key];
    }
    else if (![self isNoStoreKey:key])
    {
        result = [self cacheObjectForKey:key];
    }
    return result;
}

- (void)removeObjectForKey:(NSString *)key
{
    if ([self isPermanentStoreKey:key])
    {
        [self.userDefaults removeObjectForKey:key];
    }
    else if (![self isNoStoreKey:key])
    {
        [self cacheRemoveObjectForKey:key];
    }
}

- (NSString *)stringForKey:(NSString *)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]])
    {
        return object;
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        return [object stringValue];
    }
    return nil;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    return [self objectForKey:key requireClass:[NSArray class]];
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    return [self objectForKey:key requireClass:[NSDictionary class]];
}

- (NSData *)dataForKey:(NSString *)key
{
    return [self objectForKey:key requireClass:[NSData class]];
}

- (NSArray *) stringArrayForKey:(NSString *)key
{
    NSArray *array = [self arrayForKey:key];
    for (id item in array)
    {
        if (![item isKindOfClass:[NSString class]])
        {
            return nil;
        }
    }
    return array;
}

- (NSInteger)integerForKey:(NSString *)key
{
    return [[self numberOrStringForKey:key] integerValue];
}

- (float)floatForKey:(NSString *)key
{
    return [[self numberOrStringForKey:key] floatValue];
}

- (double)doubleForKey:(NSString *)key
{
    return [[self numberOrStringForKey:key] doubleValue];
}

- (BOOL)boolForKey:(NSString *)key
{
    return [[self numberOrStringForKey:key] boolValue];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key
{
    [self setObject:@(value) forKey:key];
}

- (void)registerDefaults:(NSDictionary *)registrationDictionary
{
    // on a case-by-case basis decide if the key goes into NSUserDefaults or our in-memory cache
    [registrationDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self isPermanentStoreKey:key])
        {
            [self.userDefaults setObject:obj forKey:key];
        }
        else if (![self isNoStoreKey:key])
        {
            [self cacheSetObject:obj forKey:key];
        }
    }];
}

- (BOOL)synchronize
{
    return [self.userDefaults synchronize];
}

@end
