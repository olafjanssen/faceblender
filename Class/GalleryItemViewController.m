//
//  GalleryItemViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/24/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "GalleryItemViewController.h"


@implementation GalleryItemViewController
@synthesize imageView,imageViewLeft,imageViewRight;
@synthesize appDelegate, galleryItem;
@synthesize toolBar, actionView;
@synthesize actionSheet;
@synthesize index,firstTouch;
@synthesize zoomImage, scrollView,hideTimer,isSweeping,imageArray;
@synthesize dragPoint, hidden;
@synthesize leftButton, rightButton, renameButton;
//@synthesize navIte

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

- (BOOL)hidesBottomBarWhenPushed{
	return TRUE;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	imageView = [[UIImageView alloc] init];
	imageViewLeft = [[UIImageView alloc] init];
	imageViewRight = [[UIImageView alloc] init];
	[imageView setClipsToBounds:YES];
	[imageViewLeft setClipsToBounds:YES];
	[imageViewRight setClipsToBounds:YES];
	
	if (scrollView != nil){
		scrollView = nil;
	}
	CGRect frame = CGRectMake(0, 0, 320, 480);
	
	scrollView = [[GalleryScrollView alloc] initWithFrame:frame];
	[zoomImage setFrame:CGRectMake(0,0,320,480)];
	[scrollView addSubview:imageViewLeft];
	[scrollView addSubview:imageViewRight];
	[scrollView addSubview:imageView];
	
	scrollView.contentSize = CGSizeMake(3*340,480);
	scrollView.bounces = YES;
	scrollView.delegate = self;
	[scrollView setMaximumZoomScale:3.0];
	[scrollView setMinimumZoomScale:1];
	[scrollView setOpaque:YES];
	[scrollView setBackgroundColor:[UIColor blackColor]];
	[scrollView setMultipleTouchEnabled:YES];
	[scrollView setScrollEnabled:YES];
	[scrollView setUserInteractionEnabled:YES];
	[scrollView setCanCancelContentTouches:YES];
	[self.view addSubview:scrollView];	
	[scrollView viewDidLoad];
	[scrollView release];
	
	[imageView setAlpha:0.0f];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0f];
	[imageView setAlpha:1.0f];
	[UIView commitAnimations];
	
	[renameButton setTitle:NSLocalizedString(@"RenameKey",@"")];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	//	[[UIApplication sharedApplication] setStatusBarHidden:NO];   
	
	//	[[UIApplication 
	//- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
	self.imageView.image = nil;
	self.imageViewLeft.image = nil;
	self.imageViewRight.image = nil;
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;		
}

-(void)restart {
	
	[self viewWillDisappear:NO];
	[self viewWillAppear:YES];
	
}

-(void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationItem setTitle:@"Gallery"];
	
    toolBar.hidden = NO;
	hidden = NO;
	
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	
	hideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideNavBar) userInfo:nil repeats:NO];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	//	[[UIApplication sharedApplication] setStatusBarHidden:YES];   
	
	[self.view bringSubviewToFront:toolBar];
	
	[self setIndex:index mode:0];
}

-(void)viewDidAppear:(BOOL )animated {
	[super viewDidAppear:animated];
}

-(IBAction)doRename {
	GalleryItemRenameViewController *viewController = [[GalleryItemRenameViewController alloc] initWithNibName:@"GalleryItemRenameViewController" bundle:[NSBundle mainBundle]];
	
	[viewController setGalleryItem:galleryItem];
	[self presentViewController:viewController animated:YES completion:nil];
	[viewController release];
}

// this helps dismiss the keyboard then the "done" button is clicked
- (BOOL)textFieldShouldReturn: (UITextField *)textField
{
	[galleryItem setDescription: textField.text];
	self.title = textField.text;
	[textField resignFirstResponder];
	[textField removeFromSuperview];
	return YES;
}


-(void)setIndex:(int)i mode:(NSInteger)m {
	isSweeping = YES;
	index = i;
	appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (index<0) index = 0;
	if (index>[appDelegate.galleryDatabaseDelegate.galleryItems count]-1)
		index = (int)[appDelegate.galleryDatabaseDelegate.galleryItems count]-1;
	
	if (appDelegate.galleryDatabaseDelegate.galleryItems.count>index)
		galleryItem = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:index];
	
	[self setTitle:galleryItem.description];
	
	if(index>0){
		[leftButton setEnabled:YES];
		if (m == 1){
			imageViewLeft.image = imageView.image;
		} else {
			GalleryItem *nextItem = nil;
			if (appDelegate.galleryDatabaseDelegate.galleryItems.count>index-1)
				nextItem = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:index-1];
			if (nextItem){
				NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:nextItem.imageName];
				UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
				imageViewLeft.image = image;
				[image release];
				imageViewLeft.contentMode = UIViewContentModeScaleAspectFill;
			}
		}
    } else {
		[leftButton setEnabled:NO];
		imageViewLeft.image = nil;
	}
	
	if(index<[appDelegate.galleryDatabaseDelegate.galleryItems count]-1){
		[rightButton setEnabled:YES];
		if (m==-1){
			imageViewRight.image = imageView.image;
		} else {
			GalleryItem *nextItem = nil;
			if (appDelegate.galleryDatabaseDelegate.galleryItems.count>index+1)
				nextItem = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:index+1];
			if (nextItem){
				NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:nextItem.imageName];
				UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
				imageViewRight.image = image;
				[image release];
				imageViewRight.contentMode = UIViewContentModeScaleAspectFill;
			}
		}
	} else {
		[rightButton setEnabled:NO];
		imageViewRight.image = nil;
	}
	
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:galleryItem.imageName];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
    imageView.image = image;
	[image release];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	[imageView setFrame: CGRectFromString(@"{{340,0},{320,480}}") ];
	[imageViewLeft setFrame: CGRectFromString(@"{{0,0},{320,480}}") ];
	[imageViewRight setFrame: CGRectFromString(@"{{680,0},{320,480}}") ];
	[imageView setBackgroundColor:[UIColor blackColor]];
	[imageView setClipsToBounds:YES];
	[imageViewLeft setClipsToBounds:YES];
	[imageViewRight setClipsToBounds:YES];
	[scrollView scrollRectToVisible:CGRectMake(340,0,320,480) animated:NO];
	isSweeping = NO;
}

-(IBAction)doLeft {
	if (hideTimer){
		[hideTimer invalidate];
		hideTimer = nil;
	}
	if (!isSweeping)	[self setIndex:index-1 mode:-1];
}
-(IBAction)doRight {
	if (hideTimer){
		[hideTimer invalidate];
		hideTimer = nil;
	}
	if (!isSweeping)	[self setIndex:index+1 mode:1];
}

-(IBAction)doAction {
	if (hideTimer){
		[hideTimer invalidate];
		hideTimer = nil;
	}
	
	actionSheet = [[UIActionSheet alloc]
				   initWithTitle:nil
				   delegate:self 
				   cancelButtonTitle:NSLocalizedString(@"CancelKey",@"")
				   destructiveButtonTitle:nil
				   otherButtonTitles:@"Upload to FaceBook",NSLocalizedString(@"ExportLibraryKey",@""), NSLocalizedString(@"ExportSavedPhotosKey",@""),nil];
	//    [actionAlert setNumberOfRows:4];
    [actionSheet showInView:self.view];
    
}

-(void)doDelete {
	if (hideTimer){
		[hideTimer invalidate];
		hideTimer = nil;
	}
	
	UIImageView *cview = [[UIImageView alloc] initWithImage:imageView.image];
	[cview setFrame:CGRectMake(0,0,320,480)];
	[cview setContentMode:UIViewContentModeScaleToFill];
	[self.view addSubview:cview];
	imageView.image = nil;
	[imageView setAlpha:0.0f];
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
	[cview setAlpha:0.0];
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:4.0];
	[imageView setAlpha:1.0];
	[UIView commitAnimations];
	
	[cview release];
	
	[appDelegate.galleryDatabaseDelegate deleteImage:galleryItem];
	if (appDelegate.galleryDatabaseDelegate.galleryItems.count > 0)
		[self setIndex:index mode:0];
	else
		[self.navigationController popViewControllerAnimated:YES];
	
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
	if (hideTimer){
		[hideTimer invalidate];
		hideTimer = nil;
	}
    UIImage *savedImage;
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:galleryItem.imageName];
	
    switch (buttonIndex){
        case 0:
			[self uploadToFacebook];
			break;
		case 1:
			[self import];
            break;
        case 2:
            savedImage = [[UIImage alloc] initWithContentsOfFile:filePath];
			UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil); 			
			[savedImage release];
            break;
        default:
            break;
    }
	
}

-(void)continueUpload {
    // do nothing
}

-(void)cancelUpload {
	[activityView removeFromSuperview];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];   
	[activityView release];
	activityView = nil;
}

-(void)uploadToFacebook {
	// do nothing
}

-(void)import {
	
	//[self.faceView pickImage];
	Face *face = [[Face alloc] init];
	BOOL isOK = NO;  
	while( !isOK) { 
		[face setUniqueId: (arc4random() % 20000) + 1];
		face.name = galleryItem.description;
		face.imageName = [NSString stringWithFormat:@"img%d.png", [face uniqueId]];
		face.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:filePath]) isOK = YES;
	}
	
	[face setPoint: [galleryItem getPoint:0] at:0];
	[face setPoint: [galleryItem getPoint:1] at:1];
	[face setPoint: [galleryItem getPoint:2] at:2];
	face.traits = @"";
	
	[appDelegate.faceDatabaseDelegate saveFace:face];
    // save image to disk
	//	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:face.imageName];
	NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
    NSData *pngimage = UIImagePNGRepresentation(imageView.image);
    [pngimage writeToFile:filePath atomically:YES];
	// make icons
	[IconMaker makeIconFace:face];
	[IconMaker makeIconSmallFace:face];
	
	FaceDetailsViewController *viewController = [[FaceDetailsViewController alloc] initWithNibName:@"FaceDetailsViewController" bundle:nil];
	
	[viewController resetFace:face setName:YES];
    [viewController setIsImport:YES];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
	[face release];
}

-(void)sendEmail {
	/*	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:galleryItem.imageName];
	 //	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"FacesDatabase.sql"];
	 NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
	 NSString *encodedImage = [imageData base64Encoding];
	 [imageData release];
	 
	 NSString *eMailBody = @"<html><body><table align=\"center\" width=400><tr><td><p align=\"left\">Hi,<br><br>This image is created by mixing several images together using the iPhone Application called <b>FaceBlender</b>.<p align=\"center\"><img src=\"data:image/png;base64,";
	 eMailBody = [eMailBody stringByAppendingString:encodedImage];
	 eMailBody = [eMailBody stringByAppendingString:@"\" width=320 height=480></p><p align=\"center\"><font size =\"1\" color=\"0x999999\">Due to restrictions of the iPhone API, the image in this e-mail is base64 encoded. Some e-mail clients block such content. Our apologies for the inconvenience. Please try to view the message in another client or save the e-mail as a html file.</font></p></td></tr></table></body></html>"];
	 
	 NSString *encodedBody = [eMailBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	 
	 NSString *urlString = [NSString stringWithFormat:@"mailto:?subject=FaceBlender&body=%@", encodedBody];
	 NSURL *url = [[NSURL alloc] initWithString:urlString];
	 [[UIApplication sharedApplication] openURL:url];*/
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sv {
	//[scrollView setContentSize:CGSizeMake(321,480)];
	switch (scrollView.mode) {
		case -1:
			if (hidden) [self showNavBar]; else [self hideNavBar];
			break;
		case 1:
			[self setIndex:index-1 mode:-1];
			break;
		case 2:
			[self setIndex: index+1 mode:1];
			break;
		default:
			break;
	}
	[scrollView setMode:0];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)sv withView:(UIView *)view atScale:(CGFloat)scale {
	if (sv.subviews.count<=2) return;
	
	CGRect frame = [[[sv subviews] objectAtIndex:2] frame];
	if([scrollView zoomScale]==1){
		[self hideNavBar];
		[imageView setFrame:CGRectMake(0,frame.origin.y,frame.size.width, frame.size.height)];
		[scrollView setContentOffset:CGPointMake(imageView.center.x-160,imageView.center.y-240) animated:NO];
		[imageViewLeft setHidden:YES];
		[imageViewRight setHidden:YES];
	}
	
	[scrollView setZoomScale:scale];
	[scrollView setContentSize:CGSizeMake(frame.size.width+1, frame.size.height)];
	
	if(scale==1){
		scrollView.contentSize = CGSizeMake(3*340,480);
		[scrollView setContentOffset:CGPointMake(0,0) animated:NO];
		[imageViewLeft setHidden:NO];
		[imageViewRight setHidden:NO];
		
		[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(setCurIndex) userInfo:nil repeats:NO];
		[self showNavBar];
	}
}	

-(void)setCurIndex {
	
	[self setIndex:index mode:0];
}


-(void)hideNavBar {
	if (hideTimer){
		[hideTimer invalidate];
		hideTimer = nil;
	}
	
	hidden = TRUE;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	//	[imageView setFrame: CGRectFromString(@"{{0,0},{320,480}}") ];
	[toolBar setFrame: CGRectFromString(@"{{0,480},{320,44}}")];
	[UIView commitAnimations];
}

-(void)showNavBar {
	if (hideTimer) {
		[hideTimer invalidate];
		hideTimer = nil;
	}
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[toolBar setHidden:NO];
	[self.view bringSubviewToFront:toolBar];
	
	hidden = FALSE;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	//		[imageView setFrame: CGRectFromString(@"{{0,-44},{320,480}}") ];
	[toolBar setFrame: CGRectFromString(@"{{0,416},{320,44}}")];
	[UIView commitAnimations];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)sView{	
	if (sView.subviews.count>2)
		return [sView.subviews objectAtIndex:2]; //(The view you want to scroll)
	else return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	if (actionView) [actionView release]; actionView = nil;
	if (imageView) [imageView release]; imageView = nil;
	if (imageViewLeft) [imageViewLeft release]; imageViewLeft = nil;
	if (imageViewRight) [imageViewRight release]; imageViewRight = nil;
	appDelegate = nil;
	if (galleryItem) [galleryItem release]; galleryItem = nil;
	if (toolBar) [toolBar release]; toolBar = nil;
	if (actionView) [actionView release]; actionView = nil;
	if (actionSheet) [actionSheet release]; actionSheet = nil;
	if (zoomImage) [zoomImage release]; zoomImage = nil;
	if (scrollView) [scrollView release]; scrollView = nil;
	if (imageArray) [imageArray release]; imageArray = nil;
	if (leftButton) [leftButton release]; leftButton = nil;
	if (rightButton) [rightButton release]; rightButton = nil;
	if (renameButton) [renameButton release]; renameButton = nil;
	
    [super dealloc];
}


@end
