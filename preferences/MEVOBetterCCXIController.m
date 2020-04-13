#include "MEVORootListController.h"

@implementation MEVOBetterCCXIController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"BetterCCXI" target:self] mutableCopy];
		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
