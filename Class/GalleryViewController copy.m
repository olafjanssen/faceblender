//
//  GalleryViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/20/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "GalleryViewController.h"


@implementation GalleryViewController
@synthesize mixerView;
@synthesize galleryTable;
@synthesize addButton,editButton,doneButton;
@synthesize appDelegate;
@synthesize galleryItemView,sizeCrop;
@synthesize maxFCnt, fCnt, alert, progView,pool, workThread;
@synthesize curCnt, curImage;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];   
	[appDelegate.galleryDatabaseDelegate.galleryItems sortUsingSelector:@selector(compare:)];
	
	if (workThread) [workThread release];	
	workThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImages) object:nil];
	[workThread start];
	[self.galleryTable setFrame:CGRectMake(0,0,320,367)];
	
	if (mixerView) {
		[mixerView release];
		mixerView = nil;
	}
}

-(void)incrementalLoadTable {
	
	
}

-(void)loadImages{
	pool = [[NSAutoreleasePool alloc] init];
		
	BOOL reload = YES;
	for (GalleryItem *g in appDelegate.galleryDatabaseDelegate.galleryItems){
		if ( !g.icon){
			[self makeIcon:g];
		}
		if ([workThread isCancelled]){
			reload = NO;
			break;
		}
	}
	if (reload)	[self.galleryTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

//	[self.galleryTable reloadData];
	[pool release];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (workThread.isExecuting) {
		[workThread cancel];
	}
	while (workThread.isExecuting) {}
}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];

    addButton = [[[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self
								   action:@selector(addGalleryItem)] autorelease];
	self.navigationItem.leftBarButtonItem = addButton;  

	editButton = [[[UIBarButtonItem alloc]
				  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
				  target:self
				  action:@selector(editGallery)] autorelease];

	self.navigationItem.rightBarButtonItem = editButton;  
	
    self.title = @"Blends";
    
	sizeCrop = 20;
	
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];

    // set the delegate and source of the table to self
    galleryTable.delegate = self;
    galleryTable.dataSource = self;
	[galleryTable setAllowsSelectionDuringEditing:YES];
    
    galleryTable.rowHeight = 100;
	[self.galleryTable reloadData];

}


-(void) updateFirstLoad {
//	[progView setProgress:(float)(mixCnt_+1)/(float)mixMax_];
	[progView setNeedsDisplay];
//	[self.view setNeedsDisplay];
}


-(void)reloadTable {
	[galleryTable reloadData];
}

-(void)editGallery {
	// stop thread
	if (workThread.isExecuting) {
		[workThread cancel];
	}
	
    [galleryTable setEditing:YES animated:YES];
//	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
	
    // set edit button to done
    doneButton = [[[UIBarButtonItem alloc]
				   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				   target:self
				   action:@selector(doneEditGallery)] autorelease];
	self.navigationItem.rightBarButtonItem = doneButton;
	
	sizeCrop = 120;
	[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];

//	[galleryTable reloadData];
//	[galleryTable setNeedsDisplay];
}

-(void)doneEditGallery {
//	[galleryTable setSectionIndexMinimumDisplayRowCount:20];
    [galleryTable setEditing:NO animated:YES];
//	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
    
	// set edit button to done
    editButton = [[[UIBarButtonItem alloc]
				   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
				   target:self
				   action:@selector(editGallery)] autorelease];
	self.navigationItem.rightBarButtonItem = editButton;  
	sizeCrop = 20;
	[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];

//	[galleryTable reloadData];
//	[galleryTable setNeedsDisplay];
}


-(IBAction)addGalleryItem {
	
	if (appDelegate.faceDatabaseDelegate.faces.count == 0){

		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:@"Face library is empty!" 
								  message:@"Would you like to load the sample face library, containing over 100 faces to play with?" 
								  delegate:self
								  cancelButtonTitle:@"No"
								  otherButtonTitles:@"Yes", nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
				   initWithTitle:@"New Blend Based On:"
				   delegate:self 
				   cancelButtonTitle:@"Cancel"
				   destructiveButtonTitle:nil
				   otherButtonTitles:@"All Faces", @"Manual Selection",@"Trait Criteria",nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	switch (buttonIndex){
        case 1:
		{
			NSMutableArray *settings;
			NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
			settings = [NSMutableArray arrayWithContentsOfFile:filePath];
			NSString *newStr2 = [NSString stringWithString:@"YES"];
			[settings replaceObjectAtIndex:2 withObject:newStr2];
			[settings writeToFile:filePath atomically:YES];
			//[settings release];
			
			[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];
			[appDelegate reloadFacesDatabase];
			[appDelegate hideActivityViewer];
		}
            break;
	}			
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
	mixerView = [[MixerController alloc] initWithNibName:@"MixerController" bundle:nil];

    switch (buttonIndex){
        case 0:
            [self presentModalViewController:self.mixerView animated:YES];
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:mixerView selector:@selector(mixAll) userInfo:nil repeats:NO];
            break;
        case 1:
            [self presentModalViewController:self.mixerView animated:YES];
            [self.mixerView mixSelection];
            break;
        case 2:
            [self presentModalViewController:self.mixerView animated:YES];
            [self.mixerView mixTraitLogic];
            break;
		case 3:
			break;
        default:
            break;
    }
	//[mixerView release];

}

-(void)makeIcon:(GalleryItem *) galleryItem  {
	if (galleryItem.icon) return;

	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];

	NSString *base = @"tmb_";
	NSString *tmbName = [base stringByAppendingString:galleryItem.imageName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *tmbpath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:tmbName];
	if ([fileManager fileExistsAtPath:tmbpath]){
		UIImage *icon = [[UIImage alloc] initWithContentsOfFile:tmbpath];
		galleryItem.icon = icon;
		[icon release];
	} else {
	}
	
	[tmpPool release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *lbl = (UILabel *)[cell viewWithTag:2];
	lbl.frame = CGRectMake(80, 10, 250-100, 20);
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
	lbl2.frame = CGRectMake(80, 30, 250-100, 20);
    
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];
	lbl3.frame = CGRectMake(80, 50, 250-100, 40);
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *lbl = (UILabel *)[cell viewWithTag:2];
	lbl.frame = CGRectMake(80, 10, 250, 20);
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
	lbl2.frame = CGRectMake(80, 30, 250, 20);
    
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];
	lbl3.frame = CGRectMake(80, 50, 250, 40);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.galleryDatabaseDelegate.galleryItems.count;
}

-(UITableViewCell *)reuseTableViewCellWithIdentifier:(NSString *)identifier {
	
	//Rectangle which will be used to create labels and table view cell.
    CGRect cellRectangle;

    //Returns a rectangle with the coordinates and dimensions.
    cellRectangle = CGRectMake(0.0, 0.0, 320, 200);

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
    
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GalleryCell";
    
    //Initialize a UITableViewCell with the rectangle we created.    
	UITableViewCell *cell=nil;
	
    if(cell == nil)
        cell = [self reuseTableViewCellWithIdentifier:CellIdentifier];
	
    // set up cell
    GalleryItem *galleryItem  = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:indexPath.row];
    UIImageView *im = (UIImageView *)[cell viewWithTag:1];
	if (galleryItem.icon) im.image = galleryItem.icon; else im.image = nil;
    
    UILabel *lbl = (UILabel *)[cell viewWithTag:2];
    lbl.text = galleryItem.title;
    
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
    lbl2.text = galleryItem.method;
    
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];
    lbl3.text = galleryItem.description;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    GalleryItem *galleryItem  = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:indexPath.row];
	[appDelegate.galleryDatabaseDelegate deleteImage:galleryItem];
	
	[galleryTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![tableView isEditing]){
	// Navigation logic -- create and push a new view controller
    if(self.galleryItemView == nil){
        GalleryItemViewController *viewController = [[GalleryItemViewController alloc] initWithNibName:@"GalleryItemViewController" bundle:[NSBundle mainBundle]];
        //viewController.hidesBottomBarWhenPushed=YES;
		self.galleryItemView = viewController;
        [viewController release];
    }
        
    [self.navigationController pushViewController:self.galleryItemView animated:YES];
	[self.galleryItemView setIndex:indexPath.row mode:0];
	} else {
		GalleryItemRenameViewController *viewController = [[GalleryItemRenameViewController alloc] initWithNibName:@"GalleryItemRenameViewController" bundle:[NSBundle mainBundle]];
		
		[viewController setGalleryItem:[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:indexPath.row ]];
		[self presentModalViewController:viewController animated:YES];
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
