#import "MagmaEvo.h"

#define kDefaultContainerBackground [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.09]

%hook PrysmConnectivityModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	[self magmaEvoColorize];
	[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
}

%new
-(void)magmaEvoColorize {
	forceLayerUpdate(self.view.layer.sublayers);

	self.view.backgroundColor = [MagmaHelper colorForKey:@"connectivityContainerBackground" withFallback:kDefaultContainerBackground];
}
%end

%hook PrysmSliderModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	[self magmaEvoColorize];
	[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
}

%new
-(void)magmaEvoColorize {
	self.audioSlider.overlayView.backgroundColor =              [MagmaHelper colorForKey:@"slidersVolumeBackground" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.91]];
	self.audioSlider.percentOverlayLabel.textColor =            [MagmaHelper colorForKey:@"slidersVolumeLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.15]];

	// Static Glyph
	self.audioSlider.overlayImageView.tintColor =               [MagmaHelper colorForKey:@"slidersVolumeGlyph" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.15]];
	// Animated Glyph
	self.audioSlider.packageView.layer.compositingFilter =      [settings valueForKey:@"slidersVolumeGlyph"] ? nil : @"destOut";
	forceLayerUpdate(@[self.audioSlider.packageView.layer]);


	self.brightnessSlider.overlayView.backgroundColor =         [MagmaHelper colorForKey:@"slidersBrightnessBackground" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.91]];
	self.brightnessSlider.percentOverlayLabel.textColor =       [MagmaHelper colorForKey:@"slidersBrightnessLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.15]];

	// Static Glyph
	self.brightnessSlider.overlayImageView.tintColor =          [MagmaHelper colorForKey:@"slidersBrightnessGlyph" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.15]];
	// Animated Glyph
	self.brightnessSlider.packageView.layer.compositingFilter = [settings valueForKey:@"slidersBrightnessGlyph"] ? nil : @"destOut";
	forceLayerUpdate(@[self.brightnessSlider.packageView.layer]);

	self.view.backgroundColor =                                 [MagmaHelper colorForKey:@"slidersContainerBackground" withFallback:kDefaultContainerBackground];
}
%end

%hook PrysmWeatherModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	[self magmaEvoColorize];
	[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
}

%new
-(void)magmaEvoColorize {
	self.currentTemperatureLabel.textColor = [MagmaHelper colorForKey:@"prysmWeatherCurrentTemperature" withFallback:UIColor.whiteColor];
	self.locationTitleLabel.textColor =      [MagmaHelper colorForKey:@"prysmWeatherLocationTitle" withFallback:UIColor.whiteColor];
	self.locationSubtitleLabel.textColor =   [MagmaHelper colorForKey:@"prysmWeatherLocationSubtitle" withFallback:UIColor.whiteColor];
	self.temperatureRangeLabel.textColor =   [MagmaHelper colorForKey:@"prysmWeatherTemperatureRange" withFallback:UIColor.whiteColor];

	self.conditionImageView.image =          [settings valueForKey:@"prysmWeatherIcon"] ? [self.conditionImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.conditionImageView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.conditionImageView.tintColor =      [MagmaHelper colorForKey:@"prysmWeatherIcon" withFallback:UIColor.whiteColor];

	self.view.backgroundColor =              [MagmaHelper colorForKey:@"prysmWeatherContainerBackground" withFallback:kDefaultContainerBackground];
}
%end

%hook PrysmRemindersModuleViewController
-(void)reloadRemindersInfo {
	%orig;

	self.firstEvent.eventTitleLabel.textColor =		[MagmaHelper colorForKey:@"prysmReminderTitle" withFallback:UIColor.whiteColor];
	self.secondEvent.eventTitleLabel.textColor =	[MagmaHelper colorForKey:@"prysmReminderTitle" withFallback:UIColor.whiteColor];
	self.thirdEvent.eventTitleLabel.textColor =		[MagmaHelper colorForKey:@"prysmReminderTitle" withFallback:UIColor.whiteColor];
	self.fourthEvent.eventTitleLabel.textColor =	[MagmaHelper colorForKey:@"prysmReminderTitle" withFallback:UIColor.whiteColor];

	self.firstEvent.dateLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderDate" withFallback:UIColor.whiteColor];
	self.secondEvent.dateLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderDate" withFallback:UIColor.whiteColor];
	self.thirdEvent.dateLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderDate" withFallback:UIColor.whiteColor];
	self.fourthEvent.dateLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderDate" withFallback:UIColor.whiteColor];

	self.firstEvent.timeLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderTime" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.secondEvent.timeLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderTime" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.thirdEvent.timeLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderTime" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.fourthEvent.timeLabel.textColor = 			[MagmaHelper colorForKey:@"prysmReminderTime" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];

	// No idea why this is necessary, but it is. Without the delay, the ring doesn't get colored
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
		self.firstEvent.ringView.layer.borderColor = 	[MagmaHelper colorForKey:@"prysmReminderRing" withFallback:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]].CGColor;
		self.secondEvent.ringView.layer.borderColor = 	[MagmaHelper colorForKey:@"prysmReminderRing" withFallback:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]].CGColor;
		self.thirdEvent.ringView.layer.borderColor = 	[MagmaHelper colorForKey:@"prysmReminderRing" withFallback:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]].CGColor;
		self.fourthEvent.ringView.layer.borderColor = 	[MagmaHelper colorForKey:@"prysmReminderRing" withFallback:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]].CGColor;
	});

	self.firstEvent.circleView.backgroundColor = 		[MagmaHelper colorForKey:@"prysmReminderCircle" withFallback:[UIColor colorWithRed:0.19 green:0.8 blue:0.07 alpha:1]];
	self.secondEvent.circleView.backgroundColor = 		[MagmaHelper colorForKey:@"prysmReminderCircle" withFallback:[UIColor colorWithRed:0.19 green:0.8 blue:0.07 alpha:1]];
	self.thirdEvent.circleView.backgroundColor = 		[MagmaHelper colorForKey:@"prysmReminderCircle" withFallback:[UIColor colorWithRed:0.19 green:0.8 blue:0.07 alpha:1]];
	self.fourthEvent.circleView.backgroundColor = 		[MagmaHelper colorForKey:@"prysmReminderCircle" withFallback:[UIColor colorWithRed:0.19 green:0.8 blue:0.07 alpha:1]];

	self.noRemindersLabel.textColor = 				[MagmaHelper colorForKey:@"prysmReminderNoReminders" withFallback:UIColor.whiteColor];
	
	self.view.backgroundColor =              [MagmaHelper colorForKey:@"prysmReminderContainerBackground" withFallback:kDefaultContainerBackground];
}
%end

%hook PrysmMediaModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	[self magmaEvoColorize];
	[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
}

%new
-(void)magmaEvoColorize {
	self.rewindButton.tintColor                 = [MagmaHelper colorForKey:@"mediaControlsLeftButton" withFallback:UIColor.whiteColor];
	self.playPauseButton.tintColor              = [MagmaHelper colorForKey:@"mediaControlsMiddleButton" withFallback:UIColor.whiteColor];

	if (self.playPauseButton.hidden) {
		self.skipButton.tintColor               = [MagmaHelper colorForKey:@"mediaControlsMiddleButton" withFallback:UIColor.whiteColor];
	} else {
		self.skipButton.tintColor               = [MagmaHelper colorForKey:@"mediaControlsRightButton" withFallback:UIColor.whiteColor];
	}

	self.titleLabel.textColor                   = [MagmaHelper colorForKey:@"mediaControlsPrimaryLabel" withFallback:UIColor.whiteColor];
	self.subtitleLabel.textColor                = [MagmaHelper colorForKey:@"mediaControlsSecondaryLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.5]];

	self.progressView.backgroundColor           = [MagmaHelper colorForKey:@"mediaControlsSlider" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.1]];
	self.roundProgressView.progressColor        = [MagmaHelper colorForKey:@"mediaControlsSlider" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0]];

	self.artworkView.tintColor                  = [MagmaHelper colorForKey:@"prysmMediaControlsArtworkPreview" withFallback:UIColor.whiteColor];
	self.artworkView.backgroundColor            = [MagmaHelper colorForKey:@"prysmMediaControlsArtworkPreviewBackground" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.15]];

	self.applicationContainer.backgroundColor   = [MagmaHelper colorForKey:@"prysmMediaControlsAirplayBackground" withFallback:[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.4]];
	self.applicationOverlayView.tintColor       = [MagmaHelper colorForKey:@"mediaControlsRoutingButton" withFallback:UIColor.whiteColor];
	self.applicationView.tintColor              = [MagmaHelper colorForKey:@"mediaControlsRoutingButton" withFallback:UIColor.whiteColor];

	self.view.backgroundColor                   = [MagmaHelper colorForKey:@"mediaControlsContainerBackground" withFallback:kDefaultContainerBackground];

}
%end

%hook PrysmPowerModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	[self magmaEvoColorize];
	[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
}

%new
-(void)magmaEvoColorize {

	// We have to call the setter again because only now the PrysmButtonView will have a viewcontroller we can check. Pass it the default color as fallback
	UIColor *defaultColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
	self.respringButton.backgroundColor = defaultColor;
	self.safemodeButton.backgroundColor = defaultColor;
	self.lockButton.backgroundColor = defaultColor;
	self.rebootButton.backgroundColor = defaultColor;
	self.shutdownButton.backgroundColor = defaultColor;


	self.respringButton.imageView.image =     [settings valueForKey:@"prysmPowerRespring"] ? [self.respringButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.respringButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.respringButton.imageView.tintColor = [MagmaHelper colorForKey:@"prysmPowerRespring" withFallback:UIColor.whiteColor];

	self.safemodeButton.imageView.image =     [settings valueForKey:@"prysmPowerSafemode"] ? [self.safemodeButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.safemodeButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.safemodeButton.imageView.tintColor = [MagmaHelper colorForKey:@"prysmPowerSafemode" withFallback:UIColor.whiteColor];

	self.lockButton.imageView.image =         [settings valueForKey:@"prysmPowerLock"] ? [self.lockButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.lockButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.lockButton.imageView.tintColor =     [MagmaHelper colorForKey:@"prysmPowerLock" withFallback:UIColor.whiteColor];

	self.rebootButton.imageView.image =       [settings valueForKey:@"prysmPowerReboot"] ? [self.rebootButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.rebootButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.rebootButton.imageView.tintColor =   [MagmaHelper colorForKey:@"prysmPowerReboot" withFallback:UIColor.whiteColor];

	self.shutdownButton.imageView.image =     [settings valueForKey:@"prysmPowerShutdown"] ? [self.shutdownButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.shutdownButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.shutdownButton.imageView.tintColor = [MagmaHelper colorForKey:@"prysmPowerShutdown" withFallback:UIColor.whiteColor];

	self.view.backgroundColor =               [MagmaHelper colorForKey:@"prysmPowerContainerBackground" withFallback:kDefaultContainerBackground];
}
%end

%hook PrysmBatteryModuleViewController
-(void)reloadBatteryInfo {
	%orig;

	// First device
	self.firstDevice.batteryPercentLabel.textColor =  [MagmaHelper colorForKey:@"prysmBatteryFirstBatteryPercentage" withFallback:UIColor.whiteColor];
	self.firstDevice.deviceNameLabel.textColor =      [MagmaHelper colorForKey:@"prysmBatteryFirstDeviceName" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.firstDevice.deviceIconView.image =           [settings valueForKey:@"prysmBatteryFirstDeviceIcon"] ? [self.firstDevice.deviceIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.firstDevice.deviceIconView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.firstDevice.deviceIconView.tintColor =       [MagmaHelper colorForKey:@"prysmBatteryFirstDeviceIcon" withFallback:UIColor.whiteColor];

	self.firstDevice.batteryView.fillColor =          [MagmaHelper colorForKey:@"prysmBatteryFirstBatteryIcon" withFallback:UIColor.whiteColor];
	self.firstDevice.batteryView.bodyColor =          [MagmaHelper colorForKey:@"prysmBatteryFirstBatteryIcon" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.4]];
	self.firstDevice.batteryView.pinColor =           [MagmaHelper colorForKey:@"prysmBatteryFirstBatteryIcon" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.5]];


	// Second device
	self.secondDevice.batteryPercentLabel.textColor = [MagmaHelper colorForKey:@"prysmBatterySecondBatteryPercentage" withFallback:UIColor.whiteColor];
	self.secondDevice.deviceNameLabel.textColor =     [MagmaHelper colorForKey:@"prysmBatterySecondDeviceName" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.secondDevice.deviceIconView.image =          [settings valueForKey:@"prysmBatterySecondDeviceIcon"] ? [self.secondDevice.deviceIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.secondDevice.deviceIconView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.secondDevice.deviceIconView.tintColor =      [MagmaHelper colorForKey:@"prysmBatterySecondDeviceIcon" withFallback:UIColor.whiteColor];

	self.secondDevice.batteryView.fillColor =         [MagmaHelper colorForKey:@"prysmBatterySecondBatteryIcon" withFallback:UIColor.whiteColor];
	self.secondDevice.batteryView.bodyColor =         [MagmaHelper colorForKey:@"prysmBatterySecondBatteryIcon" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.4]];
	self.secondDevice.batteryView.pinColor =          [MagmaHelper colorForKey:@"prysmBatterySecondBatteryIcon" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.5]];


	// Third device
	self.thirdDevice.batteryPercentLabel.textColor =  [MagmaHelper colorForKey:@"prysmBatteryThirdBatteryPercentage" withFallback:UIColor.whiteColor];
	self.thirdDevice.deviceNameLabel.textColor =      [MagmaHelper colorForKey:@"prysmBatteryThirdDeviceName" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.thirdDevice.deviceIconView.image =           [settings valueForKey:@"prysmBatteryThirdDeviceIcon"] ? [self.thirdDevice.deviceIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [self.thirdDevice.deviceIconView.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
	self.thirdDevice.deviceIconView.tintColor =       [MagmaHelper colorForKey:@"prysmBatteryThirdDeviceIcon" withFallback:UIColor.whiteColor];

	self.thirdDevice.batteryView.fillColor =          [MagmaHelper colorForKey:@"prysmBatteryThirdBatteryIcon" withFallback:UIColor.whiteColor];
	self.thirdDevice.batteryView.bodyColor =          [MagmaHelper colorForKey:@"prysmBatteryThirdBatteryIcon" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.4]];
	self.thirdDevice.batteryView.pinColor =           [MagmaHelper colorForKey:@"prysmBatteryThirdBatteryIcon" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.5]];


	self.view.backgroundColor =                       [MagmaHelper colorForKey:@"prysmBatteryContainerBackground" withFallback:kDefaultContainerBackground];
}
%end

%hook PrysmCalendarModuleViewController
-(void)reloadCalendarInfo {
	%orig;

	[self magmaEvoColorize];
}

%new
-(void)magmaEvoColorize {
	if ([settings valueForKey:@"prysmCalendarFirstColorIndicator"]) {
		self.firstEvent.colorIndicatorView.backgroundColor = [MagmaHelper colorForKey:@"prysmCalendarFirstColorIndicator" withFallback:nil];
	}
	self.firstEvent.eventTitleLabel.textColor =          [MagmaHelper colorForKey:@"prysmCalendarFirstEventTitle" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.firstEvent.dateLabel.textColor =                [MagmaHelper colorForKey:@"prysmCalendarFirstDateLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.firstEvent.timeLabel.textColor =                [MagmaHelper colorForKey:@"prysmCalendarFirstTimeLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];

	if ([settings valueForKey:@"prysmCalendarSecondColorIndicator"]) {
		self.secondEvent.colorIndicatorView.backgroundColor = [MagmaHelper colorForKey:@"prysmCalendarSecondColorIndicator" withFallback:nil];
	}
	self.secondEvent.eventTitleLabel.textColor =          [MagmaHelper colorForKey:@"prysmCalendarSecondEventTitle" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.secondEvent.dateLabel.textColor =                [MagmaHelper colorForKey:@"prysmCalendarSecondDateLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.secondEvent.timeLabel.textColor =                [MagmaHelper colorForKey:@"prysmCalendarSecondTimeLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];

	if ([settings valueForKey:@"prysmCalendarThirdColorIndicator"]) {
		self.thirdEvent.colorIndicatorView.backgroundColor = [MagmaHelper colorForKey:@"prysmCalendarThirdColorIndicator" withFallback:nil];
	}
	self.thirdEvent.eventTitleLabel.textColor =          [MagmaHelper colorForKey:@"prysmCalendarThirdEventTitle" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.thirdEvent.dateLabel.textColor =                [MagmaHelper colorForKey:@"prysmCalendarThirdDateLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];
	self.thirdEvent.timeLabel.textColor =                [MagmaHelper colorForKey:@"prysmCalendarThirdTimeLabel" withFallback:[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.7]];

	self.view.backgroundColor =                          [MagmaHelper colorForKey:@"prysmCalendarContainerBackground" withFallback:kDefaultContainerBackground];

}
%end

%hook PrysmCardBackgroundViewController
-(void)viewDidLayoutSubviews {
	%orig;

	[self magmaEvoColorize];
	[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
}

%new
-(void)magmaEvoColorize {
	self.overlayView.backgroundColor = [MagmaHelper colorForKey:@"miscMainBackground" withFallback:[UIColor colorWithWhite:0 alpha:0.3]];
}
%end

%hook PrysmMainPageViewController
-(void)setDarkModeEnabled:(BOOL)arg1 {
	%orig;

	// This method gets called everytime the CC is opened. %orig then sets the backgroundColor and style according to arg1, so we have to overwrite it again
	self.cardViewController.backdropViewController.overlayView.backgroundColor = [MagmaHelper colorForKey:@"miscMainBackground" withFallback:[UIColor colorWithWhite:0 alpha:0.3]];

}
%end

%hook PrysmButtonView
-(void)setBackgroundColor:(UIColor *)color {
	[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoForceUpdate) name:@"com.noisyflake.magmaevo/reload" object:nil];

	if (![self._viewControllerForAncestor isKindOfClass:%c(PrysmConnectivityModuleViewController)] && ![self._viewControllerForAncestor isKindOfClass:%c(PrysmPowerModuleViewController)]) {
		color = [MagmaHelper colorForKey:@"togglesContainerBackground" withFallback:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.15]];
	}

	if ([self._viewControllerForAncestor isKindOfClass:%c(PrysmPowerModuleViewController)] && [settings valueForKey:@"prysmPowerToggleBackground"]) {
		color = [MagmaHelper colorForKey:@"prysmPowerToggleBackground" withFallback:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.15]];
	}

	%orig(color);
}

%new
-(void)magmaEvoForceUpdate {
	self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
}
%end

UIColor *getPrysmConnectivityColor(PrysmButtonView *view) {
	NSString *internalName = nil;
	PrysmConnectivityModuleViewController *parent = view._viewControllerForAncestor;
	if (view == parent.airdropButton) internalName = @"CCUIConnectivityAirDropViewController";
	if (view == parent.airplaneButton) internalName = @"CCUIConnectivityAirplaneViewController";
	if (view == parent.bluetoothButton) internalName = @"CCUIConnectivityBluetoothViewController";
	if (view == parent.cellularButton) internalName = @"CCUIConnectivityCellularDataViewController";
	if (view == parent.wifiButton) internalName = @"CCUIConnectivityWifiViewController";

	NSString *prefKey = [NSString stringWithFormat:@"%@%@", internalName, view.state ? @"Enabled" : @"Disabled"];
	UIColor *color = nil;

	if (view.state) {
		color = [[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] ? [UIColor clearColor] : getColorForPrefKey(prefKey);
	} else {
		color = [[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] ? [UIColor clearColor] : nil;
	}

	if (color == nil) {
		if ([prefKey isEqual:@"CCUIConnectivityAirDropViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
		if ([prefKey isEqual:@"CCUIConnectivityAirplaneViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#FF9500"];
		if ([prefKey isEqual:@"CCUIConnectivityBluetoothViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
		if ([prefKey isEqual:@"CCUIConnectivityCellularDataViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#4CD964"];
		if ([prefKey isEqual:@"CCUIConnectivityHotspotViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#4CD964"];
		if ([prefKey isEqual:@"CCUIConnectivityWifiViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
	}

	return color;
}

UIColor *getPrysmConnectivityGlyphColor(UIImageView *view) {
	NSString *prefKey = nil;
	PrysmConnectivityModuleViewController *parent = view._viewControllerForAncestor;
	if (view == parent.airdropButton.altStateImageView) prefKey = @"CCUIConnectivityAirDropViewControllerEnabled";
	if (view == parent.airdropButton.imageView) prefKey = @"CCUIConnectivityAirDropViewControllerDisabled";

	if (view == parent.airplaneButton.altStateImageView) prefKey = @"CCUIConnectivityAirplaneViewControllerEnabled";
	if (view == parent.airplaneButton.imageView) prefKey = @"CCUIConnectivityAirplaneViewControllerDisabled";

	if (view == parent.bluetoothButton.altStateImageView) prefKey = @"CCUIConnectivityBluetoothViewControllerEnabled";
	if (view == parent.bluetoothButton.imageView) prefKey = @"CCUIConnectivityBluetoothViewControllerDisabled";

	if (view == parent.cellularButton.altStateImageView) prefKey = @"CCUIConnectivityCellularDataViewControllerEnabled";
	if (view == parent.cellularButton.imageView) prefKey = @"CCUIConnectivityCellularDataViewControllerDisabled";

	if (view == parent.wifiButton.altStateImageView) prefKey = @"CCUIConnectivityWifiViewControllerEnabled";
	if (view == parent.wifiButton.imageView) prefKey = @"CCUIConnectivityWifiViewControllerDisabled";

	if (([[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] && [prefKey containsString:@"Enabled"])
		|| [prefKey containsString:@"Disabled"]) {
		UIColor *color = getColorForPrefKey(prefKey);
		if (color == nil) {
			if ([prefKey isEqual:@"CCUIConnectivityAirDropViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
			if ([prefKey isEqual:@"CCUIConnectivityAirplaneViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#FF9500"];
			if ([prefKey isEqual:@"CCUIConnectivityBluetoothViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
			if ([prefKey isEqual:@"CCUIConnectivityCellularDataViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#4CD964"];
			if ([prefKey isEqual:@"CCUIConnectivityHotspotViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#4CD964"];
			if ([prefKey isEqual:@"CCUIConnectivityWifiViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
		}

		return color ?: UIColor.whiteColor;
	}

	if (![[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] && [prefKey containsString:@"Enabled"]) {
		return [getColorForPrefKey(prefKey) evoIsBrightColor] ? [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] : [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
	}

	return nil;
}

UIColor *getPrysmToggleColor(UIView *view) {
	PrysmButtonView *prysmView = getPrysmButtonView(view);

	if (prysmView == nil) return nil;

	NSString *prefKey = [NSString stringWithFormat:@"%@%@", prysmView.identifier, isPrysmButtonSelected(prysmView) ? @"Enabled" : @"Disabled"];

	return getColorForPrefKey(prefKey);
}

bool isPrysmButtonSelected(PrysmButtonView *view) {
	UIViewController *controller = view.moduleController ?: view.ccButton;

	if ([controller isKindOfClass:%c(CCUIButtonModuleViewController)]) {
		return ((CCUIButtonModuleViewController *)controller).selected;
	}

	return NO;
}

PrysmButtonView *getPrysmButtonView(UIView *view) {
	while (view.superview != nil && ![view isKindOfClass:%c(PrysmButtonView)]) {
		view = view.superview;
	}

	if ([view isKindOfClass:%c(PrysmButtonView)]) return (PrysmButtonView *)view;
	return nil;
}

%ctor {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"] && [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"]) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib", RTLD_LAZY);
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmConnectivity.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmSlider.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmMedia.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmWeather.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmPower.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmBattery.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmCalendar.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmReminders.bundle/"] load];
		%init;
	}
}
