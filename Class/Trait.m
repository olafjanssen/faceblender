//
//  Trait.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/22/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "Trait.h"

@implementation Trait
@synthesize uniqueId, description;

-(id) initWithUniqueId:(NSInteger)uid Description:(NSString *)n {
    uniqueId = uid;
    description = [[NSString alloc] initWithString: n];
    return self;
}

-(void)dealloc {
	[description release]; description = nil;
	[super dealloc];
}

@end
