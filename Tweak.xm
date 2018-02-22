#include "BBSBoardListTableView.h"

NSRegularExpression * fromPattern(NSString *pattern) {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern 
        options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        return regex;
    } else {
        return nil;
    }
}

BOOL matchTitle(NSDictionary *item, NSRegularExpression *regex) {
    NSString *title = item[@"title"];
    if ([title length] == 0) {
        return NO;
    }
    NSRange range = NSMakeRange(0, title.length);
    NSUInteger numMatches = [regex numberOfMatchesInString:title options:0 range:range];
    return numMatches > 0;
}

BOOL isAd(NSDictionary *item) {
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

BOOL shouldRemoveTopic(NSDictionary *item) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pattern = nil;

    pattern = [userDefaults stringForKey:@"title"];
    if ([pattern length]) {
        NSRegularExpression *regex = fromPattern(pattern);
        if (regex && matchTitle(item, regex)) {
            return YES;
        }
    }

    if ([userDefaults boolForKey:@"adsFilter"]) {
    	if (isAd(item)) {
    		return YES;
    	}
    }
    return NO;
}

BOOL enableDebugRegex() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"debug"];
}

BOOL enableFilters() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enabled"];
}

%hook BBSBoardListTableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = %orig;
    if (cell) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.hidden = NO;

        NSArray *itemsArray = nil;
        if (tableView == self.newreplyTableView) {
            itemsArray = self.newreplydataArray;
        } else if (tableView == self.newpostTableView) {
            itemsArray = self.newpostdataArray;
        }

        if (itemsArray.count <= indexPath.row) {
            return cell;
        }

        NSDictionary *item = itemsArray[indexPath.row];
        if (item && enableFilters() && shouldRemoveTopic(item)) {
            cell.clipsToBounds = YES;
            if (enableDebugRegex()) {
                cell.contentView.backgroundColor = [UIColor yellowColor];
            } else {
                cell.hidden = YES;
            }
        }
    }
    return cell;
}

- (double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *itemsArray = nil;
    if (tableView == self.newreplyTableView) {
        itemsArray = self.newreplydataArray;
    } else if (tableView == self.newpostTableView) {
        itemsArray = self.newpostdataArray;
    }

    if (itemsArray.count <= indexPath.row) {
        return %orig;
    }

    NSDictionary *item = itemsArray[indexPath.row];
    if (enableFilters() && !enableDebugRegex() && shouldRemoveTopic(item)) {
        return 0;
    }

    return %orig;
}

%end


%hook AppDelegate

- (void)applicationDidBecomeActive:(id)arg1 {
	%orig;
    
	static NSString *kPrefFilePath = @"/var/mobile/Library/Preferences/com.kh.filterpref.plist";
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:kPrefFilePath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:plistDict];
}

%end
