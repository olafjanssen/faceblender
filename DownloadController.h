//
//  DownloadController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 5/28/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZipController.h"
#import "Reachability.h"
#import "FaceBlenderAppDelegate.h"
#import "Face.h"
#import "IconMaker.h"

@interface DownloadController : UIView {
	NSURLConnection *connection;
	NSMutableData *receivedData;
	NSInteger totalSize;
	UIAlertView *alert;
	UIProgressView *progbar;
	NSFileHandle *filehandle;
	NSDictionary *info;
	id delegate;
}

@property (assign) id delegate;

-(void)isDownloadNeeded;
-(void)startDownload;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)updateProgress;
-(void)updateAlert;
-(void)storeAndExtractFiles;



@end
