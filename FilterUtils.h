#include <Foundation/Foundation.h>

@interface FilterUtils : NSObject

+ (NSRegularExpression *)regexFromPattern:(NSString *)pattern;
+ (BOOL)item:(NSDictionary *)item titleMatchesRegex:(NSRegularExpression *)regex;
+ (BOOL)isAd:(NSDictionary *)item;
+ (BOOL)shouldRemoveItem:(NSDictionary *)item;
+ (BOOL)debugModeEnabled;
+ (BOOL)filtersEnabled;

@end