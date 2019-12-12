@interface UIView (MagmaEvo)
-(id)_viewControllerForAncestor;
@end

@interface CCUIButtonModuleView : UIControl
@end

@interface CCUIButtonModuleViewController : UIViewController
@property (assign,getter=isSelected,nonatomic) BOOL selected;
@end

@interface CCUILabeledRoundButtonViewController : UIViewController
@property (assign,getter=isEnabled,nonatomic) BOOL enabled;
@property (nonatomic,retain) UIColor * highlightColor;
@end

@interface CCUIToggleModule : NSObject
@end

@interface CCUIToggleViewController : CCUIButtonModuleViewController
-(CCUIToggleModule *)module;
@end

@interface _UIStatusBar : UIView
@property (nonatomic,readonly) UIView * containerView;
@end

@interface CAFilter : NSObject
@property (copy) NSString * name;
@end

@interface CALayer (MagmaEvo)
@property (assign) CGColorRef contentsMultiplyColor;
@property (retain) CAFilter *compositingFilter;
@end

static CGColorRef getColorForLayer(CALayer *layer, CGColorRef originalColor, BOOL overwriteEmpty);
static void forceLayerUpdate(NSArray *layers);
