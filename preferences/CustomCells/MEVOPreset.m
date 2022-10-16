#include "../MEVORootListController.h"

@interface MEVOPreset : PSTableCell
@end

@implementation MEVOPreset

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
}

-(void) didMoveToWindow {
	[super didMoveToWindow];

	UIColor *textColor = kEVOCOLOR;
	if ([[self.specifier propertyForKey:@"textColor"] isEqual:@"regular"]) textColor = [UIColor respondsToSelector:@selector(labelColor)] ? UIColor.labelColor : UIColor.darkTextColor;
	if ([[self.specifier propertyForKey:@"textColor"] isEqual:@"disabled"]) textColor = UIColor.systemGrayColor;

	self.textLabel.textColor = textColor;
	self.textLabel.highlightedTextColor = textColor;

    if ([self.specifier propertyForKey:@"isActive"]) {
        [self setAccessoryType:UITableViewCellAccessoryCheckmark];
        self.tintColor = kEVOCOLOR;
    }

    NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] init];

    if ([[self.specifier propertyForKey:@"isUnsaved"] boolValue]) {
        [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Unsaved"]];
        [detailText setAttributes:@{NSForegroundColorAttributeName:kEVOCOLOR} range:NSMakeRange(0, 7)];
    }

    if ([[self.specifier propertyForKey:@"isDarkDefault"] boolValue]) {
        if (detailText.length > 0) [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
        [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Used for Dark Mode"]];
    } else if ([[self.specifier propertyForKey:@"isLightDefault"] boolValue]) {
        if (detailText.length > 0) [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
        [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Used for Light Mode"]];
    }

    if (detailText.length > 0) self.detailTextLabel.attributedText = detailText;
}

@end
