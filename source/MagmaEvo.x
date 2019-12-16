/*

	Magma Evo
	Your Control Center. Redefined.

	Copyright (C) 2019 by NoisyFlake

	All Rights Reserved

*/

NSMutableDictionary *prefs, *defaultPrefs;

BOOL prefBool(NSString *key) {
	id ret = [prefs objectForKey:key] ?: [defaultPrefs objectForKey:key];
	return [ret boolValue];
}

NSString* prefValue(NSString *key) {
	return [prefs objectForKey:key] ?: [defaultPrefs objectForKey:key];
}

static void initPreferences() {
	// Copy the default preferences file if the actual preference file doesn't exist
	NSString *path = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/MagmaEvo.bundle/defaults.plist";

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}

	defaultPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:pathDefault];
}

static void updatePreferences() {
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.magmaevo.plist"];
}

%ctor {
	initPreferences();
	updatePreferences();
}
