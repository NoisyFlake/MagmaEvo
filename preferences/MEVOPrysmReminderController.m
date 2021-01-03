#include "MEVORootListController.h"

@implementation MEVOPrysmReminderController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"PrysmReminder" target:self] mutableCopy];
		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
