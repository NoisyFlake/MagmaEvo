#include "MEVORootListController.h"

@implementation MEVOSlidersController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [self loadSpecifiersFromPlistName:@"Sliders" target:self];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/CCRingerModule.bundle/CCRingerModule"]) {
			for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
				if ([spec.properties[@"key"] containsString:@"Ringer"]) {
					[mutableSpecifiers removeObject:spec];
				}
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
