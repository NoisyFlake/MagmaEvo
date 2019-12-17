#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define kEVOCOLOR [UIColor colorWithRed:0.81 green:0.06 blue:0.13 alpha:1.0]

@interface UINavigationItem (CozyBadges)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end

@interface MEVOBaseController : PSListController
@end

@interface MEVORootListController : MEVOBaseController
@end

@interface MEVOConnectivityController : MEVOBaseController
@end
