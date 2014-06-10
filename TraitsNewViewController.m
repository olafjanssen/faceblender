//
//  GalleryItemRenameViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 2/16/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "TraitsNewViewController.h"

@implementation TraitsNewViewController

@synthesize tableView, headerView, txtFld;
@synthesize appDelegate, renameLabel;
@synthesize face;

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.headerView.frame.size.height);
	self.headerView.backgroundColor = [UIColor clearColor];
	self.headerView.frame = newFrame;
	
	self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
	//  self.tableView.rowHeight = 100;
	
	self.tableView.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property	
	
	txtFld = [[UITextField alloc] initWithFrame:CGRectMake(40,100,240,30)];
	[txtFld setKeyboardAppearance:UIKeyboardAppearanceAlert];
	[txtFld setBorderStyle:UITextBorderStyleNone];
	[txtFld setLeftViewMode:UITextFieldViewModeAlways];
	[self.view addSubview:txtFld];
	[txtFld becomeFirstResponder];
	[txtFld setDelegate:self];
	//	[txtFld setClearButtonMode:UITextFieldViewModeWhileEditing]; 	
	
	self.title = NSLocalizedString(@"NewTraitKey",@"");
	renameLabel.text = NSLocalizedString(@"NewTraitKey",@"");
	
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,205,320,40)];
	[toolBar setBarStyle:UIBarStyleBlackTranslucent];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									 target:self
									 action:@selector(cancel)];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								   target:self
								   action:@selector(done)];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
							   target:self
							   action:nil];
	
	NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
	[buttonArray addObject:cancelButton];
	[buttonArray addObject:spacer];
	[buttonArray addObject:saveButton];
	[toolBar setItems:buttonArray];
	
	[cancelButton release];
	[spacer release];
	[saveButton release];
	[buttonArray release];
	
	[self.view addSubview:toolBar];
	[toolBar release];
	
	
}

// this helps dismiss the keyboard then the "done" button is clicked
- (BOOL)textFieldShouldReturn: (UITextField *)textField
{	
	if (textField.text.length>0){
		NSString *str = [[NSString alloc] initWithFormat:@"@%@",textField.text];
		Trait *trait;
		
		BOOL isExist = NO;
		for(Trait *oldtrait in appDelegate.faceDatabaseDelegate.traits){
			if ([oldtrait.description compare:str]==NSOrderedSame) isExist = YES;
		}
		if (!isExist && appDelegate.faceDatabaseDelegate.traitSections.count>6){
			trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:6];
			[trait setUniqueId: ([trait uniqueId]+1)];
			
			Trait *newTrait = [[Trait alloc] initWithUniqueId: [appDelegate.faceDatabaseDelegate.traits count] Description:str];
			[appDelegate.faceDatabaseDelegate.traits addObject:newTrait];
			[newTrait release];
			
		}
		[str release];
		
		// add to selected list of current face
		if (face.traitsTmp){
			[face.traitsTmp release];
		}
		face.traitsTmp = [[NSString alloc] initWithFormat:@"@%@",textField.text];
	}
	
	[textField resignFirstResponder];
	[textField removeFromSuperview];
	[self dismissViewControllerAnimated:YES completion: NULL];
	return YES;
}

- (void)done
{
	[self textFieldShouldReturn: txtFld];
}

- (void)cancel
{
	[txtFld resignFirstResponder];
	[txtFld removeFromSuperview];
	[self dismissViewControllerAnimated:YES completion: NULL];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>6)
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:6];
    
	if (trait)    return NSLocalizedString(trait.description,@"");
	else		  return @"";
}


-(UITableViewCell *)reuseTableViewCellWithIdentifier:(NSString *)identifier {
	
	//Rectangle which will be used to create labels and table view cell.
    CGRect cellRectangle;
	
    //Returns a rectangle with the coordinates and dimensions.
    cellRectangle = CGRectMake(0.0, 0.0, 320-40, 200);
	
    //Initialize a UITableViewCell with the rectangle we created.
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GalleryCell";
    
	UITableViewCell *cell=nil;
	
    if(cell == nil)
        cell = [self reuseTableViewCellWithIdentifier:CellIdentifier];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	tableView = nil;
	headerView = nil;
	appDelegate = nil;
	renameLabel = nil;
	txtFld.text = nil;
    [super dealloc];
}


@end
