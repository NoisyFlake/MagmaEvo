#include "MEVORootListController.h"

@implementation MEVOMiscController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Misc" target:self] mutableCopy];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/PowerModule.bundle"]) {
			for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
				if ([spec.properties[@"feature"] isEqual:@"PowerModule"]) {
					[mutableSpecifiers removeObject:spec];
				}
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
