#include "../MEVORootListController.h"

@interface PSSegmentTableCell : PSControlTableCell
@end

@interface MEVOSegment : PSSegmentTableCell
@end

@implementation MEVOSegment

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) [((UISegmentedControl *)[self control]) setTintColor:kEVOCOLOR];

	return self;
}

@end
