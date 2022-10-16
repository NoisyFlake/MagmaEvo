#include "../MEVORootListController.h"

@interface MEVOButton : PSTableCell
@end

@implementation MEVOButton

-(void) layoutSubviews {
	[super layoutSubviews];

	UIColor *textColor = kEVOCOLOR;
	if ([[self.specifier propertyForKey:@"textColor"] isEqual:@"regular"]) textColor = [UIColor respondsToSelector:@selector(labelColor)] ? UIColor.labelColor : UIColor.darkTextColor;
	if ([[self.specifier propertyForKey:@"textColor"] isEqual:@"disabled"]) textColor = UIColor.systemGrayColor;

	self.textLabel.textColor = textColor;
	self.textLabel.highlightedTextColor = textColor;

	if ([[self.specifier propertyForKey:@"textAlignment"] isEqual:@"center"]) {
		self.textLabel.textAlignment = NSTextAlignmentCenter;
		self.textLabel.frame = CGRectMake(self.frame.origin.x, self.textLabel.frame.origin.y, self.frame.size.width, self.textLabel.frame.size.height);
	}
}

@end
