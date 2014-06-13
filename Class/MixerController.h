//
//  MixerController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/20/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBlenderAppDelegate.h"
#import "GalleryItem.h"
#import "FaceSelectorViewController.h"
#import "TraitLogicViewController.h"
#import "Transformer.h"
#import "Face.h"
#import "IconMaker.h"

#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>


@interface MixerController : UIViewController {
    IBOutlet UIImageView *imageView;
    BOOL *toggles;
    FaceBlenderAppDelegate *appDelegate;
    int mode;
    IBOutlet UIProgressView *progressView;
    GalleryItem *theNewItem;
    FaceSelectorViewController *selectorView;
    TraitLogicViewController *traitLogicView;
    IBOutlet UINavigationBar *navBar;
	IBOutlet UINavigationItem *navItem;
	UIBarButtonItem *leftButton;
	IBOutlet UIButton *cancelButton;
	
	NSDate *refDate;
	
    BOOL usedSelector;
	BOOL usedTraitLogic;
    Transformer *transformer;
    CGAffineTransform transform;
    UIImage *curFaceImg;
    float *mixData;
    char *curBitmapData;
    CGColorSpaceRef colorSpace;
    CGContextRef cgctx;
    int mix_;
    int mixMax_;
    int mixCnt_;
    NSTimer *mixTimer;
	NSAutoreleasePool *pool;
	UIImage *result;
	NSThread *workThread;
	
	int sx,sy;
	char *inputNodes;
	float *kohonenNodes;
	int time;
	
	int reswidth;
	int resheight;
	BOOL doAura;
	BOOL isDone;
	BOOL showTips;
	NSTimer *traitPoller;
	
	UITextView *tipView;
	
	NSDate *startDate;
	
	long long        elapsed1;
    long long        elapsed2;
    long long        elapsed3;
    long long        elapsed4;
    long long        elapsed5;
	
}

@property ( assign) int sx;
@property ( assign) int sy;
@property ( assign) char *inputNodes;
@property ( assign) float *kohonenNodes;
@property ( retain) NSDate *startDate;

@property ( retain) IBOutlet UIImageView *imageView;
@property ( retain) IBOutlet UIProgressView *progressView;
@property ( retain) FaceBlenderAppDelegate *appDelegate;
@property ( retain) IBOutlet UINavigationBar *navBar;
@property ( retain) IBOutlet UINavigationItem *navItem;
@property ( retain) UIBarButtonItem *leftButton;
@property ( assign) int mode;
@property ( assign) BOOL *toggles;
@property ( assign) BOOL usedSelector;
@property ( assign) BOOL usedTraitLogic;
@property ( assign) GalleryItem *theNewItem;
@property ( retain) FaceSelectorViewController *selectorView;
@property ( retain) TraitLogicViewController *traitLogicView;

@property ( retain)    Transformer *transformer;
@property ( assign)    CGAffineTransform transform;
@property ( retain)    UIImage *curFaceImg;
@property ( assign)    float *mixData;
@property (assign)    char *curBitmapData;
@property (assign)    CGColorSpaceRef colorSpace;
@property (assign)    CGContextRef cgctx;
@property ( retain)    NSTimer *mixTimer;
@property ( assign)    int mix_;
@property ( assign)    int mixMax_;
@property ( assign)    int mixCnt_;
@property ( assign)    int reswidth;
@property ( assign)    int resheight;
@property ( assign)	 BOOL doAura;
@property ( assign)	 BOOL showTips;

@property ( assign)   int time;
@property ( retain) NSTimer *traitPoller;
@property ( assign) BOOL isDone;

@property (retain)  NSAutoreleasePool *pool;
@property (copy) UIImage *result;
@property (retain) NSThread *workThread;

@property (retain) UITextView *tipView;
@property (retain) IBOutlet UIButton *cancelButton;


-(void)finishUp;
-(void)mixAll;
-(void)mixSelection;
-(void)doMix;
-(void)dismiss;
-(void) updateView;
-(void)finalizeMix;
-(IBAction)exitButton;
-(IBAction)doneSelection;
-(IBAction)CANCELbutton;
-(void)mixTraitLogic;
@end
