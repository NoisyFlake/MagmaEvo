#include "MEVORootListController.h"

@implementation MEVOMiscController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Misc" target:self];
	}

	return _specifiers;
}


@end
