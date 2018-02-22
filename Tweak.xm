#include "BBSBoardListTableView.h"
#include "FilterUtils.h"
#include "HPGRecommendPostListTVC.h"

void applyStylesToMatchedCell(UITableViewCell *cell) {
    cell.clipsToBounds = YES;
    if ([FilterUtils debugModeEnabled]) {
        cell.contentView.backgroundColor = [UIColor yellowColor];
    } else {
        cell.hidden = YES;
    }
}

void resetCellStyles(UITableViewCell *cell) {
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.hidden = NO;
}

%hook BBSBoardListTableView

%new 
- (NSArray *)dataArrayForTableView:(UITableView *)tableView {
    if (tableView == self.newreplyTableView) {
        return self.newreplydataArray;
    } else if (tableView == self.newpostTableView) {
        return self.newpostdataArray;
    } else if (tableView == self.newreplyTableView) {
        return self.newreplydataArray;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = %orig;
    if (!cell) {
        return cell;
    }

    resetCellStyles(cell);

    NSArray *itemsArray = [self dataArrayForTableView:tableView];
    if (itemsArray.count <= indexPath.row) {
        return cell;
    }

    NSDictionary *item = itemsArray[indexPath.row];
    if (item && [FilterUtils filtersEnabled] && [FilterUtils shouldRemoveItem:item]) {
        applyStylesToMatchedCell(cell);
    }
    return cell;
}

- (double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *itemsArray = [self dataArrayForTableView:tableView];
    if (itemsArray.count <= indexPath.row) {
        return %orig;
    }

    NSDictionary *item = itemsArray[indexPath.row];
    if (item && [FilterUtils filtersEnabled] && ![FilterUtils debugModeEnabled] && [FilterUtils shouldRemoveItem:item]) {
        return 0;
    }
    return %orig;
}

%end

%hook HPGRecommendPostListTVC

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = %orig;
    if (!cell) {
        return cell;
    }

    resetCellStyles(cell);

    if (self.mForumsArray.count <= indexPath.row) {
        return cell;
    }

    NSDictionary *item = self.mForumsArray[indexPath.row];
    if (item && [FilterUtils filtersEnabled] && [FilterUtils shouldRemoveItem:item]) {
        applyStylesToMatchedCell(cell);
    }
    return cell;
}

- (double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mForumsArray.count <= indexPath.row) {
        return %orig;
    }

    NSDictionary *item = self.mForumsArray[indexPath.row];
    if (item && [FilterUtils filtersEnabled] && ![FilterUtils debugModeEnabled] && [FilterUtils shouldRemoveItem:item]) {
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
