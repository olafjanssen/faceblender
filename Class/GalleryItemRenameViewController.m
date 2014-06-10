//
//  GalleryItemRenameViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 2/16/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "GalleryItemRenameViewController.h"

@implementation GalleryItemRenameViewController

@synthesize tableView, headerView, galleryItem, txtFld;
@synthesize appDelegate, renameLabel;

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
    
    self.tableView.rowHeight = 100;
	
	//self.tableView.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property	
	
	txtFld = [[UITextField alloc] initWithFrame:CGRectMake(10,140,300,30)];
	txtFld.text = galleryItem.description;
	[txtFld setKeyboardAppearance:UIKeyboardAppearanceAlert];
	[txtFld setBorderStyle:UITextBorderStyleRoundedRect];
	[txtFld setLeftViewMode:UITextFieldViewModeAlways];
	[self.view addSubview:txtFld];
	[txtFld becomeFirstResponder];
	[txtFld setDelegate:self];
	[txtFld setClearButtonMode:UITextFieldViewModeWhileEditing]; 	
		
	self.title = NSLocalizedString(@"RenameKey",@"");
	renameLabel.text = NSLocalizedString(@"RenameKey",@"");
	
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
	[galleryItem setDescription: textField.text];
	[appDelegate.galleryDatabaseDelegate updateImage:galleryItem];
	self.title = textField.text;
	[textField resignFirstResponder];
	[textField removeFromSuperview];
	[self dismissModalViewControllerAnimated:YES];
	return YES;
}

- (void)done
{
	[galleryItem setDescription: txtFld.text];
	[appDelegate.galleryDatabaseDelegate updateImage:galleryItem];
	self.title = txtFld.text;
	[txtFld resignFirstResponder];
	[txtFld removeFromSuperview];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancel
{
	[txtFld resignFirstResponder];
	[txtFld removeFromSuperview];
	[self dismissModalViewControllerAnimated:YES];
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

-(UITableViewCell *)reuseTableViewCellWithIdentifier:(NSString *)identifier {
	
	//Rectangle which will be used to create labels and table view cell.
    CGRect cellRectangle;
	
    //Returns a rectangle with the coordinates and dimensions.
    cellRectangle = CGRectMake(0.0, 0.0, 320-40, 200);
	
    //Initialize a UITableViewCell with the rectangle we created.
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:cellRectangle reuseIdentifier:identifier] autorelease];
    
    UIImageView *imageView;
	
    //Create a rectangle container for the number text.
    cellRectangle = CGRectMake(0,5,80,90);
	
	
    //Initialize the label with the rectangle.
    imageView = [[UIImageView alloc] initWithFrame:cellRectangle];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageView.tag = 1;
    [cell.contentView addSubview:imageView];
    [imageView release];
	
	int sizeCrop = 40;
	
    UILabel *label;
    //Create a rectangle container for the number text.
    cellRectangle = CGRectMake(80, 10, 250-sizeCrop, 20);
    //Initialize the label with the rectangle. 
    label = [[UILabel alloc] initWithFrame:cellRectangle];
    [label setFont: [UIFont boldSystemFontOfSize: 16.00]];
    [cell.contentView addSubview:label];
    [label release];
    label.tag = 2;
    
    UILabel *label2;
    //Create a rectangle container for the number text.
    cellRectangle = CGRectMake(80, 30, 250-sizeCrop, 20);
    //Initialize the label with the rectangle. 
    label2 = [[UILabel alloc] initWithFrame:cellRectangle];
    [label2 setFont: [UIFont boldSystemFontOfSize: 12.00]];
    [cell.contentView addSubview:label2];
    [label2 release];
    label2.tag = 3;
    
    UILabel *label3;
    //Create a rectangle container for the number text.
    cellRectangle = CGRectMake(80, 50, 250-sizeCrop, 40);
    //Initialize the label with the rectangle. 
    label3 = [[UILabel alloc] initWithFrame:cellRectangle];
    [label3 setFont: [UIFont systemFontOfSize: 12.00]];
    [cell.contentView addSubview:label3];
    [label3 release];
    label3.tag = 4;
    
	//[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"GalleryCell";
    
	UITableViewCell *cell=nil;
	
    if(cell == nil)
        cell = [self reuseTableViewCellWithIdentifier:CellIdentifier];
	
    // set up cell
    //GalleryItem *galleryItem  = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:indexPath.row];
    UIImageView *im = (UIImageView *)[cell viewWithTag:1];
	im.image = galleryItem.icon;
    
    UILabel *lbl = (UILabel *)[cell viewWithTag:2];
    lbl.text = galleryItem.title;
    
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
    lbl2.text = galleryItem.method;
    
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];
    lbl3.text = galleryItem.description;
		return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	if (tableView) [tableView release]; tableView = nil;
	galleryItem = nil;
	if (txtFld) [txtFld release]; txtFld = nil;
	appDelegate = nil;
	renameLabel = nil;
    [super dealloc];
}


@end
