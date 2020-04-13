#import "MagmaEvo.h"

%hook CCUIRoundButton
	-(void)didMoveToWindow {
		%orig;

		[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
	}

	-(void)_updateForStateChange {
		%orig;

		[self magmaEvoColorize];
	}

	%new
	-(void)magmaEvoColorize {
		if (
			[self._viewControllerForAncestor isKindOfClass:%c(LockButtonController)] ||
			[self._viewControllerForAncestor isKindOfClass:%c(PowerDownButtonController)] ||
			[self._viewControllerForAncestor isKindOfClass:%c(RebootButtonController)] ||
			[self._viewControllerForAncestor isKindOfClass:%c(RespringButtonController)] ||
			[self._viewControllerForAncestor isKindOfClass:%c(SafemodeButtonController)] ||
			[self._viewControllerForAncestor isKindOfClass:%c(UICacheButtonController)]
		) {
			self.normalStateBackgroundView.alpha = [settings boolForKey:@"powerModuleHideBackground"] ? 0 : 1;
		}


		if ([self._viewControllerForAncestor isKindOfClass:%c(CCUIConnectivityButtonViewController)]) {
			self.normalStateBackgroundView.alpha = [[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] ? 0 : 1;

			UIColor *selectedColor;

			if ([[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"]) {
				selectedColor = UIColor.clearColor;
			} else {
				NSString *prefKey = [NSString stringWithFormat:@"%@Enabled", NSStringFromClass([self._viewControllerForAncestor class])];
				if ([settings valueForKey:prefKey]) {
					selectedColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:prefKey]];
				} else {
					if ([prefKey isEqual:@"CCUIConnectivityAirDropViewControllerEnabled"]) selectedColor = [UIColor evoRGBAColorFromHexString:@"#007AFF"];
					if ([prefKey isEqual:@"CCUIConnectivityAirplaneViewControllerEnabled"]) selectedColor = [UIColor evoRGBAColorFromHexString:@"#FF9500"];
					if ([prefKey isEqual:@"CCUIConnectivityBluetoothViewControllerEnabled"]) selectedColor = [UIColor evoRGBAColorFromHexString:@"#007AFF"];
					if ([prefKey isEqual:@"CCUIConnectivityCellularDataViewControllerEnabled"]) selectedColor = [UIColor evoRGBAColorFromHexString:@"#4CD964"];
					if ([prefKey isEqual:@"CCUIConnectivityHotspotViewControllerEnabled"]) selectedColor = [UIColor evoRGBAColorFromHexString:@"#4CD964"];
					if ([prefKey isEqual:@"CCUIConnectivityWifiViewControllerEnabled"]) selectedColor = [UIColor evoRGBAColorFromHexString:@"#007AFF"];
				}
			}

			self.selectedStateBackgroundView.backgroundColor = selectedColor;
		}

		if (self.glyphPackageView == nil) {
			// Only need to update the selectedGlyphView because the regular one is already colored after a respring
			forceLayerUpdate(@[self.selectedGlyphView.layer]);
		} else {
			// WiFi & Bluetooth buttons
			forceLayerUpdate(self.glyphPackageView.layer.sublayers);
		}
	}

	-(BOOL)useAlternateBackground {
		if ([self._viewControllerForAncestor isKindOfClass:%c(CCUIConnectivityButtonViewController)]) return NO;
		return %orig;
	}
%end

%hook CCUIConnectivityModuleViewController
	-(void)_setupPortraitButtons {
		%orig;

		NSArray *newOrder = [self evoGetToggleOrder:self.portraitButtonViewControllers];
		if ([newOrder count] != 0) {
			[self setPortraitButtonViewControllers:newOrder];
		} else {
			// Write them to the preference file so we know which ones are available later
			NSString *path = @"/User/Library/Preferences/com.noisyflake.magmaevo.plist";
			NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];

			for (int i = 0; i < [self.portraitButtonViewControllers count]; i++) {
				[settings setObject:NSStringFromClass([self.portraitButtonViewControllers[i] class]) forKey:[NSString stringWithFormat:@"connectivityPosition%d", i]];
			}

			[settings writeToFile:path atomically:YES];
		}
	}

	-(void)_setupLandscapeButtons {
		%orig;

		NSArray *newOrder = [self evoGetToggleOrder:self.landscapeButtonViewControllers];
		if ([newOrder count] != 0) [self setLandscapeButtonViewControllers:newOrder];
	}

	%new
	-(NSArray*)evoGetToggleOrder:(NSArray *)originalOrder {

		NSMutableArray *newOrder = [NSMutableArray arrayWithCapacity: 6];
		for (int i = 0; i < 6; i++) {
    		[newOrder addObject:[NSNull null]];
		}

		for (id obj in originalOrder) {
			for (int i = 0; i < 6; i++) {
				NSString *val = [settings valueForKey:[NSString stringWithFormat:@"connectivityPosition%d", i]];
				if (val != nil && [val isEqual:NSStringFromClass([obj class])]) [newOrder replaceObjectAtIndex:i withObject:obj];
			}
		}

		[newOrder removeObjectIdenticalTo:[NSNull null]];

		return newOrder;
	}
%end

CGColorRef getConnectivityGlyphColor(CCUILabeledRoundButtonViewController *controller) {
	NSString *prefKey = [NSString stringWithFormat:@"%@%@", NSStringFromClass([controller class]), [controller isEnabled] ? @"Enabled" : @"Disabled"];
	UIColor *color = ([settings valueForKey:prefKey] != nil) ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:prefKey]] : nil;

	if ([[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] || ![controller isEnabled]) {
		if (color != nil) return [color CGColor];

		if ([prefKey isEqual:@"CCUIConnectivityAirDropViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#007AFF"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityAirplaneViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#FF9500"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityBluetoothViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#007AFF"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityCellularDataViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#4CD964"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityHotspotViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#4CD964"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityWifiViewControllerEnabled"]) return [[UIColor evoRGBAColorFromHexString:@"#007AFF"] CGColor];
	}	else if([controller isEnabled]) {
		if (color != nil && [color evoIsBrightColor]) return [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] CGColor];
	}

	return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
}

CGColorRef getPowerModuleColor(CCUILabeledRoundButtonViewController *controller) {
	NSString *prefKey = NSStringFromClass([controller class]);
	UIColor *color = ([settings valueForKey:prefKey] != nil) ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:prefKey]] : nil;

	if (color != nil) return [color CGColor];

	return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
}

%ctor {
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		// Load WeatherVane or QuickCC if installed because they have to be injected BEFORE the Connectivity Module gets loaded
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/QuickCC.dylib"]) {
			dlopen("/Library/MobileSubstrate/DynamicLibraries/QuickCC.dylib", RTLD_LAZY);
		}

		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/WeatherVane.dylib"]) {
			dlopen("/Library/MobileSubstrate/DynamicLibraries/WeatherVane.dylib", RTLD_LAZY);
		}

		// Need to load the Connectivity Bundle here or our CCUIConnectivityModuleViewController will be injected too early
		[[NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/"] load];
		%init;
	}
}
