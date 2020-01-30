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
				[mutableSpecifiers removeObject:spec];
				continue;
			}

			if ([spec.properties[@"key"] containsString:keyword]) {
				[mutableSpecifiers removeObject:spec];
			} else if ([spec.properties[@"key"] isEqual:@"state"]) {
				spec.name = mevoEnabledConnectivityState ? @"ENABLED STATE" : @"DISABLED STATE";
			} else if ([spec.properties[@"key"] isEqual:@"switchState"]) {
				spec.name = mevoEnabledConnectivityState ? @"Switch to Disabled State" : @"Switch to Enabled State";
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
