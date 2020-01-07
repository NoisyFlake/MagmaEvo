#include "MEVORootListController.h"

NSString *mevoSelectedPreset = nil;
NSString *presetPath = @"/User/Library/Preferences/com.noisyflake.magmaevo.presets/";
NSString *settingsFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";

@implementation MEVOPresetsController

- (NSArray *)specifiers {
	if (!_specifiers) {

		NSFileManager *fileManager= [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:presetPath]) {
			[fileManager createDirectoryAtPath:presetPath withIntermediateDirectories:YES attributes:nil error:nil];
		}

		NSMutableArray *mutableSpecifiers = [NSMutableArray array];

		[mutableSpecifiers addObject:[self createMEVOButton:@"New" withAction:@selector(newPreset)]];
		[mutableSpecifiers addObject:[self createMEVOButton:@"Import" withAction:@selector(importPreset)]];

		PSSpecifier* availablePresets = [PSSpecifier preferenceSpecifierNamed:@"Available Presets" target:self set:nil get:nil detail:Nil cell:PSGroupCell edit:Nil];
		[mutableSpecifiers addObject:availablePresets];

		NSArray *presets = [fileManager contentsOfDirectoryAtPath:presetPath error:NULL];

		for (NSString *fileName in presets) {
			NSString *presetName = [fileName substringToIndex:[fileName length]-6];

			PSSpecifier* preset = [PSSpecifier preferenceSpecifierNamed:presetName target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
			[preset setProperty:NSClassFromString(@"MEVOButton") forKey:@"cellClass"];
			[preset setProperty:([presetName isEqual:mevoSelectedPreset] ? @"regular" : @"disabled") forKey:@"textColor"];
			[preset setProperty:presetName forKey:@"fileName"];
			preset.buttonAction = @selector(selectPreset:);

			[mutableSpecifiers addObject:preset];
		}

		if (mevoSelectedPreset != nil) {
			PSSpecifier* actions = [PSSpecifier preferenceSpecifierNamed:mevoSelectedPreset target:self set:nil get:nil detail:Nil cell:PSGroupCell edit:Nil];
			[mutableSpecifiers addObject:actions];

			[mutableSpecifiers addObject:[self createMEVOButton:@"Load" withAction:@selector(loadPreset)]];
			[mutableSpecifiers addObject:[self createMEVOButton:@"Save" withAction:@selector(savePreset)]];
			[mutableSpecifiers addObject:[self createMEVOButton:@"Export" withAction:@selector(exportPreset)]];
			[mutableSpecifiers addObject:[self createMEVOButton:@"Delete" withAction:@selector(deletePreset)]];

		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (PSSpecifier*)createMEVOButton:(NSString *)name withAction:(SEL)action {
	PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
	[spec setProperty:NSClassFromString(@"MEVOButton") forKey:@"cellClass"];
	spec.buttonAction = action;

	return spec;
}

- (void)viewDidLoad {
	mevoSelectedPreset = nil;
	[super viewDidLoad];
}

- (void)selectPreset:(PSSpecifier *)specifier {
	mevoSelectedPreset = [specifier propertyForKey:@"fileName"];
	[self reloadSpecifiers];
}

- (void)newPreset {
	UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"New Preset"
									message: @"Choose a name for the new preset"
									preferredStyle:UIAlertControllerStyleAlert];

	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Name";
	}];

	UIAlertAction* yesButton = [UIAlertAction
								actionWithTitle:@"Save"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action) {
									NSString *name = alert.textFields[0].text;
									NSFileManager *fileManager= [NSFileManager defaultManager];
									NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, name];
									if([fileManager fileExistsAtPath:presetFile]) {
										UIAlertController *failure = [UIAlertController alertControllerWithTitle: @"Error"
																		message: @"A preset with this name already exists."
																		preferredStyle:UIAlertControllerStyleAlert];
										UIAlertAction* okButton = [UIAlertAction
																	actionWithTitle:@"OK"
																	style:UIAlertActionStyleDefault
																	handler:^(UIAlertAction * action) {
																		return;
																	}];

										[failure addAction:okButton];
										[self presentViewController:failure animated:YES completion:nil];
									} else {
										[fileManager copyItemAtPath:settingsFile toPath:presetFile error:nil];
										[self reloadSpecifiers];
									}
								}];

	UIAlertAction* noButton = [UIAlertAction
								actionWithTitle:@"Cancel"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action) {
									return;
								}];

	[alert addAction:yesButton];
	[alert addAction:noButton];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)loadPreset {
	NSFileManager *fileManager= [NSFileManager defaultManager];
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, mevoSelectedPreset];
	if(![fileManager fileExistsAtPath:presetFile]) return;

	UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"Load Preset"
									message: [NSString stringWithFormat:@"Are you sure you want to load '%@'? All your settings will be overwritten.", mevoSelectedPreset]
									preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* yesButton = [UIAlertAction
								actionWithTitle:@"Yes"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action) {
									[fileManager removeItemAtPath:settingsFile error:nil];
									[fileManager copyItemAtPath:presetFile toPath:settingsFile error:nil];

									UIAlertController *success = [UIAlertController alertControllerWithTitle: @"Success"
										  							message: @"Preset successfully loaded."
										  							preferredStyle:UIAlertControllerStyleAlert];
									UIAlertAction* okButton = [UIAlertAction
																actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
																handler:^(UIAlertAction * action) {
																	return;
																}];

									[success addAction:okButton];
									[self presentViewController:success animated:YES completion:nil];
								}];

	UIAlertAction* noButton = [UIAlertAction
								actionWithTitle:@"Cancel"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action) {
									return;
								}];

	[alert addAction:yesButton];
	[alert addAction:noButton];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)savePreset {
	NSFileManager *fileManager= [NSFileManager defaultManager];
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, mevoSelectedPreset];
	if(![fileManager fileExistsAtPath:presetFile]) return;

	UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"Save Preset"
									message: [NSString stringWithFormat:@"Are you sure you want to overwrite '%@' with your current settings?", mevoSelectedPreset]
									preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* yesButton = [UIAlertAction
								actionWithTitle:@"Yes"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action) {
									[fileManager removeItemAtPath:presetFile error:nil];
									[fileManager copyItemAtPath:settingsFile toPath:presetFile error:nil];

									UIAlertController *success = [UIAlertController alertControllerWithTitle: @"Success"
																	message: @"Preset successfully saved."
																	preferredStyle:UIAlertControllerStyleAlert];
									UIAlertAction* okButton = [UIAlertAction
																actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
																handler:^(UIAlertAction * action) {
																	return;
																}];

									[success addAction:okButton];
									[self presentViewController:success animated:YES completion:nil];
								}];

	UIAlertAction* noButton = [UIAlertAction
								actionWithTitle:@"Cancel"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action) {
									return;
								}];

	[alert addAction:yesButton];
	[alert addAction:noButton];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)deletePreset {
	NSFileManager *fileManager= [NSFileManager defaultManager];
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, mevoSelectedPreset];
	if(![fileManager fileExistsAtPath:presetFile]) return;

	UIAlertController * alert = [UIAlertController
									alertControllerWithTitle:@"Delete Preset"
									message:[NSString stringWithFormat:@"Are you sure you want to delete '%@'?", mevoSelectedPreset]
									preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* yesButton = [UIAlertAction
								actionWithTitle:@"Yes"
								style:UIAlertActionStyleDestructive
								handler:^(UIAlertAction * action) {
									[fileManager removeItemAtPath:presetFile error:nil];
									mevoSelectedPreset = nil;
									[self reloadSpecifiers];
								}];

	UIAlertAction* noButton = [UIAlertAction
								actionWithTitle:@"Cancel"
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction * action) {
									return;
								}];

	[alert addAction:yesButton];
	[alert addAction:noButton];

	[self presentViewController:alert animated:YES completion:nil];
}
@end
