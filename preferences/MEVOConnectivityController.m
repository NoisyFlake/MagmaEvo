#include "MEVORootListController.h"

BOOL mevoEnabledConnectivityState = YES;

@implementation MEVOConnectivityController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [self loadSpecifiersFromPlistName:@"Connectivity" target:self];

		NSString *keyword = mevoEnabledConnectivityState ? @"Disabled" : @"Enabled";

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
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
