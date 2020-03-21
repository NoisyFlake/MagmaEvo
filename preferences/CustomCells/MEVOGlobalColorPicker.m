#import <Preferences/PSTableCell.h>
#import "../../source/UIColor+MagmaEvo.h"
#import <libcolorpicker.h>
#import <Preferences/PSSpecifier.h>
#include "../MEVORootListController.h"

@interface MEVOGlobalColorPicker : PSTableCell
@end

@interface MEVOGlobalColorPicker ()

@property (nonatomic, retain) UIView *colorPreview;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
- (void)displayAlert;
- (void)drawAccessoryView;

@end

@implementation MEVOGlobalColorPicker

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if(self) {
        [specifier setTarget:self];
        [specifier setButtonAction:@selector(displayAlert)];

        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.delegate = self;
        lpgr.minimumPressDuration = 1;
        [self.contentView addGestureRecognizer:lpgr];

        [self drawAccessoryView];
    }

    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];

    self.textLabel.textColor = kEVOCOLOR;
    self.textLabel.highlightedTextColor = kEVOCOLOR;
}


-(void)drawAccessoryView {
    _colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    [self setAccessoryView:_colorPreview];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove Global Color"
                                    message: @"This will remove all colors on the current settings page. Do you want to continue?"
                                    preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.specifier.properties[@"defaults"]];
            NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];

            for (PSSpecifier *spec in [self._viewControllerForAncestor specifiers]) {
                if ([spec propertyForKey:@"cellClass"] == NSClassFromString(@"MEVOColorPicker") && ![spec.properties[@"key"] containsString:@"ContainerBackground"]) {
                    [settings removeObjectForKey:spec.properties[@"key"]];
                }
            }

            [settings writeToFile:path atomically:YES];
            [self._viewControllerForAncestor reloadSpecifiers];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self._viewControllerForAncestor presentViewController:alert animated:YES completion:nil];
}

-(void)displayAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Global Color"
                                    message: @"This will overwrite all colors on the current settings page. Do you want to continue?"
                                    preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        UIColor *startColor = [UIColor evoRGBAColorFromHexString:@"#FF0000:1.00"];
        BOOL alpha = [[self.specifier propertyForKey:@"alpha"] boolValue];

        PFColorAlert *cpa = [PFColorAlert colorAlertWithStartColor:startColor showAlpha:alpha];

        [cpa displayWithCompletion:^void(UIColor *pickedColor) {
            NSString *hexString = [UIColor evoHexStringFromColor:pickedColor];
            hexString = [hexString stringByAppendingFormat:@":%.2f", pickedColor.alpha];

            NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.specifier.properties[@"defaults"]];
            NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];

            for (PSSpecifier *spec in [self._viewControllerForAncestor specifiers]) {
                if ([spec propertyForKey:@"cellClass"] == NSClassFromString(@"MEVOColorPicker") && ![spec.properties[@"key"] containsString:@"ContainerBackground"]) {
                    [settings setObject:hexString forKey:spec.properties[@"key"]];
                }
            }

            [settings writeToFile:path atomically:YES];
            [self._viewControllerForAncestor reloadSpecifiers];
        }];

    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self._viewControllerForAncestor presentViewController:alert animated:YES completion:nil];

}

@end
