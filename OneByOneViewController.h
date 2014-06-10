//
//  OneByOneViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 5/31/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBlenderAppDelegate.h";
#import "Face.h";
#import "GalleryItem.h";
#import "Transformer.h";
#import "IconMaker.h";

@interface OneByOneViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    FaceBlenderAppDelegate *appDelegate;
	IBOutlet UITableView *faceTable;
	IBOutlet UIImageView *imageView;
	IBOutlet UINavigationItem *navItem;
	UIActivityIndicatorView *activityView;
	
	int *faceCount;
	
	//mixer
	int reswidth;
	int resheight;
	BOOL doAura;
	BOOL isDone;
	GalleryItem *newItem;
	Transformer *transformer;
	NSTimer *waitTimer;
	int faceToBlend;
	int timesToBlend;
	
    CGAffineTransform transform;
    float *mixData;
    char *curBitmapData;
    CGColorSpaceRef colorSpace;
    CGContextRef cgctx;
    int mix_;
    int mixMax_;
    int mixCnt_;
	UIImage *result;
		
}

@property (retain) FaceBlenderAppDelegate *appDelegate;
@property (retain) IBOutlet UITableView *faceTable;
@property (retain) IBOutlet UIImageView *imageView;
@property (retain) GalleryItem *newItem;
@property (retain) Transformer *transformer;
@property ( retain) IBOutlet UINavigationItem *navItem;
@property (retain) NSTimer *waitTimer;
@property (retain) UIActivityIndicatorView *activityView;

@property (assign) int faceToBlend;
@property (assign) int timesToBlend;
@property ( assign)    CGAffineTransform transform;
@property ( assign)    float *mixData;
@property (assign)    char *curBitmapData;
@property (assign)    CGColorSpaceRef colorSpace;
@property (assign)    CGContextRef cgctx;
@property ( assign)    int mix_;
@property ( assign)    int mixMax_;
@property ( assign)    int mixCnt_;
@property ( assign)    int reswidth;
@property ( assign)    int resheight;
@property (copy) UIImage *result;

-(void)waiter;
-(void)mixPrepare;
-(void)doMix:(Face *)face;
-(void)firstMix:(Face *)face;
-(void)finalizeMix;
-(void)finishUp;
-(void)doDoneButton;
-(void)doCancelButton;


@end
