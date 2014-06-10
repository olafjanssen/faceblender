//
//  Face.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "Face.h"


@implementation Face
@synthesize name,imageName,P0x,P0y,P1x,P1y,P2x,P2y,traits,traitsTmp,index,uniqueId;
@synthesize custom,icon,iconSmall,path,isEditable;

-(id) init {
	uniqueId = -1;
	self.name = @"New Face";
	self.imageName = @"UITabBarContacts.jpg";
	self.P0x = 0;
	self.P0y = 0;
	self.P1x = 0;
	self.P1y = 0;
	self.P2x = 0;
	self.P2y = 0;
	self.traits = @"";
	self.traitsTmp = nil;
	self.icon = nil;
	self.iconSmall = nil;
	self.path = nil;
	self.isEditable = YES;
	return self;
}

-(void)dealloc {
	[name release]; name = nil;
	[imageName release]; imageName = nil;
	[path release]; path = nil;
	[traits release]; traits=  nil;
	[traitsTmp release]; traitsTmp = nil;
	[icon release]; icon = nil;
	[iconSmall release]; iconSmall = nil;
	[super dealloc];
}

-(id) initWithUniqueID:(NSInteger) uid Name:(NSString *)n Image:(NSString *)img P0x:(float)p0x P0y:(float)p0y P1x:(float)p1x P1y:(float)p1y P2x:(float)p2x P2y:(float)p2y {
    uniqueId = uid;
    self.name = n;
    self.imageName = img;
    P0x = p0x;
    P0y = p0y;
    P1x = p1x;
    P1y = p1y;
    P2x = p2x;
    P2y = p2y;
	traits = @"";
	traitsTmp = nil;
	isEditable = YES;
    return self;
}

/*
-(NSInteger)getUniqueId {
    return uniqueId;
}

-(void)setUniqueId:(NSInteger) uid {
    uniqueId = uid;
}
*/

-(NSComparisonResult) compare:(Face *)item {
	return [self.name compare: item.name options:NSCaseInsensitiveSearch ];
}

-(CGPoint) getPoint:(NSInteger)c {
    CGPoint retval;
    switch (c) {
        case 0:
              retval = CGPointMake(P0x, P0y);
            break;
        case 1:
              retval = CGPointMake(P1x, P1y);
            break;
        case 2:
              retval = CGPointMake(P2x, P2y);
            break;
        default:
            break;
    } 
    return retval;
}

-(void) setPoint:(CGPoint)p at:(NSInteger)c {
    switch (c) {
        case 0:
              P0x = p.x;
              P0y = p.y;
            break;
        case 1:
              P1x = p.x;
              P1y = p.y;
            break;
        case 2:
              P2x = p.x;
              P2y = p.y;
            break;
        default:
            break;
    } 
}

@end
