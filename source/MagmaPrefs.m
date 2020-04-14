/*

	Magma Evo
	Redefine your Control Center

	Copyright (C) 2020 by NoisyFlake

	All Rights Reserved

*/

#import "MagmaEvo.h"

static MagmaPrefs *sharedInstance = nil;

static NSString *settingsFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";
static NSString *defaultFile = @"/Library/PreferenceBundles/MagmaEvo.bundle/defaults.plist";

static NSString *persistentFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.persistent.plist";
static NSString *persistentDefaultFile = @"/Library/PreferenceBundles/MagmaEvo.bundle/persistent.plist";

static void updatePreferences() {
	[[MagmaPrefs sharedInstance] load];
}

@implementation MagmaPrefs

+(id)sharedInstance {
	if (sharedInstance == nil) {
		NSLog("Initializing preferences.");
		sharedInstance = [[self alloc] init];
	}

	return sharedInstance;
}

-(id)init {
	self = [super init];

	if (self) {
		// Copy the default preferences file if the actual preference file doesn't exist
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:settingsFile]) {
			[fileManager copyItemAtPath:defaultFile toPath:settingsFile error:nil];
		}

		if (![fileManager fileExistsAtPath:persistentFile]) {
			[fileManager copyItemAtPath:persistentDefaultFile toPath:persistentFile error:nil];
		}

		_defaultSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultFile];
		[self load];

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePreferences, CFSTR("com.noisyflake.magmaevo/update"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}

	return self;
}

-(void)load {
	_settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFile];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.noisyflake.magmaevo/reload" object:nil];
}

-(void)loadPresetForStyle:(UIUserInterfaceStyle)style {
	NSMutableDictionary *persistentSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:persistentFile];


	NSString *presetName;
	if (style == 1) {
		presetName = persistentSettings[@"lightDefault"];
	} else if (style == 2) {
		presetName = persistentSettings[@"darkDefault"];
	}

	if (presetName == nil) return;

	NSString *presetFile = [NSString stringWithFormat:@"/User/Library/Preferences/com.noisyflake.magmaevo.presets/%@.plist", presetName];
	NSString *settingsFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";

	NSFileManager *fileManager= [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:presetFile]) return;

	[fileManager removeItemAtPath:settingsFile error:nil];
	[fileManager copyItemAtPath:presetFile toPath:settingsFile error:nil];

	[persistentSettings setObject:presetName forKey:@"currentPreset"];
	[persistentSettings setObject:@NO forKey:@"unsaved"];
	[persistentSettings writeToFile:persistentFile atomically:YES];

	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.noisyflake.magmaevo/presetChanged" object:nil];

	[self load];
}

-(BOOL)boolForKey:(NSString *)key {
	id ret = _settings[key] ?: _defaultSettings[key];
	return [ret boolValue];
}

-(NSString *)valueForKey:(NSString *)key {
	return _settings[key] ?: _defaultSettings[key];
}

@end
