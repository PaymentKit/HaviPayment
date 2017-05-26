//
//  WDPRModelTransform.m
//  Pods
//
//  Created by J.Rodden on 10/21/15.
//
//

#import "WDPRModelTransform.h"

@implementation WDPRModelTransform

+ (id)transform:(id)object 
           with:(NSDictionary<NSString*, id>*)transform
{
    if (!transform || !transform.count)
    {
        return object;
    }
    
    WDPRModelTransform* transformer = [self new];
    
    transformer.transform = transform;
    transformer.transformedObject = object;
    
    return transformer;
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    return (self.transform[key] ?: 
            self.transformedObject[key]);
}

@end
