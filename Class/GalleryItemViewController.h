//
//  GalleryItemViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/24/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryItem.h"
#import "GalleryScrollView.h"
#import "FaceBlenderAppDelegate.h"
#import "NSDataM64.h"
#import "GalleryItemRenameViewController.h"
#import "FaceDetailsViewController.h"
#import "FBSessionController.h"


@interface GalleryItemViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
	UIImageView *imageView, *imageViewLeft, *imageViewRight;
    GalleryItem *galleryItem;
    FaceBlenderAppDelegate *appDelegate;
    IBOutlet UIToolbar *toolBar;
    CGFloat initialDistance;
    IBOutlet UIView *actionView;
    BOOL hidden;
	int index;
	UITouch *firstTouch;
    CGPoint dragPoint;
	UIActionSheet *actionSheet;
	GalleryScrollView *scrollView;
	UIImageView *zoomImage;
	NSTimer *hideTimer;
	BOOL isSweeping;
	NSMutableArray *imageArray;
	IBOutlet UIBarButtonItem *leftButton;
	IBOutlet UIBarButtonItem *rightButton;
	IBOutlet UIBarButtonItem *renameButton;
	UIView *activityView;
}

@property(retain) IBOutlet UIBarButtonItem *leftButton;
@property(retain) IBOutlet UIBarButtonItem *rightButton;
@property(retain) IBOutlet UIBarButtonItem *renameButton;
@property(retain) UIImageView *imageView;
@property(retain) UIImageView *imageViewLeft;
@property(retain) UIImageView *imageViewRight;
@property(retain) GalleryItem *galleryItem;
@property(retain) UIActionSheet *actionSheet;
@property(retain) FaceBlenderAppDelegate *appDelegate;
//@property (retain) IBOutlet UINavigationBar *navBar;
//@property (retain) IBOutlet UINavigationItem *navItem;
@property (retain) IBOutlet UIToolbar *toolBar;
@property (retain) IBOutlet UIView *actionView;
@property (assign) BOOL hidden;
@property (assign) int index;
@property (assign) CGPoint dragPoint;
@property (retain) UITouch *firstTouch;
@property (retain) UIScrollView *scrollView;
@property (retain) UIImageView *zoomImage;
@property (retain) NSTimer *hideTimer;
@property (retain) NSMutableArray *imageArray;
@property (assign) BOOL isSweeping;
@property (retain) UIView *activityView;

- (BOOL)hidesBottomBarWhenPushed;
//- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
//- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
-(IBAction)doAction;
-(IBAction)doDelete;
-(IBAction)doLeft;
-(IBAction)doRight;
-(IBAction)doRename;
-(void)setIndex:(int)i mode:(NSInteger)m;
-(void)import;
-(void)uploadToFacebook;
-(void)hideNavBar;
-(void)showNavBar;
-(void)cancelUpload;
-(void)continueUpload;

@end
