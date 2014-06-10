//
//  TraitLogicViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/27/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBlenderAppDelegate.h"
#import "Trait.h"

@interface TraitLogicViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIAlertViewDelegate> {
    IBOutlet UITableView *traitsTable;
    FaceBlenderAppDelegate *appDelegate;
	BOOL isEmpty;
    BOOL *toggles;
    BOOL *togglesOpen;
    BOOL *togglesLocal;
    BOOL curOperator;
	BOOL notOperator;
    BOOL isDone;
	BOOL firstTime;
    Trait *curTrait;
    NSMutableString *logicString;
    NSMutableString *logicString2;
	
	NSMutableIndexSet *chosenUids;
	
    IBOutlet UITextView *textView;
	IBOutlet UIBarButtonItem *andButton;
	IBOutlet UIBarButtonItem *orButton;
	IBOutlet UIBarButtonItem *notButton;
	IBOutlet UISegmentedControl *segControl;
	IBOutlet UIToolbar *toolbar;
	
	NSMutableArray *rowsInSection;
	NSMutableArray *facesPerTrait;
}

@property ( retain) IBOutlet UITableView *traitsTable;
@property ( retain) IBOutlet FaceBlenderAppDelegate *appDelegate;
@property ( assign) BOOL *toggles;
@property ( assign) BOOL *togglesOpen;
@property ( assign) BOOL *togglesLocal;
@property ( assign) BOOL curOperator;
@property ( assign) BOOL notOperator;
@property ( assign) BOOL isDone;
@property ( assign) BOOL firstTime;
@property ( assign) BOOL isEmpty;
@property ( retain) NSMutableString *logicString;
@property ( retain) NSMutableString *logicString2;
@property ( retain) IBOutlet UITextView *textView;
@property ( retain) Trait *curTrait;
@property ( retain) IBOutlet UIBarButtonItem *andButton;
@property ( retain) IBOutlet UIBarButtonItem *orButton;
@property ( retain) IBOutlet UIBarButtonItem *notButton;
@property ( retain) NSMutableIndexSet *chosenUids;
@property ( retain) UISegmentedControl *segControl;
@property ( retain) UIToolbar *toolbar;

@property (retain) NSMutableArray *rowsInSection;
@property (retain) NSMutableArray *facesPerTrait;

-(IBAction) ANDbutton;
-(IBAction) ORbutton;
-(IBAction) NOTbutton;
-(IBAction) DONEbutton;
-(IBAction) CANCELbutton;
-(void)startLogic;

-(NSInteger)rowsInSection:(NSInteger) section;
-(Trait *)traitForIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)realSection:(NSInteger) section;

@end
