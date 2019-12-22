#import <Preferences/PSTableCell.h>
#import "../../source/UIColor+MagmaEvo.h"
#import <libcolorpicker.h>
#import <Preferences/PSSpecifier.h>

@interface MEVOColorPicker : PSTableCell
@end

@interface MEVOColorPicker ()

@property (nonatomic, retain) UIView *colorPreview;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;

- (NSString *)previewColor;

- (void)displayAlert;
- (void)drawAccessoryView;
- (void)updateCellDisplay;

@end

@implementation MEVOColorPicker

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if(self) {
        [specifier setTarget:self];

        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.delegate = self;
        lpgr.minimumPressDuration = 1;
        [self.contentView addGestureRecognizer:lpgr];

        [specifier setButtonAction:@selector(displayAlert)];
        [self drawAccessoryView];
    }

    return self;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.specifier.properties[@"defaults"]];
  NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
  [settings removeObjectForKey:self.specifier.properties[@"key"]];
  [settings writeToFile:path atomically:YES];

  [self updateCellDisplay];
}

-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self updateCellDisplay];
}

-(void)displayAlert {
    NSString *color = [self previewColor];
    if (color == nil) {
        color = @"#FF0000:1.00";
    }

    UIColor *startColor = [UIColor RGBAColorFromHexString:color];
    BOOL alpha = [[self.specifier propertyForKey:@"alpha"] boolValue];

    PFColorAlert *alert = [PFColorAlert colorAlertWithStartColor:startColor showAlpha:alpha];

    [alert displayWithCompletion:^void(UIColor *pickedColor) {
        NSString *hexString = [UIColor hexStringFromColor:pickedColor];

        hexString = [hexString stringByAppendingFormat:@":%.2f", pickedColor.alpha];

        NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.specifier.properties[@"defaults"]];
        NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        [settings setObject:hexString forKey:self.specifier.properties[@"key"]];
        [settings writeToFile:path atomically:YES];
        // CFStringRef notificationName = (CFStringRef)self.specifier.properties[@"PostNotification"];
        // if (notificationName) {
        //     CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
        // }

        [self updateCellDisplay];
    }];
}

-(void)drawAccessoryView {
    _colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];

    _colorPreview.layer.cornerRadius = _colorPreview.frame.size.width / 2;
    _colorPreview.layer.borderWidth = 0.5;
    _colorPreview.layer.borderColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0].CGColor;

    [self setAccessoryView:_colorPreview];
    [self updateCellDisplay];
}

-(NSString *)previewColor {
    NSMutableDictionary *_prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.noisyflake.magmaevo.plist"];
    return [_prefs valueForKey:[self.specifier propertyForKey:@"key"]];
}

-(void)updateCellDisplay {
    NSString *color = [self previewColor];

    if (color == nil) {
        _colorPreview.hidden = YES;
        self.detailTextLabel.text = @"Default";
        self.detailTextLabel.alpha = 0.5;
        return;
    }

    _colorPreview.hidden = NO,
    _colorPreview.backgroundColor = [UIColor RGBAColorFromHexString:color];

    NSUInteger location = [color rangeOfString:@":"].location;

    if(location != NSNotFound) {
        NSString *alphaString = [color substringWithRange:NSMakeRange(location + 1, 4)];
        double alpha = [alphaString doubleValue] * 100;

        color = [color substringWithRange:NSMakeRange(0, location)];
        if (alpha < 100) {
            color = [NSString stringWithFormat:@"%@ %d%%", color, (int)alpha];
        }
    }

    self.detailTextLabel.text = color;
    self.detailTextLabel.alpha = 1;
}

@end
