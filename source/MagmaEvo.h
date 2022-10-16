#import <UIKit/UIKit.h>
#import "UIColor+MagmaEvo.h"
#include <dlfcn.h>

#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((@"[MagmaEvo] " fmt), ##__VA_ARGS__)
#else
#define NSLog(fmt, ...)
#endif

@interface NSObject (MagmaEvo)
- (id)safeValueForKey:(id)arg1;
@end

@interface UILabel (MagmaEvo)
-(void)magmaEvoColorize;
-(UIColor *)magmaEvoGetLabelColor;
@end

@interface MagmaPrefs : NSObject
@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) NSDictionary *defaultSettings;
+ (id)sharedInstance;
- (id)init;
-(void)loadPresetForStyle:(UIUserInterfaceStyle)style;
-(BOOL)boolForKey:(NSString *)key;
-(NSString *)valueForKey:(NSString *)key;
@end

@interface MagmaHelper : NSObject
+ (void)colorizeMaterialView:(UIView *)view forSetting:(NSString *)key;
+ (UIColor *)colorForKey:(NSString *)key withFallback:(UIColor *)fallback;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface UITraitCollection (MagmaEvo)
@property(nonatomic, readonly) UIUserInterfaceStyle userInterfaceStyle API_AVAILABLE(ios(12.0));
@end

@interface UIView (MagmaEvo)
@property (nonatomic,readonly) UIView * _ui_superview;
@property (assign,nonatomic) long long compositingMode;
@property (nonatomic,readonly) id parentFocusEnvironment;
-(id)_viewControllerForAncestor;
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection;
@end

@interface UIRootSceneWindow : UIView
@end

@interface UIViewController (MagmaEvo)
@property (nonatomic,readonly) id parentFocusEnvironment;
@end

@interface NSArray (MagmaEvo)
- (NSArray *)shuffledArray;
@end

@interface MTMaterialView : UIView
@property (assign,nonatomic) long long configuration;
@end

@interface _MTBackdropView : UIView
@property (nonatomic,copy) UIColor * colorAddColor;
@property (nonatomic, copy) UIColor *colorMatrixColor;
@property (nonatomic) double saturation;
@property (assign,nonatomic) double brightness;
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,copy) NSString * moduleIdentifier;
@property (nonatomic,retain) UIViewController * contentViewController;
@end

@interface CCUIContentModuleContentContainerView : UIView
@property (nonatomic,readonly) MTMaterialView * moduleMaterialView;
-(void)magmaEvoColorize;
@end

@interface CCUIButtonModuleView : UIControl
@property (nonatomic,retain) UIColor * selectedGlyphColor;
-(void)magmaEvoColorize;
@end

@interface CCUICAPackageView : UIView
@end

@interface PrysmButtonView : UIView
@property (nonatomic,copy) NSString * identifier;
@property (nonatomic,retain) UIColor * altStateColor;
@property (assign,nonatomic) BOOL state;
@property(readonly, nonatomic) UIImageView *altStateImageView;
@property(readonly, nonatomic) UIImageView *imageView;
@property(nonatomic, strong, readwrite) UIViewController *ccButton;
@property(nonatomic, strong, readwrite) UIViewController *moduleController;
-(void)magmaEvoForceUpdate;
@end

@interface PrysmConnectivityModuleViewController : UIViewController
@property (nonatomic,readonly) PrysmButtonView *airdropButton;
@property (nonatomic,readonly) PrysmButtonView *airplaneButton;
@property (nonatomic,readonly) PrysmButtonView *bluetoothButton;
@property (nonatomic,readonly) PrysmButtonView *cellularButton;
@property (nonatomic,readonly) PrysmButtonView *wifiButton;
-(void)magmaEvoColorize;
@end

@interface PrysmSliderViewController : UIViewController
@property (nonatomic,retain) UIView * overlayView;
@property (nonatomic,retain) UIImageView * overlayImageView;
@property (nonatomic,retain) UILabel * percentOverlayLabel;
@property (nonatomic,retain) CCUICAPackageView * packageView;
@property (nonatomic,assign,readwrite) int style;
@end

@interface PrysmWeatherModuleViewController : UIViewController
@property (nonatomic,strong,readwrite) UIImageView *conditionImageView;
@property (nonatomic,strong,readwrite) UILabel *currentTemperatureLabel;
@property (nonatomic,strong,readwrite) UILabel *locationSubtitleLabel;
@property (nonatomic,strong,readwrite) UILabel *locationTitleLabel;
@property (nonatomic,strong,readwrite) UILabel *temperatureRangeLabel;
-(void)magmaEvoColorize;
@end

@interface PrysmReminderView : UIView
@property (nonatomic, retain) UILabel *eventTitleLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UIView *ringView;
@property (nonatomic, retain) UIView *circleView;
@end

@interface PrysmRemindersModuleViewController : UIViewController
@property (nonatomic,readonly) PrysmReminderView *firstEvent;
@property (nonatomic,readonly) PrysmReminderView *secondEvent;
@property (nonatomic,readonly) PrysmReminderView *thirdEvent;
@property (nonatomic,readonly) PrysmReminderView *fourthEvent;
@property (nonatomic, retain) UILabel *noRemindersLabel;
-(void)magmaEvoColorize;
@end

@interface PrysmPowerModuleViewController : UIViewController
@property (nonatomic,readonly) PrysmButtonView *respringButton;
@property (nonatomic,readonly) PrysmButtonView *safemodeButton;
@property (nonatomic,readonly) PrysmButtonView *lockButton;
@property (nonatomic,readonly) PrysmButtonView *rebootButton;
@property (nonatomic,readonly) PrysmButtonView *shutdownButton;
-(void)magmaEvoColorize;
@end

@interface PrysmCalendarView : UIView
@property (nonatomic,readonly) UIView *colorIndicatorView;
@property (nonatomic,readonly) UILabel *eventTitleLabel;
@property (nonatomic,readonly) UILabel *dateLabel;
@property (nonatomic,readonly) UILabel *timeLabel;
@end

@interface PrysmCalendarModuleViewController : UIViewController
@property (nonatomic,readonly) PrysmCalendarView *firstEvent;
@property (nonatomic,readonly) PrysmCalendarView *secondEvent;
@property (nonatomic,readonly) PrysmCalendarView *thirdEvent;
-(void)magmaEvoColorize;
@end

@interface _UIBatteryView : UIView
@property (nonatomic,copy) UIColor* fillColor;
@property (nonatomic,copy) UIColor* bodyColor;
@property (nonatomic,copy) UIColor* pinColor;
@end

@interface PrysmBatteryDeviceView : UIView
@property (nonatomic, strong, readwrite) UIImageView *deviceIconView;
@property (nonatomic, strong, readwrite) UILabel *batteryPercentLabel;
@property (nonatomic, strong, readwrite) _UIBatteryView *batteryView;
@property (nonatomic, strong, readwrite) UILabel *deviceNameLabel;
@end

@interface PrysmBatteryModuleViewController : UIViewController
@property (nonatomic, strong, readwrite) PrysmBatteryDeviceView *firstDevice;
@property (nonatomic, strong, readwrite) PrysmBatteryDeviceView *secondDevice;
@property (nonatomic, strong, readwrite) PrysmBatteryDeviceView *thirdDevice;
@end

@interface PrysmSliderModuleViewController : UIViewController
@property (nonatomic,retain) PrysmSliderViewController * audioSlider;
@property (nonatomic,retain) PrysmSliderViewController * brightnessSlider;
-(void)magmaEvoColorize;
@end

@interface PrysmProgressIndicator : UILabel
@property (nonatomic, copy, readwrite) UIColor *progressColor;
@end

@interface PrysmMediaModuleViewController : UIViewController
@property (nonatomic,retain) UIButton * skipButton;
@property (nonatomic,retain) UIButton * rewindButton;
@property (nonatomic,retain) UIButton * playPauseButton;
@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UILabel * subtitleLabel;
@property (nonatomic,strong,readwrite) UIView * progressView;
@property (nonatomic,strong,readwrite) PrysmProgressIndicator * roundProgressView;
@property (nonatomic,strong,readwrite) UIView * artworkView;
@property (nonatomic,strong,readwrite) UIView * applicationContainer;
@property (nonatomic,strong,readwrite) UIImageView * applicationView;
@property (nonatomic,strong,readwrite) UIImageView * applicationOverlayView;
-(void)magmaEvoColorize;
@end

@interface PrysmCardBackgroundViewController : UIViewController
@property (nonatomic,retain) UIView * overlayView;
-(void)magmaEvoColorize;
@end

@interface PrysmCardViewController : UIViewController
@property (nonatomic, strong, readwrite) PrysmCardBackgroundViewController *backdropViewController;
@end

@interface PrysmMainPageViewController : UIViewController
@property (nonatomic, strong, readwrite) PrysmCardViewController *cardViewController;
@end

@interface NextUpViewController : UIViewController
@property (nonatomic, assign, readwrite) BOOL controlCenter;
@end

@interface CCUIRoundButton : UIControl
@property (nonatomic,retain) UIView * normalStateBackgroundView;
@property (nonatomic,retain) UIView * selectedStateBackgroundView;
@property (nonatomic,retain) UIImageView * selectedGlyphView;
@property (nonatomic,retain) CCUICAPackageView * glyphPackageView;
-(void)magmaEvoColorize;
@end

@interface CCUILabeledRoundButtonViewController : UIViewController
@property (assign,getter=isEnabled,nonatomic) BOOL enabled;
-(UIColor *)evoGetToggleColor:(UIColor *)color;
@end

@interface CCUIContentModuleContext : NSObject
@property (nonatomic,copy,readonly) NSString * moduleIdentifier;
@end

@interface CCUIBaseSliderView : UIControl
@end

@interface CCUIContinuousSliderView : CCUIBaseSliderView
-(void)magmaEvoColorize;
@end

@interface CCUIModuleSliderView : UIControl
-(void)magmaEvoColorize;
@end

@interface MediaControlsVolumeSliderView : CCUIContinuousSliderView
-(void)magmaEvoColorizeContainer;
@end

@interface MediaControlsTimeControl : UIControl
@property (nonatomic,retain) UIView * elapsedTrack;
-(void)magmaEvoColorize;
@end

@interface CCUIButtonModuleViewController : UIViewController
@property (assign,getter=isSelected,nonatomic) BOOL selected;
@property (assign,getter=isExpanded,nonatomic) BOOL expanded;
@property (nonatomic,readonly) CCUIButtonModuleView * buttonView;
-(CCUIContentModuleContext *)contentModuleContext;
@end

@interface CCUIConnectivityModuleViewController : UIViewController
@property (nonatomic,strong,readwrite) NSArray *portraitButtonViewControllers;
@property (nonatomic,strong,readwrite) NSArray *landscapeButtonViewControllers;
-(NSArray*)evoGetToggleOrder:(NSArray *)originalOrder;
@end

@interface HUCCHomeButton : UIControl
-(void)magmaEvoUpdateLayers;
@end

@interface CCUIMenuModuleViewController : CCUIButtonModuleViewController
@end

@interface MPButton : UIButton
@end

@interface MediaControlsTransportButton : MPButton
@end

@interface MediaControlsTransportStackView : UIView
@property (nonatomic,retain) MediaControlsTransportButton * leftButton;
@property (nonatomic,retain) MediaControlsTransportButton * middleButton;
@property (nonatomic,retain) MediaControlsTransportButton * rightButton;
@property (assign,nonatomic) long long style;
-(void)magmaEvoColorize;
@end

@interface MediaControlsHeaderView : UIView
@property (nonatomic,retain) UILabel * primaryLabel;
@property (nonatomic,retain) UILabel * secondaryLabel;
@property (assign,nonatomic) long long style;
@property (assign,nonatomic) long long buttonType;
-(void)magmaEvoColorize;
@end

@interface MRUNowPlayingView : UIView
-(void)magmaEvoColorize;
@end

@interface MRUNowPlayingTimeControlsView : UIControl
@property (nonatomic,retain) UIView * elapsedTrack;
-(void)magmaEvoColorize;
@end

@interface MRUNowPlayingRoutingButton : MPButton
@property (nonatomic,retain) CCUICAPackageView * packageView;
-(void)magmaEvoColorize;
@end

@interface MRUTransportButton : MPButton
@end

@interface MRUNowPlayingTransportControlsView : UIView
@property (nonatomic,retain) MRUTransportButton * leftButton;
@property (nonatomic,retain) MRUTransportButton * middleButton;
@property (nonatomic,retain) MRUTransportButton * rightButton;
-(void)magmaEvoColorize;
@end

@interface MRUNowPlayingLabelView : UIView
@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UILabel * subtitleLabel;
@property (nonatomic,retain) UILabel * placeholderLabel;
-(void)magmaEvoColorize;
@end

@interface NextUpMediaHeaderView : MediaControlsHeaderView
@end

@interface MediaControlsMaterialView : UIView
-(void)magmaEvoColorize;
@end

@interface MediaControlsRoutingCornerView : CCUICAPackageView
@end

@interface MRPlatterViewController : UIViewController
@property(nonatomic) long long style;
@property(retain, nonatomic) MediaControlsRoutingCornerView *routingCornerView;
@end

@interface CCUIToggleModule : NSObject
-(CCUIContentModuleContext *)contentModuleContext;
@end

@interface CCUIToggleViewController : CCUIButtonModuleViewController
-(CCUIToggleModule *)module;
@end

@interface _UIStatusBar : UIView
@property (nonatomic,readonly) UIView * containerView;
-(void)setForegroundColor:(UIColor *)arg1;
-(void)magmaEvoColorize;
@end

@interface CCUIStatusBar : UIView
@property (assign,nonatomic) double leadingAlpha;
@end

@interface TVRMContentViewController : UIViewController
@property (nonatomic, strong, readwrite) CCUIButtonModuleViewController *buttonModuleViewController;
@end

@interface CCUIModularControlCenterViewController : UIViewController
@end

@interface CCUIHeaderPocketView : UIView
@property (assign,nonatomic) double backgroundAlpha;
@end

@interface AXCCIconViewController : UIViewController
-(void)magmaEvoUpdateLayers;
@end

@interface CCUIModularControlCenterOverlayViewController : CCUIModularControlCenterViewController
@property (nonatomic,readonly) MTMaterialView * overlayBackgroundView;
@property(readonly, nonatomic) UIView *overlayContainerView;
@property(readonly, nonatomic) UIScrollView *overlayScrollView;
@property(readonly, nonatomic) long long overlayInterfaceOrientation;
@property (nonatomic,readonly) CCUIHeaderPocketView * overlayHeaderView;
-(void)magmaEvoColorizeMain;
@end

@interface CAFilter : NSObject
@property (copy) NSString * name;
@property (getter=isEnabled) BOOL enabled;
+(id)filterWithName:(id)arg1;
@end

@interface CALayer (MagmaEvo)
@property (assign) CGColorRef contentsMultiplyColor;
@property (retain) CAFilter *compositingFilter;
@end

@interface CABackdropLayer : CALayer
@end

@interface MTMaterialLayer : CABackdropLayer
@property (assign,getter=isReduceMotionEnabled,nonatomic) BOOL reduceMotionEnabled;
@property (assign,getter=isReduceTransparencyEnabled,nonatomic) BOOL reduceTransparencyEnabled;
-(void)_setNeedsConfiguring;
-(void)_updateForChangeInRecipeAndConfiguration;
@end

@interface WAWeatherPlatterViewController
@property(readonly, nonatomic) UIView *backgroundView;
@end

// --- Method list --- //

void forceLayerUpdate(NSArray *layers);

CGColorRef getConnectivityGlyphColor(CCUILabeledRoundButtonViewController *controller);
CGColorRef getPowerModuleColor(CCUILabeledRoundButtonViewController *controller);

UIColor *getToggleColor(UIViewController *controller);
UIColor *getColorForPrefKey(NSString *prefKey);

CGColorRef getSliderColor(UIViewController *controller, UIView *view);

UIColor *getPrysmConnectivityGlyphColor(UIImageView *view);
UIColor *getPrysmConnectivityColor(PrysmButtonView *view);
UIColor *getPrysmToggleColor(UIView *view);
bool isPrysmButtonSelected(PrysmButtonView *view);
PrysmButtonView *getPrysmButtonView(UIView *view);

// --- Definitions --- //

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

// --- Global objects --- //

MagmaPrefs *settings;
