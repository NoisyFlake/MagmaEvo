#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define kEVOCOLOR [UIColor colorWithRed:0.81 green:0.06 blue:0.13 alpha:1.0]

@interface UIView (MagmaEvo)
@property (copy,readonly) NSArray * allSubviews;
@end

@interface UINavigationItem (MagmaEvo)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end

@interface UIColor (MagmaEvo)
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

@interface MEVOMiscController : MEVOBaseController
@end

@interface MEVOPresetsController : MEVOBaseController
@end
