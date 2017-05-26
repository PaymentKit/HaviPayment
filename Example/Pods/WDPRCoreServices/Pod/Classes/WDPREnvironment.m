//
// Created by Clark, Daniel on 7/20/15.
//

#import "WDPREnvironment.h"
#import "WDPRServices.h"
#import "WDPRCoreServicesConfiguration.h"

static NSString * const kCoreServicesPrefix = @"coreserviceskey_";

@implementation WDPREnvironment

- (NSString *) name
{
    NSString *name = [NSUserDefaults.
            standardUserDefaults
            stringForKey:WDPRChosenEnvironment];

    return (name.length ? name :
            [NSBundle.mainBundle
                    objectForInfoDictionaryKey:
                            WDPRChosenEnvironment] ?: WDPRDefaultEnvironment);
}

- (NSDictionary *) details
{
    NSDictionary *details = WDPRServices.configData[WDPRDefaultEnvironment];

    if (![self.name isEqualToString:WDPRDefaultEnvironment])
    {
        details = details.mutableCopy;

        [(NSMutableDictionary *) details addEntriesFromDictionary:WDPRServices.configData[self.name]];
    }

    return details;
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value
                                              forKey:[kCoreServicesPrefix stringByAppendingString:key]];
}

- (id) valueForKey:(NSString *)key
{
    id modifiedValue = ([[NSUserDefaults standardUserDefaults] objectForKey:
                         [kCoreServicesPrefix stringByAppendingString:key]]);
    
    if (modifiedValue)
    {
        return modifiedValue;
    }
    
    id val = [WDPRCoreServicesConfiguration configValueForKey:key];
    
    return val;
}

- (id) objectForKeyedSubscript:(NSString *)key
{
    return [self valueForKey:key
                  withTokens:nil];
}

- (BOOL) useSoftLaunchEnvironment
{
    return self.class.useSoftLaunchEnvironment;
}

+ (BOOL) useSoftLaunchEnvironment
{
    return [NSUserDefaults.standardUserDefaults
            boolForKey:kServiceUsesSoftlaunchKey];
}

- (id)valueForKey:(NSString *)key withTokens:(NSDictionary *)args
{
    return [self valueForKey:key withTokens:args removePlaceholders:YES];
}

- (id)valueForKey:(NSString *)key withTokens:(NSDictionary *)args removePlaceholders:(BOOL)removePlaceholders
{
    NSString *path = [self valueForKey:key];
    return [self valueForPath:path withTokens:args removePlaceholders:removePlaceholders];
}

- (id)valueForPath:(NSString *)path withTokens:(NSDictionary *)args
{
    return [self valueForPath:path withTokens:args removePlaceholders:YES];
}

- (id)valueForPath:(NSString*)path withTokens:(NSDictionary *)args removePlaceholders:(BOOL)removePlaceholders
{
    // substitute args for placeholders in path
    for (NSString *token in args.allKeys)
    {
        NSString *placeholder = [NSString stringWithFormat:@"{%@}", token];
        NSString *substitution = [NSString stringWithFormat:@"%@", args[token]];
        path = [path stringByReplacingOccurrencesOfString:placeholder
                                               withString:substitution];
    }

    // now remove placeholders for which no arg was provided
    while (removePlaceholders)
    {
        NSRange leadingBrace = [path rangeOfString:@"{"];
        NSRange trailingBrace = [path rangeOfString:@"}"];

        if (!leadingBrace.length || !trailingBrace.length)
        {
            break;
        }

        NSRange fullPlaceholder = NSMakeRange(
                leadingBrace.location,
                trailingBrace.length - leadingBrace.location + trailingBrace.location);

        NSRange placeholderString =
                NSMakeRange(leadingBrace.length + leadingBrace.location,
                            trailingBrace.location +
                                    -(leadingBrace.length + leadingBrace.location));

        // look for another environment variable that matches the placeholder
        NSString *substitution =
                [self valueForKey:[path substringWithRange:placeholderString]];

        if (!substitution.length)
        {
            path = path.mutableCopy;
            [(NSMutableString *) path deleteCharactersInRange:fullPlaceholder];
        }
        else
        {
            path = [path stringByReplacingCharactersInRange:fullPlaceholder
                                                 withString:substitution];
        }

        // eliminate any argument separators that got pushed together by above
        // change
        // path = [path stringByReplacingOccurrencesOfString:@"?&" withString:@"?"];
        //  path = [path stringByReplacingOccurrencesOfString:@"&&" withString:@"&"];
    }

    // additional cleanup of above changes
    if ([path hasSuffix:@"&"])
    {
        path = [path substringToIndex:path.length - 1];
    }

    if ([path hasSuffix:@"?"])
    {
        path = [path substringToIndex:path.length - 1];
    }

    return path;
}

- (NSURL *) urlForService:(NSString *)service withTokens:(NSDictionary *)args
{
    // now assemble the final url
    NSString *path = [self valueForKey:service
                            withTokens:args];
    NSURL *url = [NSURL URLWithString:path];

    if (!url.host.length)
    {
        url = [NSURL
                URLWithString:path
                relativeToURL:[NSURL URLWithString:self.details[WDPRServicesHost]]];

        url = url.absoluteURL;
        path = url.absoluteString;
    }

    if (!url.scheme.length)
    {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:path]];
    }

    return url;
}

@end  // @implementation WDPREnvironment