//
//  GalleryItemRenameViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 2/16/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBlenderAppDelegate.h"
#import "GalleryItem.h"

@interface GalleryItemRenameViewController : UIViewController < UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    FaceBlenderAppDelegate *appDelegate;
    IBOutlet UIView *headerView;
    IBOutlet UITableView *tableView;
	GalleryItem *galleryItem;
	UITextField *txtFld;
	IBOutlet UILabel *renameLabel;
    
}

@property ( retain) IBOutlet UILabel *renameLabel;
@property ( retain) FaceBlenderAppDelegate *appDelegate;
@property ( retain) IBOutlet UIView *headerView;
@property ( retain) IBOutlet UITableView *tableView;
@property ( retain) GalleryItem *galleryItem;
@property ( retain) UITextField *txtFld;

@end