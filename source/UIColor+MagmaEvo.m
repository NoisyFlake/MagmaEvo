#include "UIColor+MagmaEvo.h"

@implementation UIColor (MagmaEvo)

+(UIColor *)evoRGBAColorFromHexString:(NSString *)string {
    if(string == nil || string.length == 0) {
        return nil;
    }

    CGFloat alpha = 1.0;
    NSUInteger location = [string rangeOfString:@":"].location;
    NSString *hexString;

    if(location != NSNotFound) {
        alpha = [[string substringFromIndex:(location + 1)] floatValue];
        hexString = [string substringWithRange:NSMakeRange(0, location)];
    } else {
        hexString = [string copy];
    }

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];

    if([hexString rangeOfString:@"#"].location == 0) {
        [scanner setScanLocation:1];
    }

    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0
                    green:((rgbValue & 0xFF00) >> 8) / 255.0
                    blue:(rgbValue & 0xFF) / 255.0
                    alpha:alpha];
}

+(NSString *)evoHexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    CGFloat a = components[3];

    return [NSString stringWithFormat:@"#%02X%02X%02X:%f", (int)(r * 255), (int)(g * 255), (int)(b * 255), a];
}

+(UIColor *)evoInverseColor:(UIColor *)color {
    CGFloat r, g, b, a;

    [color getRed:&r green:&g blue:&b alpha:&a];

    return [UIColor colorWithRed:(1.0 - r) green:(1.0 - g) blue:(1.0 - b) alpha:a];
}

- (BOOL)evoIsBrightColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    return (colorBrightness > 0.65);
}

@end

@implementation NSNotificationCenter (MagmaEvo)

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object {

        [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];

}

@end
