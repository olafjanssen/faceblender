//
//  GalleryViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/20/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixerController.h"
#import "FaceBlenderAppDelegate.h"
#import "GalleryItemViewController.h"
#import "ManualViewController.h"
#import "GalleryItemRenameViewController.h"
#import "DownloadController.h"
#import "OneByOneViewController.h"

@interface GalleryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    MixerController *mixerView;
    IBOutlet UITableView *galleryTable;
    UIBarButtonItem *addButton;
    UIBarButtonItem *editButton;
    UIBarButtonItem *doneButton;
    FaceBlenderAppDelegate *appDelegate;
    GalleryItemViewController *galleryItemView;
	
	int sizeCrop;
	
	int fCnt;
	NSThread *workThread;
	UIProgressView *progView;
	UIAlertView *alert;
	NSAutoreleasePool *pool;
	UIImage *curImage;
	int curCnt;
	NSMutableArray *tableData;
	BOOL firstView;
}

@property (retain) MixerController *mixerView;
@property (retain) IBOutlet UITableView *galleryTable;
@property (retain) FaceBlenderAppDelegate *appDelegate;
@property (retain) UIBarButtonItem *addButton;
@property (retain) UIBarButtonItem *editButton;
@property (retain) UIBarButtonItem *doneButton;
@property (retain) GalleryItemViewController *galleryItemView;
@property ( assign) int sizeCrop;
@property ( assign) int fCnt;
@property ( retain) NSThread *workThread;
@property ( retain) UIProgressView *progView;
@property ( retain) UIAlertView *alert;
@property ( retain) NSAutoreleasePool *pool;
@property ( retain) UIImage *curImage;
@property ( assign) int curCnt;
@property (retain) NSMutableArray *tableData;
@property (assign) BOOL firstView;


-(void)viewWillAppear:(BOOL)animated;
-(void)makeIcon:(GalleryItem *) galleryItem;
-(void)notIncrementalLoadTable;

@end
