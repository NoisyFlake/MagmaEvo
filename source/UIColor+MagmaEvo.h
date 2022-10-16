#import <UIKit/UIKit.h>

@interface UIColor (MagmaEvo)

+ (UIColor *)evoRGBAColorFromHexString:(NSString *)string;
+ (NSString *)evoHexStringFromColor:(UIColor *)color;
+ (UIColor *)evoInverseColor:(UIColor *)color;
- (BOOL)evoIsBrightColor;

@end

@interface NSNotificationCenter (MagmaEvo)

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object;

@end
