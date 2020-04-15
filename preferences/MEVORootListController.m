#include "MEVORootListController.h"
#import <spawn.h>

@implementation MEVORootListController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) self.navigationItem.navigationBar.tintColor = nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];
		NSFileManager *fileManager= [NSFileManager defaultManager];

		if (![fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"]) {
			for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
				if ([spec.properties[@"feature"] isEqual:@"prysm"]) [mutableSpecifiers removeObject:spec];
			}
		}

		NSString *path = @"/User/Library/Preferences/com.noisyflake.magmaevo.configured";

        if (![fileManager fileExistsAtPath:path]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Welcome" message: @"Thank you for buying Magma Evo! Here you can configure colors and other settings for all parts of your Control Center.\n\nWhenever you want to reset a specific color setting, simply long-press on the setting name and the color will be reset to the default." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

            [self presentViewController:alert animated:YES completion:nil];

            [fileManager createFileAtPath:path contents:nil attributes:nil];
        }

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)resetSettings {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset All Settings"
									message: @"Are you sure you want to reset all settings to the default value?"
									preferredStyle:UIAlertControllerStyleAlert];

	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		NSFileManager *fileManager= [NSFileManager defaultManager];
		NSString *settings = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";
		NSString *settingsDefault = @"/Library/PreferenceBundles/MagmaEvo.bundle/defaults.plist";
		[fileManager removeItemAtPath:settings error:nil];
		[fileManager copyItemAtPath:settingsDefault toPath:settings error:nil];

		UIAlertController *success = [UIAlertController alertControllerWithTitle: @"Success" message: @"All settings resetted." preferredStyle:UIAlertControllerStyleAlert];
		[success addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.noisyflake.magmaevo/update", NULL, NULL, YES);

		NSString *persistentFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.persistent.plist";
		NSMutableDictionary *persistentSettings = [NSMutableDictionary dictionaryWithContentsOfFile:persistentFile];
		[persistentSettings removeObjectForKey:@"currentPreset"];
		[persistentSettings writeToFile:persistentFile atomically:YES];

		[self presentViewController:success animated:YES completion:nil];
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}

@end
