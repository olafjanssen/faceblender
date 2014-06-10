//
//  IconMaker.h
//  FaceBlender
//
//  Created by Olaf Janssen on 3/5/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Face.h"
#import "GalleryItem.h"
#import "Resizer.h"

@interface IconMaker : NSObject {

}

+(void)makeIconItem:(GalleryItem *)galleryItem;
+(void)makeIconFace:(Face *)face;
+(void)makeIconSmallFace:(Face *)face;

@end
