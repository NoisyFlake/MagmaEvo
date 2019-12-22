#import "MagmaEvo.h"

%hook CCUIButtonModuleView
	-(void)setGlyphState:(NSString *)arg1 {
		%orig;
		forceLayerUpdate(self.layer.sublayers);
	}
%end

%hook CCUIMenuModuleViewController
	-(void)willTransitionToExpandedContentMode:(BOOL)arg1 {
		%orig;
		forceLayerUpdate(self.view.layer.sublayers);
	}
%end

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
