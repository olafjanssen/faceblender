//
//  LibraryViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/18/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBlenderAppDelegate.h"
#import "Trait.h"
#import "LibraryViewController.h"
#import "FaceDetailsViewController.h"

@interface PreLibraryViewController : UITableViewController <UIActionSheetDelegate >{
	IBOutlet UITableView *traitTable;
	FaceDetailsViewController *faceView;
	LibraryViewController *libView;
	FaceBlenderAppDelegate *appDelegate;
	NSMutableArray *rowsInSection;
	NSMutableArray *facesPerTrait;
	AddLibraryViewController *pickPointsView;
	UIView *activityView;
}

@property ( retain) IBOutlet UITableView *traitTable;
@property ( retain) LibraryViewController *libView;
@property ( retain) FaceDetailsViewController *faceView;
@property (retain) AddLibraryViewController *pickPointsView;
@property (retain) UIView *activityView;

@property (retain) NSMutableArray *rowsInSection;
@property (retain) NSMutableArray *facesPerTrait;


-(NSInteger)rowsInSection:(NSInteger) section;
-(Trait *)traitForIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)realSection:(NSInteger) section;
-(void) facebookPick;

@end


