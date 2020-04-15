#import "MagmaEvo.h"

@implementation MagmaHelper

+ (void)colorizeMaterialView:(UIView *)view forSetting:(NSString *)key {
    NSString *value = [settings valueForKey:key];

    if ([view isKindOfClass:%c(MTMaterialView)] && [view respondsToSelector:@selector(configuration)]) {
        if (value) {
            ((MTMaterialView *)view).configuration = 1;
        } else {
            ((MTMaterialView *)view).configuration = 2;
            [((MTMaterialLayer *)view.layer) _updateForChangeInRecipeAndConfiguration];
            [((MTMaterialLayer *)view.layer) _setNeedsConfiguring];
        }
    } else if ([view isKindOfClass:%c(_MTBackdropView)]) {
        view = [view safeValueForKey:@"_backdropView"];

        if (value) {
            ((_MTBackdropView *)view).colorAddColor = nil;
			((_MTBackdropView *)view).brightness = 0;
        } else {
            ((_MTBackdropView *)view).colorAddColor = [UIColor colorWithWhite:1.0 alpha:0.25];
            ((_MTBackdropView *)view).brightness = 0.52;
        }
    }

    view.backgroundColor = value ? [UIColor evoRGBAColorFromHexString:value] : nil;
}

+ (UIColor *)colorForKey:(NSString *)key withFallback:(UIColor *)fallback {
    return [settings valueForKey:key] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:key]] : fallback;
}

@end