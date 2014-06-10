//
//  FaceBlenderAppDelegate.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/18/08.
//  Copyright Delft University of Technology 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceDatabaseDelegate.h"
#import "GalleryDatabaseDelegate.h"
#import "ManualViewController.h"
#import "FBSessionController.h"

@interface FaceBlenderAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIImagePickerControllerDelegate> {
    BOOL firstLoad;
	UIWindow *window;
    UITabBarController *tabBarController;
    //UIImagePickerController* imagePickerController;
    FaceDatabaseDelegate *faceDatabaseDelegate;
    GalleryDatabaseDelegate *galleryDatabaseDelegate;
	FBSessionController *fbc;
	
	const NSString *documentsDir;
	NSMutableArray *settings;
	NSAutoreleasePool *pool;
	
	UIView *activityView;
	UILabel *activityLabel;
	NSString *activityText;
}

@property ( retain) IBOutlet UIWindow *window;
@property ( retain) IBOutlet UITabBarController *tabBarController;
@property ( retain) FaceDatabaseDelegate *faceDatabaseDelegate;
@property ( retain) GalleryDatabaseDelegate *galleryDatabaseDelegate;
@property (retain ) FBSessionController *fbc;
@property ( retain) const NSString *documentsDir;
@property ( retain) NSMutableArray *settings;
@property (retain) NSAutoreleasePool *pool;
@property (assign) BOOL firstLoad;
//@property (retain) UIImagePickerController *imagePickerController;

@property (retain) UIView *activityView;
@property (retain) UILabel *activityLabel;
@property (copy) NSString *activityText;

-(void) reloadFacesDatabase;
-(void)hideActivityViewer;
-(void)showActivityViewer;


@end
