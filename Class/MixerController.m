//
//  MixerController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/20/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//
#import "MixerController.h"
#import <QuartzCore/QuartzCore.h>
#import "math.h"

@implementation MixerController
@synthesize imageView,appDelegate,mode,toggles,newItem,progressView;
@synthesize selectorView,traitLogicView, navBar, navItem, leftButton;
@synthesize transformer, curFaceImg, mixData, curBitmapData, mixTimer;
@synthesize transform, colorSpace, cgctx, mix_,mixMax_,mixCnt_,usedSelector,usedTraitLogic;
@synthesize reswidth,resheight, doAura, tipView,showTips;
@synthesize sx,sy,inputNodes,kohonenNodes,pool, result,workThread,time,isDone,traitPoller;
@synthesize startDate,cancelButton;

/*
 // Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
 	
    navBar.hidden = YES;
	leftButton.enabled = NO;
	
	[progressView setProgress:(float)0];
	
	usedTraitLogic = NO;
	usedSelector = NO;
	
	tipView = [[UITextView alloc] initWithFrame:CGRectMake(10,360,300,90)]; 
	[self.view addSubview:tipView];
	[tipView setFont:[UIFont fontWithName:@"Verdana" size:14]];
	[tipView setTextColor:[UIColor whiteColor]];
	[tipView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
	
	[cancelButton setTitle:NSLocalizedString(@"CancelKey",@"") forState: UIControlStateNormal];
	
	elapsed1 =0;
	elapsed2 =0;
	elapsed3 =0;
	elapsed4 =0;
	elapsed5 =0;
}

-(void)viewWillDisappear {
}

-(void)setRandomTip {
	
	int tipid = (arc4random() % 12);
	
	NSString *tip;
	switch(tipid){
		case 0:
			tip = NSLocalizedString(@"Tip1Key",@"");
			break;
		case 1:
			tip = NSLocalizedString(@"Tip2Key",@"");
			break;
		case 2:
			tip = NSLocalizedString(@"Tip3Key",@"");
			break;
		case 3:
			tip = NSLocalizedString(@"Tip4Key",@"");
			break;
		case 4:
			tip = NSLocalizedString(@"Tip5Key",@"");
			break;
		case 5:
			tip = NSLocalizedString(@"Tip6Key",@"");
			break;
		case 6:
			tip = NSLocalizedString(@"Tip7Key",@"");
			break;
		case 7:
			tip = NSLocalizedString(@"Tip8Key",@"");
			break;
		case 8:
			tip = NSLocalizedString(@"Tip9Key",@"");
			break;
		case 9:
			tip = NSLocalizedString(@"Tip10Key",@"");
			break;
		case 10:
			tip = NSLocalizedString(@"Tip11Key",@"");
			break;
		case 11:
			tip = NSLocalizedString(@"Tip12Key",@"");
			break;
		default:
			tip = NSLocalizedString(@"TipDefKey",@"");
			break;
	}
	
	[tipView setText:tip];
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
	
	NSString *tips = @"";
	if (settings.count>1) [settings objectAtIndex:1];
	if ([tips compare:@"YES"] == NSOrderedSame) showTips = YES; else showTips = NO;
	
}

-(void)viewWillAppear {	
    navBar.hidden = YES;
	leftButton.enabled = YES;
	
	if(traitLogicView && traitLogicView.isDone) [self doneSelection];
	if(usedTraitLogic) [self doneSelection];
	
}


-(IBAction)exitButton {
	if (workThread && workThread.isExecuting) [workThread cancel];
	else [self dismiss];
}


-(void)mixAll {
	[self loadSettings];
	
	// if no faces then treat as cancel
	if (appDelegate.faceDatabaseDelegate.faces.count == 0){
		[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
		return;
	}
	
    // set all toggles to true
    toggles = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
    for(int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
		toggles[c] = YES;
    }
    
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
    [newItem setDescription:NSLocalizedString(@"AllFacesKey",@"")];
	
	startDate = [[NSDate alloc] init];
	if (showTips){
		[self setRandomTip];
	} else [tipView setHidden:YES];
	
    mixMax_ = appDelegate.faceDatabaseDelegate.faces.count;
	if (workThread) [workThread release];	
	workThread = [[NSThread alloc] initWithTarget:self selector:@selector(prepareMix) object:nil];
	[workThread start];
}

-(void)mixSelection {
    if(self.selectorView == nil){
        FaceSelectorViewController *viewController = [[FaceSelectorViewController alloc] initWithNibName:@"FaceSelectorViewController" bundle:[NSBundle mainBundle]];
        self.selectorView = viewController;
        [viewController release];
    }
    [self.selectorView.view setCenter:CGPointMake(160,280)];
    [navBar.topItem setTitle:[NSString stringWithFormat: NSLocalizedString(@"FaceXSelectionKey",@""),0]];
	self.selectorView.navItem = navBar.topItem;
	
    navBar.hidden = NO;
    [self.view addSubview:self.selectorView.view];
    usedSelector = YES;
	
}

-(void)doneSelection { 
	[self loadSettings];
	
	if( usedSelector ){
		int total = 0;
		NSMutableString *nameslist = [NSMutableString stringWithString:@""];
		// set all toggles to true
		toggles = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
		for(int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
			toggles[c] = selectorView.toggles[c];
			if (toggles[c]){
				total++;
				Face *face = nil;
				if (appDelegate.faceDatabaseDelegate.faces.count>c)
					face = [appDelegate.faceDatabaseDelegate.faces objectAtIndex:c];
				if (face){
					if (total>1) [nameslist appendString:@", "];
					[nameslist appendString:face.name];
				}
			}
		}
		
		if (self.selectorView){
			[self.selectorView viewWillDisappear:YES];
			[self.selectorView.view removeFromSuperview];
			[self.selectorView release]; selectorView = nil;
		}
		navBar.hidden = YES;
		leftButton.enabled = YES;
		
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
		[newItem setMethod:[NSString stringWithFormat:NSLocalizedString(@"BlendingXSelectionKey",@""), total] ];
		[newItem setDescription:nameslist];
		
		startDate = [[NSDate alloc] init];
		if (showTips){
			[self setRandomTip];
		} else [tipView setHidden:YES];
		
		mixMax_ = total;
		if (workThread) [workThread release];	
		workThread = [[NSThread alloc] initWithTarget:self selector:@selector(prepareMix) object:nil];
		[workThread start];
		
    }
    else {
		int total = 0;
		NSMutableString *nameslist = traitLogicView.logicString;
		// set all toggles to true
		toggles = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
		for(int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
			toggles[c] = traitLogicView.toggles[c];
			if (toggles[c]){
				total++;
			}
		}
		
		[self.traitLogicView.view removeFromSuperview];
//		[self.traitLogicView release];
//		self.traitLogicView = nil;
		navBar.hidden = YES;
		
		
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
		[newItem setMethod:[NSString stringWithFormat:NSLocalizedString(@"BlendingXTraitKey",@""), total] ];
		[newItem setDescription:nameslist];
		
		startDate = [[NSDate alloc] init];
		if (showTips){
			[self setRandomTip];
		//	tipTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:tipView selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
		} else [tipView setHidden:YES];
		
		mixMax_ = total;
		if (workThread) [workThread release];	
		workThread = [[NSThread alloc] initWithTarget:self selector:@selector(prepareMix) object:nil];
		[workThread start];
    }
}

-(void)mixTraitLogic {
    if(self.selectorView == nil){
        TraitLogicViewController *viewController = [[TraitLogicViewController alloc] initWithNibName:@"TraitLogicViewController" bundle:[NSBundle mainBundle]];
        self.traitLogicView = viewController;
        [viewController release];
    }
	//    [self.traitLogicView.view setCenter:CGPointMake(160,280)];
    [navBar.topItem setTitle:NSLocalizedString(@"SelectTraitKey",@"")];
    navBar.hidden = NO;
	
    [self.view addSubview:self.traitLogicView.view];

    [self.traitLogicView startLogic];
    usedSelector = NO;
	usedTraitLogic = YES;
	
	traitPoller = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(pollTraitDone) userInfo:nil repeats:YES];
	
}

-(void) pollTraitDone {
	if (self.traitLogicView.isDone){
		[traitPoller invalidate];
		[self doneSelection];
	}
}

-(void)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)CANCELbutton {
	if (workThread){
		[workThread cancel];
	}
	while ([workThread isExecuting]) {
	};
	[self dismissModalViewControllerAnimated:YES];
}

-(void)removeTipView {
	[tipView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
}

-(void)prepareMix{
	pool = [[NSAutoreleasePool alloc] init];
	
    // start mixing
    transformer = [[Transformer alloc] init];
	// find correct ending points
    int icnt = 0;
	int fcnt = 0;
	float AB = 0;
	float AC = 0;
	float theta = 0;
	BOOL isQuit = NO;
	
    for (Face *face in appDelegate.faceDatabaseDelegate.faces){
		if(toggles[fcnt++]==NO) continue;
		
		icnt++;
        CGPoint P0 = [face getPoint:0];
        CGPoint P1 = [face getPoint:1];
        CGPoint P2 = [face getPoint:2];
		
		NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];

		curFaceImg = [[UIImage alloc] initWithContentsOfFile:filePath];
		// continue if image is corrupt
		if (!curFaceImg) {
			icnt--;
			continue;
		}
		float resheight2 = curFaceImg.size.height/curFaceImg.size.width * reswidth;
		[curFaceImg release];
		
		float dAB = sqrt( (P1.x-P0.x)*(P1.x-P0.x)*reswidth*reswidth + (P1.y-P0.y)*(P1.y-P0.y)*resheight2*resheight2);
		float dAC = sqrt( (P2.x-P0.x)*(P2.x-P0.x)*reswidth*reswidth + (P2.y-P0.y)*(P2.y-P0.y)*resheight2*resheight2);
		
        AB += dAB;
        AC += dAC;
		
		theta += acos( ( (P1.x-P0.x)*(P2.x-P0.x)*reswidth*reswidth +  (P1.y-P0.y)*(P2.y-P0.y)*resheight2*resheight2)/dAB/dAC);
		
    }
	
	if (icnt == 0){
		[self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
		return;
	}
	
	AB /= (float)icnt;
	AC /= (float)icnt;
	theta /= (float)icnt;
	
	
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
	mix_ = -1; mixCnt_ = -1;
	for (int q=0;q<appDelegate.faceDatabaseDelegate.faces.count;q++)
		if ([[NSThread currentThread] isCancelled]){
			isQuit = YES;
			break;
		} else [self doMix];
		
	if (!isQuit) [self finalizeMix];
	[self finishUp];
	[self dismiss];
	[pool release];
}

-(void)doMix {
	uint64_t        start1;
    uint64_t        end1;
	uint64_t        start2;
    uint64_t        end2;
	uint64_t        start3;
    uint64_t        end3;
	uint64_t        start4;
    uint64_t        end4;
	uint64_t        start5;
    uint64_t        end5;
	
	
    mix_++;
    if(toggles[mix_]==NO) return;
    mixCnt_++;
	
	//usleep(1e6/50);
	
	Face *face = nil;
	if (appDelegate.faceDatabaseDelegate.faces.count>mix_)
		face = [appDelegate.faceDatabaseDelegate.faces objectAtIndex:mix_];
	if(!face) return;
	
	NSAutoreleasePool *mixPool = [[NSAutoreleasePool alloc] init];

//	start1 = mach_absolute_time();
	
	NSString *filePath = [face.path stringByAppendingPathComponent:face.imageName];
	curFaceImg = [[UIImage alloc] initWithContentsOfFile:filePath];
/*	UIImage *oldImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	CGRect area = CGRectMake(0, 0, oldImage.size.width, oldImage.size.height);
	CGSize size = area.size;
	UIGraphicsBeginImageContext(size);
	[oldImage drawInRect:area];
	curFaceImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[oldImage release];
*/
/*	CGImageRef imgref = [curFaceImg CGImage];
	CGColorSpaceRef cs = CGImageGetColorSpace(imgref);
	CGBitmapInfo bi = CGImageGetBitmapInfo(imgref);
	if (cs == kCGColorSpaceModelRGB) NSLog(@"RGB");
	if (bi ==  kCGBitmapByteOrder16Big) NSLog(@"16big");
*/	
//	end1 = mach_absolute_time();
	
    CGPoint p0 = [face getPoint:0];
    CGPoint p1 = [face getPoint:1];
    CGPoint p2 = [face getPoint:2];
	//	float resheight2 = resheight;// curFaceImg.size.width/curFaceImg.size.height* reswidth; //resheight;
	transform = [transformer defineAffineMatrixP0x: p0.x*curFaceImg.size.width P0y:p0.y*curFaceImg.size.height P1x:p1.x*curFaceImg.size.width P1y:p1.y*curFaceImg.size.height P2x:p2.x*curFaceImg.size.width P2y:p2.y*curFaceImg.size.height];
	
	// first resize image
	CGSize sz;
	sz.height = resheight;
	sz.width = reswidth;
	
	// millisleep to prevent context exceptions
	UIGraphicsBeginImageContext( sz );
	CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
	CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationNone);
	CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), NO);

	start2 = mach_absolute_time();	
	[curFaceImg drawInRect:CGRectMake(0,0,curFaceImg.size.width,curFaceImg.size.height)];
	end2 = mach_absolute_time();

//	start4 = mach_absolute_time();
	UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
//	end4 = mach_absolute_time();
	
//	start3 = mach_absolute_time();

	for(int q=0;q<reswidth*resheight; q++){
        curBitmapData[q*4] = 0;
        curBitmapData[q*4+1] = 0;
        curBitmapData[q*4+2] = 0;
    }
	
	//CGContextSetAlpha(cgctx,1./(mixMax_+1));
	//CGContextSetBlendMode(cgctx, kCGBlendModeCopy);
	CGContextDrawImage( cgctx, CGRectMake(0,0,reswidth,resheight), [resizedImage CGImage]);
	[curFaceImg release];
//	end3 = mach_absolute_time();

//	start4 = mach_absolute_time();
/*
	// apply contrast stretching
	float value = 0;
	float min = 256;
	float max = 0;
    for(int q=0;q<reswidth*resheight; q++){
		value = sqrt( (float)(unsigned char)curBitmapData[q*4+0]* (float)(unsigned char)curBitmapData[q*4+0]+  (float)(unsigned char)curBitmapData[q*4+1]* (float)(unsigned char)curBitmapData[q*4+1]+ (float)(unsigned char) curBitmapData[q*4+2]* (float)(unsigned char)curBitmapData[q*4+2])/sqrt(3);
		if (value < min) min = value;
		if (value > max) max = value;
	}
	// check if we're not overdoing our stretching
	int overcount = 0;
	for(int q=0;q<reswidth*resheight; q++){
		for (int c=0;c<3;c++){
			if ( ((float)(unsigned char)curBitmapData[q*4+c]-min) * 256/(max-min) > 255) overcount++;
		}
	}
	
	if ((float)overcount / (reswidth*resheight*3.0) > 0.01){
		// if so apply more conersvative stretching
		max = 0;
		for(int q=0;q<reswidth*resheight; q++){
			for(int c=0;c<3;c++){
				value = (float)(unsigned char)curBitmapData[q*4+c];
				if (value > max) max = value;
			}
		}
	}
	
	float tmpValue = 0;
	for(int q=0;q<reswidth*resheight; q++){
		for (int c=0;c<3;c++){
			tmpValue = ( (float)(unsigned char)curBitmapData[q*4+c]-min) * 256/(max-min);
			if (tmpValue<0) curBitmapData[q*4+c] = 0;
			else if (tmpValue>255) curBitmapData[q*4+c] = 255;
			else curBitmapData[q*4+c] = tmpValue;
		}
	}
	*/
//	end4 = mach_absolute_time();
//	start4= 0; end4=0;	
//	start5 = mach_absolute_time();
	
	// copy to big buffer
    for(int q=0;q<reswidth*resheight; q++){		
        mixData[q*3] += (float)(unsigned char)curBitmapData[q*4];
        mixData[q*3+1] += (float)(unsigned char)curBitmapData[q*4+1];
        mixData[q*3+2] += (float)(unsigned char)curBitmapData[q*4+2];
    }	
    // copy from big buffer to output buffer
    for(int q=0;q<reswidth*resheight; q++){
        curBitmapData[q*4] = (char)(int)(mixData[q*3]/(mixCnt_+1));
        curBitmapData[q*4+1] = (char)(int)(mixData[q*3+1]/(mixCnt_+1));
        curBitmapData[q*4+2] = (char)(int)(mixData[q*3+2]/(mixCnt_+1));
    }
	
    // copy from big buffer to output buffer
    //for(int q=0;q<reswidth*resheight; q++){
    //    if (curBitmapData[q*4] != 0) NSLog(@"not nil");
    //}
	elapsed2 += (end2-start2);
	
/*	end5 = mach_absolute_time();	
	elapsed1 += (end1-start1);
	elapsed3 += (end3-start3);
	elapsed4 += (end4-start4);
	elapsed5 += (end5-start5);
//	NSLog([NSString stringWithFormat:@"%lld %lld %lld %lld %lld",end1-start1,end2-start2,end3-start3,end4-start4,end5-start5]);
//	NSLog([NSString stringWithFormat:@"avg = %ld %ld %ld %ld %ld",(long)elapsed1,(long)elapsed2,(long)elapsed3,(long)elapsed4,(long)elapsed5]);
*/	if (mixCnt_ == mixMax_-1){
//		long long total = (elapsed1+elapsed2+elapsed3+elapsed4+elapsed5);
//		NSLog([NSString stringWithFormat:@"avg = %lld %lld %lld %lld %lld %lld",elapsed1,elapsed2,elapsed3,elapsed4,elapsed5, total]);
//		long long a1 = (100*elapsed1) / total;
//		long long a2 = (100*elapsed2) / total;
//		long long a3 = (100*elapsed3) / total;
//		long long a4 = (100*elapsed4) / total;
//		long long a5 = (100*elapsed5) / total;
//		NSLog([NSString stringWithFormat:@"avg = %lld %lld %lld %lld %lld",a1,a2,a3,a4,a5]);
//		NSLog([NSString stringWithFormat:@"total: %lld", (elapsed1+elapsed2+elapsed3+elapsed4+elapsed5)/100000]);
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"total: %lld", (elapsed1+elapsed2+elapsed3+elapsed4+elapsed5)/1000000] 
//														message:[NSString stringWithFormat:@"avg = %lld %lld %lld %lld %lld",a1,a2,a3,a4,a5] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"total: %lld", (elapsed2)/1000000] 
message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
	
	[mixPool release];
	
}

-(void)finalizeMix{
    float x,y;
	float dx,dy,fx,fy; 
	
    // filter data
    //for(int q=0;q<reswidth*resheight; q++){
	//	for (int c=0;c<3;c++)  mixData[q*3+c] /= mixMax_;
    //}
	
	for(int q=0;q<reswidth*resheight; q++){		
        mixData[q*3] = (float)(unsigned char)curBitmapData[q*4];
        mixData[q*3+1] = (float)(unsigned char)curBitmapData[q*4+1];
        mixData[q*3+2] = (float)(unsigned char)curBitmapData[q*4+2];
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
	
	// apply aura
	if (doAura)
		for(int q=0;q<reswidth*resheight; q++){
			// apply black glow
			y = floor(q /reswidth);
			x = q%reswidth;
			
			dx = (abs(x-reswidth/2))/(float)reswidth;
			if (dx<0.35) fx = 1; else fx = 1- (dx-0.35)/(0.5-0.35);
			dy = (abs(y-resheight/2))/(float)resheight;
			if (dy<0.35) fy = 1; else fy = 1- (dy-0.35)/(0.5-0.35);
			for (int c=0;c<3;c++)  mixData[q*3+c] *= fx*fy;
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


-(void) finishUp{
	// free data
	[newItem release]; newItem = nil;
	CGColorSpaceRelease(colorSpace);
	free(toggles); toggles = nil;
	free(mixData); mixData  = nil;
	free(curBitmapData); curBitmapData = nil;
	CGContextRelease(cgctx);
	[transformer release]; transformer = nil;
}

-(void) updateView {
	CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
	result = [UIImage imageWithCGImage:imgRef];
	[imageView setImage:result];
	CGImageRelease(imgRef);
	
	[progressView setProgress:(float)(mixCnt_+1)/(float)mixMax_];
	
	NSDate *nowDate = [[NSDate alloc] init];
	NSTimeInterval ival = [nowDate timeIntervalSinceDate:startDate];
	[nowDate release];
	
	if (ival>10 && !tipView.hidden) [tipView setHidden:YES];
	
}

/*
 -(void)prepareKohonen {
 //pool = [[NSAutoreleasePool alloc] init];
 
 reswidth = 80;
 resheight = 120;
 int inodes = appDelegate.faceDatabaseDelegate.faces.count;
 // make input nodes
 // reserve memory
 inputNodes = malloc(reswidth*resheight*inodes * 4);
 
 // make the input nodes
 int BPC = 8;
 
 // then flip and transform
 colorSpace = CGColorSpaceCreateDeviceRGB();                       
 
 // start mixing
 transformer = [Transformer alloc];
 // find correct ending points
 int icnt = 0;
 int fcnt = 0;
 float AB = 0;
 float AC = 0;
 float theta = 0;
 
 for (Face *face in appDelegate.faceDatabaseDelegate.faces){
 if(toggles[fcnt++]==NO) continue;
 
 icnt++;
 CGPoint P0 = [face getPoint:0];
 CGPoint P1 = [face getPoint:1];
 CGPoint P2 = [face getPoint:2];
 
 Face *face = [appDelegate.faceDatabaseDelegate.faces objectAtIndex:mix_];
 NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:face.imageName];
 
 curFaceImg = [UIImage imageWithContentsOfFile:filePath];
 float resheight2 = curFaceImg.size.width/curFaceImg.size.height*resheight;
 
 float dAB = sqrt( (P1.x-P0.x)*(P1.x-P0.x)*reswidth*reswidth + (P1.y-P0.y)*(P1.y-P0.y)*resheight2*resheight2);
 float dAC = sqrt( (P2.x-P0.x)*(P2.x-P0.x)*reswidth*reswidth + (P2.y-P0.y)*(P2.y-P0.y)*resheight2*resheight2);
 
 AB += dAB;
 AC += dAC;
 
 theta += acos( ( (P1.x-P0.x)*(P2.x-P0.x)*reswidth*reswidth +  (P1.y-P0.y)*(P2.y-P0.y)*resheight2*resheight2)/dAB/dAC);
 }
 
 // if no faces then treat as cancel
 if (icnt == 0){
 [self dismissModalViewControllerAnimated:YES];
 return;
 }
 
 AB /= (float)icnt;
 AC /= (float)icnt;
 theta /= (float)icnt;
 
 CGPoint b0 = CGPointMake((reswidth - AB)/2,0.48*resheight);
 CGPoint b1= CGPointMake((reswidth + AB)/2,0.48*resheight);
 CGPoint b2 = CGPointMake(b0.x + AC*cos(theta), b0.y + AC*sin(theta) );
 
 [transformer setDestPointsP0x: b0.x P0y: b0.y P1x: b1.x P1y: b1.y P2x: b2.x P2y: b2.y];
 
 
 //transformer = [Transformer alloc];
 mixCnt_ = -1; mixMax_ = inodes;
 mix_ = -1;
 for (Face *face in appDelegate.faceDatabaseDelegate.faces){
 //	NSAutoreleasePool *initPool = [[NSAutoreleasePool alloc] init];
 
 mixCnt_++; mix_++;
 Face *face = [appDelegate.faceDatabaseDelegate.faces objectAtIndex:mix_];
 NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:face.imageName];
 
 curFaceImg = [UIImage imageWithContentsOfFile:filePath];
 
 CGPoint p0 = [face getPoint:0];
 CGPoint p1 = [face getPoint:1];
 CGPoint p2 = [face getPoint:2];
 transform = [transformer defineAffineMatrixP0x: p0.x*reswidth P0y:p0.y*resheight P1x:p1.x*reswidth P1y:p1.y*resheight P2x:p2.x*reswidth P2y:p2.y*resheight];
 
 curBitmapData = malloc(reswidth*resheight*4);
 for(int q=0;q<reswidth*resheight*4; q++) curBitmapData[q]=0;
 
 cgctx = CGBitmapContextCreate( curBitmapData,
 reswidth,
 resheight,
 BPC,
 reswidth*4,
 colorSpace,
 kCGImageAlphaNoneSkipLast);
 
 // first resize image
 CGSize sz;
 sz.height = resheight;
 sz.width = reswidth;
 
 UIGraphicsBeginImageContext( sz );
 CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
 CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1,-1);
 CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0,-resheight);
 CGContextDrawImage( UIGraphicsGetCurrentContext() , CGRectMake(0,0,reswidth,resheight), [curFaceImg CGImage]);
 UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 
 CGContextDrawImage( cgctx, CGRectMake(0,0,reswidth,resheight), [resizedImage CGImage]);
 
 // copy to input buffer
 int offset = reswidth*resheight*4 *mixCnt_;
 for(int q=0;q<reswidth*resheight; q++){		
 inputNodes[offset + q*4] = (unsigned char)curBitmapData[q*4];
 inputNodes[offset + q*4+1] = (unsigned char)curBitmapData[q*4+1];
 inputNodes[offset + q*4+2] = (unsigned char)curBitmapData[q*4+2];
 }
 
 result = resizedImage;
 
 [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
 
 free(curBitmapData);
 
 //	[initPool release];
 }
 
 result = nil;
 [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
 
 // make nodenetwork
 sx = 10;
 sy = 6;
 int knodes = sx*sy;
 kohonenNodes = malloc(sx*sy* reswidth*resheight*sizeof(float)*3);
 
 // initialize nodes with input pictures
 for (int n=0;n<knodes;n++){
 int offset = reswidth*resheight*4* n;
 int offsetk = reswidth*resheight*3* n;
 
 for(int q=0;q<reswidth*resheight; q++){		
 kohonenNodes[offsetk + q*3] = (float)(unsigned char)inputNodes[offset + q*4];
 kohonenNodes[offsetk + q*3+1] = (float)(unsigned char)inputNodes[offset + q*4+1];
 kohonenNodes[offsetk + q*3+2] = (float)(unsigned char)inputNodes[offset + q*4+2];
 }
 }
 
 char *outputData = malloc( reswidth*resheight*4*knodes );
 
 // then flip and transform
 CGContextRef outctx = CGBitmapContextCreate( outputData,
 reswidth*sx,
 resheight*sy,
 BPC,
 reswidth*4*sx,
 colorSpace,
 kCGImageAlphaNoneSkipLast);
 
 for (int n=0;n<knodes;n++){
 int offsetk = reswidth*resheight*n;
 int offset = (int)(n%sx) * reswidth + (int)(n/sx)*reswidth*sx*resheight;
 for(int ly=0;ly<resheight;ly++){
 int offset2 = ly*reswidth*sx;
 for(int lx=0;lx<reswidth;lx++){		
 outputData[(offset + offset2 + lx)*4] = (unsigned char)(int)kohonenNodes[(offsetk + ly*reswidth + lx)*3];
 outputData[(offset + offset2 + lx)*4+1] = (unsigned char)(int)kohonenNodes[(offsetk + ly*reswidth + lx)*3+1];
 outputData[(offset + offset2 + lx)*4+2] = (unsigned char)(int)kohonenNodes[(offsetk + ly*reswidth + lx)*3+2];
 }
 }
 }	
 CGImageRef imgRef = CGBitmapContextCreateImage(outctx);
 result = [UIImage imageWithCGImage:imgRef];
 CGImageRelease(imgRef);	
 
 [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
 
 //	[pool release];
 time = 0;
 [NSTimer scheduledTimerWithTimeInterval:(0.01) target:self selector:@selector(doKohonen) userInfo:nil repeats:YES];  
 //	[self doKohonen];
 }
 //	}
 
 -(void)doKohonen {
 time++;
 
 int tmax = 10000;
 
 float alpha = 0.1*(1 - (float)time/(float)tmax);
 float norm = 0.5*sqrt(sx*sx+sy*sy)*(1 - (float)time/(float)tmax); 
 if (alpha <= 0) return;
 
 
 
 int inodes = appDelegate.faceDatabaseDelegate.faces.count;
 int knodes = sx*sy;
 
 //pick random face
 int fnr = (arc4random() % inodes);
 
 // calculate euclidean distances and find best matching node
 float dist; float minDist; int minNode = 0;
 int offsetk = reswidth*resheight*fnr;
 
 for (int n=0;n<knodes;n++){
 int offset = reswidth*resheight*n;
 dist = 0;		
 for(int q=0;q<reswidth*resheight; q++){		
 for(int r=0;r<3;r++)
 dist += (kohonenNodes[(offset + q)*3+r]-(float)(unsigned char)inputNodes[(offsetk + q)*4+r])*(kohonenNodes[(offset + q)*3+r]-(float)(unsigned char)inputNodes[(offsetk + q)*4+r]);
 }
 dist = 1./dist;
 if (dist > minDist){ minDist = dist; minNode = n; }
 }
 
 // learn the nodes
 for (int n=0;n<knodes;n++){
 float theta = sqrt(((fnr%sx)-(n%sx))*((fnr%sx)-(n%sx)) +  ((fnr/sx)-(n/sx))*((fnr/sx)-(n/sx)));
 theta = exp( - (theta*theta)/(norm*norm));
 
 //float alpha = 0.5;
 
 int offset = reswidth*resheight*n;
 dist = 0;		
 for(int q=0;q<reswidth*resheight; q++){		
 for(int r=0;r<3;r++)
 kohonenNodes[(offset + q)*3+r] += theta*alpha*((float)(unsigned char)inputNodes[(offsetk + q)*4+r]-kohonenNodes[(offset + q)*3+r]);
 }
 }
 
 // output new map
 int BPC = 8;
 char *outputData = malloc( reswidth*resheight*4*knodes );
 
 // then flip and transform
 CGContextRef outctx = CGBitmapContextCreate( outputData,
 reswidth*sx,
 resheight*sy,
 BPC,
 reswidth*4*sx,
 colorSpace,
 kCGImageAlphaNoneSkipLast);
 
 for (int n=0;n<knodes;n++){
 int offsetk = reswidth*resheight*n;
 int offset = (int)(n%sx) * reswidth + (int)(n/sx)*reswidth*sx*resheight;
 for(int ly=0;ly<resheight;ly++){
 int offset2 = ly*reswidth*sx;
 for(int lx=0;lx<reswidth;lx++){		
 outputData[(offset + offset2 + lx)*4] = (unsigned char)(int)kohonenNodes[(offsetk + ly*reswidth + lx)*3];
 outputData[(offset + offset2 + lx)*4+1] = (unsigned char)(int)kohonenNodes[(offsetk + ly*reswidth + lx)*3+1];
 outputData[(offset + offset2 + lx)*4+2] = (unsigned char)(int)kohonenNodes[(offsetk + ly*reswidth + lx)*3+2];
 }
 }
 }	
 CGImageRef imgRef = CGBitmapContextCreateImage(outctx);
 result = [UIImage imageWithCGImage:imgRef];
 CGImageRelease(imgRef);	
 
 if (time%100 ==0){
 NSData *pngimage = UIImagePNGRepresentation(result);
 NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"kohonen.png"];
 [pngimage writeToFile:filePath atomically:YES];
 }
 
 [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
 
 free(outputData);
 
 }
 
 
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	if (imageView) [imageView release]; imageView = nil;
	if (toggles){ free(toggles); toggles = nil; }
	appDelegate = nil;
	if (progressView) [progressView release]; progressView = nil;
	if (newItem) [newItem release]; newItem = nil;
	if (selectorView) [selectorView release]; selectorView = nil;
	if (traitLogicView) [traitLogicView release]; traitLogicView = nil;
	if (navBar) [navBar release]; navBar = nil;
	if (navItem) [navItem release]; navItem = nil;
	if (leftButton) [leftButton release]; leftButton = nil;
	if (transformer) [transformer release]; transformer = nil;
	if (mixData) { free(mixData); mixData = nil; }
	if (curBitmapData) { free(curBitmapData); curBitmapData = nil; }
	[mixTimer invalidate]; mixTimer = nil;
	[workThread release]; workThread = nil;
	[tipView release]; tipView = nil;
	[startDate release]; startDate = nil;

    [super dealloc];
}


@end
