//
//  GalleryScrollView.h
//  FaceBlender
//
//  Created by Olaf Janssen on 1/13/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GalleryScrollView : UIScrollView <UIScrollViewDelegate> {
	int xdist;
	int mode;
	CGFloat zoomScale;
}

@property ( assign) int xdist;
@property ( assign) int mode;
@property ( nonatomic, assign) CGFloat zoomScale;

-(BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view;
- (void)viewDidLoad;

@end
