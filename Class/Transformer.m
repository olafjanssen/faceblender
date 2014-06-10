//
//  Transformer.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/20/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "Transformer.h"

@implementation Transformer

- (void)setDestPointsP0x:(float)x0 P0y:(float)y0 P1x:(float)x1 P1y:(float)y1 P2x:(float)x2 P2y:(float)y2 {
    destPoints[0][0] = x0;
    destPoints[0][1] = y0;
    destPoints[1][0] = x1;
    destPoints[1][1] = y1;
    destPoints[2][0] = x2;
    destPoints[2][1] = y2;
}

- (CGAffineTransform)defineAffineMatrixP0x:(float)x0 P0y:(float)y0 P1x:(float)x1 P1y:(float)y1 P2x:(float)x2 P2y:(float)y2 {
    
 /*  
    affinematrix[2] = (x0*destPoints[2][0] - x2*destPoints[0][0] + x0*(x0+x2)*(destPoints[1][0]-destPoints[0][0])/(x0+x1))/(y2*x0-x2+(x0+x2)/(x0+x1)*(x1*y0-x0*y1));
    affinematrix[4] = ((destPoints[1][0])*x0 + (x1*y0-x0*y1)*affinematrix[2])/(x0+x1);
    affinematrix[0] = (destPoints[0][0]-y0*affinematrix[2]+affinematrix[4])/x0;

    affinematrix[3] = (x0*destPoints[2][1] - x2*destPoints[0][1] + x0*(x0+x2)*(destPoints[1][1]-destPoints[0][1])/(x0+x1))/(y2*x0-x2+(x0+x2)/(x0+x1)*(x1*y0-x0*y1));
    affinematrix[5] = ((destPoints[1][1])*x0 + (x1*y0-x0*y1)*affinematrix[3])/(x0+x1);
    affinematrix[1] = (destPoints[0][1]-y0*affinematrix[3]+affinematrix[5])/x0;
   */
 /*  
   affinematrix[4] = ((destPoints[2][0] - destPoints[0][0]*x2/x0) - (y2-y0*x2/x0)*(destPoints[1][0]-destPoints[0][0]*x1/x0)/(y1-y0*x1/x0))/( (1-x2/x0)-(y2-y0*x2/x0)*(destPoints[1][0]-destPoints[0][0]*x1/x0)/(y1-y0*x1/x0));
   affinematrix[2] = ((destPoints[1][0] - destPoints[0][0]*x1/x0)/(y1-y0*x1/x0)) - ( (1-x2/x0)-(y2-y0*x2/x0)*(1-x1/x0)/(y1-y0*x1/x0))*affinematrix[4];
   affinematrix[0] = (destPoints[0][0]/x0 - y0/x0*(destPoints[1][0]-destPoints[0][0]*x1/x0)/(y1-y0*x1/x0)) - (1/x0 -y0/x0*(1-x1/x0)/(y1-y0*x1/x0))*affinematrix[4];
   
   affinematrix[5] = ((destPoints[2][1] - destPoints[0][1]*x2/x0) - (y2-y0*x2/x0)*(destPoints[1][1]-destPoints[0][1]*x1/x0)/(y1-y0*x1/x0))/( (1-x2/x0)-(y2-y0*x2/x0)*(destPoints[1][1]-destPoints[0][1]*x1/x0)/(y1-y0*x1/x0));
   affinematrix[3] = ((destPoints[1][1] - destPoints[0][1]*x1/x0)/(y1-y0*x1/x0)) - ( (1-x2/x0)-(y2-y0*x2/x0)*(1-x1/x0)/(y1-y0*x1/x0))*affinematrix[5];
   affinematrix[1] = (destPoints[0][1]/x0 - y0/x0*(destPoints[1][1]-destPoints[0][1]*x1/x0)/(y1-y0*x1/x0)) - (1/x0 -y0/x0*(1-x1/x0)/(y1-y0*x1/x0))*affinematrix[5];
   */  
//    A = [a b 0; c d 0; e f 1]
    for(int i=0;i<2;i++) {
    
        float a = x0;    float b = y0;    float d = -destPoints[0][i];
        float l = x1;    float m = y1;    float k = -destPoints[1][i];
        float p = x2;    float q = y2;    float s = -destPoints[2][i];
    
        float D = (a*m+b*p+l*q) - (a*q+b*l+m*p);
        affinematrix[0+i] = ((b*k + m*s + d*q) - (b*s +q*k + d*m))/D;
        affinematrix[2+i] = ((a*s + p*k + d*l) - (a*k +l*s + d*p))/D;
        affinematrix[4+i] = ((a*q*k + b*l*s + d*m*p) - (a*m*s +b*p*k + d*l*q))/D;
    }   
    
    CGAffineTransform output = CGAffineTransformMake( affinematrix[0], affinematrix[1], affinematrix[2], affinematrix[3],affinematrix[4],affinematrix[5]);
    return output;
}

@end
