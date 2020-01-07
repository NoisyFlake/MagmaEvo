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
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
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

		[self presentViewController:success animated:YES completion:nil];
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}

@end
