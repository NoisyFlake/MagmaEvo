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
