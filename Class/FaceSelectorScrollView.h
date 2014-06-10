//
//  GalleryScrollView.h
//  FaceBlender
//
//  Created by Olaf Janssen on 1/13/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FaceSelectorScrollView : UIScrollView <UIScrollViewDelegate> {
	UINavigationController *navController;
	CGPoint startPosition;
}

@property ( retain) UINavigationController *navController;
@property ( assign) CGPoint startPosition;

-(BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view;
- (void)viewDidLoad;

@end
