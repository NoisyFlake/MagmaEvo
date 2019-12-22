#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#include "../MEVORootListController.h"

@interface MEVOButton : PSTableCell
@end

@implementation MEVOButton

-(void) layoutSubviews {
	[super layoutSubviews];
	[[self textLabel] setTextColor:kEVOCOLOR];
}

@end
