//
//  PreLibraryViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/18/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "PreLibraryViewController.h"

@implementation PreLibraryViewController

@synthesize traitTable, libView, faceView, pickPointsView;
@synthesize rowsInSection,facesPerTrait,activityView;

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
     UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
	 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
	 target:self
	 action:@selector(addLibraryItem)] autorelease];
	 self.navigationItem.leftBarButtonItem = addButton;  
	 
    self.title = NSLocalizedString(@"LibraryKey",@"");
    
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
		
	rowsInSection = [[NSMutableArray alloc] init];
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traitSections.count+1;c++){
		[rowsInSection addObject:[NSNumber numberWithInt:-1]];
	}
	facesPerTrait = [[NSMutableArray alloc] init];
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traits.count+1;c++){
		[facesPerTrait addObject:[NSNumber numberWithInt:-1]];
	}
	
}

-(void)viewWillAppear:(BOOL)animated {	
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	[rowsInSection removeAllObjects];
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traitSections.count+1;c++){
		[rowsInSection addObject:[NSNumber numberWithInt:-1]];
	}
	[facesPerTrait removeAllObjects];
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traits.count+1;c++){
		[facesPerTrait addObject:[NSNumber numberWithInt:-1]];
	}
	
	[tmpPool release];
	
	[self.tableView reloadData];
	
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(IBAction)addLibraryItem {
	// check if the device is an iPod, otherwise the camera can also be used
	UIDevice *curDevice = [UIDevice currentDevice];
	if ([curDevice.model compare: @"iPod touch"] == NSOrderedSame){
/*		if(self.faceView == nil){
			FaceDetailsViewController *viewController = [[FaceDetailsViewController alloc] initWithNibName:@"FaceDetailsViewController" bundle:nil];
			self.faceView = viewController;
			[viewController release];
		}
		[self.navigationController pushViewController:self.faceView animated:NO];
		[self.faceView pickImage];
*/				
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:NSLocalizedString(@"AddFaceFromKey",@"")
									  delegate:self 
									  cancelButtonTitle:NSLocalizedString(@"CancelKey",@"")
									  destructiveButtonTitle:nil
									  otherButtonTitles:NSLocalizedString(@"Facebook Friends",@""),NSLocalizedString(@"AddressBookKey",@""),NSLocalizedString(@"PhotoLibraryKey",@""),nil];
		[actionSheet showInView:[self.view window]];
		[actionSheet release];
		
	} else {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:NSLocalizedString(@"AddFaceFromKey",@"")
								  delegate:self 
								  cancelButtonTitle:NSLocalizedString(@"CancelKey",@"")
								  destructiveButtonTitle:nil
								  otherButtonTitles:NSLocalizedString(@"Facebook Friends",@""),NSLocalizedString(@"AddressBookKey",@""),NSLocalizedString(@"PhotoLibraryKey",@""), NSLocalizedString(@"CameraKey",@""),nil];
    [actionSheet showInView:[self.view window]];
	[actionSheet release];
	}
}

/*
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{	
	if(self.faceView == nil){
        FaceDetailsViewController *viewController = [[FaceDetailsViewController alloc] initWithNibName:@"FaceDetailsViewController" bundle:nil];
        self.faceView = viewController;
        [viewController release];
    }
	
    switch (buttonIndex){
        case 0:			
			[self.navigationController pushViewController:self.faceView animated:NO];
            [self.faceView pickImageFromAddressBook];
            break;
        case 1:
			[self.navigationController pushViewController:self.faceView animated:NO];
            [self.faceView pickImage];
            break;
        case 2:
			if ([[UIDevice currentDevice].model compare: @"iPod touch"] != NSOrderedSame){
				[self.navigationController pushViewController:self.faceView animated:NO];
				[self.faceView pickImageFromCamera];
			}
            break;
        default:
            break;
    }
	
}
*/

-(void)continuePick {
    // do nothing
}

-(void)cancelPick {
	[activityView removeFromSuperview];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];   
	[activityView release];
	activityView = nil;
}

-(void) facebookPick {
    // do nothing
}




-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{	
	if(self.faceView == nil){
        FaceDetailsViewController *viewController = [[FaceDetailsViewController alloc] initWithNibName:@"FaceDetailsViewController" bundle:nil];
        self.faceView = viewController;
        [viewController release];
    }
	
    switch (buttonIndex){
        case 0:			
			//[self.navigationController pushViewController:self.faceView animated:NO];
            //[self.faceView pickImageFromFacebook];
			[self facebookPick];
            break;
        case 1:			
			[self.navigationController pushViewController:self.faceView animated:NO];
            [self.faceView pickImageFromAddressBook];
            break;
        case 2:
			[self.navigationController pushViewController:self.faceView animated:NO];
            [self.faceView pickImage];
            break;
        case 3:
			if ([[UIDevice currentDevice].model compare: @"iPod touch"] != NSOrderedSame){
				[self.navigationController pushViewController:self.faceView animated:NO];
				[self.faceView pickImageFromCamera];
			}
            break;
        default:
            break;
    }
	
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int cnt=0;
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traitSections.count;c++) {
		if ([self rowsInSection:c] > 0) cnt++;
	}
	
	return cnt+1;
//	return appDelegate.faceDatabaseDelegate.traitSections.count+1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0){
		//if (appDelegate.faceDatabaseDelegate.faces.count>0) return 1; else return 3;
		return 1;
	}
    return [self rowsInSection:[self realSection:section]];
}

-(void)initPreList {
}

-(NSInteger)facesPerTrait:(Trait *)trait {
	if (!trait) return 0;
	
	NSInteger cached = -1;
	if(facesPerTrait.count>trait.uniqueId) 
		cached = [[facesPerTrait objectAtIndex:trait.uniqueId] intValue];
	if (cached != -1) return cached;

	int gcnt = 0;
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){
		if (trait.description)
		if ([ [f traits] rangeOfString:trait.description].location==NSNotFound) continue;
		gcnt++;
	}
	
	if (facesPerTrait.count>trait.uniqueId)
		[facesPerTrait replaceObjectAtIndex:trait.uniqueId withObject:[NSNumber numberWithInt:gcnt]];
	return gcnt;
}

-(NSInteger)realSection:(NSInteger) section {
	int cnt=0;
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traitSections.count;c++) {
		if ([self rowsInSection:c] == 0) continue;
		cnt++;
		if (section == cnt) return c;
	}
	return 0;
}

-(NSInteger)rowsInSection:(NSInteger) section {
	NSInteger cached = -1;
	if(rowsInSection.count>section) 
		cached = [[rowsInSection objectAtIndex:section] intValue];
	if (cached != -1) return cached;
	
	int offset = 0;
	for (int c=0;c<section;c++){
		if (appDelegate.faceDatabaseDelegate.traitSections.count>c)
			offset += (int)[[appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:c] uniqueId];
	}
	
	Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>section)
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:section];
	if (!trait) return 0;
	
	int cnt=0;
	for (int c=offset;c<offset+trait.uniqueId;c++){
		Trait *t = nil;
		if (appDelegate.faceDatabaseDelegate.traits.count>c)
			t = [appDelegate.faceDatabaseDelegate.traits objectAtIndex:c];
		if (!t) continue;
		
		int gcnt = 0;
		for (Face *f in appDelegate.faceDatabaseDelegate.faces){
			if (t.description)
				if ([ [f traits] rangeOfString:t.description].location==NSNotFound) continue;
			gcnt++; break;
		}
		if (gcnt>0) cnt++;
	}
	
	if (rowsInSection.count>section)
		[rowsInSection replaceObjectAtIndex:section withObject: [NSNumber numberWithInt:cnt]];
	return cnt;
}

-(Trait *)traitForIndexPath:(NSIndexPath *)indexPath {
	// offset from section
	int section = [self realSection:indexPath.section];
	int offset = 0;
	for (int c=0;c<section;c++){
		if (appDelegate.faceDatabaseDelegate.traitSections.count>c)
			offset += (int)[[appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:c] uniqueId];
	}
	
	// find row belonging to non-empty trait
	Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>section)
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:section];
	if (!trait) return nil;
	
	int cnt=0; int tcnt = 0;
	for (int c=offset;c<offset+trait.uniqueId;c++){
		Trait *t = nil;
		if (appDelegate.faceDatabaseDelegate.traits.count>c)
			t = [appDelegate.faceDatabaseDelegate.traits objectAtIndex:c];
		if (!t) continue;

		int gcnt = 0;
		for (Face *f in appDelegate.faceDatabaseDelegate.faces){
			if (t.description)
				if ([ [f traits] rangeOfString:t.description].location==NSNotFound) continue;
			gcnt++; break;
		}
		if (gcnt>0) cnt++;
		if (cnt == indexPath.row+1) {
			tcnt = c; 
			break;
		}
	}
	
	if (appDelegate.faceDatabaseDelegate.traits.count>tcnt)
		return [appDelegate.faceDatabaseDelegate.traits objectAtIndex:tcnt];
	else return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) return @"";
	
	Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>[self realSection:section])
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:[self realSection:section]];
    if (trait)
		return NSLocalizedString(trait.description,@"");
	else return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PreLibCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }

	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];

	if (indexPath.section == 0){
		if (appDelegate.faceDatabaseDelegate.faces.count>0) {
			[cell setText:[NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"AllFacesKey",@""), appDelegate.faceDatabaseDelegate.faces.count]];
/*		
			UIButton *noButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[noButton setFrame:CGRectMake(250,12,35,44-2*12)];
			[noButton setEnabled:NO];
			[noButton setTitle:[NSString stringWithFormat:@"%d",appDelegate.faceDatabaseDelegate.faces.count] forState:UIControlStateNormal];
			[cell addSubview:noButton];
 */
		}
		else {
			[cell setText:NSLocalizedString(@"LibraryEmptyKey",@"")];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			[tmpPool release];
			return cell;
		}
		
	} else {			
		Trait *trait = [self traitForIndexPath:indexPath];
		if (trait){
		int gcnt = [self facesPerTrait:trait];
		if (gcnt>0) {
			if (trait.description.length>0)
			if ([[trait.description substringToIndex:1] compare:@"@"]==NSOrderedSame){
				[cell setText:[NSString stringWithFormat:@"%@ (%d)", [trait.description substringFromIndex:1], gcnt]];
			} else		
				[cell setText:[NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(trait.description,@""), gcnt]];
		}
		else
			[cell setText:NSLocalizedString(trait.description,@"")];
/*
		if (gcnt>0) {
			UIButton *noButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[noButton setFrame:CGRectMake(250,12,35,44-2*12)];
			[noButton setEnabled:NO];
			[noButton setTitle:[NSString stringWithFormat:@"%d",gcnt] forState:UIControlStateNormal];
			[noButton setBackgroundColor:[UIColor grayColor]];
			[noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[cell addSubview:noButton];
		}
*/		
	}
	}
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	[tmpPool release];
			  
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *txt = @"";
	if (indexPath.section == 0){
		txt = NSLocalizedString(@"AllFacesKey",@"");
	} else {	
		Trait *trait = [self traitForIndexPath:indexPath];
		if (trait) txt = trait.description;
	}
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (appDelegate.faceDatabaseDelegate.faces.count>0){
		if(!self.libView){
			LibraryViewController *viewController = [[LibraryViewController alloc] init];
			self.libView = viewController;
			[viewController release];
		}
		
		[self.libView setTrait: txt];		
		[self.navigationController pushViewController:self.libView animated:YES];
	}
	
}


- (void)dealloc {	
	[rowsInSection release]; rowsInSection = nil;
	[facesPerTrait release]; facesPerTrait = nil;
    [super dealloc];
}


@end
