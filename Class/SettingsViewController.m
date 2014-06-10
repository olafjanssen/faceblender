//
//  SettingsViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
@synthesize appDelegate;
@synthesize headerView,tableView, tableArray;
@synthesize demoSwitch, resControl;
@synthesize itemSelected,settings;
@synthesize keyRes, keyTips, keyCrop, keyDemo,isLoaded;
@synthesize tipsSwitch, cropSwitch;

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

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
		
    self.title = NSLocalizedString(@"SettingsKey",@"");
	
    // set up the table's header view based on our UIView 'myHeaderView' outlet
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
		
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];

	// read settings or either create them if they do not exist
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
		
//	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	settings = [NSMutableArray arrayWithContentsOfFile:filePath];
	if (settings.count>3){
	if ([[settings objectAtIndex:0] compare:@"0.5x"] == NSOrderedSame) keyRes = 0;
	if ([[settings objectAtIndex:0] compare:@"1x"] == NSOrderedSame) keyRes = 1;
	if ([[settings objectAtIndex:0] compare:@"2x"] == NSOrderedSame) keyRes = 1;	// 2x is no longer supported
	
	keyTips = ([[settings objectAtIndex:1] compare:@"YES"]==NSOrderedSame);
	keyDemo = ([[settings objectAtIndex:2] compare:@"YES"]==NSOrderedSame);
	keyCrop = ([[settings objectAtIndex:3] compare:@"YES"]==NSOrderedSame);
	}
	isLoaded = NO;
	
	tipsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200,8,50,50)];
	cropSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200,8,50,50)];
	demoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200,8,50,50)];
	
	loginButton = [[FBLoginButton alloc] init]; 
//	[loginButton setStyle:FBLoginButtonStyleWide];

}

-(void)viewWillAppear:(BOOL)animated {
	isLoaded = YES;
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	settings = [NSMutableArray arrayWithContentsOfFile:filePath];
	if (settings.count>3){
	if ([[settings objectAtIndex:0] compare:@"0.5x"] == NSOrderedSame) keyRes = 0;
	if ([[settings objectAtIndex:0] compare:@"1x"] == NSOrderedSame) keyRes = 1;
	if ([[settings objectAtIndex:0] compare:@"2x"] == NSOrderedSame) keyRes = 2;
	
	keyTips = ([[settings objectAtIndex:1] compare:@"YES"]==NSOrderedSame);
	keyDemo = ([[settings objectAtIndex:2] compare:@"YES"]==NSOrderedSame);
	keyCrop = ([[settings objectAtIndex:3] compare:@"YES"]==NSOrderedSame);
	}
	[self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
	[tableView reloadData];
	[super viewWillAppear:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)makeIconSmall:(Face *) face {
	if (face.iconSmall) return;
	
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
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return NSLocalizedString(@"SettingsBlenderKey",@"");
			break;
		case 1:
			return NSLocalizedString(@"SettingsDataKey",@"");
			break;
		case 2:
			return NSLocalizedString(@"SettingsGeneralKey",@"");
			break;
		default:
			return NSLocalizedString(@"SettingsOther",@"");
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 3;
			break;
		case 2:
		{
			UIDevice *curDevice = [UIDevice currentDevice];
			if ([curDevice.model compare: @"iPod touch"] == NSOrderedSame) return 4; else return 3;
		}
			break;
		default:
			return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIAlertView *newAlert;
	AboutViewController *aboutController;

	switch (indexPath.section) {
		case 0:
			break;
		case 1:
			switch( indexPath.row){
				case 1:
					itemSelected = 0;
					newAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WarningKey",@"") message:NSLocalizedString(@"DeleteLibraryKey",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey",@"") otherButtonTitles:NSLocalizedString(@"DeleteKey",@""),nil];
					[newAlert show];
					[newAlert release];
					break;
				case 2:
					itemSelected = 1;
					newAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WarningKey",@"") message:NSLocalizedString(@"DeleteBlendsKey",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey",@"") otherButtonTitles:NSLocalizedString(@"DeleteKey",@""),nil];
					[newAlert show];
					[newAlert release];
					break;
				default:
					break;
			}
			break;
		case 2:
			if ( (([[[UIDevice currentDevice] model] compare: @"iPod touch"] == NSOrderedSame) && indexPath.row == 3) || 
				 (([[[UIDevice currentDevice] model] compare: @"iPod touch"] != NSOrderedSame) && indexPath.row == 2)) {
			aboutController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
			[self.navigationController pushViewController:aboutController animated:YES];
			[aboutController.navigationItem setTitle:NSLocalizedString(@"AboutKey",@"")];
			[aboutController.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
			[aboutController release];
			}
			break;
		default:
			break;
	}

	[self.tableView deselectRowAtIndexPath:indexPath	animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger) buttonIndex
{    
	switch (buttonIndex){
        case 0:
            break;
        case 1:
			if (itemSelected == 0){
				// delete library
				while (appDelegate.faceDatabaseDelegate.faces.count>0)
					[appDelegate.faceDatabaseDelegate deleteFace:[appDelegate.faceDatabaseDelegate.faces objectAtIndex:0]];
				// turn off demo library
				[demoSwitch setOn:NO animated:YES];
				
			}
			if (itemSelected == 1){
				// delete gallery
				while (appDelegate.galleryDatabaseDelegate.galleryItems.count>0)
					[appDelegate.galleryDatabaseDelegate deleteImage:[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:0]];
				
			}
            break;
        default:
            break;
    }
    
}

#define kCellID @"cellID"

- (void) switchedDemoOption
{
	if (!demoSwitch.on) {
		[self switchedOption];
		[appDelegate reloadFacesDatabase];
		for(Face *f in appDelegate.faceDatabaseDelegate.faces){
			[IconMaker makeIconFace:f];
			[IconMaker makeIconSmallFace:f];
			[self makeIconSmall:f];
		}
	} else {
		DownloadController *dc = [[DownloadController alloc] init];
		[dc setDelegate:self];
		[dc isDownloadNeeded];
	}

	[self switchedOption];	
}



- (void) switchedOption
{
	keyRes = resControl.selectedSegmentIndex;
	keyTips = tipsSwitch.on;
	keyDemo = demoSwitch.on;
	keyCrop = cropSwitch.on;
	
	NSString *newStr0;
	if (resControl.selectedSegmentIndex == 0)
		newStr0 = [NSString stringWithString:@"0.5x"];
	else if (resControl.selectedSegmentIndex == 1)
		newStr0 = [NSString stringWithString:@"1x"];
	else if (resControl.selectedSegmentIndex == 2)
		newStr0 = [NSString stringWithString:@"2x"];
	else newStr0 = [NSString stringWithString:@"0.5x"];
	
	NSString *newStr1;
	if (tipsSwitch.on) 
		newStr1 = [NSString stringWithString:@"YES"];
	else
		newStr1 = [NSString stringWithString:@"NO"];

	NSString *newStr2;
	if (demoSwitch.on) 
		newStr2 = [NSString stringWithString:@"YES"];
	else
		newStr2 = [NSString stringWithString:@"NO"];

	NSString *newStr3;
	if (cropSwitch.on) 
		newStr3 = [NSString stringWithString:@"YES"];
	else
		newStr3 = [NSString stringWithString:@"NO"];
	
	settings = [[NSMutableArray alloc] init];
	
	[settings addObject:newStr0];
	[settings addObject:newStr1];
	[settings addObject:newStr2];
	[settings addObject:newStr3];

	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	[settings writeToFile:filePath atomically:YES];
	[settings release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCellID] autorelease];
	}
		
	switch (indexPath.section) {
		case 0:
			switch(indexPath.row){
				case 0:
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.text = NSLocalizedString(@"ResolutionKey",@"");
					resControl = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects: NSLocalizedString(@"LoResKey",@""), NSLocalizedString(@"HiResKey",@""), nil]];
					resControl.frame = CGRectMake(132,8,160,30);
					[cell.contentView addSubview:resControl];
					[resControl addTarget:self action:@selector(switchedOption) forControlEvents:UIControlEventValueChanged];

					[resControl setSelectedSegmentIndex:keyRes];
					
					break;
				default:
					break;
			}
			break;
		case 1:
			switch(indexPath.row){
				case 0:
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.text = NSLocalizedString(@"ShowSampleLibraryKey",@"");
					[cell.contentView addSubview:demoSwitch];
					
					[demoSwitch addTarget:self action:@selector(switchedDemoOption) forControlEvents:UIControlEventValueChanged];
					if (keyDemo)
						[demoSwitch setOn:YES];
					else 
						[demoSwitch setOn:NO];
					
					break;
				case 1:					
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.text = NSLocalizedString(@"ClearLibraryKey",@"");
					break;
				case 2:
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.text = NSLocalizedString(@"ClearBlendsKey",@"");
					break;
				default:
					break;
			}
			break;
		case 2:
			switch(indexPath.row){
				case 0:
					cell.text = @"Facebook";
					CGRect brect = loginButton.frame;
					brect.origin.x = 200;
					brect.origin.y = 8;
					
					[loginButton setFrame:brect];
					
					[cell.contentView addSubview:loginButton];
					
					break;
				case 1:
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.text = NSLocalizedString(@"ShowTipsKey",@"");
					[cell.contentView addSubview:tipsSwitch];
					
					[tipsSwitch addTarget:self action:@selector(switchedOption) forControlEvents:UIControlEventValueChanged];
					if (keyTips)
						[tipsSwitch setOn:YES];
					else 
						[tipsSwitch setOn:NO];
					
					break;
				case 2:
					if ([[[UIDevice currentDevice] model] compare: @"iPod touch"] == NSOrderedSame) {
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
						cell.text = NSLocalizedString(@"CropZoomKey",@"");
					[cell.contentView addSubview:cropSwitch];
					
					[cropSwitch addTarget:self action:@selector(switchedOption) forControlEvents:UIControlEventValueChanged];
					if (keyCrop)
						[cropSwitch setOn:YES];
					else 
						[cropSwitch setOn:NO];
					} else {
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						cell.selectionStyle = UITableViewCellSelectionStyleBlue; 
						cell.text = NSLocalizedString(@"AboutKey",@"");
					}
					break;
				case 3:
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue; 
					cell.text = NSLocalizedString(@"AboutKey",@"");
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	
	
	return cell;
}

- (void)dealloc {
	[tipsSwitch release];
	[cropSwitch release];
	[demoSwitch release];
	[loginButton release];
    [super dealloc];
}


@end
