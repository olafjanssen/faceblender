//
//  GalleryDatabaseDelegate.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/23/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "GalleryDatabaseDelegate.h"


@implementation GalleryDatabaseDelegate
@synthesize databaseName,databasePath, galleryItems;

-(id)init {
    [super init];
    
    databaseName = @"Gallery.sql";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
    galleryItems = [[NSMutableArray alloc] init];
    
    [self checkAndCreateDatabase];
    [self readImagesFromDatabase];
    return self;
}

-(void) dealloc {
	[galleryItems release]; galleryItems = nil;
	[super dealloc];
}
-(void) checkAndCreateDatabase{

    BOOL success;

    // first check if the database already exists
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    if (success) return;

    // if not the copy the default database
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
    success = [fileManager copyItemAtPath: databasePathFromApp toPath:databasePath error:&error];
    if(!success){
        NSAssert1(0,@"Failed to create writable database with message '%@'.", [error localizedDescription]);
     }
     
}

-(void) readImagesFromDatabase {
//	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
    databaseName = @"Gallery.sql";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];

    sqlite3 *database;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
        const char *sqlStatement = "SELECT * FROM images ORDER BY id DESC";
        sqlite3_stmt *compiledStatement;
			
		NSString *aImageName;
		NSString *aTitle;
		NSString *aMethod;
		NSString *aDescription;
		
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSInteger aUid = sqlite3_column_int(compiledStatement, 0);
				aImageName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                aTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                aMethod = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                aDescription = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                
				float aP0x = sqlite3_column_double(compiledStatement, 5);
                float aP0y = sqlite3_column_double(compiledStatement, 6);
                float aP1x = sqlite3_column_double(compiledStatement, 7);
                float aP1y = sqlite3_column_double(compiledStatement, 8);
                float aP2x = sqlite3_column_double(compiledStatement, 9);
                float aP2y = sqlite3_column_double(compiledStatement, 10);
				
				
                GalleryItem *galleryItem = [[GalleryItem alloc] init];
                [galleryItem setUniqueId:aUid];
                [galleryItem setImageName:aImageName];
                [galleryItem setTitle:aTitle];
                [galleryItem setMethod:aMethod];
                [galleryItem setDescription:aDescription];
				[galleryItem setP0x:aP0x];
				[galleryItem setP0y:aP0y];
				[galleryItem setP1x:aP1x];
				[galleryItem setP1y:aP1y];
				[galleryItem setP2x:aP2x];
				[galleryItem setP2y:aP2y];
                [galleryItems addObject:galleryItem];
                [galleryItem release];
								
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// do check on galleryItems
	for (GalleryItem *g in galleryItems) {
		// create image file if it does not exist
		NSString *filePath = [documentsDir stringByAppendingPathComponent:g.imageName];
		NSString *filePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:g.imageName];
		
		NSError *error;
		if (! [fileManager fileExistsAtPath:filePath]){
			if ( [fileManager fileExistsAtPath:filePathFromApp])
				[fileManager copyItemAtPath:filePathFromApp toPath:filePath error:&error];
			
		}
		
		NSString *base = @"tmb_";
		NSString *tmbName = [base stringByAppendingString:g.imageName];
		NSString *tmbfilePath = [documentsDir stringByAppendingPathComponent:tmbName];
		NSString *tmbfilePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tmbName];
		if ([fileManager fileExistsAtPath:tmbfilePathFromApp])
			[fileManager copyItemAtPath:tmbfilePathFromApp toPath:tmbfilePath error:&error];
	}
	
//	[tmpPool release];
	
}

-(void)updateImage:(GalleryItem *)galleryItem{
    
    databaseName = @"Gallery.sql";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    sqlite3 *database;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		sqlite3_stmt *updateStmt;
		const char *sql = "UPDATE images SET description =? WHERE id = ?";
		
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		
		sqlite3_bind_text(updateStmt, 1, [galleryItem.description UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(updateStmt, 2, (int)galleryItem.uniqueId);
		
		if(SQLITE_DONE != sqlite3_step(updateStmt))
			NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
		
		//    sqlite3_sleep(10);
		
		sqlite3_reset(updateStmt);
    }
    sqlite3_close(database);
	
	[galleryItems sortUsingSelector:@selector(compare:)];
}


-(void)saveImage:(GalleryItem *)galleryItem {
    
	CGPoint p0 = [galleryItem getPoint:0];
    CGPoint p1 = [galleryItem getPoint:1];
    CGPoint p2 = [galleryItem getPoint:2];
	
    databaseName = @"Gallery.sql";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    sqlite3 *database;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
    
    sqlite3_stmt *addStmt;
    
    const char *sql = "INSERT INTO images (image, title, method, description,  P0x, P0y, P1x, P1y, P2x, P2y) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
    NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));

    sqlite3_bind_text(addStmt, 1, [galleryItem.imageName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(addStmt, 2, [galleryItem.title UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(addStmt, 3, [galleryItem.method UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(addStmt, 4, [galleryItem.description UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(addStmt, 5, (double)p0.x);
	sqlite3_bind_double(addStmt, 6, (double)p0.y);
	sqlite3_bind_double(addStmt, 7, (double)p1.x);
	sqlite3_bind_double(addStmt, 8, (double)p1.y);
	sqlite3_bind_double(addStmt, 9, (double)p2.x);
	sqlite3_bind_double(addStmt, 10, (double)p2.y);
		
    if(SQLITE_DONE != sqlite3_step(addStmt))
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));

    //Reset the add statement.
    sqlite3_reset(addStmt);
    }
        sqlite3_close(database);
    
    // save in faces object
//    [galleryItems addObject:galleryItem];	
//	[galleryItems sortUsingSelector:@selector(compare:)];	
	[galleryItems release];
	galleryItems = [[NSMutableArray alloc] init];
	[self readImagesFromDatabase];
    
}

-(void)deleteImage:(GalleryItem *)galleryItem {

    int uid = galleryItem.uniqueId;

    databaseName = @"Gallery.sql";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    sqlite3 *database;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
    
    sqlite3_stmt *deleteStmt;
    const char *sql = "DELETE FROM images WHERE id = ?";
    if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
        NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
    
    //When binding parameters, index starts from 1 and not zero.
    sqlite3_bind_int(deleteStmt, 1, (int)uid);

    if (SQLITE_DONE != sqlite3_step(deleteStmt))
    NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));

    sqlite3_reset(deleteStmt);
    }
    sqlite3_close(database);
    
    //delete image
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *aName = [NSString stringWithString:galleryItem.imageName];
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aName];
	NSString *tmbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[@"tmb_" stringByAppendingString: aName]];

	[fileManager removeItemAtPath:filePath error:nil];
	[fileManager removeItemAtPath:tmbPath error:nil];
	
    // delete object
    [galleryItems removeObject:galleryItem];
	[galleryItems sortUsingSelector:@selector(compare:)];	

}


@end
