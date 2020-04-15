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
    }

    // For iOS 12 we don't need to do anything except set the backgroundColor as the BackdropView is already correctly configured

    view.backgroundColor = value ? [UIColor evoRGBAColorFromHexString:value] : nil;
}

+ (UIColor *)colorForKey:(NSString *)key withFallback:(UIColor *)fallback {
    return [settings valueForKey:key] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:key]] : fallback;
}

@end