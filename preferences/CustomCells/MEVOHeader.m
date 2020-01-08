#import <Preferences/PSTableCell.h>
#include "../MEVORootListController.h"

@interface MEVOHeader : PSTableCell {
	UILabel *version;
}
@end

@implementation MEVOHeader

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
	if (self) {
		CGFloat x = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? -20 : 0;

		UILabel *tweakName = [[UILabel alloc] initWithFrame:CGRectMake(x, 20, self.frame.size.width, 10)];
		[tweakName layoutIfNeeded];
		tweakName.numberOfLines = 1;
		tweakName.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0f];
		tweakName.textColor = kEVOCOLOR;
		tweakName.text = @"Magma Evo";
		tweakName.textAlignment = NSTextAlignmentCenter;
		[self addSubview:tweakName];

		version = [[UILabel alloc] initWithFrame:CGRectMake(x, 58, self.frame.size.width, 5)];
		version.numberOfLines = 1;
		version.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		version.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
		version.textColor = UIColor.systemGrayColor;
		version.textAlignment = NSTextAlignmentCenter;
		version.text = @"Version unknown";
		version.alpha = 0;
		[self addSubview:version];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSPipe *pipe = [NSPipe pipe];

			NSTask *task = [[NSTask alloc] init];
			task.arguments = @[@"-c", @"dpkg -s com.noisyflake.magmaevo | grep -i version | cut -d' ' -f2"];
			task.launchPath = @"/bin/sh";
			[task setStandardOutput: pipe];
			[task launch];
			[task waitUntilExit];

			NSFileHandle *file = [pipe fileHandleForReading];
			NSData *output = [file readDataToEndOfFile];
			NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
			[file closeFile];

			dispatch_async(dispatch_get_main_queue(), ^(void){
				// Update label on the main queue
				if ([outputString length] > 0) {
					version.text = [NSString stringWithFormat:@"Version %@", outputString];
				}

				[UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					version.alpha = 1;
				} completion:nil];
			});
		});

	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 100.0f;
}
@end