//
//  FaceDetailsViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "FaceDetailsViewController.h"
#import "FaceBlenderAppDelegate.h"

@implementation FaceDetailsViewController

@synthesize imageView, imageViewBorder, textField, pickPointsView, face, pickTraitsView;
@synthesize appDelegate;
@synthesize headerView,tableView, tableArray;
@synthesize textLabel, imageButton, suggestion, isImport, traitsLst,blackView;

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(saveDetails)];
	self.navigationItem.rightBarButtonItem = saveButton;  
    [saveButton release];
	
    // set up the table's header view based on our UIView 'myHeaderView' outlet
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.headerView.frame.size.height);
	self.headerView.backgroundColor = [UIColor clearColor];
	self.headerView.frame = newFrame;
	self.tableView.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    textField.delegate = self;
    [textField setFont:[UIFont systemFontOfSize:14]];
	[textField setClearButtonMode:UITextFieldViewModeWhileEditing]; 	          
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
}

//–(void) textFieldDidBeginEditing {
-(void)viewWillDisappear:(BOOL)animated {	
	if (blackView) {
		[blackView removeFromSuperview];
		[blackView release];
	}
	blackView = nil;
	
	[super viewWillDisappear:animated];
}


-(void)viewWillAppear:(BOOL)animated {
	if ( pickPointsView ){
		//if (pickPointsView.face)
			if (pickPointsView.faceId == -1) {
				imageView.image = nil;
				[textField setText:@""];
				[textLabel setText:@""];
								
				blackView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,480)];
				[blackView setBackgroundColor:[UIColor blackColor]];
				[self.view addSubview:blackView];
				
				[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
			} else {
				// get new face object that is retained
				for ( Face *f in appDelegate.faceDatabaseDelegate.faces){
					if (f.uniqueId == pickPointsView.faceId) face = f;
				}
				
				if ([face.name compare:NSLocalizedString(@"NewFaceKey",@"")]==NSOrderedSame) {
					if ([pickPointsView addressName] != nil){
						face.name = pickPointsView.addressName;
					}
					[self resetFace:face setName:YES];
				} else
					[self resetFace:face setName:NO];

		}

		if (pickPointsView.addressName != nil) [pickPointsView.addressName release];

		[pickPointsView release];
		pickPointsView = nil;
	} else if (pickTraitsView){
		[pickTraitsView release];
		pickTraitsView = nil;
		[self resetFace:face setName:NO];

	} else if (face) [self resetFace:face setName:YES]; 
	
	if ([face.name compare:NSLocalizedString(@"NewFaceKey",@"")]==NSOrderedSame)
		[textField setClearsOnBeginEditing:YES];
	else
		[textField setClearsOnBeginEditing:NO];
	
	
	// if face is just imported we give the option of deleting the face again
	if (isImport){
		isImport = NO;
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									   target:self
									   action:@selector(saveDetails)];
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									   target:self
									   action:@selector(cancelImport)];
		self.navigationItem.rightBarButtonItem = saveButton;  
		self.navigationItem.leftBarButtonItem = cancelButton;  
		[saveButton release];
		[cancelButton release];
	}
	
	
	[super viewWillAppear:YES];

}

-(void)dismiss {
	[self.navigationController popViewControllerAnimated:NO];
	[appDelegate hideActivityViewer];
}

-(void) textFieldChanged {
	//[face setName: textField.text];
	[textLabel setText:textField.text];
}

-(void)pickImage {
	if(!self.pickPointsView){
        AddLibraryViewController *viewController = [[AddLibraryViewController alloc] initWithNibName:@"AddLibraryViewController" bundle:[NSBundle mainBundle]];
        self.pickPointsView = viewController;
        [viewController release];
    }
    [self.navigationController pushViewController:self.pickPointsView animated:YES];
	[self.pickPointsView pickImage];
}

-(void)pickImageFromFacebook {
	if(!self.pickPointsView){
        AddLibraryViewController *viewController = [[AddLibraryViewController alloc] initWithNibName:@"AddLibraryViewController" bundle:[NSBundle mainBundle]];
        self.pickPointsView = viewController;
        [viewController release];
    }
    [self.navigationController pushViewController:self.pickPointsView animated:YES];
	[self.pickPointsView pickImageFromFacebook];
}

-(void)pickImageFromAddressBook {
	if(!self.pickPointsView){
        AddLibraryViewController *viewController = [[AddLibraryViewController alloc] initWithNibName:@"AddLibraryViewController" bundle:[NSBundle mainBundle]];
        self.pickPointsView = viewController;
        [viewController release];
    }
    [self.navigationController pushViewController:self.pickPointsView animated:YES];
	[self.pickPointsView pickImageFromAddressBook];
}

-(void)pickImageFromCamera {
    if(!self.pickPointsView){
        AddLibraryViewController *viewController = [[AddLibraryViewController alloc] initWithNibName:@"AddLibraryViewController" bundle:[NSBundle mainBundle]];
        self.pickPointsView = viewController;
        [viewController release];
    }
    
    [self.navigationController pushViewController:self.pickPointsView animated:YES];    
	[self.pickPointsView pickImageFromCamera];
}

-(void)saveDetails {
    // get the data
    [face setName:textField.text];
	[face setTraits:traitsLst];
	if(traitsLst) [traitsLst release];
	traitsLst = nil;
	
    [appDelegate.faceDatabaseDelegate updateFace:face];
        
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)cancelImport {
    // get the data
    [appDelegate.faceDatabaseDelegate deleteFace: face];
	
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)resetFace:(Face *)f setName:(BOOL )isName {
	//isImport = NO;
    face = f;
    if (isName) {
		[textField setText: face.name];
		[textLabel setText: face.name];
	}
	
	NSString *filepath = [face.path stringByAppendingPathComponent:face.imageName];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:filepath];
    imageView.image = img;
	[img release];
	[imageView setContentMode:UIViewContentModeScaleAspectFill];
	[imageView setClipsToBounds:YES];
	
	[imageButton setImage:img forState:UIControlStateNormal];
	[imageButton setContentMode:UIViewContentModeScaleAspectFill];
	[imageButton setClipsToBounds:YES];
	
	//if(traitsLst) [traitsLst release];
	traitsLst = [[NSString alloc] initWithString: face.traits];

	[self fillTraitTable];
}

-(void)fillTraitTable {
	if (tableArray){
		[tableArray release];
		tableArray = nil;
	}
    tableArray = [[NSMutableArray alloc] init];
    
    for(Trait *trait in appDelegate.faceDatabaseDelegate.traits){
        if (trait.description)
		if ([traitsLst rangeOfString:trait.description].location!=NSNotFound)
            if ([[trait.description substringToIndex:1] compare:@"@"]==NSOrderedSame){
				[tableArray addObject:[trait.description substringFromIndex:1]];	
			} else
				[tableArray addObject:NSLocalizedString(trait.description,@"")];
    }
    
    if([tableArray count] == 0) [tableArray addObject:NSLocalizedString(@"NoneKey",@"")];
    
    [self.tableView reloadData];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
	[self.textField resignFirstResponder];
	[self textFieldChanged];

	if ([self.textField.text compare:NSLocalizedString(@"NewFaceKey",@"")]==NSOrderedSame)
		[self.textField setClearsOnBeginEditing:YES];
	else
		[self.textField setClearsOnBeginEditing:NO];

	[suggestion removeFromSuperview];

   return YES;
}

-(void)doSuggestion {
	[textField resignFirstResponder];
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){
		if ([f.name compare:suggestion.currentTitle] == NSOrderedSame){
			
			NSMutableString *cpyString = [NSMutableString stringWithString:f.traits];
			cpyString = [NSMutableString stringWithString: [cpyString stringByReplacingOccurrencesOfString:@", Eyes Closed" withString:@""] ];
			cpyString = [NSMutableString stringWithString: [cpyString stringByReplacingOccurrencesOfString:@"Eyes Closed" withString:@""] ];
			cpyString = [NSMutableString stringWithString: [cpyString stringByReplacingOccurrencesOfString:@", Mouth Open" withString:@""] ];
			cpyString = [NSMutableString stringWithString: [cpyString stringByReplacingOccurrencesOfString:@"Mouth Open" withString:@""] ];
			
			if(traitsLst) [traitsLst release];
			traitsLst = [[NSString alloc] initWithString: cpyString];
			
			break;
		}
	}
//	face.name = suggestion.currentTitle;
//	[self resetFace:face setName:YES];
	[textField setText:suggestion.currentTitle];
	[textLabel setText:suggestion.currentTitle];
	[self fillTraitTable];
	[suggestion removeFromSuperview];
}

-(void)textFieldDidBeginEditing: (UITextField *)tField{
//	suggestion = [[UIButton alloc] initWithFrame:CGRectMake(textField.frame.origin.x,textField.frame.origin.y+40,textField.frame.size.width,textField.frame.size.height)];
	suggestion = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	suggestion.frame = CGRectMake(textField.frame.origin.x,textField.frame.origin.y+40,textField.frame.size.width,textField.frame.size.height);
	[suggestion addTarget:self action:@selector(doSuggestion) forControlEvents:UIControlEventTouchDown];

	[suggestion setHidden:YES];
	[self.view addSubview:suggestion];
}

- (BOOL)textField:(UITextField *)tField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSMutableString *newString = [NSMutableString stringWithString: tField.text];
	NSString *newestString = [newString stringByReplacingCharactersInRange:range withString:string];
	
	// check if we can find a suggestion
	BOOL notFound = YES;
	// first check by exact match
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){
		if (f.name.length < newestString.length) continue;
		if ([[f.name substringToIndex:newestString.length] compare:newestString] == NSOrderedSame){
			[suggestion setTitle:f.name forState:UIControlStateNormal];
			notFound = NO;
			float len = f.name.length;
			float width = 20.0+len*12.0	; if (width> tField.frame.size.width) width = tField.frame.size.width;
			[suggestion setFrame:CGRectMake(suggestion.frame.origin.x+(suggestion.frame.size.width-width)/2,suggestion.frame.origin.y, width, suggestion.frame.size.height)];
			break;
		}
	}
	// then check on substring occurance
	if (notFound)
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){ 
		if ([f.name rangeOfString:newestString].location!=NSNotFound) {
			[suggestion setTitle:f.name forState:UIControlStateNormal];
			notFound = NO;
			float len = f.name.length;
			float width = 20.0+len*12.0	; if (width> tField.frame.size.width) width = tField.frame.size.width;
			[suggestion setFrame:CGRectMake(suggestion.frame.origin.x+(suggestion.frame.size.width-width)/2,suggestion.frame.origin.y, width, suggestion.frame.size.height)];
			break;
		}
	}
	if ([newestString compare:@""]==NSOrderedSame) notFound = YES;
	if (notFound) [suggestion setHidden:YES]; else [suggestion setHidden:NO];
	return YES;
}


-(IBAction)pickPoints {
//	if(self.pickPointsView) pickPointsView = nil;
	
    if(self.pickPointsView == nil){
        AddLibraryViewController *viewController = [[AddLibraryViewController alloc] initWithNibName:@"AddLibraryViewController" bundle:[NSBundle mainBundle]];
        self.pickPointsView = viewController;
        [viewController release];
    }
    
	//	self.pickPointsView.closeView.image = self.imageView.image;

    [self.navigationController pushViewController:self.pickPointsView animated:YES];
    [pickPointsView setImage: imageView.image Face:face];
    [self.pickPointsView setPoints];
	
   
}

-(IBAction)pickTraits {
//	if(self.pickTraitsView) pickTraitsView = nil;
    if(self.pickTraitsView == nil){
        TraitsViewController *viewController = [[TraitsViewController alloc] initWithNibName:@"TraitsViewController" bundle:[NSBundle mainBundle]];
        self.pickTraitsView = viewController;
		[viewController release];
    }
        
    [self.navigationController pushViewController:self.pickTraitsView animated:YES];
	[self.pickTraitsView setTraits:[NSString stringWithString: traitsLst]];
    [self.pickTraitsView setFace:face];
	
	self.pickTraitsView.imageView.image =  imageView.image;
	self.pickTraitsView.textLabel.text = textLabel.text;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"TraitsKey",@"");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [tableArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self pickTraits];
	[self.tableView deselectRowAtIndexPath:indexPath	animated:YES];
}

#define kCellID @"cellID"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCellID] autorelease];
	}
	
	if(indexPath.row == 0)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (tableArray.count>indexPath.row)
		cell.text = [tableArray objectAtIndex:[indexPath row]];
	
	return cell;
}

@synthesize imageView, imageViewBorder, textField, pickPointsView, face, pickTraitsView;
@synthesize appDelegate;
@synthesize headerView,tableView, tableArray;
@synthesize textLabel, imageButton, suggestion, isImport, traitsLst,blackView;


- (void)dealloc {
	imageView.image = nil;
	imageView = nil;
   
	if (pickPointsView) [pickPointsView release]; pickPointsView = nil;
    if (pickTraitsView) pickTraitsView =nil;
    //if (face) [face release]; face=nil;
	//face = nil;
	appDelegate=nil;
	headerView=nil;
    tableView=nil;

	if(traitsLst) [traitsLst release]; traitsLst=nil;
	
	[textField setText:nil];
	[textLabel setText:nil];
	
    if (tableArray) [tableArray release]; tableArray=nil;
	imageButton=nil;
	
	//if(blackView) [blackView release]; blackView = nil;
	
    [super dealloc];
}
/*
-(void)release {
	[super release];
}

/*
-(id)alloc {
	return [super alloc];
}
*/

@end
