#include "MEVORootListController.h"

NSString *presetPath = @"/User/Library/Preferences/com.noisyflake.magmaevo.presets/";
NSString *settingsFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";
NSString *persistentFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.persistent.plist";

NSMutableDictionary *persistentSettings;

@implementation MEVOPresetsController

- (NSArray *)specifiers {
	if (!_specifiers) {

		NSFileManager *fileManager= [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:presetPath]) {
			[fileManager createDirectoryAtPath:presetPath withIntermediateDirectories:YES attributes:nil error:nil];
		}

		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Presets" target:self] mutableCopy];

		NSArray *presets = [fileManager contentsOfDirectoryAtPath:presetPath error:NULL];
		NSArray *sortedPresets = [presets sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

		persistentSettings = [NSMutableDictionary dictionaryWithContentsOfFile:persistentFile];

		for (NSString *fileName in sortedPresets) {
			if (![fileName hasSuffix:@".plist"]) continue;

			NSString *presetName = [fileName substringToIndex:[fileName length]-6];

			PSSpecifier* preset = [PSSpecifier preferenceSpecifierNamed:presetName target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
			[preset setProperty:NSClassFromString(@"MEVOPreset") forKey:@"cellClass"];
			[preset setProperty:@"regular" forKey:@"textColor"];
			[preset setProperty:presetName forKey:@"fileName"];
			preset.buttonAction = @selector(selectPreset:);

			if ([presetName isEqual:persistentSettings[@"currentPreset"]]) {
				[preset setProperty:@YES forKey:@"isActive"];

				if([persistentSettings[@"unsaved"] boolValue]) {
					[preset setProperty:@YES forKey:@"isUnsaved"];
				}
			}

			if ([presetName isEqual:persistentSettings[@"darkDefault"]]) {
				[preset setProperty:@YES forKey:@"isDarkDefault"];
			} else if ([presetName isEqual:persistentSettings[@"lightDefault"]]) {
				[preset setProperty:@YES forKey:@"isLightDefault"];
			}


			[mutableSpecifiers addObject:preset];
		}

		[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.noisyflake.magmaevo/presetChanged" object:nil];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSpecifiers) name:@"com.noisyflake.magmaevo/presetChanged" object:nil];

		UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePreset)];
		self.navigationItem.rightBarButtonItem = applyButton;
		self.navigationItem.rightBarButtonItem.enabled = persistentSettings[@"currentPreset"] && [persistentSettings[@"unsaved"] boolValue];

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)selectPreset:(PSSpecifier *)specifier {
	NSString *presetName = [specifier propertyForKey:@"fileName"];

	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:presetName message:@"Select an action for this preset" preferredStyle:UIAlertControllerStyleActionSheet];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Load" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self loadPreset:presetName];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Export" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self exportPreset:presetName];
    }]];

	NSFileManager *fileManager= [NSFileManager defaultManager];
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") || [fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/NoctisToggle.bundle/"]) {

		if (![[specifier propertyForKey:@"isDarkDefault"] boolValue]) {
			[actionSheet addAction:[UIAlertAction actionWithTitle:@"Use for Dark Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self setAsDefault:presetName forMode:@"dark"];
			}]];
		} else {
			[actionSheet addAction:[UIAlertAction actionWithTitle:@"Stop using for Dark Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self removeDefaultForMode:@"dark"];
			}]];
		}

		if (![[specifier propertyForKey:@"isLightDefault"] boolValue]) {
			[actionSheet addAction:[UIAlertAction actionWithTitle:@"Use for Light Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self setAsDefault:presetName forMode:@"light"];
			}]];
		} else {
			[actionSheet addAction:[UIAlertAction actionWithTitle:@"Stop using for Light Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self removeDefaultForMode:@"light"];
			}]];
		}

	}

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deletePreset:specifier];
    }]];

    [actionSheet setModalPresentationStyle:UIModalPresentationPopover];

	UIPopoverPresentationController *popPresenter = [actionSheet popoverPresentationController];
	for (UIView *subview in self.view.allSubviews) {
		if ([subview isKindOfClass:%c(UITableViewLabel)] && [((UILabel *)subview).text isEqual:presetName]) {
			popPresenter.sourceView = subview;
			popPresenter.sourceRect = subview.bounds;
		}
	}

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)newPreset {
	UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"New Preset" message: @"This will create a new preset with your current settings. Please enter a name:" preferredStyle:UIAlertControllerStyleAlert];

	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Name";
	}];

	[alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		NSString *name = alert.textFields[0].text;

		NSFileManager *fileManager= [NSFileManager defaultManager];
		NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, name];
		if([fileManager fileExistsAtPath:presetFile]) {
			UIAlertController *failure = [UIAlertController alertControllerWithTitle: @"Error" message: @"A preset with this name already exists. If you want to overwrite it, use the Save button instead." preferredStyle:UIAlertControllerStyleAlert];
			[failure addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

			[self presentViewController:failure animated:YES completion:nil];
		} else {
			[fileManager copyItemAtPath:settingsFile toPath:presetFile error:nil];
			[self setPresetActive:name];
		}
	}]];


	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)importPreset {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

	if (pasteboard.string == nil) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clipboard empty" message:@"Please make sure that you have a valid Magma Evo preset in your clipboard and try again." preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
		return;
	}

	NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:pasteboard.string options:0];
	NSString *settings = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];

	if (settings == nil || [settings length] <= 0 || ![settings hasPrefix:@"MagmaEvo:"]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Import failed" message:@"Please make sure that you have a valid Magma Evo preset in your clipboard and try again." preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		// Add a fake import spinner so that stupid users hopefully won't try to paste the import string as the name because they don't fucking read.

		UIView *_hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
		_hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95];
		_hudView.clipsToBounds = YES;
		_hudView.layer.cornerRadius = 10.0;
		_hudView.center = self.view.center;

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		UIActivityIndicatorView *_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		#pragma clang diagnostic pop

		_activityIndicatorView.frame = CGRectMake(55, 30, _activityIndicatorView.bounds.size.width, _activityIndicatorView.bounds.size.height);
		[_hudView addSubview:_activityIndicatorView];
		[_activityIndicatorView startAnimating];

		UILabel *_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, 130, 22)];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor whiteColor];
		_captionLabel.adjustsFontSizeToFitWidth = YES;
		_captionLabel.textAlignment = NSTextAlignmentCenter;
		_captionLabel.text = @"Importing...";
		[_hudView addSubview:_captionLabel];

		[self.view addSubview:_hudView];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){ // 2 
			[_hudView removeFromSuperview];

			UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Import successful" message: @"The preset was imported from your clipboard. Please enter a name for it:" preferredStyle:UIAlertControllerStyleAlert];

			[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
				textField.placeholder = @"Name";
			}];

			[alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				NSString *name = alert.textFields[0].text;

				NSFileManager *fileManager= [NSFileManager defaultManager];
				NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, name];

				if([fileManager fileExistsAtPath:presetFile]) {
					UIAlertController *failure = [UIAlertController alertControllerWithTitle: @"Error" message: @"A preset with this name already exists." preferredStyle:UIAlertControllerStyleAlert];
					[failure addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

					[self presentViewController:failure animated:YES completion:nil];
				} else {
					NSString *fileContent = [settings substringFromIndex:9];
					[fileContent writeToFile:presetFile atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
					[self reloadSpecifiers];
				}
			}]];

			[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

			[self presentViewController:alert animated:YES completion:nil];
		});
	}

	
}

- (void)loadPreset:(NSString *)presetName {
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, presetName];
	NSFileManager *fileManager= [NSFileManager defaultManager];

	if ([persistentSettings[@"unsaved"] boolValue]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle: presetName
									message: @"You have unsaved changes. If you load this preset, all your changes will be lost!"
	 								preferredStyle:UIAlertControllerStyleAlert];

		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			NSFileManager *fileManager= [NSFileManager defaultManager];
			[fileManager removeItemAtPath:settingsFile error:nil];
			[fileManager copyItemAtPath:presetFile toPath:settingsFile error:nil];

			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.noisyflake.magmaevo/update", NULL, NULL, YES);

			[self setPresetActive:presetName];
		}]];

		[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];

	} else {
		[fileManager removeItemAtPath:settingsFile error:nil];
		[fileManager copyItemAtPath:presetFile toPath:settingsFile error:nil];

		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.noisyflake.magmaevo/update", NULL, NULL, YES);

		[self setPresetActive:presetName];
	}
}

- (void)savePreset {
	NSString *presetName = persistentSettings[@"currentPreset"];

	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, presetName];

	NSFileManager *fileManager= [NSFileManager defaultManager];
	[fileManager removeItemAtPath:presetFile error:nil];
	[fileManager copyItemAtPath:settingsFile toPath:presetFile error:nil];

	[self setPresetActive:presetName];
}

-(void)exportPreset:(NSString *)presetName {
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, presetName];

	NSString *settings = [NSString stringWithContentsOfFile:presetFile encoding:NSUTF8StringEncoding error:nil];
	settings = [NSString stringWithFormat:@"MagmaEvo:%@", settings];

    NSData *plainData = [settings dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = base64String;

	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Export successful" message:@"A unique string containg this preset has been copied to the clipboard." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deletePreset:(PSSpecifier *)specifier {
	NSString *presetName = [specifier propertyForKey:@"fileName"];
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, presetName];

	UIAlertController * alert = [UIAlertController alertControllerWithTitle:presetName message:@"Are you sure you want to delete this preset?" preferredStyle:UIAlertControllerStyleAlert];

	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
		NSFileManager *fileManager= [NSFileManager defaultManager];
		[fileManager removeItemAtPath:presetFile error:nil];
		[self removeSpecifier:specifier animated:YES];

		if ([presetName isEqual:persistentSettings[@"currentPreset"]]) [persistentSettings removeObjectForKey:@"currentPreset"];
		if ([presetName isEqual:persistentSettings[@"lightDefault"]]) [persistentSettings removeObjectForKey:@"lightDefault"];
		if ([presetName isEqual:persistentSettings[@"darkDefault"]]) [persistentSettings removeObjectForKey:@"darkDefault"];
		[persistentSettings writeToFile:persistentFile atomically:YES];
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}

-(void)setPresetActive:(NSString *)presetName {
	[persistentSettings setObject:presetName forKey:@"currentPreset"];
	[persistentSettings setObject:@NO forKey:@"unsaved"];
	[persistentSettings writeToFile:persistentFile atomically:YES];

	[self reloadSpecifiers];
}

-(void)setAsDefault:(NSString *)presetName forMode:(NSString *)mode {
	if ([mode isEqual:@"dark"]) {
		[persistentSettings setObject:presetName forKey:@"darkDefault"];

		if ([presetName isEqual:persistentSettings[@"lightDefault"]]) {
			[persistentSettings removeObjectForKey:@"lightDefault"];
		}
	} else {
		[persistentSettings setObject:presetName forKey:@"lightDefault"];

		if ([presetName isEqual:persistentSettings[@"darkDefault"]]) {
			[persistentSettings removeObjectForKey:@"darkDefault"];
		}
	}

	[persistentSettings writeToFile:persistentFile atomically:YES];

	[self reloadSpecifiers];
}

-(void)removeDefaultForMode:(NSString *)mode {
	if ([mode isEqual:@"dark"]) {
		[persistentSettings removeObjectForKey:@"darkDefault"];
	} else {
		[persistentSettings removeObjectForKey:@"lightDefault"];
	}

	[persistentSettings writeToFile:persistentFile atomically:YES];

	[self reloadSpecifiers];
}
@end
