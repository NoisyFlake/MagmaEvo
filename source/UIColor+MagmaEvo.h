@interface UIColor (MagmaEvo)

+ (UIColor *)RGBAColorFromHexString:(NSString *)string;
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (UIColor *)inverseColor:(UIColor *)color;
- (BOOL)isBrightColor;

@end
