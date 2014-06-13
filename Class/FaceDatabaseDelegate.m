//
//  FaceDatabaseDelegate.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "FaceDatabaseDelegate.h"
#import "Face.h"
#import "Trait.h"

@implementation FaceDatabaseDelegate

@synthesize faces, traits, traitSections;
@synthesize databaseName, databasePath;

-(id)init {
    [super init];

	databaseName = @"FacesDatabase.sql";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    if (!faces) faces = [[NSMutableArray alloc] init];
    if (!traits) traits = [[NSMutableArray alloc] init];
    if (!traitSections) traitSections = [[NSMutableArray alloc] init];
	
	return self;
}

-(void)load {
	// reset
	[faces removeAllObjects];
	[traits removeAllObjects];
	[traitSections removeAllObjects];
	
    [self checkAndCreateDatabase:databaseName];
    [self readFacesFromDatabase:databaseName res:NO];
	
	// reload settings
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	NSMutableArray *settings;
	settings = [NSArray arrayWithContentsOfFile:filePath];
	
	if (settings.count>2)
		if ([(NSString *)[settings objectAtIndex:2] compare:@"YES"] == NSOrderedSame){
	    //[self checkAndCreateDatabase:@"DemoFacesDatabase.sql"];
		[self readFacesFromDatabase:@"DemoFacesDatabase.sql" res:YES];
	}
	
	[self readTraitsFromDatabase];
	
}

-(void)dealloc {
	[faces release]; faces = nil;
	[traits release]; traits = nil;
	[traitSections release]; traitSections = nil;
	[super dealloc];
}

-(void)clearAll {
	[faces removeAllObjects];
	[traits removeAllObjects];
	[traitSections removeAllObjects];
}


-(void) checkAndCreateDatabase:(NSString *)dbaseName{

    BOOL success;

	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:dbaseName];
	
    // first check if the database already exists
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    if (success) return;

    // if not the copy the default database
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbaseName];
    success = [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:&error];
    if(!success){
        NSAssert1(0,@"Failed to create writable databse with message '%@'.", [error localizedDescription]);
     }
     
}

-(void) readFacesFromDatabase:(NSString *)dbaseName res:(BOOL)isRes{
    //databaseName = @"FacesDatabase.sql";
	//databaseName = dbaseName;
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSDictionary *info;
	if (!isRes){
    databasePath = [documentsDir stringByAppendingPathComponent:dbaseName];
	} else {
		info = [NSDictionary dictionaryWithContentsOfFile: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.xml"]];
		databasePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[info objectForKey:@"folder"]] stringByAppendingPathComponent:[info objectForKey:@"sql"]];
		//databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbaseName];
		NSLog(databasePath, NULL);
		if ( ![[NSFileManager defaultManager] fileExistsAtPath:databasePath]){
			NSLog(@"does not exist");
		}
	}
	
    sqlite3 *database;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
        const char *sqlStatement = "SELECT * FROM faces ORDER BY Name ASC";
        sqlite3_stmt *compiledStatement;
                
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int cnt = 0;
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSInteger aUid = sqlite3_column_int(compiledStatement, 0);
                NSString *aName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                NSString *aImageName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                float aP0x = sqlite3_column_double(compiledStatement, 3);
                float aP0y = sqlite3_column_double(compiledStatement, 4);
                float aP1x = sqlite3_column_double(compiledStatement, 5);
                float aP1y = sqlite3_column_double(compiledStatement, 6);
                float aP2x = sqlite3_column_double(compiledStatement, 7);
                float aP2y = sqlite3_column_double(compiledStatement, 8);
				
				NSString *aTraits;
				char *tmp = (char *)sqlite3_column_text(compiledStatement, 9);
				
				if (tmp != NULL)
					aTraits = [NSString stringWithUTF8String:tmp];
				else aTraits = @"";
					
                Face *face = [[Face alloc] initWithUniqueID:aUid Name:aName Image:aImageName P0x:aP0x P0y:aP0y P1x:aP1x P1y:aP1y P2x:aP2x P2y:aP2y];
                if (!isRes){
					face.path = documentsDir;
					face.isEditable = YES;
				} else {
					face.path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[info objectForKey:@"folder"]];
					face.isEditable = NO;
				}

				[face setIndex:cnt++];
                [face setTraits:aTraits];
                				
                [faces addObject:face];
				
				// legacy thing (remove demo images from the documents dir
				if (isRes){
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSString *filePath = [documentsDir stringByAppendingPathComponent:face.imageName];
				if ([fileManager fileExistsAtPath:filePath]){
					NSLog([NSString stringWithFormat: @"Removing demo file from Documents folder: %@",face.name], NULL);
					[fileManager removeItemAtPath:filePath error:nil];
				}			
				NSString *base = @"tmb_";
				NSString *tmbName = [base stringByAppendingString:face.imageName];
				NSString *base2 = @"tmbsm_";
				NSString *tmbName2 = [base2 stringByAppendingString:face.imageName];
				NSString *tmbfilePath = [documentsDir stringByAppendingPathComponent:tmbName];
				NSString *tmb2filePath = [documentsDir stringByAppendingPathComponent:tmbName2];
				if ([fileManager fileExistsAtPath:tmbfilePath]){
					NSLog([NSString stringWithFormat: @"Removing demo file from Documents folder: %@",face.name], NULL);
					[fileManager removeItemAtPath:tmbfilePath error:nil];
				}			
				if ([fileManager fileExistsAtPath:tmb2filePath]){
					NSLog([NSString stringWithFormat: @"Removing demo file from Documents folder: %@",face.name], NULL);
					[fileManager removeItemAtPath:tmb2filePath error:nil];
				}			
				}
				
				[face release];

            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
	
	[faces sortUsingSelector:@selector(compare:)];
		
		/*	 // create image file if it does not exist
	 NSFileManager *fileManager = [NSFileManager defaultManager];
	 NSString *filePath = [documentsDir stringByAppendingPathComponent:face.imageName];
	 NSString *filePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:face.imageName];
	 
	 if (! [fileManager fileExistsAtPath:filePath]){
	 NSError *error;
	 if ([fileManager fileExistsAtPath:filePathFromApp])
	 [fileManager copyItemAtPath:filePathFromApp toPath:filePath error:&error];
	 
	 NSString *base = @"tmb_";
	 NSString *tmbName = [base stringByAppendingString:face.imageName];
	 NSString *base2 = @"tmbsm_";
	 NSString *tmbName2 = [base2 stringByAppendingString:face.imageName];
	 NSString *tmbfilePath = [documentsDir stringByAppendingPathComponent:tmbName];
	 NSString *tmb2filePath = [documentsDir stringByAppendingPathComponent:tmbName2];
	 NSString *tmbfilePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tmbName];
	 NSString *tmb2filePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tmbName2];
	 if ([fileManager fileExistsAtPath:tmbfilePathFromApp])
	 [fileManager copyItemAtPath:tmbfilePathFromApp toPath:tmbfilePath error:&error];
	 if ([fileManager fileExistsAtPath:tmb2filePathFromApp])
	 [fileManager copyItemAtPath:tmb2filePathFromApp toPath:tmb2filePath error:&error];
	 }*/
	//}
	
}

-(void) readTraitsFromDatabase {
    int cnt = 0;
    // gender
    [traitSections addObject:[[[Trait alloc] initWithUniqueId:2 Description:@"Gender"] autorelease]];
    [traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Male"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Female"] autorelease]];
    // relation
	[traitSections addObject:[[[Trait alloc] initWithUniqueId:5 Description:@"Relation"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Me"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Friend"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Family"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Colleague"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Pet"] autorelease]];
    // skin complexion
	[traitSections addObject:[[[Trait alloc] initWithUniqueId:3 Description:@"Skin"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Light"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Olive"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Dark"] autorelease]];
    // hair
	[traitSections addObject:[[[Trait alloc] initWithUniqueId:6 Description:@"Hair"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Black"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Blond"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Brown"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Grey"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Red"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Bald"] autorelease]];
    // age
	[traitSections addObject:[[[Trait alloc] initWithUniqueId:4 Description:@"Age"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Baby"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Child"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Adult"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Elderly"] autorelease]];
    // Photo Specific
	[traitSections addObject:[[[Trait alloc] initWithUniqueId:2 Description:@"Photo Specific"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Eyes Closed"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt++ Description:@"Mouth Open"] autorelease]];
    // custom
	[traitSections addObject:[[[Trait alloc] initWithUniqueId:1 Description:@"Various"] autorelease]];
	[traits addObject:[[[Trait alloc] initWithUniqueId:cnt Description:@"Glasses"] autorelease]];
	
	// now search faces for new traits
	for (Face *face in faces){
		if (face.traits.length==0) continue;
		
		NSArray *split = [face.traits componentsSeparatedByString:@", "];
		if (split.count == 1 && [[split objectAtIndex:0] length]==0  ) continue;
		for(int t=0;t<split.count;t++){
			BOOL isFound = NO;
			for(int tog=0;tog<traits.count;tog++){
				if ([[[traits objectAtIndex:tog] description] compare: [split objectAtIndex:t]] == NSOrderedSame){
					isFound = YES;
					break;
				};
			}		
			if (!isFound){
				if (traitSections.count>6)
					[(Trait *)[traitSections objectAtIndex:6] setUniqueId: [(Trait *)[traitSections objectAtIndex:6] uniqueId]+1];
				Trait *trait = [[ Trait alloc] initWithUniqueId:[traits count] Description:[split objectAtIndex:t]];
				[traits addObject:trait];
				[trait release];
				NSLog([split objectAtIndex:t], NULL);
			}
		}
	}
			
}

-(void)saveFace:(Face *)face{
    CGPoint p0 = [face getPoint:0];
    CGPoint p1 = [face getPoint:1];
    CGPoint p2 = [face getPoint:2];

    //databaseName = @"FacesDatabase.sql";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    sqlite3 *database;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
    
    sqlite3_stmt *addStmt;
    
    const char *sql = "INSERT INTO faces (id, name, image,  P0x, P0y, P1x, P1y, P2x, P2y, traits) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
//    const char *sql = "INSERT INTO faces (name) VALUES (?)";
    if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
    NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));

    sqlite3_bind_int(addStmt, 1, (int)[face uniqueId]);
    sqlite3_bind_text(addStmt, 2, [face.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(addStmt, 3, [face.imageName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(addStmt, 4, (double)p0.x);
    sqlite3_bind_double(addStmt, 5, (double)p0.y);
    sqlite3_bind_double(addStmt, 6, (double)p1.x);
    sqlite3_bind_double(addStmt, 7, (double)p1.y);
    sqlite3_bind_double(addStmt, 8, (double)p2.x);
    sqlite3_bind_double(addStmt, 9, (double)p2.y);
    sqlite3_bind_text(addStmt, 10, [face.traits UTF8String], -1, SQLITE_TRANSIENT);

    if(SQLITE_DONE != sqlite3_step(addStmt))
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));

    //Reset the add statement.
    sqlite3_reset(addStmt);
    }
        sqlite3_close(database);
    
    // save in faces object
    face.index = (int)faces.count;
    [faces addObject:face];
	[faces sortUsingSelector:@selector(compare:)];
	
	// reindex
	int ind = 0;
	for (Face *f in faces){
		f.index = ind;
		ind++;
	}
    
}

-(void)updateFace:(Face *)face{
	if (!face.isEditable){
		[faces sortUsingSelector:@selector(compare:)];
		return;
	}
	
    CGPoint p0 = [face getPoint:0];
    CGPoint p1 = [face getPoint:1];
    CGPoint p2 = [face getPoint:2];
    
    //databaseName = @"FacesDatabase.sql";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    sqlite3 *database;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
    
    sqlite3_stmt *updateStmt;
    const char *sql = "UPDATE faces SET name = ?, image = ?, P0x = ?, P0y = ?, P1x = ?, P1y = ?, P2x = ?, P2y = ?, traits = ? WHERE id = ?";
    
    if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
        NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
    
    sqlite3_bind_text(updateStmt, 1, [face.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStmt, 2, [face.imageName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(updateStmt, 3, (double)p0.x);
    sqlite3_bind_double(updateStmt, 4, (double)p0.y);
    sqlite3_bind_double(updateStmt, 5, (double)p1.x);
    sqlite3_bind_double(updateStmt, 6, (double)p1.y);
    sqlite3_bind_double(updateStmt, 7, (double)p2.x);
    sqlite3_bind_double(updateStmt, 8, (double)p2.y);
    sqlite3_bind_text(updateStmt, 9, [face.traits UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(updateStmt, 10, (int)[face uniqueId]);


    if(SQLITE_DONE != sqlite3_step(updateStmt))
       NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));

//    sqlite3_sleep(10);

    sqlite3_reset(updateStmt);
    }
    sqlite3_close(database);
	
	[faces sortUsingSelector:@selector(compare:)];
}

-(void)deleteFace:(Face *)face{
	if (!face.isEditable){
	    [faces removeObject:face];
		return;
	}

    int uid = [face uniqueId];

    //databaseName = @"FacesDatabase.sql";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    sqlite3 *database;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
    
    sqlite3_stmt *deleteStmt;
    const char *sql = "DELETE FROM faces WHERE id = ?";
    if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
        NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
    
    //When binding parameters, index starts from 1 and not zero.
    sqlite3_bind_int(deleteStmt, 1, (int)uid);

    if (SQLITE_DONE != sqlite3_step(deleteStmt))
    NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));

    sqlite3_reset(deleteStmt);
    }
    sqlite3_close(database);
    
    // delete object
	if ([face.path compare:[[NSBundle mainBundle] resourcePath]] != NSOrderedSame){
	NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
	NSString *tmbPath = [face.path stringByAppendingPathComponent:[@"tmb_" stringByAppendingString: face.imageName]];
	NSString *tmbPathSmall = [face.path stringByAppendingPathComponent:[@"tmbsm_" stringByAppendingString: face.imageName]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
	[fileManager removeItemAtPath:tmbPath error:nil];
	[fileManager removeItemAtPath:tmbPathSmall error:nil];
	}

    [faces removeObject:face];
}




@end
