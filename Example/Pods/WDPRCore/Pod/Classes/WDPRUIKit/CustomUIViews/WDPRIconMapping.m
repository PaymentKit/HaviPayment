//
//  WDPRIconMapping.m
//  Pods
//
//  Created by Sergio Sanchez on 10/27/15.
//  Copyright © 2015 WDPRO. All rights reserved.
//

#import "WDPRIconMapping.h"
#import "WDPRFoundation.h"
#import "NSDictionary+WDPR.h"

@interface WDPRIconMapping ()

@property (nonatomic) NSDictionary *peptasiaIconsList;
@property (nonatomic) NSDictionary *mappingIconsList;

@end

@implementation WDPRIconMapping

#pragma mark - Initializers

- (instancetype)initPeptasiaIconsWithFileName:(NSString *)fileName
{
    return [self initPeptasiaIconsWithFileName:fileName language:nil];
}

- (instancetype)initPeptasiaIconsWithFileName:(NSString *)fileName language:(NSString *)language;
{
    self = [super init];
    if (self) {
        self.mappingIconsList = [NSDictionary dictionaryFromPList:fileName];
        if (language != nil)
        {
            self.mappingIconsList = self.mappingIconsList[language];
        }
        self.peptasiaIconsList = [NSDictionary dictionaryFromPList:@"WDPRPeptasiaIconsMapping" inBundle:[WDPRFoundation wdprCoreResourceBundle]];
    }
    
    return self;
}

#pragma mark - Getter

- (NSDictionary *)getIcons
{
    NSMutableDictionary *dictionaryPeptasia = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in self.mappingIconsList) {
        NSString *value = [self.mappingIconsList objectForKey:key];
        [dictionaryPeptasia setValue:[self.peptasiaIconsList objectForKey:value] forKey:key];
    }
    
    return dictionaryPeptasia;
}

@end
