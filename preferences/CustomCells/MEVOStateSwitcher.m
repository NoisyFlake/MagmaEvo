#include "../MEVORootListController.h"

@interface MEVOStateSwitcher : PSTableCell
@end

@implementation MEVOStateSwitcher

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if(self) {
        self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        self.accessoryView.hidden = YES;

        self.detailTextLabel.text = @"Tap to Switch State";
    }

    return self;
}

-(void) layoutSubviews {
	[super layoutSubviews];

	UIColor *textColor = [UIColor respondsToSelector:@selector(labelColor)] ? UIColor.labelColor : UIColor.darkTextColor;

	self.textLabel.textColor = textColor;
	self.textLabel.highlightedTextColor = textColor;

    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.frame = CGRectMake(self.frame.origin.x, self.textLabel.frame.origin.y, self.frame.size.width, self.textLabel.frame.size.height);

    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.detailTextLabel.frame = CGRectMake(self.frame.origin.x, self.detailTextLabel.frame.origin.y, self.frame.size.width, self.detailTextLabel.frame.size.height);
}

@end
