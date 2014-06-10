//
//  LibraryViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/18/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "LibraryViewController.h"

@implementation LibraryViewController

@synthesize faceTable;
@synthesize faceView;
@synthesize editButton, doneButton, appDelegate;
@synthesize alphabet;
@synthesize trait;
@synthesize curImage,loadThread;
@synthesize tableData;
@synthesize sects;

//@synthesize libraryListView;

/*
 // Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
	
    editButton = [[[UIBarButtonItem alloc]
				   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
				   target:self
				   action:@selector(editLibrary)] autorelease];
	self.navigationItem.rightBarButtonItem = editButton;  
	
//    self.title = @"Library";
//	self.title = NSLocalizedString(@"LibraryKey",@"");
    
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ#";
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
    [self.tableView setSectionIndexMinimumDisplayRowCount:20];
	
	curImage = [[UIImage alloc] initWithContentsOfFile:@"EmptyIconSmall2.png"];
	
	tableData = [[NSMutableArray alloc] init];
	sects = 0;
	for (int c=0;c<27;c++) rowsPerSection[c] = 0;
	for (int c=0;c<27;c++) realSections[c] = 0;
	for (int c=0;c<27;c++) startIndex[c] = 0;
	
	[super viewDidLoad];
}

-(void)incrementalLoadTable {
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	// reset data
	[tableData removeAllObjects];
	sects = 0;
	for (int c=0;c<27;c++) rowsPerSection[c] = 0;
	for (int c=0;c<27;c++) realSections[c] = 0;
	for (int c=0;c<27;c++) startIndex[c] = 0;
	
	
	// sort faces of the current index
	for (Face *face in appDelegate.faceDatabaseDelegate.faces){
		if (![self hasTrait:face.traits]) continue;
		if (face.name.length > 0 ){
		char firstChar = [face.name characterAtIndex:0];
		if (firstChar<65 || firstChar>122 || (firstChar>90 && firstChar<97)) {
		} else {
			[tableData addObject:face];	
		}
		}
	}
	for (Face *face in appDelegate.faceDatabaseDelegate.faces){
		if (![self hasTrait:face.traits]) continue;
		if (face.name.length > 0 ){
		char firstChar = [face.name characterAtIndex:0];
		if (firstChar<65 || firstChar>122 || (firstChar>90 && firstChar<97)){
			[tableData addObject:face];
		} else {
		} 
		} else [tableData addObject:face];
	}
	
	BOOL isFirst = YES;
	int fCnt = 0;
	int cSect = -1;
	
	for (Face *face in tableData){
		char firstChar;
		
		if (face.name.length > 0)
			firstChar = [face.name characterAtIndex:0];
		else firstChar = 0;

		int sect = 0;
		if (firstChar>96) 
			sect = firstChar - 97; 
		else 
			sect = firstChar - 65;
		
		if (cSect != sect ){
			if (sect>-1 && sect<26){
				cSect = sect;
				realSections[sects] = cSect;
				if (sects>0) startIndex[sects] = startIndex[sects-1] + fCnt;
				sects++;
				fCnt=0;
			} else if (isFirst){
				isFirst = NO;
				cSect = 26;
				realSections[sects] = cSect;
				startIndex[sects] = startIndex[sects-1] + fCnt;
				sects++;
				fCnt=0;
			}
		}
		[self makeIconSmall:face];
		rowsPerSection[sects-1]++;
		fCnt ++;
	}
	
	[tmpPool release];
}

-(void)makeIconSmall:(Face *) face {
	if (face.iconSmall) return;
	
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	NSString *base = @"tmbsm_";
	NSString *tmbName = [base stringByAppendingString:face.imageName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *tmbpath = [face.path stringByAppendingPathComponent:tmbName];
	if ([fileManager fileExistsAtPath:tmbpath]){
		UIImage *icon = [[UIImage alloc] initWithContentsOfFile:tmbpath];
		face.iconSmall = icon;
		[icon release];
	} else {
	}
	
	[tmpPool release];
}

-(BOOL)hasTrait:(NSString *)traitStr {
	if ([trait compare:NSLocalizedString(@"AllFacesKey",@"")]==NSOrderedSame) return YES;
	if ([traitStr rangeOfString:trait.description].location!=NSNotFound)
		return YES;
	else
		return NO;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	if ([[trait substringToIndex:1] compare:@"@"] == NSOrderedSame)
		self.title = [trait substringFromIndex:1];
	else
		self.title = NSLocalizedString(trait,@"");
	
	if (loadThread){
		[loadThread release];
		loadThread = nil;
	}
	if (self.faceView){
		[faceView release];
		faceView = nil;
	}
	
		sects=0;
		for (int c=0;c<27;c++) rowsPerSection[c] = 0;
		for (int c=0;c<27;c++) realSections[c] = 0;
		for (int c=0;c<27;c++) startIndex[c] = 0;
	
	[self incrementalLoadTable];
	[self.tableView reloadData];
}

-(void)reloadTable {
	[self.tableView reloadData];
	[self.tableView setHidden:NO];
}

-(void)editLibrary {
	[self.tableView setSectionIndexMinimumDisplayRowCount:1000];
    [self.tableView setEditing:YES animated:YES];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
	
    // set edit button to done
    doneButton = [[[UIBarButtonItem alloc]
				   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				   target:self
				   action:@selector(doneEditLibrary)] autorelease];
	
	self.navigationItem.rightBarButtonItem = doneButton;  
}

-(void)doneEditLibrary {
	[self.tableView setSectionIndexMinimumDisplayRowCount:20];
    [self.tableView setEditing:NO animated:YES];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
    
	// set edit button to done
    editButton = [[[UIBarButtonItem alloc]
				   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
				   target:self
				   action:@selector(editLibrary)] autorelease];
	
	self.navigationItem.rightBarButtonItem = editButton;  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

///////// TABLE DELEGATE METHODS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (sects==0) return 1;	
    return sects;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (rowsPerSection)	return rowsPerSection[section];
	else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [alphabet substringWithRange: NSMakeRange( realSections[section], 1)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellLib";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,320,tableView.rowHeight)  reuseIdentifier:CellIdentifier] autorelease];
    }
	
    Face *face =nil;
	if (tableData.count>startIndex[indexPath.section]+ indexPath.row)
		face = (Face *)[tableData objectAtIndex: startIndex[indexPath.section]+ indexPath.row];
	
	[cell setText:face.name];
	if (face.iconSmall == nil) 
		[cell setImage:curImage];
	else 
		[cell setImage:face.iconSmall];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {	

    if(editingStyle == UITableViewCellEditingStyleDelete) {
		
		Face *face =nil;
		if (tableData.count>startIndex[indexPath.section]+ indexPath.row)
			face = (Face *)[tableData objectAtIndex: startIndex[indexPath.section]+ indexPath.row];
		if (!face) return;
		
        [appDelegate.faceDatabaseDelegate deleteFace:face];
        
		[tableData removeObjectAtIndex:startIndex[indexPath.section]+ indexPath.row];
		rowsPerSection[indexPath.section]--;
		for (int k=indexPath.section+1;k<sects;k++) startIndex[k] -= 1;
				
        //Delete the object from the table.
		if (appDelegate.faceDatabaseDelegate.faces.count == 0){
			[self incrementalLoadTable];
			[tableView reloadData];
		} else {
		
		NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

		if (rowsPerSection[indexPath.section]==0) {
			[self incrementalLoadTable];
			if(sects>0){
				[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];		
			}
		}
		//[tableView reloadData];

		[tmpPool release];
		}
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic -- create and push a new view controller
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];

    Face *face =nil;
	if (tableData.count>startIndex[indexPath.section]+ indexPath.row)
		face = (Face *)[tableData objectAtIndex: startIndex[indexPath.section]+ indexPath.row];
	if(!face) return;
	
    if(!self.faceView){
        FaceDetailsViewController *viewController = [[FaceDetailsViewController alloc] initWithNibName:@"FaceDetailsViewController" bundle:nil];
        self.faceView = viewController;
        [viewController release];
    }
	
    [faceView resetFace:face setName:YES];    
	[self.navigationController pushViewController:faceView animated:YES];
	
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (self.editing) return nil;
	NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
	
	for(int c=0;c<27;c++){
		if (rowsPerSection[c]) [tmp addObject:[alphabet substringWithRange:NSMakeRange(realSections[c] ,1)]];
	}
	
	return [NSArray arrayWithArray:tmp];
}


- (void)dealloc {
	[curImage release]; curImage = nil;
	
	if (self.faceView) {
		[self.faceView release];
		self.faceView = nil;
	}

	appDelegate = nil;
	alphabet = nil;
	trait = nil;
	
	sects=0;
	
	if (tableData) [tableData release]; tableData = nil;
	
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
}

/*
-(void)release {
	[super release];
}
*/

@end
