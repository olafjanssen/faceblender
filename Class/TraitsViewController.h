//
//  TraitsViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/22/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBlenderAppDelegate.h"
#import "TraitsNewViewController.h"

@interface TraitsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *traitsTable;
	IBOutlet UIView *headerView;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *textLabel;

    FaceBlenderAppDelegate *appDelegate;
    
    BOOL *toggles;
    Face *face;
    UIImage *selected;
    UIImage *unselected;
	NSString *traitsLst;
	BOOL isNew;
}

@property (retain) IBOutlet UILabel *textLabel;
@property (retain)  IBOutlet UIImageView *imageView;
@property ( retain) IBOutlet UIView *headerView;
@property ( retain) IBOutlet UITableView *traitsTable;
@property ( retain) FaceBlenderAppDelegate *appDelegate;
@property ( retain) UIImage *selected;
@property ( retain) UIImage *unselected;
@property ( retain) Face *face;
@property ( assign) BOOL *toggles;
@property (retain) NSString *traitsLst;
@property (assign) BOOL isNew;

//-(void)setFace:(Face *)f;
-(void)setTraits:(NSString *)f;


@end
