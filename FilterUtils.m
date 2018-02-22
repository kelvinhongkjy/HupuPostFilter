#include "FilterUtils.h"

@implementation FilterUtils

+ (NSRegularExpression *)regexFromPattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern 
        options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        return regex;
    } else {
        return nil;
    }
}

+ (BOOL)item:(NSDictionary *)item titleMatchesRegex:(NSRegularExpression *)regex {
    NSString *title = item[@"title"];
    if ([title length] == 0) {
        return NO;
    }
    NSRange range = NSMakeRange(0, title.length);
    NSUInteger numMatches = [regex numberOfMatchesInString:title options:0 range:range];
    return numMatches > 0;
}

+ (BOOL)isAd:(NSDictionary *)item {
    if (item[@"is_recommend"] != nil) {
    	return YES;
    } else if (item[@"badge"]) {
    	NSArray *badges = item[@"badge"];
    	for (NSDictionary *badge in badges) {
    		if ([badge[@"name"] isEqual:@"广告"]) {
    			return YES;
    		}
    	}
    }
    return NO;
}

+ (BOOL)shouldRemoveItem:(NSDictionary *)item {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pattern = nil;

    pattern = [userDefaults stringForKey:@"title"];
    if ([pattern length]) {
        NSRegularExpression *regex = [self regexFromPattern:pattern];
        if (regex && [self item:item titleMatchesRegex:regex]) {
            return YES;
        }
    }

    if ([userDefaults boolForKey:@"adsFilter"]) {
    	if ([self isAd:item]) {
    		return YES;
    	}
    }
    return NO;
}

+ (BOOL)debugModeEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"debug"];
}

+ (BOOL)filtersEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled"];
}

@end
