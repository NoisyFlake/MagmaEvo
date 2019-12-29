#include "MEVORootListController.h"

@implementation MEVOMediaControlsController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"MediaControls" target:self];
	}

	return _specifiers;
}


@end
