#import <Preferences/Preferences.h>

#define kEVOCOLOR [UIColor colorWithRed:0.81 green:0.06 blue:0.13 alpha:1.0]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface NSTask : NSObject
- (instancetype)init;
- (void)setLaunchPath:(NSString *)path;
- (void)setArguments:(NSArray *)arguments;
- (void)setStandardOutput:(id)output;
- (void)launch;
- (void)waitUntilExit;
@end

@interface UIView (MagmaEvo)
@property (copy,readonly) NSArray * allSubviews;
-(id)_viewControllerForAncestor;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface UINavigationItem (MagmaEvo)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end

@interface UIColor (MagmaEvoPrefs)
@property(class, nonatomic, readonly) UIColor *labelColor;
@property(class, nonatomic, readonly) UIColor *systemGrayColor;
@end

@interface CCSModuleSettingsProvider : NSObject
+(id)sharedProvider;
-(id)orderedUserEnabledModuleIdentifiers;
@end

@interface CCSModuleMetadata : NSObject
@property (nonatomic,copy,readonly) NSURL* moduleBundleURL;
@end

@interface CCSModuleRepository : NSObject
+(id)repositoryWithDefaults;
-(CCSModuleMetadata *)moduleMetadataForModuleIdentifier:(id)arg1;
@end

@interface MEVOBaseController : PSListController
@end

@interface MEVORootListController : MEVOBaseController
@end

@interface MEVOConnectivityController : MEVOBaseController
@end

@interface MEVOConnectivityOrderController : MEVOBaseController
@end

@interface MEVOTogglesController : MEVOBaseController
@end

@interface MEVOMediaControlsController : MEVOBaseController
@end

@interface MEVOSlidersController : MEVOBaseController
@end

@interface MEVOPrysmController : MEVOBaseController
@end

@interface MEVOPrysmPowerController : MEVOBaseController
@end

@interface MEVOPrysmWeatherController : MEVOBaseController
@end

@interface MEVOPrysmReminderController : MEVOBaseController
@end

@interface MEVOPrysmBatteryController : MEVOBaseController
@end

@interface MEVOPrysmCalendarController : MEVOBaseController
@end

@interface MEVOMiscController : MEVOBaseController
@end

@interface MEVOPowerModuleController : MEVOBaseController
@end

@interface MEVOBetterCCXIController : MEVOBaseController
@end

@interface MEVOPresetsController : MEVOBaseController
@end
