#include "MEVORootListController.h"

@implementation MEVOPrysmCalendarController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"PrysmCalendar" target:self] mutableCopy];
		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}


@end
