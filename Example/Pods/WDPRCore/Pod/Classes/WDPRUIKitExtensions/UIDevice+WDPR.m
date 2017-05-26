//
//  UIDevice+WDPR.m
//  DLR
//
//  Created by Delafuente, Rob on 5/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "UIDevice+WDPR.h"
#import <sys/sysctl.h>

static const char kHWMachine[] = "hw.machine";

@implementation UIDevice (WDPR)

- (NSString *)deviceProductName
{
    return [self deviceProductNameWithDeviceId:[self systemInfoWithSpecifier:kHWMachine]];
}

- (NSString *)systemInfoWithSpecifier:(const char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = alloca(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    return results;
}

- (BOOL)isIphone6Plus
{
    NSString *deviceId = [self systemInfoWithSpecifier:kHWMachine];

    return [deviceId isEqualToString:@"iPhone7,1"];
}

- (BOOL)isIphone6
{
    NSString *deviceId = [self systemInfoWithSpecifier:kHWMachine];
    
    return [deviceId isEqualToString:@"iPhone7,2"];
}

- (BOOL)isIphone6SPlus
{
    NSString *deviceId = [self systemInfoWithSpecifier:kHWMachine];
    
    return [deviceId isEqualToString:@"iPhone8,2"];
}

- (BOOL)isIphone5Series
{
    NSString *deviceId = [self systemInfoWithSpecifier:kHWMachine];
    
    return  [deviceId rangeOfString:@"iPhone5"].location != NSNotFound ||
            [deviceId rangeOfString:@"iPhone6"].location != NSNotFound;
}

- (NSString *)deviceProductNameWithDeviceId:(NSString *)deviceId
{
    return (@{ @"iPhone1,1" : @"iPhone 1G" ,
               @"iPhone1,2" : @"iPhone 3G" ,
               @"iPhone2,1" : @"iPhone 3GS" ,
               @"iPhone3,1" : @"iPhone 4" ,
               @"iPhone3,3" : @"Verizon iPhone 4" ,
               @"iPhone4,1" : @"iPhone 4S" ,
               @"iPhone5,1" : @"iPhone 5 (GSM)" ,
               @"iPhone5,2" : @"iPhone 5 (GSM+CDMA)" ,
               @"iPhone5,3" : @"iPhone 5c (GSM)" ,
               @"iPhone5,4" : @"iPhone 5c (GSM+CDMA)" ,
               @"iPhone6,1" : @"iPhone 5s (GSM)" ,
               @"iPhone6,2" : @"iPhone 5s (GSM+CDMA)" ,
               @"iPhone7,2" : @"iPhone 6" ,
               @"iPhone7,1" : @"iPhone 6 Plus" ,
               @"iPhone8,1" : @"iPhone 6s",
               @"iPhone8,2" : @"iPhone 6s Plus",
               @"iPhone8,4" : @"iPhone SE",
               @"iPhone9,1" : @"iPhone 7 (CDMA)",
               @"iPhone9,2" : @"iPhone 7 Plus (CDMA)",
               @"iPhone9,3" : @"iPhone 7 (GSM)",
               @"iPhone9,4" : @"iPhone 7 Plus (GSM)",
               @"iPod1,1" : @"iPod Touch 1G" ,
               @"iPod2,1" : @"iPod Touch 2G" ,
               @"iPod3,1" : @"iPod Touch 3G" ,
               @"iPod4,1" : @"iPod Touch 4G" ,
               @"iPod5,1" : @"iPod Touch 5G" ,
               @"iPad1,1" : @"iPad",
               @"iPad2,1" : @"iPad 2 WiFi",
               @"iPad2,2" : @"iPad 2 GSM",
               @"iPad2,3" : @"iPad 2 CDMA",
               @"iPad2,4" : @"iPad 2 CDMAS",
               @"iPad2,5" : @"iPad Mini Wifi",
               @"iPad2,6" : @"iPad mini (Cellular ATT)",
               @"iPad2,7" : @"iPad mini (Cellular Verizon)",
               @"iPad3,1" : @"iPad 3 WiFi",
               @"iPad3,2" : @"iPad 3 CDMA",
               @"iPad3,3" : @"iPad 3 GSM",
               @"iPad3,4" : @"iPad 4 Wifi",
               @"iPad3,5" : @"iPad 3 (Cellular ATT)",
               @"iPad3,6" : @"iPad 3 (Cellular Verizon)",
               @"iPad4,1" : @"iPad 4 WiFi",
               @"iPad4,2" : @"iPad 4 GSM",
               @"iPad4,3" : @"iPad 4 CDMA",
               @"iPad4,4" : @"iPad mini 2 (WiFi)",
               @"iPad4,5" : @"iPad mini 2 (Cellular)",
               @"iPad4,6" : @"iPad mini 2 (Cellular CN)",
               @"iPad4,7" : @"iPad mini 3 (WiFi)",
               @"iPad4,8" : @"iPad mini 3 (Cellular)",
               @"iPad4,9" : @"iPad mini 3 (Cellular CN)",
               @"iPad5,1" : @"iPad mini 4 (WiFi)",
               @"iPad5,2" : @"iPad mini 4 (Cellular)",
               @"iPad5,3" : @"iPad 5 Wifi",
               @"iPad5,4" : @"iPad 5 GSM",
               @"iPad6,3" : @"iPad Pro 9.7-inch (WiFi)",
               @"iPad6,4" : @"iPad Pro 9.7-inch (Cellular)",
               @"iPad6,7" : @"iPad Pro 12.9-inch (WiFi)",
               @"iPad6,8" : @"iPad Pro 12.9-inch (Cellular)",
               @"i386" : @"Simulator" ,
               @"x86_64" : @"Simulator"}[deviceId]) ?: @"Unknown Device";
}
@end
