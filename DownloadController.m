//
//  DownloadController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 5/28/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "DownloadController.h"


@implementation DownloadController
@synthesize delegate;

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
	switch (buttonIndex) {
		case 0:
			break;
		case 1:
			[self startDownload];
			break;
		default:
			break;
	}
}

-(void)isDownloadNeeded {
	// first see if a demo library file is already available
	if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.xml"]]) {
		if (delegate) [[delegate demoSwitch] setOn:NO animated:YES];
		alert = [[UIAlertView alloc] initWithTitle:@"Download Database" //needlocal
										   message:@"Would you like to download the free sample database? (approximately 7MB)" //needlocal
										  delegate:self 
								 cancelButtonTitle:NSLocalizedString(@"CancelKey",@"") 
								 otherButtonTitles:NSLocalizedString(@"OkKey",@""),nil];
		[alert show];
		[alert release];
		return;
	}
	
	// then check if we have an internet connection; otherwise ignore
	if ([[Reachability sharedReachability] internetConnectionStatus]){

	// obtain xml file
	NSURLRequest *request  = [NSURLRequest requestWithURL: [ NSURL URLWithString: @"http://www.awokenwell.com/FaceBlender/Zips/DemoFaceLibrary.xml" ]];
	NSData *xmlData = [ NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

	[xmlData writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.tmp"] atomically:YES];
	NSDictionary *ninfo = [NSDictionary dictionaryWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.tmp"]];
	NSDictionary *oinfo = [NSDictionary dictionaryWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.xml"]];

	if ([[oinfo objectForKey:@"version"] compare:[ninfo objectForKey:@"version"]]!=NSOrderedSame){
		if (delegate) [[delegate demoSwitch] setOn:NO animated:YES];

		alert = [[UIAlertView alloc] initWithTitle:@"Download Database" //needlocal
									   message:@"There is a newer version of the free sample database. Would you like to download it? (approximately 7MB)" //needlocal
									  delegate:self 
							 cancelButtonTitle:NSLocalizedString(@"CancelKey",@"") 
							 otherButtonTitles:NSLocalizedString(@"OkKey",@""),nil];
	[alert show];
	[alert release];
		return;
	}
	}

	NSMutableArray *settings;
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	settings = [NSMutableArray arrayWithContentsOfFile:filePath];
	NSString *newStr2 = [NSString stringWithString:@"YES"];
	if (settings.count>2)
		[settings replaceObjectAtIndex:2 withObject:newStr2];
	[settings writeToFile:filePath atomically:YES];
	
	FaceBlenderAppDelegate *appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	appDelegate.activityText = NSLocalizedString(@"LoadingDatabaseKey",@"");
	[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];
	
	[appDelegate reloadFacesDatabase];
	for(Face *f in appDelegate.faceDatabaseDelegate.faces){
		[IconMaker makeIconFace:f];
		[IconMaker makeIconSmallFace:f];
		[delegate makeIconSmall:f];
	}
	[appDelegate hideActivityViewer]; 
}

-(void)startDownload {
	if (![[Reachability sharedReachability] internetConnectionStatus]){
		alert = [[UIAlertView alloc] initWithTitle:@"No internet!" //needlocal
														message:@"Host cannot be reached." //needlocal
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:NSLocalizedString(@"OkKey",@""),nil];
		[alert show];
		[alert release];
		return;
	}

	// obtain xml file
	NSURLRequest *prerequest  = [NSURLRequest requestWithURL: [ NSURL URLWithString: @"http://www.awokenwell.com/FaceBlender/Zips/DemoFaceLibrary.xml" ]];
	NSData *xmlData = [ NSURLConnection sendSynchronousRequest:prerequest returningResponse:nil error:nil];
	
	[xmlData writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.tmp"] atomically:YES];
	info = [[NSDictionary alloc] initWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.tmp"]];
	
	NSString *url = [NSString stringWithFormat:@"http://www.awokenwell.com/FaceBlender/Zips/%@",[info objectForKey:@"archive"]];
	
	 alert = [[UIAlertView alloc] initWithTitle:@"Downloading Database" //needlocal
													message:@"    " //needlocal
												    delegate:self 
													cancelButtonTitle:NSLocalizedString(@"CancelKey",@"") 
													otherButtonTitles:nil];
	
	// Create the progress bar and add it to the alert
	progbar = [[UIProgressView alloc] initWithFrame:
							   CGRectMake(30.0f, 55.0f, 220.0f, 20.0f)];
	[alert addSubview:progbar];
	[alert show];
	NSString *basePath= NSTemporaryDirectory(); //[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	[[NSFileManager defaultManager] createFileAtPath:[basePath stringByAppendingPathComponent:@"download.zip"] contents:nil attributes:nil];
	filehandle = [[NSFileHandle fileHandleForUpdatingAtPath:[basePath stringByAppendingPathComponent:@"download.zip"]] retain];
	
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	NSNumber *size = [info objectForKey:@"size"]; //[nf numberFromString: [info objectForKey:@"size"]];
	totalSize = [size intValue];
	[nf release];
	
	NSURLRequest *request  = [[ [ NSURLRequest alloc ] initWithURL: [ NSURL URLWithString:url ] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60 ] autorelease];
	connection = [[ NSURLConnection alloc] initWithRequest:request delegate:self];	
	if (connection){
		receivedData = [[NSMutableData data] retain];	
	} else {
		NSLog(@"something went wrong");	
	}
}

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
}

-(void)updateProgress {
	[progbar setProgress: [receivedData length]/(float)totalSize];
}

-(void)updateAlert {
	[progbar removeFromSuperview];
	[alert setMessage:@"Extracting data..."];	
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)data{
	[receivedData appendData:data];
	[filehandle truncateFileAtOffset:[filehandle seekToEndOfFile]]; //setting aFileHandle to write at the end of the file
	[filehandle writeData:data]; //actually write the data
		
	[self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:YES];
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error{
	[_connection release];
	NSLog(@"Connection failed! Error - %@ %@",
	      [error localizedDescription],
	      [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection {
   NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    [_connection release];
    [receivedData release];
	[filehandle closeFile];
	[filehandle release];
//	[self performSelectorOnMainThread:@selector(updateAlert) withObject:nil waitUntilDone:YES];
	
	[progbar removeFromSuperview];
	[alert dismissWithClickedButtonIndex:0 animated:YES];
	
	alert = [[UIAlertView alloc] initWithTitle:@"Downloading Database" //needlocal
									   message:@"Extracting data..." //needlocal
									  delegate:self 
							 cancelButtonTitle:NSLocalizedString(@"CancelKey",@"") 
							 otherButtonTitles:nil];
	[alert show];
	
	[self storeAndExtractFiles];
}

-(void)storeAndExtractFiles {
	[[NSFileManager defaultManager] createDirectoryAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[info objectForKey:@"folder"]]  attributes:nil];
	
	ZipController *zc = [[ZipController alloc] init];
	[zc UnzipOpenFile:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download.zip"]];
	[zc UnzipFileTo: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[info objectForKey:@"folder"]] overWrite:YES];
	[zc release];
	
	if (delegate) [[delegate demoSwitch] setOn:YES animated:YES];

	NSMutableArray *settings;
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	settings = [NSMutableArray arrayWithContentsOfFile:filePath];
	NSString *newStr2 = [NSString stringWithString:@"YES"];
	if (settings.count>2)
		[settings replaceObjectAtIndex:2 withObject:newStr2];
	[settings writeToFile:filePath atomically:YES];
	
	[[NSFileManager defaultManager] moveItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.tmp"]
										    toPath: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DemoFaceLibrary.xml"]
											error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download.zip"] error:nil];
	
	 [alert dismissWithClickedButtonIndex:0 animated:YES];
	
	// load the freshly downloaded database
	FaceBlenderAppDelegate *appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	appDelegate.activityText = NSLocalizedString(@"LoadingDatabaseKey",@"");
	[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];
	
	[appDelegate reloadFacesDatabase];
	for(Face *f in appDelegate.faceDatabaseDelegate.faces){
		[IconMaker makeIconFace:f];
		[IconMaker makeIconSmallFace:f];
		[delegate makeIconSmall:f];
	}
	[appDelegate hideActivityViewer];
	
}

-(void)dealloc {
	if (connection) [connection release];
	connection = nil;
	
	if (receivedData) [receivedData release];
	receivedData = nil;
	
	if (alert) [alert release];
	alert = nil;
	
	if (progbar) [progbar release];
	progbar = nil;
	
	if (filehandle) [filehandle release];
	filehandle = nil;
	
	if (info) [info release]; 
	info = nil;
	delegate = nil;
	
	[super dealloc];
}

@end
