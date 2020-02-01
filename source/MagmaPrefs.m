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

@implementation MagmaPrefs

+(id)sharedInstance {
	if (sharedInstance == nil) {
		NSLog(@"Initializing preferences.");
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

		_defaultSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultFile];
		_settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFile];

		NSLog(@"Preferences loaded.");
	}

	return self;
}

-(BOOL)boolForKey:(NSString *)key {
	id ret = _settings[key] ?: _defaultSettings[key];
	return [ret boolValue];
}

-(NSString *)valueForKey:(NSString *)key {
	return _settings[key] ?: _defaultSettings[key];
}

@end
