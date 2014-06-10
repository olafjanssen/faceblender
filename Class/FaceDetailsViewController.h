//
//  FaceDetailsViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddLibraryViewController.h"
#import "TraitsViewController.h"
#import "Face.h"
#import "Trait.h"

@interface FaceDetailsViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIImageView *imageViewBorder;
    IBOutlet UIImageView *imageView;
    IBOutlet UITextField *textField;
    IBOutlet UILabel *textLabel;
	
	AddLibraryViewController *pickPointsView;
    TraitsViewController *pickTraitsView;
    Face *face;
    FaceBlenderAppDelegate *appDelegate;
    IBOutlet UIView *headerView;
    IBOutlet UITableView *tableView;
    NSMutableArray *tableArray;
	IBOutlet UIButton *imageButton;
    UIButton *suggestion;
	NSString *traitsLst;
	BOOL isImport;
	UIImageView *blackView;
}

@property ( retain) IBOutlet UIImageView *imageViewBorder;
@property ( retain) IBOutlet UIImageView *imageView;
@property ( retain) IBOutlet UITextField *textField;
@property ( copy) Face *face;
@property ( retain) AddLibraryViewController *pickPointsView;
@property ( retain) TraitsViewController *pickTraitsView;
@property ( retain) FaceBlenderAppDelegate *appDelegate;
@property ( retain) IBOutlet UIView *headerView;
@property ( retain) IBOutlet UITableView *tableView;
@property ( retain) IBOutlet UILabel *textLabel;
@property ( retain) NSMutableArray *tableArray;
@property ( retain) IBOutlet UIButton *imageButton;
@property ( retain) UIButton *suggestion;
@property ( assign ) BOOL isImport;
@property ( retain) NSString *traitsLst;
@property ( retain) UIImageView *blackView;

-(IBAction)pickPoints;
-(IBAction)pickTraits;
-(void)pickImage;
-(void)pickImageFromCamera;
-(void)pickImageFromAddressBook;
-(void)pickImageFromFacebook;
-(void)resetFace:(Face *)f setName:(BOOL)isName;
-(void)fillTraitTable;

@end
