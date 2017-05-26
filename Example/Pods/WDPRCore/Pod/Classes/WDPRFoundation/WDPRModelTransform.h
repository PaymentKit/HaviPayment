//
//  WDPRModelTransform.h
//  Pods
//
//  Created by J.Rodden on 10/21/15.
//
//

#import <Foundation/Foundation.h>

/// Utility class for applying a small set of changes to a (model) class.
/// This is particularly handy when used with WDPRDataSource to modify
/// or add some properties to an object, simply as part of presentation.
///
/// When an instance is used in place of the ObjectType, properties 
/// accessed via subscript notation (foo[property]) will be taken first
/// from the transform dictionary, and only if not found there, from the
/// original transformedObject.

@interface WDPRModelTransform<ObjectType> : NSObject

@property (nonatomic) ObjectType transformedObject;
@property (nonatomic, copy) NSDictionary<NSString*, id> *transform;

+ (instancetype)transform:(ObjectType)object 
                     with:(NSDictionary<NSString*, id>*)transform;
@end
