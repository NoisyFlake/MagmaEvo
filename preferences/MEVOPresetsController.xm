#include "MEVORootListController.h"

NSString *presetPath = @"/User/Library/Preferences/com.noisyflake.magmaevo.presets/";
NSString *settingsFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";

@implementation MEVOPresetsController

- (NSArray *)specifiers {
	if (!_specifiers) {

		NSFileManager *fileManager= [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:presetPath]) {
			[fileManager createDirectoryAtPath:presetPath withIntermediateDirectories:YES attributes:nil error:nil];
		}

		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Presets" target:self] mutableCopy];

		NSArray *presets = [fileManager contentsOfDirectoryAtPath:presetPath error:NULL];

		for (NSString *fileName in presets) {
			NSString *presetName = [fileName substringToIndex:[fileName length]-6];

			PSSpecifier* preset = [PSSpecifier preferenceSpecifierNamed:presetName target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
			[preset setProperty:NSClassFromString(@"MEVOButton") forKey:@"cellClass"];
			[preset setProperty:@"regular" forKey:@"textColor"];
			[preset setProperty:presetName forKey:@"fileName"];
			preset.buttonAction = @selector(selectPreset:);

			[mutableSpecifiers addObject:preset];
		}

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

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self savePreset:presetName];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Export" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self exportPreset:presetName];
    }]];

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
	UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"New Preset" message: @"Enter a name for the new preset" preferredStyle:UIAlertControllerStyleAlert];

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
			[fileManager copyItemAtPath:settingsFile toPath:presetFile error:nil];
			[self reloadSpecifiers];
		}
	}]];


	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)importPreset {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

	NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:pasteboard.string options:0];
	NSString *settings = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];

	if ([settings length] <= 0 || ![settings hasPrefix:@"MagmaEvo:"]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Import failed" message:@"Please make sure that you have a valid Magma Evo preset in your clipboard and try again." preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Import Preset" message: @"Enter a name for the imported preset" preferredStyle:UIAlertControllerStyleAlert];

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
	}
}

- (void)loadPreset:(NSString *)presetName {
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, presetName];

	UIAlertController *alert = [UIAlertController alertControllerWithTitle: presetName
									message: @"Are you sure you want to load this preset? All your settings will be overwritten."
									preferredStyle:UIAlertControllerStyleAlert];

	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		NSFileManager *fileManager= [NSFileManager defaultManager];
		[fileManager removeItemAtPath:settingsFile error:nil];
		[fileManager copyItemAtPath:presetFile toPath:settingsFile error:nil];

		UIAlertController *success = [UIAlertController alertControllerWithTitle: @"Success" message: @"Preset successfully loaded." preferredStyle:UIAlertControllerStyleAlert];
		[success addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

		[self presentViewController:success animated:YES completion:nil];
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}

- (void)savePreset:(NSString *)presetName {
	NSString *presetFile = [NSString stringWithFormat:@"%@%@.plist", presetPath, presetName];

	UIAlertController *alert = [UIAlertController alertControllerWithTitle: presetName
									message: @"Are you sure you want to overwrite this preset with your current settings?"
									preferredStyle:UIAlertControllerStyleAlert];

	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		NSFileManager *fileManager= [NSFileManager defaultManager];
		[fileManager removeItemAtPath:presetFile error:nil];
		[fileManager copyItemAtPath:settingsFile toPath:presetFile error:nil];

		UIAlertController *success = [UIAlertController alertControllerWithTitle:presetName message: @"Preset successfully saved." preferredStyle:UIAlertControllerStyleAlert];
		[success addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

		[self presentViewController:success animated:YES completion:nil];
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
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
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}
@end
