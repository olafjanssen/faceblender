//
//  LibraryViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/18/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceDetailsViewController.h"
#import "FaceBlenderAppDelegate.h"
#import "Trait.h"
#import "Face.h"
#import "AddLibraryViewController.h"

@interface LibraryViewController : UITableViewController <UIActionSheetDelegate >{
	IBOutlet UITableView *faceTable;
	
	FaceDetailsViewController *faceView;
	FaceBlenderAppDelegate *appDelegate;
	
	NSString *alphabet;
	BOOL sectionExists[27];
	NSString *trait;
	
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	
	NSThread *loadThread;
	UIImage *curImage;
	
	int sects;
	int rowsPerSection[27];
	int realSections[27];
	int startIndex[27];
	NSMutableArray *tableData;
}

@property ( retain) IBOutlet UITableView *faceTable;
@property ( retain) FaceDetailsViewController *faceView;
@property ( retain) FaceBlenderAppDelegate *appDelegate;
@property ( retain) UIBarButtonItem *editButton;
@property ( retain) UIBarButtonItem *doneButton;
@property ( retain) NSString *alphabet;
@property ( retain) NSString *trait;
@property (retain) NSThread *loadThread;
@property (retain) UIImage *curImage;
@property (retain) NSMutableArray *tableData;
@property (assign) int sects;

-(void)makeIconSmall:(Face *) face;
-(BOOL)hasTrait:(NSString *)traitStr;

@end


