#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#include "../MEVORootListController.h"

@interface MEVOButton : PSTableCell
@end

@implementation MEVOButton

-(void) layoutSubviews {
	[super layoutSubviews];

	self.textLabel.textColor = kEVOCOLOR;
  self.textLabel.highlightedTextColor = kEVOCOLOR;

	self.textLabel.textAlignment = NSTextAlignmentCenter;
	self.textLabel.frame = CGRectMake(self.frame.origin.x, self.textLabel.frame.origin.y, self.frame.size.width, self.textLabel.frame.size.height);
}

@end
