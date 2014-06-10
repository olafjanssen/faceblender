//
//  ZipController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 5/28/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zip.h"
#import "unzip.h"
//#import "zlib.h"
#import "zconf.h"


@interface ZipController : NSObject {
	zipFile		_zipFile;
	unzFile		_unzFile;	
	id			_delegate;
}

-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;
-(BOOL) UnzipOpenFile:(NSString*) zipFile;

@end
