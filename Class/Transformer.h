//
//  Transformer.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/20/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Transformer : NSObject {
    float affinematrix[6];
    float destPoints[3][2];
}

- (CGAffineTransform)defineAffineMatrixP0x:(float)x0 P0y:(float)y0 P1x:(float)x1 P1y:(float)y1 P2x:(float)x2 P2y:(float)y2;
- (void)setDestPointsP0x:(float)x0 P0y:(float)y0 P1x:(float)x1 P1y:(float)y1 P2x:(float)x2 P2y:(float)y2;

@end
