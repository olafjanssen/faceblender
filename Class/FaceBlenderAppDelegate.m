//
//  FaceBlenderAppDelegate.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/18/08.
//  Copyright Delft University of Technology 2008. All rights reserved.
//

#import "FaceBlenderAppDelegate.h"


@implementation FaceBlenderAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize faceDatabaseDelegate;
@synthesize galleryDatabaseDelegate;
@synthesize documentsDir;
@synthesize settings;
@synthesize pool,firstLoad;
//@synthesize imagePickerController;
@synthesize activityView, activityLabel, activityText;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    // Add the tab bar controller's current view as a subview of the window
	galleryDatabaseDelegate = [[GalleryDatabaseDelegate alloc] init];

	[window addSubview:tabBarController.view];
	if (tabBarController.viewControllers.count>2){
	[[tabBarController.viewControllers objectAtIndex:0] setTitle:NSLocalizedString(@"BlendsKey",@"")];
	[[tabBarController.viewControllers objectAtIndex:1] setTitle:NSLocalizedString(@"LibraryKey",@"")];
	[[tabBarController.viewControllers objectAtIndex:2] setTitle:NSLocalizedString(@"SettingsKey",@"")];
	}
	// DocDir
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDir = [documentPaths objectAtIndex:0];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	firstLoad = NO;
	// check if first time loaded, if so, show manual welcome page
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ticktockV1.1.000"];
	if (! [fileManager fileExistsAtPath:filePath]){
		firstLoad = YES;
		[[NSString stringWithFormat:@"Tick Tock!"] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error: NULL];
		ManualViewController *manualController = [[ManualViewController alloc] initWithNibName:@"ManualViewController" bundle:nil];
        [tabBarController presentViewController:manualController animated:YES completion:nil];
		[manualController.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
		[manualController release];
	} 
	
	// read settings or either create them if they do not exist
	settings = [NSMutableArray alloc];
	filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	
	if (! [fileManager fileExistsAtPath:filePath]){
		NSArray *defaultSetting = [NSArray arrayWithObjects: @"0.5x", @"YES", @"NO", @"YES", nil];
		[defaultSetting writeToFile:filePath atomically:YES];
	}
	
	settings = [NSMutableArray arrayWithContentsOfFile:filePath];

	// Load the Databases
	faceDatabaseDelegate = [[FaceDatabaseDelegate alloc] init];
	
//	imagePickerController = [[UIImagePickerController alloc] init];
	[NSThread detachNewThreadSelector:@selector(loadDatabases) toTarget:self withObject:nil];
	
/*	
	NSDictionary *tmpdict = [[NSDictionary alloc] initWithObjectsAndKeys:
							 [NSNumber numberWithFloat:1.1],@"version",
							 [NSString stringWithString: @"DemoFace.zip"],@"archive",
							 [NSNumber numberWithInt: 723492],@"size",
							 [NSString stringWithString:@"demolib"],@"folder",
							 [NSString stringWithString:@"DemofaceLib.sql"],@"sql",
							 nil];
	[tmpdict writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:@"test.xml"] atomically:NO];
	[tmpdict release];
 */
}

-(void) loadDatabases {
	pool = [[NSAutoreleasePool alloc] init];

	[faceDatabaseDelegate load];
//	if (faceDatabaseDelegate){
//		[faceDatabaseDelegate release];
//	}
//	faceDatabaseDelegate = [[FaceDatabaseDelegate alloc] init];
//	imagePickerController = [[UIImagePickerController alloc] init];

	[pool release];
}

-(void) reloadFacesDatabase {
	[faceDatabaseDelegate load];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

-(void)hideActivityViewer
{
	if (activityView.subviews.count>0)
		[[[activityView subviews] objectAtIndex:0] stopAnimating];
	[activityView removeFromSuperview];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];   

	activityView = nil;
}

-(void)showActivityViewer
{
	pool = [[NSAutoreleasePool alloc] init];

	[activityView release];
	activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height)];
	activityView.backgroundColor = [UIColor blackColor];
	activityView.alpha = 0.8;
	
	UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 12, window.bounds.size.height / 2 - 12, 24, 24)];
	activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									  UIViewAutoresizingFlexibleRightMargin |
									  UIViewAutoresizingFlexibleTopMargin |
									  UIViewAutoresizingFlexibleBottomMargin);
	[activityView addSubview:activityWheel];
	[activityWheel release];
	
	activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,window.bounds.size.height/2+10,320,40)];

	[activityLabel setText:activityText];
	[activityLabel setTextColor:[UIColor whiteColor]];
	
	[activityLabel setBackgroundColor:[UIColor clearColor]];
	[activityLabel setTextAlignment:NSTextAlignmentCenter];
	
	[activityView addSubview:activityLabel];
	[activityLabel release];
	
	[window addSubview: activityView];
	[activityView release];

	if (activityView.subviews.count>0)
		[[[activityView subviews] objectAtIndex:0] startAnimating];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];   
	
	[pool release];
}

- (void)dealloc {
//    [imagePickerController release];
	[faceDatabaseDelegate release];
    [galleryDatabaseDelegate release];
    [tabBarController release];
	if (documentsDir) [documentsDir release]; documentsDir=nil;
    [window release];
    [super dealloc];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"MEMORY WARNING APPLICATION");
	// release all icons
	for (Face *face in  faceDatabaseDelegate.faces){
		face.icon = nil;
		face.iconSmall = nil;
	}
	
}

@end

