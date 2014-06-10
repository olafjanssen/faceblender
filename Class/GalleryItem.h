//
//  GalleryItem.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/23/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GalleryItem : NSObject {
    int uniqueId;
    NSString  *imageName;
    NSString  *title;
    NSString  *method;
    NSString  *description;
	
	float P0x;
    float P0y;
    float P1x;
    float P1y;
    float P2x;
    float P2y;
	
	UIImage *icon;
}

@property (copy) NSString *imageName;
@property (copy) NSString *title;
@property (copy) NSString *method;
@property (copy) NSString *description;
@property ( retain) UIImage *icon;
@property (assign) int uniqueId;
@property (assign) float P0x;
@property (assign) float P0y;
@property (assign) float P1x;
@property (assign) float P1y;
@property (assign) float P2x;
@property (assign) float P2y;


-(NSComparisonResult) compare:(GalleryItem *)item;
-(void) setPoint:(CGPoint)p at:(NSInteger)c;
-(CGPoint) getPoint:(NSInteger)c;


@end
