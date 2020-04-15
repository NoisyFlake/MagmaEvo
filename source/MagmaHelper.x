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

    } else if ([view isKindOfClass:%c(MTMaterialView)]) {
        view = [view safeValueForKey:@"_backdropView"];

        if (view == nil) return;

        // Remove all filters except for the gaussianBlur one
        NSMutableArray *filters = [NSMutableArray new];
        for (CAFilter *filter in view.layer.filters) {
            if ([filter.name isEqual:@"gaussianBlur"]) [filters addObject:filter];
        }

        // Seriously, fuck everything about how iOS 12 handles this
        view.layer.filters = filters;
        view.alpha = value ? ((CGColorGetComponents([UIColor evoRGBAColorFromHexString:value].CGColor)[3] == 0) ? 0 : 1) : 1;
        view.backgroundColor = value ? [UIColor evoRGBAColorFromHexString:value] : [UIColor colorWithWhite:0 alpha:0.5]; // here we fake the missing filters with a dark fallback color
    }

}

+ (UIColor *)colorForKey:(NSString *)key withFallback:(UIColor *)fallback {
    return [settings valueForKey:key] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:key]] : fallback;
}

@end