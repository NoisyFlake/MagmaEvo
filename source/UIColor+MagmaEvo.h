@interface UIColor (MagmaEvo)

+ (UIColor *)evoRGBAColorFromHexString:(NSString *)string;
+ (NSString *)evoHexStringFromColor:(UIColor *)color;
+ (UIColor *)evoInverseColor:(UIColor *)color;
- (BOOL)evoIsBrightColor;

@end
