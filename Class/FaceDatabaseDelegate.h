//
//  FaceDatabaseDelegate.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Face.h";

@interface FaceDatabaseDelegate : NSObject {
    NSString *databaseName;
    NSString *databasePath;
    
    NSMutableArray *faces;
    NSMutableArray *traits;
    NSMutableArray *traitSections;
    
}

@property (retain) NSMutableArray *faces;
@property (retain) NSMutableArray *traits;
@property (retain) NSMutableArray *traitSections;
@property (assign) NSString *databaseName;
@property (assign) NSString *databasePath;

-(id)init;
-(void)load;
-(void)dealloc;
-(void)checkAndCreateDatabase:(NSString *)dbaseName;
-(void)readFacesFromDatabase:(NSString *)dbaseName res:(BOOL)isRes;
-(void) readTraitsFromDatabase;
-(void)saveFace:(Face *)face;
-(void)updateFace:(Face *)face;
-(void)deleteFace:(Face *)face;



@end
