//
//  NSArraySafe.h
//  FaceBlender
//
//  Created by Olaf Janssen on 5/26/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (safeVersion)
- (id)objectAtIndex:(NSUInteger)index;
@end
