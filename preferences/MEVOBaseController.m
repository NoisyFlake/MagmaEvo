#include "MEVORootListController.h"
#import <spawn.h>

@implementation MEVOBaseController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.navigationBar.tintColor = kEVOCOLOR;

	UITableView *table = self.view.subviews[0];
	table.separatorStyle = 0;
}

-(UITableViewStyle)tableViewStyle {
	return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) ? 2 : [super tableViewStyle];
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

-(void)setWithRespring:(id)value specifier:(PSSpecifier *)specifier {
	[self setPreferenceValue:value specifier:specifier];

	UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Respring required" message:@"Changing this option requires a respring. Do you want to respring now?" preferredStyle:UIAlertControllerStyleAlert];

	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		 [self respring];
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

@end
