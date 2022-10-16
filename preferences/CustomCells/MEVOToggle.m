#include "../MEVORootListController.h"

@interface MEVOToggle : PSSwitchTableCell
@end

@implementation MEVOToggle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) [((UISwitch *)[self control]) setOnTintColor:kEVOCOLOR];

	return self;
}

@end
