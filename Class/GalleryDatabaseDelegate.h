//
//  GalleryDatabaseDelegate.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/23/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "GalleryItem.h"

@interface GalleryDatabaseDelegate : NSObject {
    NSString *databaseName;
    NSString *databasePath;
    
    NSMutableArray *galleryItems;    
}

@property (retain) NSMutableArray *galleryItems;
@property (copy) NSString *databaseName;
@property (copy) NSString *databasePath;

-(id)init;
-(void)checkAndCreateDatabase;
-(void)readImagesFromDatabase;
-(void)saveImage:(GalleryItem *)galleryItem;
-(void)deleteImage:(GalleryItem *)galleryItem;
-(void)updateImage:(GalleryItem *)galleryItem;

@end
