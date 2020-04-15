#include "MEVORootListController.h"

BOOL mevoEnabledConnectivityState = YES;

@implementation MEVOConnectivityController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Connectivity" target:self] mutableCopy];

		NSString *keyword = mevoEnabledConnectivityState ? @"Disabled" : @"Enabled";
		NSFileManager *fileManager = [NSFileManager defaultManager];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"] && [spec.properties[@"key"] isEqual:@"rearrangeToggles"]) {
				[spec setProperty:@"NO" forKey:@"enabled"];
				continue;
			}

			if (![fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"] && [spec.properties[@"key"] isEqual:@"rearrangeTogglesHint"]) {
				[mutableSpecifiers removeObject:spec];
				continue;
			}

			if ([spec.properties[@"key"] containsString:keyword] && ![spec.properties[@"key"] isEqual:@"connectivityModeEnabled"]) {
				[mutableSpecifiers removeObject:spec];
			} else if ([spec.properties[@"key"] isEqual:@"switchState"]) {
				spec.name = mevoEnabledConnectivityState ? @"Colors for Enabled State" : @"Colors for Disabled State";
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)viewDidLoad {
	mevoEnabledConnectivityState = YES;
	[super viewDidLoad];
}

- (void)switchState {
	mevoEnabledConnectivityState = !mevoEnabledConnectivityState;
	[self reloadSpecifiers];
}

@end
