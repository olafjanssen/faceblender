//
//  GalleryItem.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/23/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "GalleryItem.h"


@implementation GalleryItem
@synthesize uniqueId, imageName, title, method, description;
@synthesize icon;
@synthesize P0x,P0y,P1x,P1y,P2x,P2y;

-(NSComparisonResult) compare:(GalleryItem *)item {
	if ( [self uniqueId] < [item uniqueId]) return NSOrderedDescending;
	else if ([self uniqueId] > [item uniqueId]) return NSOrderedAscending;
	else return NSOrderedSame;
}

-(void)dealloc {
	[imageName release]; imageName = nil;
	[title release]; title = nil;
	[method release]; method = nil;
	[description release]; description = nil;
	[icon release]; icon = nil;
	[super dealloc];
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

@end
