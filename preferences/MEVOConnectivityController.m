#include "MEVORootListController.h"

@implementation MEVOConnectivityController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Connectivity" target:self];
	}

	return _specifiers;
}

@end
