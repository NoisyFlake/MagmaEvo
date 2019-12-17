#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#include "../MEVORootListController.h"

@interface PSControlTableCell : PSTableCell
@property (nonatomic, retain) UIControl *control;
@end

@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface MEVOToggle : PSSwitchTableCell
@end

@implementation MEVOToggle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) [((UISwitch *)[self control]) setOnTintColor:kEVOCOLOR];

	return self;
}

@end
