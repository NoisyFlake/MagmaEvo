#include "MEVORootListController.h"

NSMutableOrderedSet *toggles;

@implementation MEVOConnectivityOrderController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [NSMutableArray array];

		PSSpecifier* hint = [PSSpecifier preferenceSpecifierNamed:@""
											target:self
											set:@selector(setPreferenceValue:specifier:)
											get:@selector(readPreferenceValue:)
											detail:Nil
											cell:PSGroupCell
											edit:Nil];

		[hint setProperty:@"Changes require a respring." forKey:@"footerText"];
		[hint setProperty:@"1" forKey:@"footerAlignment"];
		[mutableSpecifiers addObject:hint];

		toggles = [NSMutableOrderedSet orderedSetWithCapacity:6];

		for (int i = 0; i < 6; i++) {
			NSString *val = [self readPreferenceValueForKey:[NSString stringWithFormat:@"connectivityPosition%d", i]];
			if (val != nil) [toggles addObject:val];
		}

		for (NSString *key in toggles) {
				PSSpecifier *specifier = [self generateSpecifier:key];
				if (specifier) [mutableSpecifiers addObject:specifier];
		}

		_specifiers = mutableSpecifiers;
	}

	UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
	self.navigationItem.rightBarButtonItem = applyButton;

	return _specifiers;
}

- (id)readPreferenceValueForKey:(NSString*)key {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.noisyflake.magmaevo.plist"];
	return (settings[key]) ?: nil;
}

- (void)saveSettings {
	NSString *path = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];

	for (int i = 0; i < [toggles count]; i++) {
		[settings setObject:toggles[i] forKey:[NSString stringWithFormat:@"connectivityPosition%d", i]];
	}

	[settings writeToFile:path atomically:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)source  toIndexPath:(NSIndexPath *)destination {

  NSObject *o = toggles[source.row];
	[toggles removeObjectAtIndex:source.row];
	[toggles insertObject:o atIndex:destination.row];

	[self saveSettings];
}

- (PSSpecifier*)generateSpecifier:(NSString *)key {
	NSString *displayName = nil;

	if ([key isEqual:@"CCUIConnectivityAirplaneViewController"]) displayName = @"Airplane Mode";
	if ([key isEqual:@"CCUIConnectivityCellularDataViewController"]) displayName = @"Cellular Data";
	if ([key isEqual:@"CCUIConnectivityWifiViewController"]) displayName = @"WiFi";
	if ([key isEqual:@"CCUIConnectivityBluetoothViewController"]) displayName = @"Bluetooth";
	if ([key isEqual:@"CCUIConnectivityAirDropViewController"]) displayName = @"AirDrop";
	if ([key isEqual:@"CCUIConnectivityHotspotViewController"]) displayName = @"Personal Hotspot";

	if (displayName == nil) return nil;

	PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:displayName
									    target:self
									    set:@selector(setPreferenceValue:specifier:)
								   		get:nil
									    detail:nil
									    cell:PSStaticTextCell
									    edit:nil];

	[specifier setProperty:NSClassFromString(@"MEVOMovableCell") forKey:@"cellClass"];
	return specifier;
}

@end
