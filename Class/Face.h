//
//  Face.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Face : NSObject {
    int index;
    int uniqueId;
    NSString  *name;
    NSString  *imageName;
	NSString  *path;
    float P0x;
    float P0y;
    float P1x;
    float P1y;
    float P2x;
    float P2y;
    NSString *traits;
	NSString *traitsTmp;
	
	UIImage *icon;
	UIImage *iconSmall;
	BOOL custom;
	BOOL isEditable;
}

@property (retain) NSString *name;
@property (retain) NSString *imageName;
@property (retain) NSString *path;
@property (retain) NSString *traits;
@property (retain) NSString *traitsTmp;
@property (assign) int index;
@property (assign) int uniqueId;
@property (assign) float P0x;
@property (assign) float P0y;
@property (assign) float P1x;
@property (assign) float P1y;
@property (assign) float P2x;
@property (assign) float P2y;
@property (assign) BOOL custom;
@property (assign) BOOL isEditable;
@property (retain) UIImage *icon;
@property (retain) UIImage *iconSmall;

-(id) initWithUniqueID:(NSInteger) uid Name:(NSString *)n Image:(NSString *)img P0x:(float)p0x P0y:(float)p0y P1x:(float)p1x P1y:(float)p1y P2x:(float)p2x P2y:(float)p2y;
-(NSComparisonResult) compare:(Face *)item;

//-(NSInteger)getUniqueId;
//-(void)setUniqueId:(NSInteger) uid;

-(CGPoint) getPoint:(NSInteger)c;
-(void) setPoint:(CGPoint)p at:(NSInteger)c;

//-(void)makeIcon;
//-(void)makeIconSmall;

@end
