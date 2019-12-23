#include "MEVORootListController.h"
#include "CoreFoundation/CoreFoundation.h"

BOOL enabledState = YES;

@implementation MEVOToggles

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *appSpecifiers = [self loadSpecifiersFromPlistName:@"Toggles" target:self];

		if (!enabledState) {
			for (PSSpecifier *spec in appSpecifiers) {
				if ([spec.properties[@"key"] isEqual:@"togglesOverlayMode"]) {
					[appSpecifiers removeObject:spec];
				} else if ([spec.properties[@"key"] isEqual:@"state"]) {
					spec.name = @"DISABLED STATE";
				} else if ([spec.properties[@"key"] isEqual:@"switchState"]) {
					spec.name = @"Switch to Enabled State";
				}
			}
		}

		[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/ControlCenterServices.framework"] load];

		CCSModuleRepository *repo = [%c(CCSModuleRepository) repositoryWithDefaults];
		CCSModuleSettingsProvider *provider = [%c(CCSModuleSettingsProvider) sharedProvider];

		NSArray *enabledModules = [provider orderedUserEnabledModuleIdentifiers];

		for (NSString *identifier in enabledModules) {
			CCSModuleMetadata *metaData = [repo moduleMetadataForModuleIdentifier:identifier];
			NSBundle *bundle = [NSBundle bundleWithURL:metaData.moduleBundleURL];

			PSSpecifier *specifier = [self generateSpecifierForBundle:bundle];
			if (specifier) [appSpecifiers addObject:specifier];
		}

    _specifiers = appSpecifiers;
	}

	return _specifiers;
}

- (void)viewDidLoad {
	enabledState = YES;
	[super viewDidLoad];
}

- (void)switchState {
	enabledState = !enabledState;
	[self reloadSpecifiers];
}

- (PSSpecifier*)generateSpecifierForBundle:(NSBundle *)bundle {
	NSDictionary *info = [bundle infoDictionary];
	NSDictionary *localInfo = [bundle localizedInfoDictionary];

	NSString *displayName = [localInfo objectForKey:@"CFBundleDisplayName"] ?: [info objectForKey:@"CFBundleDisplayName"];

	if ([[info objectForKey:@"CFBundleIdentifier"] isEqual:@"com.apple.control-center.OrientationLockModule"]) {
		displayName = @"Orientation Lock";
	} if ([[info objectForKey:@"CFBundleIdentifier"] isEqual:@"com.apple.donotdisturb.DoNotDisturbModule"]) {
		displayName = @"Do Not Disturb";
	}

	if (displayName == nil) {
		return nil;
	}

	PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:displayName
									    target:self
									    set:@selector(setPreferenceValue:specifier:)
								   		get:@selector(readPreferenceValue:)
									    detail:Nil
									    cell:PSLinkCell
									    edit:Nil];

	/* [specifier setProperty:@YES forKey:@"alpha"]; */

	NSString *key = [NSString stringWithFormat:@"%@%@", [info objectForKey:@"CFBundleIdentifier"], enabledState ? @"Enabled" : @"Disabled"];
	[specifier setProperty:key forKey:@"key"];
	[specifier setProperty:@"com.noisyflake.magmaevo" forKey:@"defaults"];
	[specifier setProperty:NSClassFromString(@"MEVOColorPicker") forKey:@"cellClass"];
	return specifier;
}

@end
