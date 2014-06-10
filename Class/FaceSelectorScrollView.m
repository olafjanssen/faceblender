//
//  GalleryScrollView.m
//  FaceBlender
//
//  Created by Olaf Janssen on 1/13/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "FaceSelectorScrollView.h"
#import "FaceSelectorViewController.h"

@implementation FaceSelectorScrollView
@synthesize navController, startPosition;


- (void)viewDidLoad {

}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	return YES;
}

- (void)endFinalZoom:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (self.subviews.count>0)
		[[[self subviews] objectAtIndex:0] removeFromSuperview];
	[self removeFromSuperview];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event];
	NSSet *allTouches = [event allTouches];
	
    switch ([allTouches count]) {
        case 1: { //Single touch
			startPosition = [[allTouches anyObject] locationInView: self.window];//[self.delegate fakeView]];
			break;
		case 2:
			break;
		default:
			break;
		}
	}
	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
	NSSet *allTouches = [event allTouches];
		
    switch ([allTouches count]) {
        case 1: { //Single touch
			// determine the selected face
			float buf = 2;
			float sz = (320 - 2*buf)/4;
			CGPoint position = [[allTouches anyObject] locationInView: self.window ];//[self.delegate fakeView]];
			
			// distance
			float dist = sqrt((position.x-startPosition.x)*(position.x-startPosition.x) + (position.y-startPosition.y)*(position.y-startPosition.y));
			if (dist>20) return;
			
			position = [[allTouches anyObject] locationInView: [(FaceSelectorViewController *)self.delegate fakeView]];

			
			int cnt = (int)((position.y-buf)/sz) * 4 + (position.x-buf)/sz;
			
			[(FaceSelectorViewController *)self.delegate doSelection:cnt];
			break;
				case 2:
					break;
				default:
					break;
		}
	}
}

- (void)didReceiveMemoryWarning {
 //   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

/*
 - (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
 }
 */

-(void)dealloc {
	navController = nil;
	[super dealloc];
}

@end
