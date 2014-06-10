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
@synthesize zoomImage, scrollView;

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
}

- (void)viewWillDisappear:(BOOL)animated {
	for (int c=0;c<self.view.subviews.count;c++){
		if ([[self.view.subviews objectAtIndex: c] isKindOfClass: [GalleryScrollView class]])
			[[self.view.subviews objectAtIndex: c] removeFromSuperview];
	}
		
}

-(void)viewWillAppear:(BOOL)animated {
	[imageView setFrame: CGRectFromString(@"{{0,0},{320,480}}") ];
	[imageViewLeft setFrame: CGRectFromString(@"{{-320,0},{320,480}}") ];
	[imageViewRight setFrame: CGRectFromString(@"{{320,0},{320,480}}") ];
	[imageView setClipsToBounds:YES];
	[imageViewLeft setClipsToBounds:YES];
	[imageViewRight setClipsToBounds:YES];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationItem setTitle:@"Gallery"];
	[toolBar setFrame: CGRectFromString(@"{{0,480},{320,44}}")];
    toolBar.hidden = YES;
	hidden = YES;
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];   
//	[self showNavBar];
//	[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hideNavBar) userInfo:nil repeats:NO];
}

-(IBAction)doRename {
	NSLog(@"doRename");
	UITextField *txtFld = [[UITextField alloc] initWithFrame:CGRectMake(0,215,320,30)];
	txtFld.text = galleryItem.description;
	[txtFld setKeyboardAppearance:UIKeyboardAppearanceAlert];
	[txtFld setBorderStyle:UITextBorderStyleRoundedRect];
	
	[txtFld setLeftViewMode:UITextFieldViewModeAlways];
	[self.view addSubview:txtFld];
	[txtFld becomeFirstResponder];
	[txtFld setDelegate:self];
	self.title = @"Rename";
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


-(void)setIndex:(int)i {
	index = i;
	
	if (index<0) index = 0;
	if (index>[appDelegate.galleryDatabaseDelegate.galleryItems count]-1)
		index = [appDelegate.galleryDatabaseDelegate.galleryItems count]-1; 
	
    galleryItem = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:index];
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:galleryItem.imageName];

    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	[self setTitle: galleryItem.description];
	
	if(index>0){
		GalleryItem *nextItem = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:index-1];
		NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:nextItem.imageName];
		UIImage *image = [UIImage imageWithContentsOfFile:filePath];
		imageViewLeft.image = image;
		imageViewLeft.contentMode = UIViewContentModeScaleAspectFill;
    } else imageViewLeft.image = nil;
	
	if(index<[appDelegate.galleryDatabaseDelegate.galleryItems count]-1){
		GalleryItem *nextItem = (GalleryItem *)[appDelegate.galleryDatabaseDelegate.galleryItems objectAtIndex:index+1];
		NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:nextItem.imageName];
		UIImage *image = [UIImage imageWithContentsOfFile:filePath];
		imageViewRight.image = image;
		imageViewRight.contentMode = UIViewContentModeScaleAspectFill;
	} else imageViewRight.image = nil;
	
//		[imageView setFrame: CGRectFromString(@"{{0,0},{320,480}}") ];
		[imageViewLeft setFrame: CGRectFromString(@"{{-320,0},{320,480}}") ];
		[imageViewRight setFrame: CGRectFromString(@"{{320,0},{320,480}}") ];	
}

-(void)doLeft {
	[self setIndex:index-1];
}
-(void)doRight {
	[self setIndex:index+1];
}

-(void)doAction {    
     actionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:self 
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"Email Image", @"Export to Saved Photos",nil];
//    [actionAlert setNumberOfRows:4];
    [actionSheet showInView:self.view];
    
}

-(void)doDelete {
	imageView.image = nil;
	[appDelegate.galleryDatabaseDelegate deleteImage:galleryItem];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
    UIImage *savedImage;
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:galleryItem.imageName];

    switch (buttonIndex){
       case 0:
//            [appDelegate.galleryDatabaseDelegate deleteImage:galleryItem];
//            [self.navigationController popViewControllerAnimated:YES];
			[self sendEmail];
            break;
        case 1:
            savedImage = [UIImage imageWithContentsOfFile:filePath];
            //UIImageWriteToSavedPhotosAlbum(savedImage, nil, nil, nil);
			UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil); 			
            break;
        default:
            break;
    }

}

-(void)sendEmail {
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:galleryItem.imageName];
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
	[[UIApplication sharedApplication] openURL:url];
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	NSLog([error description]);
}

// Handles the continuation of a touch.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{  
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) {
        case 1: { //Single touch
            
            //Get the first touch.
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			CGPoint centerPoint = [touch locationInView:[self view]];
			dragPoint = imageView.center;
			dragPoint.x -= centerPoint.x;
			dragPoint.y -= centerPoint.y;
        } break;
        case 2: { //Double Touch
            
            //Track the initial distance between two fingers.
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
            
            initialDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:[self view]] toPoint:[touch2 locationInView:[self view]]];
            
        } break;
        default:
            break;
    }
    
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1: {
            //The image is being panned (moved left or right)
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint touchPoint = [touch locationInView:[self view]];
		    CGPoint centerPoint;
			centerPoint.x = dragPoint.x + touchPoint.x;
		    centerPoint.y = imageView.center.y;
            [imageView setCenter:centerPoint];
			centerPoint.x -= 340;
            [imageViewLeft setCenter:centerPoint];
			centerPoint.x += 680;
            [imageViewRight setCenter:centerPoint];
            
        } break;
        case 2: {
        } break;
    }
    
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	NSLog(@"CALLED");
	if (imageView.center.x<0)
		[self setIndex: index+1];
	else
		[self setIndex:index-1];
}

-(void)hideNavBar {
	hidden = TRUE;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[imageView setFrame: CGRectFromString(@"{{0,0},{320,480}}") ];
	[toolBar setFrame: CGRectFromString(@"{{0,480},{320,44}}")];
	[UIView commitAnimations];
}

-(void)showNavBar {
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[toolBar setHidden:NO];
	hidden = FALSE;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[imageView setFrame: CGRectFromString(@"{{0,0},{320,480}}") ];
	[toolBar setFrame: CGRectFromString(@"{{0,416},{320,44}}")];
	[UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint originalPos;
	originalPos.x = 160;
	originalPos.y = imageView.center.y;
	
	if ( ((originalPos.x-imageView.center.x)<50 && index<1) || 
 		 ((originalPos.x-imageView.center.x)>-50 && index>[appDelegate.galleryDatabaseDelegate.galleryItems count]-2) ){
		// return image to original position
		[UIView beginAnimations:nil context:self];
		[UIView setAnimationDuration:0.2];
		[imageView setCenter: originalPos];
		originalPos.x -= 340;
		[imageViewLeft setCenter: originalPos];
		originalPos.x += 680;
		[imageViewRight setCenter: originalPos];
		[UIView commitAnimations];
	} else if (abs(originalPos.x-imageView.center.x)>50) {
		// swoosh image to next position
		if (originalPos.x-imageView.center.x < 0){
			originalPos.x = 500;
		} else originalPos.x = -180;
		
		[UIView beginAnimations:@"swoosh" context:self];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)]; 
		[UIView setAnimationDuration:0.2];
		[imageView setCenter: originalPos];
		originalPos.x -= 340;
		[imageViewLeft setCenter: originalPos];
		originalPos.x += 680;
		[imageViewRight setCenter: originalPos];
		[UIView commitAnimations];
	}
	
	NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) {
        case 1: { //Single touch
            //Get the first touch.
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			
            switch ([touch tapCount])
            {
                case 1: //Single Tap.
                {
                    if (hidden){
						[self showNavBar];
                    } else {
						[self hideNavBar];
                    }
                } break;
                case 2: {//Double tap.
					if (scrollView != nil){
						scrollView = nil;
					}
					if (!hidden) [self hideNavBar];
					
					CGRect frame = CGRectMake(0, 0, 320, 480);
					scrollView = [[GalleryScrollView alloc] initWithFrame:frame];
					
					// Create background
//					zoomImage = [[UIImageView alloc] initWithImage:[UIImage imageWithImage: imageView.image scaledToSize:CGSizeMake(320,480)]];
					zoomImage = [[UIImageView alloc] initWithImage:imageView.image];

					[zoomImage setFrame:CGRectMake(0,0,320,480)];
					[scrollView addSubview:zoomImage];

					scrollView.contentSize = zoomImage.image.size;
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
					scrollView.navController = self.navigationController;
					[self.view addSubview:scrollView];
					[UIView beginAnimations:@"slightZoomIn" context:self];
					//[UIView setAnimationDelegate:self];
					[UIView setAnimationDuration:0.5];
					[zoomImage setFrame:CGRectMake(-0.2*320,-0.2*480,320*1.4, 480*1.4)];
					[UIView commitAnimations];
					
					[scrollView viewDidLoad];
//					[scrollView scrollRectToVisible:CGRectMake(0,0,320,480) animated:NO];
//					[scrollView scrollRectToVisible:CGRectMake(160, 240, 160, 240) animated:YES];
					[scrollView release];
                } break;
            }
        } break;
        default:
            break;
    }
	
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	
	NSLog(@"here!!");
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)sView{	
	return [sView.subviews objectAtIndex:0]; //(The view you want to scroll)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
