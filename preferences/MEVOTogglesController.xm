#include "MEVORootListController.h"
#include "CoreFoundation/CoreFoundation.h"

BOOL mevoEnabledState = YES;

@implementation MEVOTogglesController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *appSpecifiers = [[self loadSpecifiersFromPlistName:@"Toggles" target:self] mutableCopy];


		for (PSSpecifier *spec in [appSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"switchState"]) {
				spec.name = mevoEnabledState ? @"Colors for Enabled State" : @"Colors for Disabled State";
			}
		}


		[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/ControlCenterServices.framework"] load];

		CCSModuleRepository *repo = [%c(CCSModuleRepository) repositoryWithDefaults];
		CCSModuleSettingsProvider *provider = [%c(CCSModuleSettingsProvider) sharedProvider];

		NSArray *enabledModules = [provider orderedUserEnabledModuleIdentifiers];

		for (NSString *identifier in enabledModules) {
			CCSModuleMetadata *metaData = [repo moduleMetadataForModuleIdentifier:identifier];
			if (metaData.moduleBundleURL != nil) {
				NSBundle *bundle = [NSBundle bundleWithURL:metaData.moduleBundleURL];

				PSSpecifier *specifier = [self generateSpecifierForBundle:bundle];
				if (specifier) [appSpecifiers addObject:specifier];
			}
		}

		PSSpecifier* globalPicker = [PSSpecifier preferenceSpecifierNamed:@"Change All"
											target:self
											set:@selector(setPreferenceValue:specifier:)
											get:@selector(readPreferenceValue:)
											detail:Nil
											cell:PSLinkCell
											edit:Nil];

		[globalPicker setProperty:@"togglesGlobalPicker" forKey:@"key"];
		[globalPicker setProperty:@"Change All" forKey:@"label"];
		[globalPicker setProperty:@"com.noisyflake.magmaevo" forKey:@"defaults"];
		[globalPicker setProperty:NSClassFromString(@"MEVOColorPicker") forKey:@"cellClass"];
		[globalPicker setProperty:@YES forKey:@"global"];
		[appSpecifiers addObject:globalPicker];

		_specifiers = appSpecifiers;
	}

	return _specifiers;
}

- (void)viewDidLoad {
	mevoEnabledState = YES;
	[super viewDidLoad];
}

- (void)switchState {
	mevoEnabledState = !mevoEnabledState;
	[self reloadSpecifiers];
}

- (PSSpecifier*)generateSpecifierForBundle:(NSBundle *)bundle {
	NSDictionary *info = [bundle infoDictionary];
	NSDictionary *localInfo = [bundle localizedInfoDictionary];

	NSString *displayName = [localInfo objectForKey:@"CFBundleDisplayName"] ?: [info objectForKey:@"CFBundleDisplayName"];

	if ([[info objectForKey:@"CFBundleIdentifier"] isEqual:@"com.apple.control-center.OrientationLockModule"]) {
		displayName = @"Orientation Lock";
	} else if ([[info objectForKey:@"CFBundleIdentifier"] isEqual:@"com.apple.donotdisturb.DoNotDisturbModule"]) {
		displayName = @"Do Not Disturb";
	} else if ([[info objectForKey:@"CFBundleIdentifier"] isEqual:@"com.muirey03.powermodule"] || [[info objectForKey:@"CFBundleIdentifier"] isEqual:@"com.atwiiks.betterccxi.weathermodule"]) {
		return nil;
	}

	if (displayName == nil) {
		if ([[info objectForKey:@"CFBundleIdentifier"] hasPrefix:@"com.apple"]) return nil;
		displayName = [info objectForKey:@"CFBundleName"];
	}

	PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:displayName
										target:self
										set:@selector(setPreferenceValue:specifier:)
										get:@selector(readPreferenceValue:)
										detail:Nil
										cell:PSLinkCell
										edit:Nil];

	NSString *key = [NSString stringWithFormat:@"%@%@", [info objectForKey:@"CFBundleIdentifier"], mevoEnabledState ? @"Enabled" : @"Disabled"];
	[specifier setProperty:key forKey:@"key"];
	[specifier setProperty:displayName forKey:@"label"];
	[specifier setProperty:@"com.noisyflake.magmaevo" forKey:@"defaults"];
	[specifier setProperty:NSClassFromString(@"MEVOColorPicker") forKey:@"cellClass"];
	return specifier;
}

@end
