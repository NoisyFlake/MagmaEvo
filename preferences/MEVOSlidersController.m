#include "MEVORootListController.h"

@implementation MEVOSlidersController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Sliders" target:self] mutableCopy];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL prysmInstalled = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"];
		BOOL ccRingerInstalled = [fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/CCRingerModule.bundle/CCRingerModule"];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ((!prysmInstalled && [spec.properties[@"feature"] isEqual:@"prysm"]) ||
				(!ccRingerInstalled && [spec.properties[@"feature"] isEqual:@"ccRinger"])) {
				[mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
