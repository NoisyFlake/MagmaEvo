#include "MEVORootListController.h"

@implementation MEVOMiscController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Misc" target:self] mutableCopy];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL powerModuleInstalled = [fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/PowerModule.bundle"];
		BOOL prysmInstalled = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"];
		BOOL bcxiWeatherInstalled = [fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/BCIXWeatherModule.bundle"];

		if (!powerModuleInstalled || prysmInstalled) {
			for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
				if ((!powerModuleInstalled && [spec.properties[@"feature"] isEqual:@"PowerModule"])
					|| (prysmInstalled && [spec.properties[@"feature"] isEqual:@"notPrysm"])
					|| (!bcxiWeatherInstalled && [spec.properties[@"feature"] isEqual:@"bcxiWeather"])) {
					[mutableSpecifiers removeObject:spec];
				}
			}
		}



		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
