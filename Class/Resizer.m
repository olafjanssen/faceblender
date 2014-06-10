//
//  Resizer.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "Resizer.h"

@implementation UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
	UIGraphicsBeginImageContext( newSize );
	
	//apply scale to fit procedure
	CGSize orig = [image size];
	if (orig.width > orig.height){
		[image drawInRect:CGRectMake((newSize.width-newSize.height*orig.width/orig.height)/2,0,newSize.height*orig.width/orig.height,newSize.height)];		
	} else {
		[image drawInRect:CGRectMake(0,(newSize.height-newSize.width*orig.height/orig.width)/2,newSize.width,newSize.width*orig.height/orig.width)];
	}
	
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}
- (UIImage*)scaleImageToSize:(CGSize)newSize
{
	return [UIImage imageWithImage:self scaledToSize:newSize];
}
@end