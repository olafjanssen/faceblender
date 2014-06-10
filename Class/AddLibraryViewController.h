//
//  AddLibraryViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "Face.h"
#import "FaceBlenderAppDelegate.h"
#import "IconMaker.h"
#import "FacebookPickerController.h"

@interface AddLibraryViewController : UIViewController <UINavigationControllerDelegate, UIApplicationDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, ABPeoplePickerNavigationControllerDelegate> {
    UIImagePickerController *imagePickerController;
	UIImagePickerController *cameraPickerController;
	FacebookPickerController *facebookPicker;

    IBOutlet UIImageView *addImageView;
    IBOutlet UIImageView *leftEyeView;
    IBOutlet UIImageView *rightEyeView;
    IBOutlet UIImageView *chinView;
	IBOutlet UIScrollView *closeView;
	UIImageView *dotView;
    UIImageView *closeImageView;
	NSInteger faceId;
	
	FaceBlenderAppDelegate *appDelegate;
	
	NSString *addressName;

    Face *face;
    UIImageView *draggedView;
	CGPoint offset;
    BOOL isNew;
	BOOL shouldCancel;
}

@property ( retain) IBOutlet UIImageView *addImageView;
@property ( retain) IBOutlet UIImageView *leftEyeView;
@property ( retain) IBOutlet UIImageView *rightEyeView;
@property ( retain) IBOutlet UIImageView *chinView;
@property ( retain) IBOutlet UIScrollView *closeView;
@property ( retain) UIImageView *dotView;
@property ( retain) UIImageView *closeImageView;
@property ( retain) Face *face;
@property ( assign) CGPoint offset;
@property (assign) NSInteger faceId;
@property (retain) UIImagePickerController *imagePickerController;
@property (retain) UIImagePickerController *cameraPickerController;
@property (retain) FacebookPickerController *facebookPicker;
@property (retain) FaceBlenderAppDelegate *appDelegate;
@property (assign) BOOL isNew;
@property (retain) UIImageView *draggedView;
@property (retain) NSString *addressName;
@property (assign) BOOL shouldCancel;

-(void)pickImage;
-(void)pickImageFromCamera;
-(void)pickImageFromAddressBook;
-(void)pickImageFromFacebook;
-(CGPoint)decodePoint:(CGPoint) p;
-(void)setImage:(UIImage *)img Face:(Face *)f;
-(void)setCloseUpPoint:(CGPoint) p;
-(UIImage *)scaleAndRotateImage: (UIImage *)image;
-(void) cancelNew;
- (void)facebookPickerDone: (FacebookPickerController *)picker image:(UIImage *)image name:(NSString *)name;


-(void)setPoints;
@end
