#include "../../source/UIColor+MagmaEvo.h"
#include "../MEVORootListController.h"

#define kIsGlobal [self.specifier.properties[@"global"] boolValue]
#define kFilepath @"/var/mobile/Library/Preferences/com.noisyflake.magmaevo.plist"

@interface SparkColourPickerView : UIView
@end

@interface SparkColourPickerCell : PSTableCell
@property (nonatomic, strong, readwrite) NSMutableDictionary *options;
@property (nonatomic, strong, readwrite) SparkColourPickerView *colourPickerView;
-(void)colourPicker:(id)picker didUpdateColour:(UIColor*) colour;
-(void)openColourPicker;
-(void)dismissPicker;
@end

@interface MEVOColorPicker : SparkColourPickerCell
@property (nonatomic, retain) UIView *colorPreview;
@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, retain) UILongPressGestureRecognizer *lpgr;
@end

@implementation MEVOColorPicker

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if(self) {
        [specifier setTarget:self];

        _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _lpgr.delegate = self;
        _lpgr.minimumPressDuration = 1;
        [super.contentView addGestureRecognizer:_lpgr];

        [specifier setButtonAction:@selector(dismissPicker)];
    }

    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Fix sparks color picker blocking our long press gesture recognizer
    if (gestureRecognizer == _lpgr) return YES;

    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

-(void)layoutSubviews {
    [super layoutSubviews];

    if (kIsGlobal) {
        self.textLabel.textColor = kEVOCOLOR;
        self.textLabel.highlightedTextColor = kEVOCOLOR;
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kFilepath];

    if (kIsGlobal) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Global Color"
                                    message: @"This will reset all colors in the current category. Do you want to continue?"
                                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            for (PSSpecifier *spec in [self._viewControllerForAncestor specifiers]) {
                if ([spec propertyForKey:@"cellClass"] == NSClassFromString(@"MEVOColorPicker") && ![spec.properties[@"key"] containsString:@"ContainerBackground"]) {
                    [settings removeObjectForKey:spec.properties[@"key"]];
                }
            }

            [settings writeToFile:kFilepath atomically:YES];

            NSString *persistentFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.persistent.plist";
            NSMutableDictionary *persistentSettings = [NSMutableDictionary dictionaryWithContentsOfFile:persistentFile];
            [persistentSettings setObject:@YES forKey:@"unsaved"];
            [persistentSettings writeToFile:persistentFile atomically:YES];

            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.noisyflake.magmaevo/update", NULL, NULL, YES);

            [self._viewControllerForAncestor reloadSpecifiers];
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self._viewControllerForAncestor presentViewController:alert animated:YES completion:nil];
    } else {
        [settings removeObjectForKey:self.specifier.properties[@"key"]];
        [settings writeToFile:kFilepath atomically:YES];

        NSString *persistentFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.persistent.plist";
        NSMutableDictionary *persistentSettings = [NSMutableDictionary dictionaryWithContentsOfFile:persistentFile];
        [persistentSettings setObject:@YES forKey:@"unsaved"];
        [persistentSettings writeToFile:persistentFile atomically:YES];

        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.noisyflake.magmaevo/update", NULL, NULL, YES);

        _currentColor = nil;
        [self updateCellDisplay];
    }
}

-(void)colourPicker:(id)picker didUpdateColour:(UIColor*) colour {
    _currentColor = colour;

    // Don't call super because we only want to update the color on close to reduce load
}

-(void)dismissPicker {
    [super dismissPicker];

    if (kIsGlobal && _currentColor) {
        NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kFilepath];

        for (PSSpecifier *spec in [self._viewControllerForAncestor specifiers]) {
            if ([spec propertyForKey:@"cellClass"] == NSClassFromString(@"MEVOColorPicker") && ![spec.properties[@"key"] containsString:@"ContainerBackground"]) {
                [settings setObject:[UIColor evoHexStringFromColor:_currentColor] forKey:spec.properties[@"key"]];
            }
        }

        [settings writeToFile:kFilepath atomically:YES];
        NSString *persistentFile = @"/User/Library/Preferences/com.noisyflake.magmaevo.persistent.plist";
        NSMutableDictionary *persistentSettings = [NSMutableDictionary dictionaryWithContentsOfFile:persistentFile];
        [persistentSettings setObject:@YES forKey:@"unsaved"];
        [persistentSettings writeToFile:persistentFile atomically:YES];

        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.noisyflake.magmaevo/update", NULL, NULL, YES);

        [self._viewControllerForAncestor reloadSpecifiers];
    } else if (_currentColor) {
        // Now call the super method that actually writes to preferences manually
        [super colourPicker:self.colourPickerView didUpdateColour:_currentColor];
    }
}

-(void)showOverwriteAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Global Color"
                                    message: @"This will overwrite all colors in the current category. Do you want to continue?"
                                    preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openColourPicker];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self._viewControllerForAncestor presentViewController:alert animated:YES completion:nil];
}

-(NSString *)previewColor {
    if (_currentColor) return [UIColor evoHexStringFromColor:_currentColor];

    NSMutableDictionary *_prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kFilepath];
    return [_prefs valueForKey:[self.specifier propertyForKey:@"key"]];
}

-(void)createAccessoryView {
    _colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    _colorPreview.layer.cornerRadius = _colorPreview.frame.size.width / 2;
    _colorPreview.layer.shadowOpacity = 0.5;
    _colorPreview.layer.shadowOffset = CGSizeZero;
    _colorPreview.layer.shadowRadius = 5.0;
}

-(void)updateCellDisplay {
    // Set necessary options for sparks colorpicker
    if ([self.options valueForKey:@"defaults"] == nil || [self.options valueForKey:@"fallback"] == nil) {
        [self.options setObject:@"com.noisyflake.magmaevo" forKey:@"defaults"];
        [self.options setObject:@"#FF0000" forKey:@"fallback"];
    }

    if (kIsGlobal) {
        self.accessoryView.hidden = YES;
        [self.specifier setButtonAction:@selector(showOverwriteAlert)];
        return;
    } else {
        [self.specifier setButtonAction:@selector(openColourPicker)];
    }

    if (_colorPreview == nil) {
        [self createAccessoryView];
    }

    if (self.accessoryView != _colorPreview) {
        // Overwrite sparks colour preview with our custom one
        self.accessoryView = _colorPreview;
    }

    NSString *color = [self previewColor];

    if (color == nil) {
        _colorPreview.hidden = YES;
        self.detailTextLabel.text = @"Default";
        self.detailTextLabel.alpha = 0.5;
        return;
    }

    _colorPreview.hidden = NO,
    _colorPreview.backgroundColor = [UIColor evoRGBAColorFromHexString:color];
    _colorPreview.layer.shadowColor = _colorPreview.backgroundColor.CGColor;

    NSUInteger location = [color rangeOfString:@":"].location;

    if(location != NSNotFound) {
        NSString *alphaString = [color substringWithRange:NSMakeRange(location + 1, 4)];
        double alpha = [alphaString doubleValue] * 100;

        color = [color substringWithRange:NSMakeRange(0, location)];
        if (alpha == 0) {
            color = @"Hidden";
        } else if (alpha < 100) {
            color = [NSString stringWithFormat:@"%@ %d%%", color, (int)alpha];
        }
    }

    self.detailTextLabel.text = color;
    self.detailTextLabel.alpha = 1;
}

@end
