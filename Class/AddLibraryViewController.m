//
//  AddLibraryViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "AddLibraryViewController.h"
#import "FaceBlenderAppDelegate.h"

@implementation AddLibraryViewController

@synthesize addImageView;
@synthesize leftEyeView;
@synthesize rightEyeView;
@synthesize chinView;
@synthesize closeView;
@synthesize closeImageView;
@synthesize face;
@synthesize dotView;
@synthesize faceId;
@synthesize offset;
@synthesize imagePickerController,cameraPickerController,facebookPicker;
@synthesize appDelegate, isNew, draggedView, addressName;
@synthesize shouldCancel;


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
    
    self.title = NSLocalizedString(@"PickPointsKey",@"");
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									target:self
									action:@selector(doneAdding)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
//	imagePickerController = appDelegate.imagePickerController;
	
	UIImage *dotImage = [UIImage imageNamed:@"unselected.png"];
	dotView = [[UIImageView alloc] initWithImage:dotImage];
	
	[dotView setFrame:CGRectMake(40,40,20,20)];
	[dotView setHidden:YES];
	[dotView setAlpha:0.5];
	[self.view addSubview:dotView];
	
	[self.navigationItem.leftBarButtonItem setAction:@selector(cancelButton)]; 
	shouldCancel = NO;
}

-(void)dealloc {
	addImageView.image = nil; addImageView=nil;
	leftEyeView=nil;
	rightEyeView=nil;
	chinView=nil;
    closeView=nil;
	closeImageView.image = nil; closeImageView=nil;
//	if (face) [face release]; face=nil;
	dotView=nil;
	faceId=-1;
	if (imagePickerController) [imagePickerController release];
	imagePickerController=nil;
	if (cameraPickerController) [cameraPickerController release];
	cameraPickerController=nil;
	appDelegate=nil;
	if (draggedView) [draggedView release]; draggedView=nil;
	if (facebookPicker) [facebookPicker release]; facebookPicker = nil;

	[super dealloc];
}

-(void)doneAdding {    
	
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	if ([face.name compare:@"Invalid New Face"]==NSOrderedSame){
		faceId = face.uniqueId;
			face.name = NSLocalizedString(@"NewFaceKey",@"");
	}
	
    // get correct point values
    CGPoint leftLoco =leftEyeView.center;
    CGPoint rightLoco = rightEyeView.center;
    CGPoint chinLoco = chinView.center;
	
	CGSize imgSize = self.addImageView.image.size;
	CGSize frmSize = self.addImageView.frame.size;
	CGPoint p0,p1,p2;
	if (imgSize.height/imgSize.width > frmSize.height/frmSize.width){
		//	if (imgSize.height/imgSize.height > 1.5){
		float W = frmSize.width;
		float w = imgSize.width / imgSize.height * frmSize.height;
		p0 = CGPointMake( (leftLoco.x - (W-w)/2 ) /w, leftLoco.y/frmSize.height ); 
		p1 = CGPointMake( (rightLoco.x - (W-w)/2 )/w, rightLoco.y/frmSize.height ); 
		p2 = CGPointMake( (chinLoco.x - (W-w)/2 ) /w, chinLoco.y/frmSize.height ); 
    } else {
		float H = frmSize.height;
		float h = imgSize.height / imgSize.width * frmSize.width;
		p0 = CGPointMake( leftLoco.x/frmSize.width, (leftLoco.y - (H-h)/2 ) /h ); 
		p1 = CGPointMake( rightLoco.x/frmSize.width, (rightLoco.y - (H-h)/2 ) /h ); 
		p2 = CGPointMake( chinLoco.x/frmSize.width, (chinLoco.y - (H-h)/2 ) /h );
	}
    [face setPoint:p0 at:0];
    [face setPoint:p1 at:1];
    [face setPoint:p2 at:2];
    
    if (isNew){
        isNew = NO;
		appDelegate.activityText = NSLocalizedString(@"SavingFaceKey",@"");
	
		[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];
		NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:face.imageName];
		NSData *pngimage = UIImagePNGRepresentation(addImageView.image);
		[pngimage writeToFile:filePath atomically:YES];
		[IconMaker makeIconSmallFace:face];
		[IconMaker makeIconFace:face];
		[appDelegate.faceDatabaseDelegate saveFace:face];
		[face release];
		[appDelegate.faceDatabaseDelegate.faces sortUsingSelector:@selector(compare:)];

		[appDelegate hideActivityViewer];
    }
    else
		[appDelegate.faceDatabaseDelegate updateFace:face];
    
	[tmpPool release];
	
    [self.navigationController popViewControllerAnimated:YES];
}

// Handles the continuation of a touch.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{  
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint position = [touch locationInView:self.view];
	// Check to see which view, or views,  the point is in and then move to that position.
	if (CGRectContainsPoint([leftEyeView frame], position)) {
        draggedView = leftEyeView;
		offset = CGPointMake( draggedView.center.x - position.x, draggedView.center.y - position.y);
		[closeView setHidden:NO];
		[self setCloseUpPoint:draggedView.center];
		[dotView setHidden:NO];
	} 
	if (CGRectContainsPoint([rightEyeView frame], position)) {
        draggedView = rightEyeView;
		offset = CGPointMake( draggedView.center.x - position.x, draggedView.center.y - position.y);
		[closeView setHidden:NO];
		[self setCloseUpPoint:draggedView.center];
		[dotView setHidden:NO];
	} 
	if (CGRectContainsPoint([chinView frame], position)) {
        draggedView = chinView;
		offset = CGPointMake( draggedView.center.x - position.x, draggedView.center.y - position.y);
		[closeView setHidden:NO];
		[self setCloseUpPoint:draggedView.center];
		[dotView setHidden:NO];
	}
	//[self setCloseUpPoint:draggedView.center];
	if (position.x < 160) {
		[closeView setFrame:CGRectMake(220,0,100,100)];
		[dotView setFrame:CGRectMake(260,40,20,20)];
	} else {
		[closeView setFrame:CGRectMake(0,0,100,100)];
		[dotView setFrame:CGRectMake(40,40,20,20)];
	}
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint position = [touch locationInView:self.view];
    
    if (draggedView!=nil){
		leftEyeView.transform = CGAffineTransformMakeRotation( atan2((rightEyeView.center.y-leftEyeView.center.y),(rightEyeView.center.x-leftEyeView.center.x)) );
		rightEyeView.transform = CGAffineTransformMakeRotation( 3.1415926535 + atan2((leftEyeView.center.y-rightEyeView.center.y),(leftEyeView.center.x-rightEyeView.center.x)) );
		chinView.transform = CGAffineTransformMakeRotation( 3.1415926535/2 + atan2(((leftEyeView.center.y+rightEyeView.center.y)/2-chinView.center.y),((leftEyeView.center.x+rightEyeView.center.x)/2-chinView.center.x)) );

        draggedView.center = CGPointMake(offset.x + position.x, offset.y + position.y);
		[self setCloseUpPoint:draggedView.center];
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{  
    if (draggedView!=nil){
		leftEyeView.transform = CGAffineTransformMakeRotation( atan2((rightEyeView.center.y-leftEyeView.center.y),(rightEyeView.center.x-leftEyeView.center.x)) );
		rightEyeView.transform = CGAffineTransformMakeRotation( 3.1415926535 + atan2((leftEyeView.center.y-rightEyeView.center.y),(leftEyeView.center.x-rightEyeView.center.x)) );
		chinView.transform = CGAffineTransformMakeRotation( 3.1415926535/2 + atan2(((leftEyeView.center.y+rightEyeView.center.y)/2-chinView.center.y),((leftEyeView.center.x+rightEyeView.center.x)/2-chinView.center.x)) );

        draggedView=nil;
		[closeView setHidden:YES];
		[dotView setHidden:YES];
	}
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    shouldCancel = NO;

	appDelegate.activityText = NSLocalizedString(@"CancelKey",@"");
	[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];

	// assigning control back to the main controller
	[self dismissModalViewControllerAnimated:YES];
	faceId = -1;
	[self.navigationController popViewControllerAnimated:YES];	
}


- (void)facebookPickerDone: (FacebookPickerController *)picker image:(UIImage *)image name:(NSString *)name {
	//add new face information
	if (face==nil){
		isNew = YES;
        face = [[Face alloc] init];
		faceId = -1;
		
		BOOL isOK = NO;  
		while( !isOK) { 
			[face setUniqueId: (arc4random() % 20000) + 1];
			face.name = @"Invalid New Face";
			face.imageName = [NSString stringWithFormat:@"img%d.png", [face uniqueId]];
			face.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
			NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			if (![fileManager fileExistsAtPath:filePath]) isOK = YES;
		}
		
		addressName = [[NSString alloc] initWithString: name];
		
        [face setPoint:CGPointMake(0.3,0.5) at:0];
        [face setPoint:CGPointMake(0.7,0.5) at:1];
        [face setPoint:CGPointMake(0.5,0.8) at:2];
        face.traits = @"";
		
		addImageView.image = image;
    }
    
    [self setPoints];	
		
	[self setImage: addImageView.image Face:face];
	[facebookPicker.view removeFromSuperview];
	[facebookPicker release];
	facebookPicker = nil;
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								   target:self
								   action:@selector(doneAdding)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	self.title = NSLocalizedString(@"PickPointsKey",@"");
}


- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    shouldCancel = NO;
	[self dismissModalViewControllerAnimated:YES];

	// get image
	CFDataRef dataRef = ABPersonCopyImageData(person);
	addImageView.image = nil;
	if (dataRef){
		UIImage *image = [UIImage imageWithData:(NSData *)dataRef];
		image = [self scaleAndRotateImage:image];
		addImageView.image = image;
		[image release];
		CFRelease(dataRef);
	}
	
	if (addImageView.image == nil){
		[self dismissModalViewControllerAnimated:YES];
		faceId = -1;
		[self.navigationController popViewControllerAnimated:YES];	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoPhotoKey",@"")
												  message:NSLocalizedString(@"ContactNoPhotoKey",@"")
												  delegate:self 
											      cancelButtonTitle:nil 
											      otherButtonTitles:NSLocalizedString(@"OkKey",@""),nil];
		[alert show];
		[alert release];
	}
	
    //add new face information
    if (face==nil){
        face = [[Face alloc] init];
		faceId = -1;
		
		BOOL isOK = NO;  
		while( !isOK) { 
			[face setUniqueId: (arc4random() % 20000) + 1];
			face.name = @"Invalid New Face";
			face.imageName = [NSString stringWithFormat:@"img%d.png", [face uniqueId]];
			face.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
			NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
			//NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:face.imageName];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			if (![fileManager fileExistsAtPath:filePath]) isOK = YES;
		}
		
		CFTypeRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
		CFTypeRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
		
		if (firstName && lastName)
			addressName = [[NSString alloc] initWithFormat: @"%@ %@", firstName, lastName];
		else if (firstName && !lastName)
			addressName = [[NSString alloc] initWithFormat: @"%@", firstName];
		else if (!firstName && lastName)
			addressName = [[NSString alloc] initWithFormat: @"%@", lastName];
		else 
			addressName = [[NSString alloc] initWithFormat: @""];
			
		
		if (firstName) CFRelease(firstName);
		if (lastName) CFRelease(lastName);
		
        [face setPoint:CGPointMake(0.3,0.5) at:0];
        [face setPoint:CGPointMake(0.7,0.5) at:1];
        [face setPoint:CGPointMake(0.5,0.8) at:2];
        face.traits = @"";
		
    }
    
    [self setPoints];	
/*	
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	NSMutableArray *settings = [[NSArray alloc] initWithContentsOfFile:filePath];
	
	if (settings.count>3)
	if ( ([[settings objectAtIndex:3] compare:@"YES"] == NSOrderedSame) || ([[[UIDevice currentDevice] model] compare: @"iPod touch"] != NSOrderedSame))
		[imagePickerController.view setHidden:YES];
	
	[settings release];
*/
	
	[self setImage: addImageView.image Face:face];
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (void)pickImageFromFacebook {
	shouldCancel = YES;
	// release all icons
	for (Face *facet in  appDelegate.faceDatabaseDelegate.faces){
		facet.icon = nil;
		facet.iconSmall = nil;
	}
	
	if (facebookPicker){ [facebookPicker release]; facebookPicker=nil;}
	facebookPicker = [[FacebookPickerController alloc] initWithNibName:@"FacebookPickerController" bundle:[NSBundle mainBundle]];
	facebookPicker.delegate = self;
	[self.view addSubview:facebookPicker.view];

//    [navBar.topItem setTitle:[NSString stringWithFormat: NSLocalizedString(@"Facebook Friends",@""),0]];
	self.title = @"Pick Friend"; //needlocal;
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									 target:self
									 action:@selector(cancelNew)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = nil;
	[cancelButton release];
	
}
- (void)pickImageFromAddressBook {
	shouldCancel = YES;
	// release all icons
	for (Face *facet in  appDelegate.faceDatabaseDelegate.faces){
		facet.icon = nil;
		facet.iconSmall = nil;
	}
	
    isNew = YES;
	face = nil;
			// creating the picker
		ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
		// place the delegate of the picker to the controll
		picker.peoplePickerDelegate = self;
		
		// showing the picker
		[self presentModalViewController:picker animated:YES];
		// releasing
		[picker release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									 target:self
									 action:@selector(cancelNew)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
}

- (void)pickImage {
	shouldCancel = YES;
	// release all icons
	for (Face *facet in  appDelegate.faceDatabaseDelegate.faces){
		facet.icon = nil;
		facet.iconSmall = nil;
	}
	for (GalleryItem *item in  appDelegate.galleryDatabaseDelegate.galleryItems){
		item.icon = nil;
	}
	
	if (!imagePickerController) imagePickerController = [[UIImagePickerController alloc] init];

    isNew = YES;
	face = nil;
    imagePickerController.delegate = self;
	
	 NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	 NSMutableArray *settings = [NSArray arrayWithContentsOfFile:filePath];
	 
	if (settings.count>3)
	 if ([[settings objectAtIndex:3] compare:@"YES"] == NSOrderedSame)
	 imagePickerController.allowsImageEditing = YES;
	 else
	 imagePickerController.allowsImageEditing = NO;
	 
	 // force iPhones to the editing mode
	 if ([[[UIDevice currentDevice] model] compare: @"iPod touch"] != NSOrderedSame) imagePickerController.allowsImageEditing = YES;
	 
	 imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	 [imagePickerController.view setHidden:NO];
	 [appDelegate.window addSubview:imagePickerController.view];
		
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									target:self
								   action:@selector(cancelNew)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
}


- (IBAction)pickImageFromCamera {
	shouldCancel = YES;
	// release all icons
	for (Face *facet in  appDelegate.faceDatabaseDelegate.faces){
		facet.icon = nil;
		facet.iconSmall = nil;
	}
	
	if (cameraPickerController){
		[cameraPickerController release];
		cameraPickerController = nil;
	}
	if (!cameraPickerController) cameraPickerController =  [[UIImagePickerController alloc] init];
	
    isNew = YES;
	face = nil;
    cameraPickerController.delegate = self;
	// force iPhones to the editing mode
	cameraPickerController.allowsImageEditing = YES;
	
    cameraPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[cameraPickerController.view setHidden:NO];
    [appDelegate.window addSubview:cameraPickerController.view];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									 target:self
									 action:@selector(cancelNew)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
}

-(void)setImage:(UIImage *)img Face:(Face *)f{
	addImageView.image = img;
	face = f;
	float zoom = 2.0;

	closeImageView = [[UIImageView alloc] initWithImage:img];
	[closeImageView setFrame:CGRectMake(0,0,zoom*addImageView.frame.size.width,zoom*addImageView.frame.size.height)];
	[closeImageView setContentMode:UIViewContentModeScaleAspectFit];
	[closeView addSubview:closeImageView];
	
	[closeView setFrame:CGRectMake(0,0,100,100)];
	
	closeView.delegate = self;	
	[closeView setContentOffset:CGPointMake(0,0)];
	closeView.contentSize = closeImageView.frame.size;
	[closeView setHidden:YES];
	
	[closeImageView release]; closeImageView = nil;
}

-(CGPoint)decodePoint:(CGPoint) p {
	CGPoint p2;
	CGSize imgSize = self.addImageView.image.size;
	CGSize frmSize = self.addImageView.frame.size;
	
	if (imgSize.width>imgSize.height){
		p2.x = p.x;// * frmSize.width / imgSize.width;
		p2.y = (p.y - (frmSize.height-imgSize.height*frmSize.width/imgSize.width)/2) /(imgSize.height*frmSize.width/imgSize.width) *frmSize.height;
	} else {
		p2.y = p.y;
		p2.x = (p.x - (frmSize.width-imgSize.width*frmSize.height/imgSize.height)/2) /(imgSize.width*frmSize.height/imgSize.height) *frmSize.width;
	}
	return p2;
}

-(void)setCloseUpPoint:(CGPoint) p {
	float zoom = 2.0;
	CGRect rect = CGRectMake(zoom*p.x-50,zoom*p.y-50,100,100);
	//[closeView scrollRectToVisible:CGRectMake(0,0,320,480) animated:NO];
	[closeView scrollRectToVisible:rect animated:NO];
	
}

-(void)viewWillDisappear:(BOOL)animated {	
}

-(void)cancelButton {
		if (isNew){
			if (face) [face release];
		}
}

-(void)viewWillAppear:(BOOL)animated {	
	[self setPoints];
    [super viewWillAppear:animated];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	shouldCancel = NO;

	image = [self scaleAndRotateImage:image];

    addImageView.image = image;
    
    //add new face information
    if (face==nil){
        face = [[Face alloc] init];
		faceId = -1;
		
		//        arc4random_stir();
		BOOL isOK = NO;  
		while( !isOK) { 
			[face setUniqueId: (arc4random() % 20000) + 1];
			face.name = @"Invalid New Face";
			face.imageName = [NSString stringWithFormat:@"img%d.png", [face uniqueId]];
			face.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
			NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			if (![fileManager fileExistsAtPath:filePath]) isOK = YES;
		}
		
        [face setPoint:CGPointMake(0.3,0.5) at:0];
        [face setPoint:CGPointMake(0.7,0.5) at:1];
        [face setPoint:CGPointMake(0.5,0.8) at:2];
        face.traits = @"";
		
    }
    
    [self setPoints];	
	[picker dismissModalViewControllerAnimated:YES];
	[picker.view setHidden:YES];
	
	[self setImage: image Face:face];
}

-(void)cancelNew {
	appDelegate.activityText = NSLocalizedString(@"CancelKey",@"");
	[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];

	faceId = -1;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	shouldCancel = NO;

    // Dismiss the image selection and close the program
    [picker dismissModalViewControllerAnimated:YES];
	[picker.view setHidden:YES];

	appDelegate.activityText = NSLocalizedString(@"CancelKey",@"");
	[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];

	faceId = -1;
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)setPoints {
    CGPoint leftLoc = [face getPoint:0];
    CGPoint rightLoc = [face getPoint:1];
    CGPoint chinLoc = [face getPoint:2];
    
	CGSize imgSize = self.addImageView.image.size;
	CGSize frmSize = self.addImageView.frame.size;
	if (imgSize.height/imgSize.width > frmSize.height/frmSize.width){
		float W = frmSize.width;
		float w = imgSize.width / imgSize.height * frmSize.height;
		leftLoc.x =  leftLoc.x * w + (W-w)/2;
		leftLoc.y *= frmSize.height;
		rightLoc.x =  rightLoc.x * w + (W-w)/2; 
		rightLoc.y *= frmSize.height;
		chinLoc.x =  chinLoc.x * w + (W-w)/2; 		
		chinLoc.y *= frmSize.height;
    } else {
		float H = frmSize.height;
		float h = imgSize.height / imgSize.width * frmSize.width;
		leftLoc.x *= frmSize.width;
		leftLoc.y =  leftLoc.y * h + (H-h)/2;
		rightLoc.x *= frmSize.width;
		rightLoc.y =  rightLoc.y * h + (H-h)/2; 
		chinLoc.x *= frmSize.width;
		chinLoc.y =  chinLoc.y * h + (H-h)/2; 
		
	}
	
    leftEyeView.center = leftLoc;
    rightEyeView.center = rightLoc;
    chinView.center = chinLoc;
	
	leftEyeView.transform = CGAffineTransformMakeRotation( atan2((rightEyeView.center.y-leftEyeView.center.y),(rightEyeView.center.x-leftEyeView.center.x)) );
	rightEyeView.transform = CGAffineTransformMakeRotation( 3.1415926535 + atan2((leftEyeView.center.y-rightEyeView.center.y),(leftEyeView.center.x-rightEyeView.center.x)) );
	chinView.transform = CGAffineTransformMakeRotation( 3.1415926535/2 + atan2(((leftEyeView.center.y+rightEyeView.center.y)/2-chinView.center.y),((leftEyeView.center.x+rightEyeView.center.x)/2-chinView.center.x)) );
	
}

-(UIImage *)scaleAndRotateImage: (UIImage *)image
{
	int kMaxResolution = 640; // Or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	if (cameraPickerController){ [cameraPickerController release]; cameraPickerController = nil; }
	if (imagePickerController){ [imagePickerController release]; imagePickerController = nil; }
    // Release anything that's not essential, such as cached data
}


@end
