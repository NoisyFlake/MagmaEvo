#include "MEVORootListController.h"
#import <spawn.h>

@implementation MEVOBaseController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.navigationBar.tintColor = kEVOCOLOR;

	UITableView *table = self.view.subviews[0];
	table.separatorStyle = 0;
}

-(long long)tableViewStyle {
	return 2;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];

	NSString *persistentFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.persistent.plist";
	NSMutableDictionary *persistentSettings = [NSMutableDictionary dictionaryWithContentsOfFile:persistentFile];
	[persistentSettings setObject:@YES forKey:@"unsaved"];
	[persistentSettings writeToFile:persistentFile atomically:YES];

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.noisyflake.magmaevo/update", NULL, NULL, YES);
}

-(void)respring {
	[self.view endEditing:YES];

	pid_t pid;
	const char* args[] = {"sbreload", NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

@end
