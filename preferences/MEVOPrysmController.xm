#include "MEVORootListController.h"

@implementation MEVOPrysmController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Prysm" target:self] mutableCopy];
		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
