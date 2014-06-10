//
//  GalleryScrollView.m
//  FaceBlender
//
//  Created by Olaf Janssen on 1/13/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "GalleryScrollView.h"

@implementation GalleryScrollView
@synthesize xdist,mode,zoomScale;


-(BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	return YES;
}


- (void)viewDidLoad {
	zoomScale = 1;
}


- (void)endFinalZoom:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (self.subviews.count>0)
		[[[self subviews] objectAtIndex:0] removeFromSuperview];
	[self removeFromSuperview];
}


 // Handles the continuation of a touch.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{  
	[super touchesBegan:touches withEvent:event];
	
	// [self.view bringSubviewToFront:toolBar];
	
	NSSet *allTouches = [event allTouches];
	NSInteger tapCount = [[touches anyObject] tapCount];
	
	switch (tapCount){
		case 1: {
			switch ([allTouches count]) {
				case 1: { //Single touch
					//Get the first touch.
					UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
					CGPoint centerPoint = [touch locationInView:nil];
					xdist = centerPoint.x;
					
				} break;
				case 2: 
					break;
				default:
					break;
			}
		}
			break;
		case 2:
			if (zoomScale != 1){ 
			}
		break;
	}
}
 
 - (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
 
 float x = toPoint.x - fromPoint.x;
 float y = toPoint.y - fromPoint.y;
 
 return sqrt(x * x + y * y);
 }
 

 - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	 [super touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
	 
	 NSSet *allTouches = [event allTouches];
	 switch ([allTouches count]) {
		 case 1: { //Single touch
			 if (zoomScale != 1){ 
				 return;
			 }
			 
			 UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			 CGPoint centerPoint = [touch locationInView:nil];
			 UIImageView *leftView = nil; if (self.subviews.count>0) leftView = [[self subviews] objectAtIndex:0]; else break;
			 UIImageView *rightView = nil; if (self.subviews.count>1) rightView = [[self subviews] objectAtIndex:1]; else break;
			
			 int xnow = centerPoint.x;
			 
			 if ( ((xnow-xdist) <10)&& ((xnow-xdist) >-10 )){
				 mode = -1; // stay put and switch navbar
				 [self scrollRectToVisible:CGRectMake(341,0,320,480) animated:NO];
				 [self scrollRectToVisible:CGRectMake(340,0,320,480) animated:YES];
			 } else
			 if ( ((xnow-xdist) <100 || leftView.image==nil)&& ((xnow-xdist) >-100 || rightView.image==nil)){
				 mode = 0; // stay put
				 [self scrollRectToVisible:CGRectMake(340,0,320,480) animated:YES];
			 } else {
				 if ((xnow-xdist)>0) {
					 mode = 1; // go left
					 [self scrollRectToVisible:CGRectMake(0,0,320,480) animated:YES];
				 } else {
					 mode = 2; // go right
					 [self scrollRectToVisible:CGRectMake(680,0,320,480) animated:YES];
				 }
			 }
			 break;
		 }
	 }
 
 }
 
-(void) triggerAnimation {					
	[self scrollRectToVisible:CGRectMake(1,0,320,480) animated:YES];
}


- (void)dealloc {
    [super dealloc];
}


@end
