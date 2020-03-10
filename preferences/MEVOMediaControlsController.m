#include "MEVORootListController.h"

@implementation MEVOMediaControlsController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"MediaControls" target:self] mutableCopy];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL prysmInstalled = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if (!prysmInstalled && [spec.properties[@"feature"] isEqual:@"prysm"]) {
				[mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
