#include "../MEVORootListController.h"

@interface MEVOImage : PSTableCell
@end

@implementation MEVOImage {
	UIImageView *_bigImageView;;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.backgroundView = nil;

		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *iconName = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"] && specifier.properties[@"prysmIcon"] ? specifier.properties[@"prysmIcon"] : specifier.properties[@"icon"];

		NSString *path = [NSString stringWithFormat:@"/Library/PreferenceBundles/MagmaEvo.bundle/%@", iconName];
		_bigImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];

		CGRect frame = self.contentView.bounds;

		frame.origin.x -= 15;
		frame.origin.y += 5;

		// Ugly workaround for devices where it whould overlap the selector
		self.layer.zPosition = -1;

        _bigImageView.frame = frame;
		_bigImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_bigImageView.contentMode = UIViewContentModeScaleAspectFit;
		_bigImageView.layer.minificationFilter = kCAFilterTrilinear;
		[self.contentView addSubview:_bigImageView];

		self.imageView.hidden = YES;
		self.textLabel.hidden = YES;
		self.detailTextLabel.hidden = YES;
	}

	return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return lroundf(_bigImageView.image.size.height / 2);
}

 @end