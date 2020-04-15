#include "MEVORootListController.h"

@implementation MEVOMiscController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Misc" target:self] mutableCopy];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL powerModuleInstalled = [fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/PowerModule.bundle"];
		BOOL prysmInstalled = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"];
		BOOL bcxiWeatherInstalled = [fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/BCIXWeatherModule.bundle"];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			NSString *feature = spec.properties[@"feature"];
			if (
				([feature isEqual:@"powerModule"] && !powerModuleInstalled) ||
				([feature isEqual:@"prysm"] && !prysmInstalled) ||
				([feature isEqual:@"notPrysm"] && prysmInstalled) ||
				([feature isEqual:@"bcxiWeather"] && (!bcxiWeatherInstalled || prysmInstalled)) ||
				([feature isEqual:@"thirdparty"] && (!bcxiWeatherInstalled && !powerModuleInstalled))
			) {
				[mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
