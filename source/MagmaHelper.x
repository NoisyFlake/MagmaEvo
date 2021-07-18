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

        view.backgroundColor = value ? [UIColor evoRGBAColorFromHexString:value] : nil;
        view.alpha = 1;

    } else if ([view isKindOfClass:%c(MTMaterialView)]) {
        view = [view safeValueForKey:@"_backdropView"];

        if (view == nil) return;

        ((_MTBackdropView *)view).colorMatrixColor = value ? (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? UIColor.clearColor : nil) : [UIColor colorWithWhite:0.196 alpha:0.5];
        ((_MTBackdropView *)view).brightness = value ? 0 : -0.12;
        ((_MTBackdropView *)view).saturation = value ? 0 : 1.7;
        view.alpha = value ? ((CGColorGetComponents([UIColor evoRGBAColorFromHexString:value].CGColor)[3] == 0) ? 0 : 1) : 1;
        view.backgroundColor = value ? [UIColor evoRGBAColorFromHexString:value] : nil;
    }

}

+ (UIColor *)colorForKey:(NSString *)key withFallback:(UIColor *)fallback {
    return [settings valueForKey:key] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:key]] : fallback;
}

@end