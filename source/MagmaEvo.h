#import "UIColor+MagmaEvo.h"

#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((@"[MagmaEvo] [%s:%d] " fmt), __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define NSLog(fmt, ...)
#endif

@interface UIView (MagmaEvo)
@property (nonatomic,readonly) UIView * _ui_superview;
@property (copy,readonly) NSArray * allSubviews;
@property (assign,nonatomic) long long compositingMode;
@property (nonatomic,readonly) id parentFocusEnvironment;
-(id)_viewControllerForAncestor;
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
@end

@interface MediaControlsHeaderView : UIView
@property (nonatomic,retain) UILabel * primaryLabel;
@property (nonatomic,retain) UILabel * secondaryLabel;
@property (assign,nonatomic) long long style;
@property (assign,nonatomic) long long buttonType;
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

// --- Method list --- //

BOOL prefBool(NSString *key);
NSString* prefValue(NSString *key);
BOOL prefValueEquals(NSString *key, NSString *value);
void forceLayerUpdate(NSArray *layers);

CGColorRef getConnectivityGlyphColor(CCUILabeledRoundButtonViewController *controller);
CGColorRef getPowerModuleColor(CCUILabeledRoundButtonViewController *controller);
UIColor *getToggleColor(UIViewController *controller);
CGColorRef getSliderColor(UIViewController *controller, UIView *view);

// --- Definitions --- //

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
