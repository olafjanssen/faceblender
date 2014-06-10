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
@synthesize editButton, addButton, doneButton, appDelegate;
@synthesize alphabet;
@synthesize trait;
@synthesize pool,curCnt,curImage,imageViews,loadThread;

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
    [super viewDidLoad];
	
    editButton = [[[UIBarButtonItem alloc]
				   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
				   target:self
				   action:@selector(editLibrary)] autorelease];
	self.navigationItem.rightBarButtonItem = editButton;  
	
    self.title = @"Library";
    
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ#";
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	//	[self.tableView reloadData];
    [self.tableView setSectionIndexMinimumDisplayRowCount:20];
	
	curImage = [[UIImage alloc] initWithContentsOfFile:@"EmptyIconSmall.jpg"];
}

-(void)showActivity {
	NSAutoreleasePool *tmppool = [[NSAutoreleasePool alloc] init];
	[appDelegate showActivityViewer];
	[tmppool release];
}

-(void)makeIconSmall:(Face *) face {
	if (face.iconSmall) return;
	
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	NSString *base = @"tmbsm_";
	NSString *tmbName = [base stringByAppendingString:face.imageName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *tmbpath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:tmbName];
	if ([fileManager fileExistsAtPath:tmbpath]){
		UIImage *icon = [[UIImage alloc] initWithContentsOfFile:tmbpath];
		face.iconSmall = icon;
		[icon release];
	} else {
	}
	
	[tmpPool release];
}

-(BOOL)hasTrait:(NSString *)traitStr {
	if ([trait compare:@"All"]==NSOrderedSame) return YES;
	if ([traitStr rangeOfString:trait.description].location!=NSNotFound)
		return YES;
	else
		return NO;
}

-(void)viewWillAppear:(BOOL)animated {	
	[super viewWillAppear:YES];
    self.title = trait;
	
	[NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
	if (loadThread){
		[loadThread release];
		loadThread = nil;
	}
	if (self.faceView){
		[faceView release];
		faceView = nil;
	}
	loadThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImages) object:nil];
	[loadThread start];
}

-(void)reloadTable {
	[self.tableView reloadData];
	[self.tableView setHidden:NO];
}

-(void)loadImages{
	pool = [[NSAutoreleasePool alloc] init];
	
	//[self.tableView reloadData];
	
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){
		if ([self hasTrait:f.traits] && !f.iconSmall) [self makeIconSmall:f];
		if ([loadThread isCancelled]) break;
	}
	
	[pool release];
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
	faceView = nil;
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){
		[f setCustom:NO];
	}
	
	int gcnt = 0;
	int cnt = 0;
	for(int c=0;c<27;c++){
		sectionExists[c] = NO;
		for (int u=0;u<appDelegate.faceDatabaseDelegate.faces.count ;u++){
			if (![self hasTrait:[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] traits]]) continue;
			if ([[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] length]>0)
				if ([[[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] substringToIndex:1] compare:[alphabet substringWithRange: NSMakeRange( c, 1)]] == NSOrderedSame){
					[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] setCustom:YES];
					gcnt++;
					if (!sectionExists[c]){
						cnt++; 
						sectionExists[c] = YES;
					}
				};
		}
    }
	
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){
		if (![self hasTrait:[f traits]]) continue;
		if (f.custom == NO){ 
			gcnt++;
			if (!sectionExists[26]){
				sectionExists[26] = YES;
				cnt++;
			}
			//break; 
		}
	}
	
	NSString *title = [[NSString alloc] initWithFormat:@"%@ (%d)", trait.description, gcnt];
	[self setTitle:title];
	[title release];
	
	if (cnt<1) cnt = 1;
    return cnt;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// find real section number
	int realSection = -1;
	for(int c=0;c<27;c++){
		if (sectionExists[c]) realSection++;
		if (realSection == section){ realSection = c; break; }
	}
	
	int cnt = 0;
	if (realSection < 26){
		
		for (int u=0;u<appDelegate.faceDatabaseDelegate.faces.count ;u++){
			if (![self hasTrait:[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] traits]]) continue;
			if ([[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] length]>0)
				if ([[[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] substringToIndex:1] compare: [alphabet substringWithRange: NSMakeRange( realSection, 1)]] == NSOrderedSame){
					cnt++;
				};
		}
	} else {
		for (Face *f in appDelegate.faceDatabaseDelegate.faces){
			if (![self hasTrait:[f traits]]) continue;
			if (f.custom == NO){ 
				cnt++;
			}
			
		}
	}
    return cnt;
	//	return appDelegate.faceDatabaseDelegate.faces.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// find real section number
	int realSection = -1;
	for(int c=0;c<27;c++){
		if (sectionExists[c]) realSection++;
		if (realSection == section){ realSection = c; break; }
	}
	return [alphabet substringWithRange: NSMakeRange( realSection, 1)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"CellLib";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,320,tableView.rowHeight)  reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Set up the cell
	// find real section number
	int realSection = -1;
	for(int c=0;c<27;c++){
		if (sectionExists[c]) realSection++;
		if (realSection == indexPath.section){ realSection = c; break; }
	}
	
	int cnt = 0;
	int ucnt = 0;
	if (realSection < 26){
		for (int u=0;u<appDelegate.faceDatabaseDelegate.faces.count ;u++){
			if ([[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] length]>0)
				if ([self hasTrait:[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] traits]])
					if ([[[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] substringToIndex:1] compare: [alphabet substringWithRange: NSMakeRange( realSection, 1)]] == NSOrderedSame){
						if (cnt == indexPath.row) break;
						cnt++;
					};
			ucnt++;
		}
	} else {
		for (Face *f in appDelegate.faceDatabaseDelegate.faces){
			if ([self hasTrait:[f traits]])
				if (f.custom == NO){
					if( cnt == indexPath.row) break;
					cnt++;
				}
			ucnt++;
		}
	}
    Face *face = (Face *)[appDelegate.faceDatabaseDelegate.faces objectAtIndex:ucnt];
	
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
		
		int no = [self tableView:tableView numberOfRowsInSection:indexPath.section];
		
		// Set up the cell
		// find real section number
		int realSection = -1;
		for(int c=0;c<27;c++){
			if (sectionExists[c]) realSection++;
			if (realSection == indexPath.section){ realSection = c; break; }
		}
		
		int cnt = 0;
		int ucnt = 0;
		if (realSection < 26){
			for (int u=0;u<appDelegate.faceDatabaseDelegate.faces.count ;u++){
				if ([[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] length]>0)
					if ([self hasTrait:[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] traits]])
						if ([[[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] substringToIndex:1] compare: [alphabet substringWithRange: NSMakeRange( realSection, 1)]] == NSOrderedSame){
							if (cnt == indexPath.row) break;
							cnt++;
						};
				ucnt++;
			}
		} else {
			for (Face *f in appDelegate.faceDatabaseDelegate.faces){
				if ([self hasTrait:[f traits]])
					if (f.custom == NO){
						if( cnt == indexPath.row) break;
						cnt++;
					}
				ucnt++;
			}
		}
		Face *face = (Face *)[appDelegate.faceDatabaseDelegate.faces objectAtIndex:ucnt];
        
        [appDelegate.faceDatabaseDelegate deleteFace:face];
        
        //[face release];
        
        //Delete the object from the table.
		NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
		if (no>1) {
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		} else {
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:YES];		
		}
		[tmpPool release];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic -- create and push a new view controller
	
	// Set up the cell
	// find real section number
	int realSection = -1;
	for(int c=0;c<27;c++){
		if (sectionExists[c]) realSection++;
		if (realSection == indexPath.section){ realSection = c; break; }
	}
	
	int cnt = 0;
	int ucnt = 0;
	if (realSection < 26){
		for (int u=0;u<appDelegate.faceDatabaseDelegate.faces.count ;u++){
			if ([[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] length]>0)
				if ([self hasTrait:[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] traits]])
					if ([[[[appDelegate.faceDatabaseDelegate.faces objectAtIndex:u] name] substringToIndex:1] compare: [alphabet substringWithRange: NSMakeRange( realSection, 1)]] == NSOrderedSame){
						if (cnt == indexPath.row) break;
						cnt++;
					};
			ucnt++;
		}
	} else {
		for (Face *f in appDelegate.faceDatabaseDelegate.faces){
			if ([self hasTrait:[f traits]])
				if (f.custom == NO){
					if( cnt == indexPath.row) break;
					cnt++;
				}
			ucnt++;
		}
	}
    Face *face = (Face *)[appDelegate.faceDatabaseDelegate.faces objectAtIndex:ucnt];	
	
    if(!self.faceView){
        FaceDetailsViewController *viewController = [[FaceDetailsViewController alloc] initWithNibName:@"FaceDetailsViewController" bundle:nil];
        self.faceView = viewController;
        [viewController release];
    }
	
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    [faceView resetFace:face setName:YES];    
	[self.navigationController pushViewController:faceView animated:YES];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if (self.editing) return nil;
	NSMutableArray *tmp = [[[NSMutableArray alloc] init] autorelease];
	
	for(int c=0;c<27;c++){
		if (sectionExists[c]) [tmp addObject:[alphabet substringWithRange:NSMakeRange(c,1)]];
	}
	
	return [NSArray arrayWithArray:tmp];
}


- (void)dealloc {
    [addButton release]; addButton = nil;
    [editButton release]; editButton = nil;
    [doneButton release]; doneButton = nil;
	[curImage release]; curImage = nil;
	
	faceTable = nil;
	faceView = nil;
	appDelegate = nil;
	alphabet = nil;
	trait = nil;
	imageViews = nil;
	pool = nil;
	
	if (loadThread){
		[loadThread release];
		loadThread = nil;
	}
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (loadThread.isExecuting) {
		[loadThread cancel];
	}
}

/*
-(void)release {
	NSLog([NSString stringWithFormat:@"Release libviewcont: %d",[self retainCount]]);
	[super release];
}
*/

@end
