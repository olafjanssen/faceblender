//
//  Trait.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/22/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Trait : NSObject {
    NSInteger uniqueId;
    NSString  *description;
}

@property ( retain) NSString *description;
@property ( assign) NSInteger uniqueId;

-(id) initWithUniqueId:(NSInteger)uid Description:(NSString *)n;

@end
