@interface UIView (MagmaEvo)
-(id)_viewControllerForAncestor;
@end

@interface CCUIButtonModuleView : UIControl
@end

@interface CCUIButtonModuleViewController : UIViewController
@property (assign,getter=isSelected,nonatomic) BOOL selected;
@end

@interface CCUIToggleViewController : CCUIButtonModuleViewController
@end

@interface CALayer (MagmaEvo)
@property (assign) CGColorRef contentsMultiplyColor;
@end

static CGColorRef getColorForLayer(CALayer *layer, CGColorRef originalColor, BOOL overwriteEmpty);
static void forceLayerUpdate(NSArray *layers);
