#import "UIColor+MagmaEvo.h"

#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((@"[MagmaEvo] [%s:%d] " fmt), __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define NSLog(fmt, ...)
#endif

@interface NSObject (MagmaEvo)
- (id)safeValueForKey:(id)arg1;
@end

@interface MagmaPrefs : NSObject
@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) NSDictionary *defaultSettings;
+ (id)sharedInstance;
- (id)init;
-(BOOL)boolForKey:(NSString *)key;
-(NSString *)valueForKey:(NSString *)key;
@end

@interface UIView (MagmaEvo)
@property (nonatomic,readonly) UIView * _ui_superview;
@property (assign,nonatomic) long long compositingMode;
@property (nonatomic,readonly) id parentFocusEnvironment;
-(id)_viewControllerForAncestor;
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
@property (assign,nonatomic) double brightness;
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,copy) NSString * moduleIdentifier;
@property (nonatomic,retain) UIViewController * contentViewController;
@end

@interface CCUIContentModuleContentContainerView : UIView
@property (nonatomic,readonly) MTMaterialView * moduleMaterialView;
@end

@interface CCUIButtonModuleView : UIControl
@property (nonatomic,retain) UIColor * selectedGlyphColor;
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
@end

@interface PrysmConnectivityModuleViewController : UIViewController
@property (nonatomic,readonly) PrysmButtonView *airdropButton;
@property (nonatomic,readonly) PrysmButtonView *airplaneButton;
@property (nonatomic,readonly) PrysmButtonView *bluetoothButton;
@property (nonatomic,readonly) PrysmButtonView *cellularButton;
@property (nonatomic,readonly) PrysmButtonView *wifiButton;
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
@end

@interface PrysmPowerModuleViewController : UIViewController
@property (nonatomic,readonly) PrysmButtonView *respringButton;
@property (nonatomic,readonly) PrysmButtonView *safemodeButton;
@property (nonatomic,readonly) PrysmButtonView *lockButton;
@property (nonatomic,readonly) PrysmButtonView *rebootButton;
@property (nonatomic,readonly) PrysmButtonView *shutdownButton;
@end

@interface PrysmSliderModuleViewController : UIViewController
@property (nonatomic,retain) PrysmSliderViewController * audioSlider;
@property (nonatomic,retain) PrysmSliderViewController * brightnessSlider;
@end

@interface PrysmMediaModuleViewController : UIViewController
@property (nonatomic,retain) UIButton * skipButton;
@property (nonatomic,retain) UIButton * rewindButton;
@property (nonatomic,retain) UIButton * playPauseButton;
@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UILabel * subtitleLabel;
@property (nonatomic,strong,readwrite) UIView * progressView;
@property (nonatomic,strong,readwrite) UIView * artworkView;
@property (nonatomic,strong,readwrite) UIView * applicationContainer;
@property (nonatomic,strong,readwrite) UIImageView * applicationView;
@property (nonatomic,strong,readwrite) UIImageView * applicationOverlayView;
@end

@interface PrysmCardBackgroundViewController : UIViewController
@property (nonatomic,retain) UIView * overlayView;
@end

@interface CCUIRoundButton : UIControl
@property (nonatomic,retain) UIView * normalStateBackgroundView;
@property (nonatomic,retain) UIImageView * selectedGlyphView;
@property (nonatomic,retain) CCUICAPackageView * glyphPackageView;
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

@interface NextUpMediaHeaderView : MediaControlsHeaderView
@end

@interface MediaControlsMaterialView : UIView
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
@end

@interface CCUIStatusBar : UIView
@property (assign,nonatomic) double leadingAlpha;
@end

@interface CCUIModularControlCenterViewController : UIViewController
@end

@interface CCUIHeaderPocketView : UIView
@property (assign,nonatomic) double backgroundAlpha;
@end

@interface CCUIModularControlCenterOverlayViewController : CCUIModularControlCenterViewController
@property (nonatomic,readonly) MTMaterialView * overlayBackgroundView;
@property(readonly, nonatomic) UIView *overlayContainerView;
@property(readonly, nonatomic) UIScrollView *overlayScrollView;
@property(readonly, nonatomic) long long overlayInterfaceOrientation;
@property (nonatomic,readonly) CCUIHeaderPocketView * overlayHeaderView;
@end

@interface CAFilter : NSObject
@property (copy) NSString * name;
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
