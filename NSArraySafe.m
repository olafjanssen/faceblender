//
//  NSArraySafe.m
//  FaceBlender
//
//  Created by Olaf Janssen on 5/26/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "NSArraySafe.h"

@implementation NSArray (safeVersion)
- (id)objectAtIndex:(NSUInteger)index {
NSLog(@"ObjectAtIndex");
	return [self objectAtIndex:index];
}

@end