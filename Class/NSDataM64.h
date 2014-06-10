//
//  NSDataM64.h
//  FaceBlender
//
//  Created by Olaf Janssen on 1/15/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (MBBase64) 

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end
