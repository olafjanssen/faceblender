//
//  OneByOneViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 5/31/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "OneByOneViewController.h"


@implementation OneByOneViewController
@synthesize appDelegate, faceTable, imageView, navItem;
@synthesize newItem;
@synthesize transformer, mixData, curBitmapData, result;
@synthesize transform, colorSpace, cgctx, mix_,mixMax_,mixCnt_;
@synthesize reswidth,resheight, faceToBlend, timesToBlend, waitTimer,activityView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];

	mixCnt_ = 0;
	faceToBlend = -1;
	timesToBlend = 0;
	
	faceCount = malloc(sizeof(int)*appDelegate.faceDatabaseDelegate.faces.count);
	for(int q=0;q<appDelegate.faceDatabaseDelegate.faces.count;q++) faceCount[q] = 0;

	navItem.title = NSLocalizedString(@"OneByOneKey",@""); //needlocal
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc]
				  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				  target:self
				  action:@selector(doDoneButton)] autorelease];
	navItem.rightBarButtonItem = doneButton;  
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									target:self
									action:@selector(doCancelButton)] autorelease];
	navItem.leftBarButtonItem = cancelButton;  
	
	faceTable.delegate = self;
	faceTable.dataSource = self;
	faceTable.rowHeight = 72.5;
		
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityView setFrame: CGRectMake((320-73)/2-12, 480-44-30, 24, 24)];
	[self.view addSubview:activityView];

	[self mixPrepare];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	if (imageView) [imageView release]; imageView = nil;
	appDelegate = nil;
	if (newItem) [newItem release]; newItem = nil;
	if (navItem) [navItem release]; navItem = nil;
	if (transformer) [transformer release]; transformer = nil;
	if (mixData) { free(mixData); mixData = nil; }
	if (curBitmapData) { free(curBitmapData); curBitmapData = nil; }
	if (faceCount) free(faceCount); faceCount = nil;
	if (activityView){
		[activityView removeFromSuperview];
		[activityView release];
		activityView = nil;
	}
    [super dealloc];
}


-(void)loadSettings {
	// reload settings
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"settings.ser"];
	NSMutableArray *settings;
	settings = [NSArray arrayWithContentsOfFile:filePath];
	
	float mult = 1;
	NSString *txt = @"";
	if (settings.count>0) [settings objectAtIndex:0];
	if ([txt compare:@"0.5x"] == NSOrderedSame) { mult = 0.5;  }
	if ([txt compare:@"1x"] == NSOrderedSame) { mult = 1.0;  }
	if ([txt compare:@"2x"] == NSOrderedSame) { mult = 2.0;  }
	
	reswidth=320 * mult;
	resheight=480 * mult;
		
}

-(void)doDoneButton {
	[self finalizeMix];
	[self finishUp];
	[self dismissModalViewControllerAnimated:YES];	
}

-(void)doCancelButton {
	[self finishUp];
	[self dismissModalViewControllerAnimated:YES];	
}

// MIXER STUFF

-(void) finishUp{
	// free data
	if (newItem) [newItem release]; newItem = nil;
	CGColorSpaceRelease(colorSpace);
	free(mixData); mixData  = nil;
	free(curBitmapData); curBitmapData = nil;
	CGContextRelease(cgctx);
	if (transformer) [transformer release]; transformer = nil;
	if (faceCount) free(faceCount); faceCount = nil;
}

-(void)finalizeMix{
	
    // filter data
    for(int q=0;q<reswidth*resheight; q++){
		for (int c=0;c<3;c++)  mixData[q*3+c] /= mixCnt_;
    }
	
	// apply contrast stretching
	float value = 0;
	float min = 256;
	float max = 0;
    for(int q=0;q<reswidth*resheight; q++){
		value = sqrt(mixData[q*3+0]*mixData[q*3+0]+ mixData[q*3+1]*mixData[q*3+1]+ mixData[q*3+2]*mixData[q*3+2])/sqrt(3);
		if (value < min) min = value;
		if (value > max) max = value;
	}
	// check if we're not overdoing our stretching
	int overcount = 0;
	for(int q=0;q<reswidth*resheight; q++){
		for (int c=0;c<3;c++){
			if ( (mixData[q*3+c]-min) * 256/(max-min) > 255) overcount++;
		}
	}
	
	if ((float)overcount / (reswidth*resheight*3.0) > 0.01){
		// if so apply more conersvative stretching
		max = 0;
		for(int q=0;q<reswidth*resheight; q++){
			for(int c=0;c<3;c++){
				value = mixData[q*3+c];
				if (value > max) max = value;
			}
		}
	}
	
	for(int q=0;q<reswidth*resheight; q++){
		for (int c=0;c<3;c++){
			mixData[q*3+c] = (mixData[q*3+c]-min) * 256/(max-min);
			if (mixData[q*3+c]<0) mixData[q*3+c] = 0;
			if (mixData[q*3+c]>255) mixData[q*3+c] = 255;
		}
	}
	
    // clear buffer
	//    free(curBitmapData);
	//    curBitmapData = malloc( reswidth*resheight*4 );
    
    // copy from big buffer to output buffer
    for(int q=0;q<reswidth*resheight; q++){
        int Rbyte = mixData[q*3];
        int Gbyte = mixData[q*3+1];
        int Bbyte = mixData[q*3+2];
        curBitmapData[q*4] = (char)Rbyte;
        curBitmapData[q*4+1] = (char)Gbyte;
        curBitmapData[q*4+2] = (char)Bbyte;
    }        
    // output result
	
    CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
	result = [UIImage imageWithCGImage:imgRef];
    [imageView setImage:result];
    //save result to disk
    NSData *pngimage = UIImagePNGRepresentation(result);
	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:newItem.imageName];
	
    [pngimage writeToFile:filePath atomically:YES];
	
	CGImageRelease(imgRef);	
	
	[IconMaker makeIconItem:newItem];
	
	[appDelegate.galleryDatabaseDelegate saveImage:newItem];
}


-(void)mixPrepare {
	[self loadSettings];
	    
    // prepare object
    newItem = [[GalleryItem alloc] init];
    [newItem setUniqueId: (arc4random() % 20000) + 1];
    [newItem setImageName: [NSString stringWithFormat:@"gallery_%d.png", [newItem uniqueId]]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* currentDate = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString* currentTime = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    [newItem setTitle:[NSString stringWithFormat:@"%@ (%@)", currentDate, currentTime] ];
    [newItem setMethod:[NSString stringWithFormat:NSLocalizedString(@"BlendingXFacesKey",@""), appDelegate.faceDatabaseDelegate.faces.count] ];
    [newItem setDescription:NSLocalizedString(@"OneByOneKey",@"")]; //needlocal
	
}

-(void)firstMix:(Face *)face{
	
    // start mixing
    transformer = [[Transformer alloc] init];
	// find correct ending points
	float AB = 0;
	float AC = 0;
	float theta = 0;
	
        CGPoint P0 = [face getPoint:0];
        CGPoint P1 = [face getPoint:1];
        CGPoint P2 = [face getPoint:2];
		
		NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
		UIImage *curFaceImg = [[UIImage alloc] initWithContentsOfFile:filePath];
		// continue if image is corrupt
		if (!curFaceImg) {
			return;
		}
		float resheight2 = curFaceImg.size.height/curFaceImg.size.width * reswidth;
		[curFaceImg release];
		
		float dAB = sqrt( (P1.x-P0.x)*(P1.x-P0.x)*reswidth*reswidth + (P1.y-P0.y)*(P1.y-P0.y)*resheight2*resheight2);
		float dAC = sqrt( (P2.x-P0.x)*(P2.x-P0.x)*reswidth*reswidth + (P2.y-P0.y)*(P2.y-P0.y)*resheight2*resheight2);
		
        AB += dAB;
        AC += dAC;
		
		theta += acos( ( (P1.x-P0.x)*(P2.x-P0.x)*reswidth*reswidth +  (P1.y-P0.y)*(P2.y-P0.y)*resheight2*resheight2)/dAB/dAC);
	
	// autoresize images
	float ABn = 0.3*reswidth;
	float ACn = AC* ABn/AB;
	
	float dy = 0.4 * resheight;
	if(2*ACn*sin(theta) > dy){
		ACn = dy/(2*sin(theta));
		ABn = AB * ACn/AC;
	}
	
    CGPoint b0 = CGPointMake((reswidth - ABn)/2,0.45*resheight);
    CGPoint b1= CGPointMake((reswidth + ABn)/2,0.45*resheight);
	CGPoint b2 = CGPointMake(b0.x + ACn*cos(theta), b0.y + ACn*sin(theta) );
	
	CGPoint c0 = CGPointMake(b0.x/reswidth,b0.y/resheight);
    CGPoint c1= CGPointMake(b1.x/reswidth,b1.y/resheight);
	CGPoint c2 = CGPointMake(b2.x/reswidth,b2.y/resheight);
	
	[newItem setPoint:c0 at:0];
	[newItem setPoint:c1 at:1];
	[newItem setPoint:c2 at:2];
	
    [transformer setDestPointsP0x: b0.x P0y: b0.y P1x: b1.x P1y: b1.y P2x: b2.x P2y: b2.y];
	
    // set memory allocation
    mixData = malloc( reswidth*resheight*sizeof(float)*3 );
    curBitmapData = malloc( reswidth*resheight*4 );
	
	// then flip and transform
    colorSpace = CGColorSpaceCreateDeviceRGB();                       
	
	cgctx = CGBitmapContextCreate( curBitmapData,
								  reswidth,
								  resheight,
								  8,
								  reswidth*4,
								  colorSpace,
								  kCGImageAlphaNoneSkipLast);

	[self doMix:face];
	
}

-(void)doMix:(Face *)face {
    //mixCnt_++;
	mixCnt_ += timesToBlend;
	
	CGPoint p0 = [face getPoint:0];
    CGPoint p1 = [face getPoint:1];
    CGPoint p2 = [face getPoint:2];
	
	NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
//	UIImage *curFaceImg = [[UIImage alloc] initWithContentsOfFile:filePath];
	UIImage *oldImage = [[UIImage alloc] initWithContentsOfFile:filePath];

	unsigned char *fileBitmap = malloc( oldImage.size.width*oldImage.size.height*4 );
	
	// then flip and transform
	CGContextRef ictx = CGBitmapContextCreate( fileBitmap,
								  oldImage.size.width,
								  oldImage.size.height,
								  8,
								  oldImage.size.width*4,
								  colorSpace,
								  kCGImageAlphaNoneSkipLast);
	
	CGContextDrawImage( ictx, CGRectMake(0,0,oldImage.size.width,oldImage.size.height), [oldImage CGImage]);
	
	CGPoint center = CGPointMake( (p0.x+p1.x)/2.0 *oldImage.size.width, (p0.y+p1.y)/2.0 *oldImage.size.height);
	float radius = 100;
	float b = 1.5*sqrt((p1.x-p0.x)*(p1.x-p0.x)*oldImage.size.width*oldImage.size.width + (p1.y-p0.y)*(p1.y-p0.y)*oldImage.size.height*oldImage.size.height);
	float a = 1.0*sqrt((p2.x*oldImage.size.width-center.x)*(p2.x*oldImage.size.width-center.x) + (p2.y*oldImage.size.height-center.y)*(p2.y*oldImage.size.height-center.y));
	
	float col0[3]; col0[0] = (float) fileBitmap[0]; col0[1] = (float)fileBitmap[1]; col0[2] = (float)fileBitmap[2]; 
	float factor;
	float colradius;
	float buf=0.05*oldImage.size.width;

	for(int x=0;x<oldImage.size.width;x++){
		for(int y=0;y<oldImage.size.height;y++){
			radius = (center.x-x)*(center.x-x)/a/a + (center.y-y)*(center.y-y)/b/b;
			factor = 1;
//			if ( radius < 1) factor = 1;
//			else factor = 1/radius/radius;
			
			if (x<buf) factor *= x*x/buf/buf;
			if (y<buf) factor *= y*y/buf/buf;
			if (oldImage.size.width-x<buf) factor *= (oldImage.size.width-x)*(oldImage.size.width-x)/buf/buf;
			if (oldImage.size.height-y<buf) factor *= (oldImage.size.height-y)*(oldImage.size.height-y)/buf/buf;
			
			colradius = sqrt((col0[0]-fileBitmap[(y*(int)oldImage.size.width+x) *4])*(col0[0]-fileBitmap[(y*(int)oldImage.size.width+x) *4])+
						(col0[1]-fileBitmap[(y*(int)oldImage.size.width+x) *4+1])*(col0[1]-fileBitmap[(y*(int)oldImage.size.width+x) *4+1])+
						(col0[2]-fileBitmap[(y*(int)oldImage.size.width+x) *4+2])*(col0[2]-fileBitmap[(y*(int)oldImage.size.width+x) *4+2]));
	/*		
			if (colradius<100){
				if (x==0 || y==0 
					|| ((x<oldImage.size.width) && fileBitmap[(y*(int)oldImage.size.width+x+1) *4+3]==1) 
					|| ((y<oldImage.size.height) && fileBitmap[((y+1)*(int)oldImage.size.width+x) *4+3]==1) 
					|| ((x>0) && fileBitmap[(y*(int)oldImage.size.width+x-1) *4+3]==1) 
					|| ((y>0) && fileBitmap[((y-1)*(int)oldImage.size.width+x-1) *4+3]==1)){
				factor*=colradius/100;
				fileBitmap[(y*(int)oldImage.size.width+x) *4+3] = 1;
				}
			}
	*/		
			fileBitmap[(y*(int)oldImage.size.width+x) *4] *= factor;
			fileBitmap[(y*(int)oldImage.size.width+x) *4+1] *= factor;
			fileBitmap[(y*(int)oldImage.size.width+x) *4+2] *= factor;
			
		}
	}
	
	
	CGImageRef imgRefo = CGBitmapContextCreateImage(ictx);
	//UIImage *curFaceImg = [[UIImage alloc] initWithCGImage:imgRefo];
	CGImageRef leftSideRef = CGImageCreateWithImageInRect(imgRefo, CGRectMake(0,0,100,oldImage.size.height));
	UIImage *curFaceImg = [[UIImage alloc] initWithCGImage:leftSideRef];

	CGImageRelease(imgRefo);
	[oldImage release];

	CGImageRelease(leftSideRef);
	
	
	//	float resheight2 = resheight;// curFaceImg.size.width/curFaceImg.size.height* reswidth; //resheight;
	
	// first resize image
	CGSize sz;
	sz.height = resheight;
	sz.width = reswidth;
	
	// millisleep to prevent context exceptions
	for(int q=0;q<reswidth*resheight; q++){
        curBitmapData[q*4] = 0;
        curBitmapData[q*4+1] = 0;
        curBitmapData[q*4+2] = 0;
    }

	transform = [transformer defineAffineMatrixP0x: p0.x*curFaceImg.size.width P0y:p0.y*curFaceImg.size.height P1x:p1.x*curFaceImg.size.width P1y:p1.y*curFaceImg.size.height P2x:p2.x*curFaceImg.size.width P2y:p2.y*curFaceImg.size.height];
	UIGraphicsBeginImageContext( sz );
	CGContextFlush(UIGraphicsGetCurrentContext());
	CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
	CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationNone);
	CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), NO);
	
	[curFaceImg drawInRect:CGRectMake(0,0,curFaceImg.size.width,curFaceImg.size.height)];
	UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CGContextDrawImage( cgctx, CGRectMake(0,0,reswidth,resheight), [resizedImage CGImage]);

	// copy to big buffer
    for(int q=0;q<reswidth*resheight; q++){		
        mixData[q*3] += timesToBlend * (float)(unsigned char)curBitmapData[q*4];
        mixData[q*3+1] += timesToBlend * (float)(unsigned char)curBitmapData[q*4+1];
        mixData[q*3+2] += timesToBlend * (float)(unsigned char)curBitmapData[q*4+2];
    }
/*
	transform = [transformer defineAffineMatrixP0x: p1.x*curFaceImg.size.width P0y:p1.y*curFaceImg.size.height P1x:p0.x*curFaceImg.size.width P1y:p0.y*curFaceImg.size.height P2x:p2.x*curFaceImg.size.width P2y:p2.y*curFaceImg.size.height];
	UIGraphicsBeginImageContext( sz );
	CGContextFlush(UIGraphicsGetCurrentContext());
	CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
	CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationNone);
	CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), NO);
	
	[curFaceImg drawInRect:CGRectMake(0,0,curFaceImg.size.width,curFaceImg.size.height)];
	UIImage *resizedImage2 = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CGContextDrawImage( cgctx, CGRectMake(0,0,reswidth,resheight), [resizedImage2 CGImage]);
	
	// copy to big buffer
    for(int q=0;q<reswidth*resheight; q++){		
        mixData[q*3] += 0.5*timesToBlend * (float)(unsigned char)curBitmapData[q*4];
        mixData[q*3+1] += 0.5*timesToBlend * (float)(unsigned char)curBitmapData[q*4+1];
        mixData[q*3+2] += 0.5*timesToBlend * (float)(unsigned char)curBitmapData[q*4+2];
    }
*/
	
    // copy from big buffer to output buffer
    for(int q=0;q<reswidth*resheight; q++){
        curBitmapData[q*4] = (char)(int)(mixData[q*3]/(mixCnt_));
        curBitmapData[q*4+1] = (char)(int)(mixData[q*3+1]/(mixCnt_));
        curBitmapData[q*4+2] = (char)(int)(mixData[q*3+2]/(mixCnt_));
    }        
	
	CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
	result = [UIImage imageWithCGImage:imgRef];
	[imageView setImage:result];
	CGImageRelease(imgRef);
	[curFaceImg release];

	[activityView stopAnimating];
	faceToBlend = -1;
	timesToBlend = 0;
	
}

// ICON STUFF
-(void)makeIconSmall:(Face *) face {
	if (face.iconSmall) return;
	
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	NSString *base = @"tmbsm_";
	NSString *tmbName = [base stringByAppendingString:face.imageName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *tmbpath = [face.path stringByAppendingPathComponent:tmbName];
	if ([fileManager fileExistsAtPath:tmbpath]){
		UIImage *icon = [[UIImage alloc] initWithContentsOfFile:tmbpath];
		face.iconSmall = icon;
		[icon release];
	} else {
	}
	
	[tmpPool release];
}

-(void)makeIcon:(Face *) face {
	if (face.icon) return;
	
	NSString *base = @"tmb_";
	NSString *tmbName = [base stringByAppendingString:face.imageName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *tmbpath = [face.path stringByAppendingPathComponent:tmbName];
	if ([fileManager fileExistsAtPath:tmbpath]){
		UIImage *icon = [[UIImage alloc] initWithContentsOfFile:tmbpath];
		face.icon = icon;
		[icon release];
	} 
	
}

-(void) waiter {
	[self doMix:[appDelegate.faceDatabaseDelegate.faces objectAtIndex:faceToBlend]];

}

// TABLE VIEW functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return appDelegate.faceDatabaseDelegate.faces.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

-(UITableViewCell *)reuseTableViewCellWithIdentifier:(NSString *)identifier {
	
	//Rectangle which will be used to create labels and table view cell.
    CGRect cellRectangle;
	
    //Returns a rectangle with the coordinates and dimensions.
    cellRectangle = CGRectMake(0.0, 0.0, 72.5, 72.5);
	
    //Initialize a UITableViewCell with the rectangle we created.
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:cellRectangle reuseIdentifier:identifier] autorelease];
    	
    //Create a rectangle container for the number text.
    cellRectangle = CGRectMake(0,5,80,90);
	
	UIImageView *uiv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,72.5,72.5)];
	[uiv setTag:1];
	[cell.contentView addSubview:uiv];
	[uiv release];
	
	UIButton *badge = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	//[badge setTitle:[NSString stringWithFormat:@"%d",faceCount[indexPath.row]] forState:UIControlStateNormal];
	[badge setFont:[UIFont fontWithName:@"Arial" size:12]];
	[badge setEnabled:NO];
	[badge setUserInteractionEnabled:NO];
	[badge setShowsTouchWhenHighlighted:NO];
	[badge setFrame:CGRectMake(45,2,26,16)];
	[badge setTag:2];
	[cell.contentView addSubview:badge];
		
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GalleryCell";
    
    //Initialize a UITableViewCell with the rectangle we created.    
	UITableViewCell *cell=nil;
	
    if(cell == nil)
        cell = [self reuseTableViewCellWithIdentifier:CellIdentifier];
	
    Face *face =nil;
	if (indexPath.row<appDelegate.faceDatabaseDelegate.faces.count)
		face = (Face *)[appDelegate.faceDatabaseDelegate.faces objectAtIndex: indexPath.row];
	
	if (!face.icon) 
		[self makeIcon:face];
	if (face.icon){
		UIImageView *uiv = (UIImageView *)[cell viewWithTag:1];
		uiv.image = face.icon;
	}
	
	UIButton *butt = (UIButton *)[cell viewWithTag:2];
	if (faceCount[indexPath.row]==0)
		[butt setHidden:YES];
	else {
		[butt setHidden:NO];
		[butt setTitle:[NSString stringWithFormat:@"%d",faceCount[indexPath.row]] forState:UIControlStateNormal];
	}
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	if(indexPath.row<appDelegate.faceDatabaseDelegate.faces.count){
		//imageView.image = [[appDelegate.faceDatabaseDelegate.faces objectAtIndex:indexPath.row] icon];
		
		if (![activityView isAnimating]) [activityView startAnimating];
		
		if (mixCnt_==0){
			timesToBlend = 1;
			faceToBlend = indexPath.row;
			faceCount[ indexPath.row ]++;
			[self firstMix:[appDelegate.faceDatabaseDelegate.faces objectAtIndex:indexPath.row]];
		} else {
			if (faceToBlend==-1 || indexPath.row == faceToBlend){
				timesToBlend++;
				faceToBlend = indexPath.row;
				faceCount[ indexPath.row ]++;

			if (waitTimer){
				if ([waitTimer isValid]) {
					[waitTimer invalidate];
					[waitTimer release];
				}
			}
			waitTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(waiter) userInfo:nil repeats:NO] retain];
			}
		}
		
		[tableView reloadData];
	}

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return nil;
}




@end
