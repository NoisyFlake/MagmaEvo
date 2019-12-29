#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#include "../MEVORootListController.h"

@interface PSControlTableCell : PSTableCell
@property (nonatomic, retain) UIControl *control;
@end

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
