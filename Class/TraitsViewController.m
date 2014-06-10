//
//  TraitsViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/22/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "TraitsViewController.h"
#import "Trait.h"


@implementation TraitsViewController
@synthesize traitsTable, appDelegate, headerView, imageView, textLabel;
@synthesize selected,unselected, toggles;
@synthesize face, isNew,traitsLst;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	if (isNew && face.traitsTmp){
		
		NSString *strc;
		if (traitsLst.length>0)
			strc = [[NSString alloc] initWithFormat:@", %@",face.traitsTmp];
		else
			strc = [[NSString alloc] initWithFormat:@"%@",face.traitsTmp];
		
		NSString *tmp = [NSString stringWithString: traitsLst];
		[traitsLst release];
		traitsLst = [[NSString alloc] initWithString: [tmp stringByAppendingFormat:strc]];
		[face.traitsTmp release];
		face.traitsTmp = nil;
		[strc release];
		[self setTraits:traitsLst];
		isNew = NO;
	}
	
	[traitsTable reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set UI
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTraits)];
	self.navigationItem.rightBarButtonItem = doneButton;  

    // load images
    selected = [UIImage imageNamed:@"selected.png"];
    unselected = [UIImage imageNamed:@"unselected.png"];
    
	// set up the table's header view based on our UIView 'myHeaderView' outlet
	CGRect newFrame = CGRectMake(0.0, 0.0, traitsTable.bounds.size.width, self.headerView.frame.size.height);
	self.headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.headerView.frame = newFrame;
//	traitsTable.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property
	
	[self.view addSubview:self.headerView];
	
	CGRect newTableFrame = CGRectMake(0.0, self.headerView.frame.size.height, traitsTable.bounds.size.width, 480-self.headerView.frame.size.height);
	traitsTable.frame = newTableFrame;
	
    // set the delegate and source of the table to self
    traitsTable.delegate = self;
    traitsTable.dataSource = self;
//	traitsTable.rowHeight = 35;
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // initialize toggles
    toggles = malloc(sizeof(BOOL)*(appDelegate.faceDatabaseDelegate.traits.count+50));
    for(int tog=0;tog<appDelegate.faceDatabaseDelegate.traits.count;tog++) toggles[tog] = NO;
    
}

-(void)setTraits:(NSString *)f {
	if (f)	traitsLst = f;

    for(int tog=0;tog<appDelegate.faceDatabaseDelegate.traits.count;tog++){
        Trait *trait = nil;
		if (appDelegate.faceDatabaseDelegate.traits.count>tog)
			trait = [appDelegate.faceDatabaseDelegate.traits objectAtIndex:tog];
		
        if ([traitsLst rangeOfString:trait.description].location!=NSNotFound)
            toggles[tog] = YES; 
        else 
            toggles[tog] = NO;
    }
    
    [traitsTable reloadData];
	[self.navigationItem setTitle:NSLocalizedString(@"SelectTraitsKey",@"")];

}

-(void)saveTraits {
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];

    // get the data
    int cnt = 0;
    NSMutableString *traitStr = [[NSMutableString alloc] initWithCString:""];
    for(int tog=0;tog<appDelegate.faceDatabaseDelegate.traits.count;tog++){
        if (toggles[tog]){
            if (cnt>0) [traitStr appendString:@", "];            
            
			Trait *trait = nil;
			if (appDelegate.faceDatabaseDelegate.traits.count>tog)
				trait = [appDelegate.faceDatabaseDelegate.traits objectAtIndex:tog];
			if(!trait) continue;
			
			[traitStr appendString:trait.description];
            cnt++;
        }
    }
    face.traits = traitStr;
	[appDelegate.faceDatabaseDelegate updateFace:face];
	
	[traitStr release]; traitStr = nil;
	[tmpPool release];
	traitsLst = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return appDelegate.faceDatabaseDelegate.traitSections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>section)
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:section];
    if (!trait) return 0;
	
	int adder = 0;
	if (section == 6) adder = 1;
    return trait.uniqueId + adder;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>section+1)
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:section];
    if (!trait) return @"";
	
    return NSLocalizedString(trait.description,@"");
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TraitsViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell
    int rc = 0;
    for (int sections = 1; sections<=indexPath.section; sections ++) {
		Trait *trait = nil;
		if (appDelegate.faceDatabaseDelegate.traitSections.count>sections-1)
			trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:sections-1];
		if (trait) rc += trait.uniqueId;
        //[Trait release];
		trait = nil;
    }

	// adder cell
	if (indexPath.section == 6 && appDelegate.faceDatabaseDelegate.traitSections.count>6 && indexPath.row == [[appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:6] uniqueId]){
		[cell setText:NSLocalizedString(@"NewTraitKey",@"")];
		[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	} else {
	
		Trait *trait=nil;
	if (appDelegate.faceDatabaseDelegate.traits.count>indexPath.row + rc)
		trait = (Trait *)[appDelegate.faceDatabaseDelegate.traits objectAtIndex:indexPath.row + rc];
		if (trait){
            if (trait.description && trait.description.length>0 && [[trait.description substringToIndex:1] compare:@"@"]==NSOrderedSame){
				[cell setText:[trait.description substringFromIndex:1]];
			} else		
				[cell setText:NSLocalizedString(trait.description,@"")];
		}
	//[Trait release];
    
    if (toggles[indexPath.row + rc])
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
		[cell setAccessoryType:UITableViewCellAccessoryNone];
    
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	}
    
	return cell;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [traitsTable deselectRowAtIndexPath:indexPath animated:NO];

	if (indexPath.section == 6 && indexPath.row == [[appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:6] uniqueId]){
		TraitsNewViewController *viewController = [[TraitsNewViewController alloc] initWithNibName:@"TraitsNewViewController" bundle:[NSBundle mainBundle]];
		[viewController setFace: face];
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
		isNew = YES;
		return;
	}
	
    int rc = 0;
    for (int sections = 1; sections<=indexPath.section; sections ++) {
		Trait *trait = nil;
		if (appDelegate.faceDatabaseDelegate.traitSections.count>sections-1)
			trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:sections-1];
		if (trait) rc += trait.uniqueId;
//        [Trait release];
    }
    
    if (toggles[indexPath.row + rc]) 
        toggles[indexPath.row + rc] = NO;
    else {
        toggles[indexPath.row + rc] = YES;
    
	// scroll to next section
	if (indexPath.section<6){
	NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section+1];
	[traitsTable scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
	}
    [traitsTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    free(toggles);
	imageView.image = nil;
	traitsTable = nil;
	appDelegate = nil;
	headerView = nil;
	imageView = nil;
	textLabel = nil;
	selected = nil;
	unselected = nil;
	if (traitsLst) [traitsLst release]; traitsLst = nil;
    [super dealloc];
}


@end

