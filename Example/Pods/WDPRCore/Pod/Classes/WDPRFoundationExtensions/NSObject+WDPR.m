//
//  NSObject+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 7/30/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <objc/runtime.h>
#import "WDPRFoundation.h"

#define Key "WDPRObjectBlock"

#pragma mark -

@interface DeallocBlock : PlainBlockWrapper

@end

#pragma mark -

@implementation DeallocBlock

- (void)dealloc
{
    [self executeBlock];
}

@end // @implementation DeallocBlock

#pragma mark -

@implementation PlainBlockWrapper

- (void)executeBlock
{
    self.block();
}

+ (instancetype)wrapBlock:(PlainBlock)block
{
    NSAssert(block != nil, @"non-nil block required");
    PlainBlockWrapper* wrapper = [self new];
    wrapper.block = block;
    return wrapper;
}

@end

#pragma mark -

@implementation NSObject (WDPR)

- (BOOL)isA:(Class)type
{
    return [self isKindOfClass:type];
}

- (void)debugDeallocation
{
    [self debugDeallocation:nil];
}

- (void)debugDeallocation:(NSString *)name
{
    name = (name ?: NSStringFromClass(self.class));
    
    [self addDeallocBlock:
     ^{
         WDPRLog(@"%@ has been dealloc'd", name);
     }];
}

- (void)addDeallocBlock:(void (^)(void))newBlock
{
    if (newBlock)
    {
        NSMutableArray* blocks =
        objc_getAssociatedObject(self, Key);
        
        if (!blocks)
        {
            blocks = [NSMutableArray new];
            
            objc_setAssociatedObject(self, Key, blocks,
                                     OBJC_ASSOCIATION_RETAIN);
        }
        
        [blocks addObject:[DeallocBlock wrapBlock:newBlock]];
    }
}

- (void)observeNotificationName:(NSString *)name 
                         object:(id)obj queue:(NSOperationQueue *)queue 
                     usingBlock:(void (^)(NSNotification *note))block
{
    id notificationToken =
    [NSNotificationCenter.defaultCenter 
     addObserverForName:name object:obj queue:queue usingBlock:block];
    
    [self addDeallocBlock:
     ^{ 
         [NSNotificationCenter.defaultCenter removeObserver:notificationToken]; 
     }];
}

#pragma mark - KVC & Object Subscripting

- (id)objectForKeyPath:(NSString*)keyPath
{
    id result;
    
    for (NSString* component in 
         [keyPath componentsSeparatedByString:@"."])
    {
        NSUInteger index = NSNotFound;
        NSString* intermediateKey = component;
        NSRange arraySubscript = [component rangeOfString:@"["];
        
        if (arraySubscript.location != NSNotFound)
        {
            intermediateKey = [component 
                               substringToIndex:
                               arraySubscript.location];
            
            index = [component 
                     substringFromIndex:
                     arraySubscript.location+1].intValue;
        }
        
        result = (result ? result[intermediateKey] :
                  [self respondsToSelector:
                   NSSelectorFromString(intermediateKey)] ? 
                  [self valueForKey:intermediateKey] : nil);
        
        // array indexing for component
        if (index != NSNotFound)
        {
            if ([result isKindOfClass:NSArray.class])
            {
                if (index < [result count])
                {
                    result = result[index];
                }   
                else
                {
                    result = nil;
                    WDPRLog(@"index out of bounds");
                }
            }
            else
            {
                result = nil;
                WDPRLog(@"array index for non-array component");
            }
        }
        
        if (!result) break;
    }
    
    return result;
}
    
- (id)objectForKeyedSubscript:(NSString*)keyPath
{
    id result;
    
    if ([self respondsToSelector:
         NSSelectorFromString(keyPath)])
    {
        result = [self valueForKey:keyPath];
    }
    else if ([keyPath hasSubstring:@"."])
    {
        result = [self objectForKeyPath:keyPath];
     }
    
    if (!result)
    {
        result = objc_getAssociatedObject
        (self, [keyPath cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    
    return result;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //WDPRLog(@"unsupported setValue key: %@", key);
    
    const char *keyString = 
    [key cStringUsingEncoding:NSASCIIStringEncoding];
    
    objc_setAssociatedObject(self, keyString, 
                             value, OBJC_ASSOCIATION_RETAIN);
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString*)key
{
    #if 1
    // uses setValue:forUndefinedKey:
    [self setValue:obj forKey:key];
    #else
    // Make sure it can respond to the setter to avoid throwing an exception
    NSString *setter = [NSString stringWithFormat:@"set%@:", 
                        [[[key substringToIndex:1] capitalizedString] 
                         stringByAppendingString:[key substringFromIndex:1]]];
    
    if ([self respondsToSelector:NSSelectorFromString(setter)])
    {
        [self setValue:obj forKey:key];
    }
    #endif
}

- (NSDictionary *) wdpr_description
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    id LenderClass = objc_getClass([NSStringFromClass([self class]) UTF8String]);
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(LenderClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        id ojb = [self valueForKey:[NSString stringWithUTF8String:property_getName(property)]];
        id keyOjb = [NSString stringWithFormat:@"%s",property_getName(property)];
        if(ojb && keyOjb) [dict setObject:ojb forKey:keyOjb];
        
    }
    return     @{@"_CLASS_NAME_" : NSStringFromClass([self class]),
                 @"_VALUES_"      : dict};
}

- (NSString *)formattedDescription
{
    return self.description;
}

+ (NSArray *)classMethods
{
    NSMutableArray *classMethods = [[NSMutableArray alloc] init];

    unsigned int methodCount;

    Method *methods = class_copyMethodList(object_getClass([self class]), &methodCount);

    for (int i = 0; i < methodCount; i++)
    {
        [classMethods addObject:NSStringFromSelector(method_getName(methods[i]))];
    }

    return classMethods.copy;
}

+ (instancetype)safeCast:(NSObject *)obj
{
    return [obj isKindOfClass:[self class]] ? obj : nil;
}

+ (instancetype)nullify:(NSObject *)obj
{
    return obj ? obj : [[self class] new];
}

- (id)deepCopy
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:
                   [NSKeyedArchiver archivedDataWithRootObject:self]];
}

@end
