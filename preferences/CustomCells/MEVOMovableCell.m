#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#include "../MEVORootListController.h"

@interface MEVOMovableCell : PSTableCell
@end

@implementation MEVOMovableCell

-(void) layoutSubviews {
	[super layoutSubviews];
  self.showsReorderControl = YES;
	self.editing = YES;
}

@end
