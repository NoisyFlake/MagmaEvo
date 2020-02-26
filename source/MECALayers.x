#import "MagmaEvo.h"

static CGColorRef getColorForLayer(CALayer *layer, CGColorRef originalColor, BOOL overwriteEmpty);

%hook CALayer
	-(void)setBackgroundColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}

	-(void)setBorderColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}

	-(void)setContentsMultiplyColor:(CGColorRef)arg1 {
		// Need to set overwriteEmpty to true in order to color the (regularly uncolored) App Launchers
		%orig(getColorForLayer(self, arg1, YES));
	}

	-(void)setOpacity:(float)opacity {
		if ([self.delegate isKindOfClass:%c(CCUICAPackageView)]) {
			id controller = [(CCUICAPackageView *)self.delegate _viewControllerForAncestor];
			if ([controller isKindOfClass:%c(CCUIDisplayModuleViewController)] ||
				[controller isKindOfClass:%c(CCUIAudioModuleViewController)] ||
				[controller isKindOfClass:%c(MediaControlsVolumeViewController)] ||
				([settings boolForKey:@"slidersVolumeSystem"] && [controller isKindOfClass:%c(SBElasticVolumeViewController)]) ||
				[controller isKindOfClass:%c(CCRingerModuleContentViewController)]) {
				NSString *key = nil;
				if ([controller isKindOfClass:%c(CCUIDisplayModuleViewController)]) key = @"slidersBrightnessGlyph";
				if ([controller isKindOfClass:%c(MediaControlsVolumeViewController)] || [controller isKindOfClass:%c(CCUIAudioModuleViewController)] || [controller isKindOfClass:%c(SBElasticVolumeViewController)]) key = @"slidersVolumeGlyph";
				if ([controller isKindOfClass:%c(CCRingerModuleContentViewController)]) key = @"slidersRingerGlyph";
				if ([settings valueForKey:key] != nil) {
					%orig(opacity > 0 ? 1 : 0);
					return;
				}
			}
		}

		%orig;
	}
%end

%hook CAShapeLayer
	-(void)setFillColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}
%end

void forceLayerUpdate(NSArray *layers) {
	for (CALayer *sublayer in layers) {
		if ([sublayer isMemberOfClass:%c(CAShapeLayer)]) {
			CAShapeLayer *shapelayer = (CAShapeLayer *)sublayer;
			if (shapelayer.fillColor != nil) shapelayer.fillColor = shapelayer.fillColor;
		} else {
			if (sublayer.backgroundColor != nil) sublayer.backgroundColor = sublayer.backgroundColor;
			if (sublayer.borderColor != nil) sublayer.borderColor = sublayer.borderColor;
			if (sublayer.contentsMultiplyColor != nil) sublayer.contentsMultiplyColor = sublayer.contentsMultiplyColor;

			// Fix dark mode toggle being always white
			if (sublayer.filters != nil && [sublayer.name isEqual:@"outer"]) sublayer.filters = nil;
		}

		forceLayerUpdate(sublayer.sublayers);
	}
}

static CGColorRef getColorForLayer(CALayer *layer, CGColorRef originalColor, BOOL overwriteEmpty) {
	if (!overwriteEmpty &&
		(
			   originalColor == nil
			|| ([layer.compositingFilter isMemberOfClass:%c(CAFilter)] && [((CAFilter*)layer.compositingFilter).name isEqual:@"subtractS"]) // Fixes the dark mode toggle
			|| (CGColorGetNumberOfComponents(originalColor) >= 4 && CGColorGetComponents(originalColor)[3] == 0)
		)
	) {
		return originalColor;
	}

	CALayer *currentLayer = layer;
	while(currentLayer.delegate == nil && currentLayer != currentLayer.superlayer && currentLayer.superlayer != nil) {
		currentLayer = currentLayer.superlayer;
	}

	if ([currentLayer.delegate respondsToSelector:@selector(_viewControllerForAncestor)]) {
		UIViewController *controller = [((UIView*)currentLayer.delegate) _viewControllerForAncestor];

		if ([controller isKindOfClass:%c(CCUIButtonModuleViewController)]
			|| [controller isKindOfClass:%c(HUCCModuleContentViewController)]
			|| [controller isKindOfClass:%c(AXCCIconViewController)]
			|| [controller isKindOfClass:%c(WSUIModuleContentViewController)]) {

			// Ugly fix to restore the default colors for expanded modules (TODO improve this?)
			if ([layer.compositingFilter isEqual:@"plusD"]) return [settings boolForKey:@"togglesHideContainer"] ? [[UIColor clearColor] CGColor] : [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.05] CGColor];
			if ([((UIView*)currentLayer.delegate)._ui_superview isKindOfClass:%c(CCUIMenuModuleItemView)] || [((UIView*)currentLayer.delegate)._ui_superview isKindOfClass:%c(BSUIEmojiLabelView)]) return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00] CGColor];
			if ([currentLayer.delegate isKindOfClass:%c(MPAVHighlightedControl)]) return originalColor;

			UIColor *toggleColor = getToggleColor(controller);

			if ([[settings valueForKey:@"togglesOverlayMode"] isEqual:@"colorOverlay"] && [controller respondsToSelector:@selector(isSelected)] && [((CCUIButtonModuleViewController*)controller) isSelected]) {
				if (toggleColor == nil) toggleColor = ((CCUIButtonModuleViewController*)controller).buttonView.selectedGlyphColor ?: [UIColor colorWithCGColor:originalColor];

				if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [currentLayer.delegate isKindOfClass:%c(MTMaterialView)]) {
					// Future fix?: The next line is the culprit for the first connectivity button text in the expanded view being black after a
					// respring when the location module is in the CC and enabled. Yes, you read that right.
					((MTMaterialView*)currentLayer.delegate).configuration = 1;
					return [toggleColor CGColor];
				}

				if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [currentLayer.delegate isKindOfClass:%c(_MTBackdropView)]) {
					((_MTBackdropView*)currentLayer.delegate).colorAddColor = nil;
					((_MTBackdropView*)currentLayer.delegate).brightness = 0;
					return [toggleColor CGColor];
				}

				return [toggleColor evoIsBrightColor] ? [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] CGColor] : [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
			}

			if (toggleColor != nil) return [toggleColor CGColor];

			// Reset to white for off state if no other color was chosen
			if (![controller respondsToSelector:@selector(isSelected)] || ![((CCUIButtonModuleViewController*)controller) isSelected]) {
				return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
			}

		} else if([controller isKindOfClass:%c(PrysmTogglesModuleViewController)]) {

			UIColor *toggleColor = getPrysmToggleColor((UIView *)currentLayer.delegate);

			if ([[settings valueForKey:@"togglesOverlayMode"] isEqual:@"colorOverlay"] && isPrysmButtonSelected(getPrysmButtonView((UIView *)currentLayer.delegate))) {

				if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [currentLayer.delegate isKindOfClass:%c(MTMaterialView)]) {
					((MTMaterialView*)currentLayer.delegate).configuration = 1;
					return [toggleColor CGColor];
				}

				if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [currentLayer.delegate isKindOfClass:%c(_MTBackdropView)]) {
					((_MTBackdropView*)currentLayer.delegate).colorAddColor = nil;
					((_MTBackdropView*)currentLayer.delegate).brightness = 0;
					return [toggleColor CGColor];
				}

				return [toggleColor evoIsBrightColor] ? [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] CGColor] : [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];

			}

			if (toggleColor != nil) return [toggleColor CGColor];

			return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];

		} else if([controller isKindOfClass:%c(PrysmConnectivityModuleViewController)]) {

			if ([currentLayer.delegate isKindOfClass:%c(PrysmButtonView)]) {

				PrysmButtonView *view = (PrysmButtonView *)currentLayer.delegate;
				UIColor *color = getPrysmConnectivityColor(view);

				if (color != nil) return color.CGColor;

			} else if ([currentLayer.delegate isKindOfClass:%c(UIImageView)]) {
				UIImageView *view = (UIImageView *)currentLayer.delegate;
				UIColor *color = getPrysmConnectivityGlyphColor(view);

				if (color != nil) return color.CGColor;
			}

		} else if([controller isKindOfClass:%c(PrysmSliderViewController)]) {

			if ([((UIView *)currentLayer.delegate).superview isKindOfClass:%c(CCUICAPackageView)]) {

				if (((PrysmSliderViewController *)controller).style == 1) {
					if ([settings valueForKey:@"slidersBrightnessGlyph"]) {
						return [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"slidersBrightnessGlyph"]].CGColor;
					}
				} else if (((PrysmSliderViewController *)controller).style == 2) {
					if ([settings valueForKey:@"slidersVolumeGlyph"]) {
						return [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"slidersVolumeGlyph"]].CGColor;
					}
				}

			}

		} else if([controller isKindOfClass:%c(CCUIConnectivityButtonViewController)]) {

			layer.opacity = ([layer.name isEqual:@"disabled"] || [layer.name isEqual:@"bluetoothdisabled"]) ? 0 : 1;
			return getConnectivityGlyphColor((CCUILabeledRoundButtonViewController*)controller);

		} else if([controller isKindOfClass:%c(MRPlatterViewController)]) {

			if ([((UIView *)currentLayer.delegate).parentFocusEnvironment isKindOfClass:%c(MediaControlsTimeControl)]) {
				if ([settings valueForKey:@"mediaControlsSlider"] && (!([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) || [settings boolForKey:@"mediaControlsColorLockscreen"])) {
					return [[UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSlider"]] CGColor];
				}
			}

			// On iOS 12 the delegate is the correct view, on iOS 13 we only receive the subview
			if ([currentLayer.delegate isKindOfClass:%c(MediaControlsRoutingCornerView)] || [((UIView *)currentLayer.delegate).parentFocusEnvironment isKindOfClass:%c(MediaControlsRoutingCornerView)]) {
				if ([settings valueForKey:@"mediaControlsRoutingButton"] && (!([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) || [settings boolForKey:@"mediaControlsColorLockscreen"])) {
					return [[UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsRoutingButton"]] CGColor];
				}
			}

		} else if ([controller isKindOfClass:%c(CCUIDisplayModuleViewController)]
					|| [controller isKindOfClass:%c(MediaControlsVolumeViewController)]
					|| [controller isKindOfClass:%c(CCUIAudioModuleViewController)]
					|| ([settings boolForKey:@"slidersVolumeSystem"] && [controller isKindOfClass:%c(SBElasticVolumeViewController)] && ![currentLayer.delegate isKindOfClass:%c(SBFTouchPassThroughView)])
					|| [controller isKindOfClass:%c(CCRingerModuleContentViewController)]) {

			CGColorRef sliderColor = getSliderColor(controller, (UIView *)currentLayer.delegate);
			if (sliderColor != nil) return sliderColor;

		} else if ([controller isKindOfClass:%c(LockButtonController)]
					|| [controller isKindOfClass:%c(PowerDownButtonController)]
					|| [controller isKindOfClass:%c(RebootButtonController)]
					|| [controller isKindOfClass:%c(RespringButtonController)]
					|| [controller isKindOfClass:%c(SafemodeButtonController)]
					|| [controller isKindOfClass:%c(UICacheButtonController)]) {
			return getPowerModuleColor((CCUILabeledRoundButtonViewController*)controller);
		}

	}

	return originalColor;
}

%ctor {
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		%init;
	}
}
