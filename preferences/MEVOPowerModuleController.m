#include "MEVORootListController.h"

@implementation MEVOPowerModuleController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"PowerModule" target:self] mutableCopy];
		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
