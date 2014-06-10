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
@synthesize fCnt, alert, progView,pool, workThread;
@synthesize curCnt, curImage, tableData;
@synthesize firstView;

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

	if ([[[UIDevice currentDevice] systemVersion] compare:@"3.0"]!=NSOrderedSame)
		[self.galleryTable setFrame:CGRectMake(0,0,320,367)];
//	[self.navigationItem setFrame:CGRectMake(0,0,320,367)];
	
	if (mixerView) {
		[mixerView release];
		mixerView = nil;
	}
	
	if (firstView){
	if (workThread) [workThread release];	
		workThread = [[NSThread alloc] initWithTarget:self selector:@selector(incrementalLoadTable) object:nil];
		[workThread start];
	} else
		[self notIncrementalLoadTable];
	
	[super viewWillAppear:animated];
	
}

-(void)addIncRow {
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	NSIndexPath *ip = [NSIndexPath indexPathForRow:fCnt inSection:0];
	NSArray *ar = [NSArray arrayWithObjects: ip,nil];
	[galleryTable insertRowsAtIndexPaths:ar withRowAnimation: UITableViewRowAnimationFade];
	[tmpPool release];
}

-(void)notIncrementalLoadTable {
	[tableData removeAllObjects];
	fCnt = 0;
	for (GalleryItem *galleryItem in appDelegate.galleryDatabaseDelegate.galleryItems){
		[self makeIcon:galleryItem];
		[tableData addObject: galleryItem];
		fCnt ++;
	}	
	[galleryTable reloadData];
}

-(void)incrementalLoadTable {
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	[tableData removeAllObjects];
	
	fCnt = 0;
	for (GalleryItem *galleryItem in appDelegate.galleryDatabaseDelegate.galleryItems){
		[self makeIcon:galleryItem];
		[tableData addObject: galleryItem];
		if (firstView) [self performSelectorOnMainThread:@selector(addIncRow) withObject:nil waitUntilDone:YES];
		fCnt ++;
	}

	if (firstView) firstView = NO;
	else [galleryTable reloadData];
	
	[tmpPool release];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (workThread.isExecuting) {
		[workThread cancel];
	}
//	while (workThread.isExecuting) {}
	[workThread release]; workThread = nil;
	[super viewWillDisappear:animated];
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
	
    self.title = NSLocalizedString(@"BlendsKey",@"");
    
	sizeCrop = 20;
	
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];

    // set the delegate and source of the table to self
    galleryTable.delegate = self;
    galleryTable.dataSource = self;
	[galleryTable setAllowsSelectionDuringEditing:YES];
    
    galleryTable.rowHeight = 100;
	[self.galleryTable reloadData];
	
	tableData = [[NSMutableArray alloc] init];
	firstView = YES;
	
	UIImage *logo = [UIImage imageNamed: @"HEADER.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
	self.navigationItem.titleView = imageView;
	
	[imageView release];
		
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
	while (workThread.isExecuting) {}
	[workThread release]; workThread = nil;

    [galleryTable setEditing:YES animated:YES];
//	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
	
    // set edit button to done
    doneButton = [[[UIBarButtonItem alloc]
				   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				   target:self
				   action:@selector(doneEditGallery)] autorelease];
	self.navigationItem.rightBarButtonItem = doneButton;
	
	
	//sizeCrop = 120;
	//[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];

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
	//sizeCrop = 20;
	//[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];

//	[galleryTable reloadData];
//	[galleryTable setNeedsDisplay];
	
}


-(IBAction)addGalleryItem {
	
	if (appDelegate.faceDatabaseDelegate.faces.count == 0){

		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"EmptyLibraryKey",@"")
								  message:NSLocalizedString(@"EmptyLibraryMessKey",@"")
								  delegate:self
								  cancelButtonTitle:NSLocalizedString(@"NoKey",@"")
								  otherButtonTitles:NSLocalizedString(@"YesKey",@""), nil];
		[alertView show];
		[alertView release];
		return;
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
				   initWithTitle:NSLocalizedString(@"NewBlendKey",@"")
				   delegate:self 
				   cancelButtonTitle:NSLocalizedString(@"CancelKey",@"")
				   destructiveButtonTitle:nil
				   otherButtonTitles:NSLocalizedString(@"NewBlendAllFacesKey",@""), 
								  NSLocalizedString(@"NewBlendManualSelectionKey",@""),
								  NSLocalizedString(@"NewBlendTraitCriteriaKey",@""),
								  NSLocalizedString(@"One By One",@""),nil];
    [actionSheet showInView:[self.view window]];
    [actionSheet release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	switch (buttonIndex){
        case 1:
		{
			DownloadController *dc = [[DownloadController alloc] init];
			[dc setDelegate:nil];
			[dc isDownloadNeeded];
			
		}
            break;
	}			
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
	if (mixerView) [mixerView release]; mixerView = nil;
	
	MixerController *viewController = [[MixerController alloc] initWithNibName:@"MixerController" bundle:nil];
	mixerView = viewController;

	OneByOneViewController *oneByOneController;
	
    switch (buttonIndex){
        case 0:
            [self presentViewController:self.mixerView animated:YES completion: NULL];
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:mixerView selector:@selector(mixAll) userInfo:nil repeats:NO];
            break;
        case 1:
            [self presentViewController:self.mixerView animated:YES completion: NULL];
            [self.mixerView mixSelection];
            break;
        case 2:
            [self presentViewController:self.mixerView animated:YES completion: NULL];
            [self.mixerView mixTraitLogic];
            break;
		case 3:
			mixerView = nil;
			oneByOneController = [[OneByOneViewController alloc] initWithNibName:@"OneByOneViewController" bundle:nil];
			//[self.navigationController pushViewController:oneByOneController animated:YES];
			[self presentViewController:oneByOneController animated:YES completion: NULL];

			break;
        default:
            break;
    }
	//[viewController release];

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


////// TABLE DELEGATE METHODS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

}
*/


	
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *lbl = (UILabel *)[cell viewWithTag:2];
	lbl.frame = CGRectMake(80, 10, 250-100, 20);
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
	lbl2.frame = CGRectMake(80, 30, 250-100, 20);
    
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];
	lbl3.frame = CGRectMake(80, 50, 250-100, 40);
	[cell setAccessoryType:UITableViewCellAccessoryNone];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *lbl = (UILabel *)[cell viewWithTag:2];
	lbl.frame = CGRectMake(80, 10, 250, 20);
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:3];
	lbl2.frame = CGRectMake(80, 30, 250, 20);
    
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:4];
	lbl3.frame = CGRectMake(80, 50, 250, 40);
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableData.count;
}

-(UITableViewCell *)reuseTableViewCellWithIdentifier:(NSString *)identifier {
	
	//Rectangle which will be used to create labels and table view cell.
    CGRect cellRectangle;

    //Returns a rectangle with the coordinates and dimensions.
    cellRectangle = CGRectMake(0.0, 0.0, 320, 200);

    //Initialize a UITableViewCell with the rectangle we created.
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    
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
/*	if ([[[UIDevice currentDevice] systemVersion] compare:@"3.0"]==NSOrderedSame)
		[cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	else
		[cell setHidesAccessoryWhenEditing:NO]; // 2.2.1
*/	
	
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GalleryCell";
    
    //Initialize a UITableViewCell with the rectangle we created.    
	UITableViewCell *cell=nil;
	
    if(cell == nil)
        cell = [self reuseTableViewCellWithIdentifier:CellIdentifier];
	
    // set up cell
    GalleryItem *galleryItem = nil;
	if (tableData.count>indexPath.row)
		galleryItem = (GalleryItem *)[tableData objectAtIndex:indexPath.row];
	if (!galleryItem) return cell;
	
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
    GalleryItem *galleryItem  = nil;
	if(tableData.count>indexPath.row)
		galleryItem = (GalleryItem *)[tableData objectAtIndex:indexPath.row];
	if (!galleryItem) return;
	
	[appDelegate.galleryDatabaseDelegate deleteImage:galleryItem];
	[tableData removeObjectAtIndex:indexPath.row];
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
	[self.galleryItemView setIndex:(int)indexPath.row mode:0];
		
	} else {
		GalleryItemRenameViewController *viewController = [[GalleryItemRenameViewController alloc] initWithNibName:@"GalleryItemRenameViewController" bundle:[NSBundle mainBundle]];
		if (tableData.count>indexPath.row){
			[viewController setGalleryItem:[tableData objectAtIndex:indexPath.row ]];
			[self presentViewController:viewController animated:YES completion: NULL];
		}
		[viewController release];
	}
}

- (void)dealloc {
	if (mixerView) [mixerView release];
	mixerView = nil;
	
	appDelegate = nil;
    if (galleryItemView) [galleryItemView release]; galleryItemView = nil;
	
	if (workThread) [workThread release];
	workThread = nil;
	
	if (pool) [pool release]; pool = nil;
	if (curImage) [curImage release];
	curImage = nil;
	
	[tableData release]; tableData = nil;
    [super dealloc];
}


@end
