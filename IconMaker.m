//
//  IconMaker.m
//  FaceBlender
//
//  Created by Olaf Janssen on 3/5/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "IconMaker.h"


@implementation IconMaker

+(void)makeIconItem:(GalleryItem *)galleryItem {
	NSString *base = @"tmb_";
	NSString *tmbName = [base stringByAppendingString:galleryItem.imageName];
	NSString *tmbpath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:tmbName];	
NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:galleryItem.imageName];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:tmbpath]) return;

//	[icon release];*/
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:filepath];
	float netsize = 100;
	CGSize oldsz = image.size;
	CGSize newSize;
	if (oldsz.width>oldsz.height)
		newSize = CGSizeMake(netsize, oldsz.height/oldsz.width * netsize);
	else
		newSize = CGSizeMake(oldsz.width/oldsz.height * netsize, netsize);
	
	// resize snippet
	UIGraphicsBeginImageContext( newSize );
	//apply scale to fit procedure
	CGSize orig = [image size];
	if (orig.width > orig.height){
		[image drawInRect:CGRectMake((newSize.width-newSize.height*orig.width/orig.height)/2,0,newSize.height*orig.width/orig.height,newSize.height)];		
	} else {
		[image drawInRect:CGRectMake(0,(newSize.height-newSize.width*orig.height/orig.width)/2,newSize.width,newSize.width*orig.height/orig.width)];
	}
	UIImage *icon = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSData *pngimage = UIImagePNGRepresentation(icon);
	[pngimage writeToFile:tmbpath atomically:YES];
	galleryItem.icon = icon;
	
	[image release];
}

+(void)makeIconFace:(Face *)face {
	NSString *base = @"tmb_";
	NSString *tmbName = [base stringByAppendingString:face.imageName];
	NSString *tmbpath = [face.path stringByAppendingPathComponent:tmbName];
	NSString *filepath = [face.path stringByAppendingPathComponent:face.imageName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:tmbpath]) return;
	
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:filepath];
	float netsize = 72.5;
	CGSize newSize = CGSizeMake(netsize,netsize);
	
	// resize snippet
	UIGraphicsBeginImageContext( newSize );
	//apply scale to fit procedure
	CGSize orig = [image size];
	if (orig.width > orig.height){
		[image drawInRect:CGRectMake((newSize.width-newSize.height*orig.width/orig.height)/2,0,newSize.height*orig.width/orig.height,newSize.height)];		
	} else {
		[image drawInRect:CGRectMake(0,(newSize.height-newSize.width*orig.height/orig.width)/2,newSize.width,newSize.width*orig.height/orig.width)];
	}
	UIImage *icon = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSData *pngimage = UIImagePNGRepresentation(icon);
	[pngimage writeToFile:tmbpath atomically:YES];
	[face setIcon:icon];
	
	[image release];

}

+(void)makeIconSmallFace:(Face *)face {
	
	// save thumbnails
	NSString *base = @"tmbsm_";
	NSString *tmbName = [base stringByAppendingString:face.imageName];
	//	NSString *tmbpath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:tmbName];
//	NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:face.imageName];
	NSString *tmbpath = [face.path stringByAppendingPathComponent:tmbName];
	NSString *filepath = [face.path stringByAppendingPathComponent:face.imageName];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:tmbpath]) return;

	UIImage *image = [[UIImage alloc] initWithContentsOfFile:filepath];
	float netsize = 43;
	CGSize newSize = CGSizeMake(netsize,netsize);
	
	// resize snippet
	UIGraphicsBeginImageContext( newSize );
	//apply scale to fit procedure
	CGSize orig = [image size];
	if (orig.width > orig.height){
		[image drawInRect:CGRectMake((newSize.width-newSize.height*orig.width/orig.height)/2,0,newSize.height*orig.width/orig.height,newSize.height)];		
	} else {
		[image drawInRect:CGRectMake(0,(newSize.height-newSize.width*orig.height/orig.width)/2,newSize.width,newSize.width*orig.height/orig.width)];
	}
	UIImage *icon = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSData *pngimagetmb = UIImagePNGRepresentation(icon);
	[pngimagetmb writeToFile:tmbpath atomically:YES];
	[face setIconSmall:icon];
	[image release];
	
}

@end
