#import "FacebookPickerController.h"

@implementation FacebookPickerController
@synthesize tableView,appDelegate,toggles;
@synthesize faceMatrix,selectionViews,fakeView,selcnt, navItem;
@synthesize pool,curCnt,curImage,emptyImage,loadThread,imageViews;
@synthesize delegate;

-(void)viewDidLoad {
	[super viewDidLoad];
    
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    // initialize toggles
    selcnt = 0;
	toggles = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
    for(int tog=0;tog<appDelegate.faceDatabaseDelegate.faces.count;tog++) toggles[tog] = NO;
	
	emptyImage = [UIImage imageNamed:@"EmptyIcon2.png"];
	
	[faceMatrix setDelegate:self];
	
	activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,appDelegate.window.bounds.size.height/2+10,320,40)];
	
	[activityLabel setText:@"Loading..."]; //needlocal
	[activityLabel setTextAlignment:UITextAlignmentCenter];
	
	[self.view addSubview:activityLabel];
	[activityLabel release];
	
	//[self fillView];
	appDelegate.fbc.delegate = self;
	[appDelegate.fbc getFriendProfilePhotoList];
	
	//	loadThread = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	if (loadThread.isExecuting) {
		[loadThread cancel];
	}
}

-(void)dealloc {
	appDelegate = nil;
	if (toggles) free(toggles);
	[fakeView release]; fakeView = nil;
	[faceMatrix release]; faceMatrix = nil;
	[imageViews release]; imageViews = nil;
	[selectionViews release]; selectionViews = nil;
	curImage = nil;
	
	if (loadThread.isExecuting) {
		[loadThread cancel];
	}
	while (loadThread.isExecuting) {}
	[loadThread release]; loadThread = nil;
	
	[super dealloc];
}
/*
 -(void)release {
 [super release];
 }
 */


-(void)fillView {
	imageViews = [[NSMutableArray alloc] init];
	selectionViews = [[NSMutableArray alloc] init];
	
	float buf = 2;
	float sz = (320 - 2*buf)/4;
	
	//add fakeView
	fakeView = [[ UIView alloc] initWithFrame:CGRectMake(0,0,320,buf+sz)];
	[faceMatrix addSubview:fakeView];
	
	for (int cnt=0;cnt< appDelegate.fbc.friendNames.count;cnt++){
		
		UIImageView *iv = [[UIImageView alloc] init ];
		[iv setFrame:CGRectMake(2*buf+(cnt%4)*sz,2*buf+(cnt/4)*sz,sz-2*buf,sz-2*buf)];
		
		[iv setImage:emptyImage];
		
		[imageViews addObject:iv];
		[faceMatrix addSubview:iv];
		[iv release];
		
		UIImageView *ib2 = [[UIImageView alloc] initWithFrame:CGRectMake(buf+(cnt%4)*sz,buf+(cnt/4)*sz,sz,sz)];
		[ib2 setBackgroundColor:[UIColor blueColor]];
		[ib2 setAlpha:0];
		[faceMatrix addSubview:ib2];
		[selectionViews addObject:ib2];			
		[ib2 release];
	
	}
	
	[faceMatrix setContentSize:CGSizeMake(320,5+((appDelegate.fbc.friendNames.count+12)/4)*80)];
	
	loadThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImages) object:nil];
	[loadThread start];
    
	[activityLabel removeFromSuperview];
}

-(void)loadImages{
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	for (int cnt=0;cnt< appDelegate.fbc.friendNames.count;cnt++){
		if ([[NSThread currentThread] isCancelled]) break;
		if ([appDelegate.fbc.friendSquarePic objectAtIndex:cnt]== [NSNull null] ) continue;
		
		NSURLRequest *request  = [NSURLRequest requestWithURL: [ NSURL URLWithString: [appDelegate.fbc.friendSquarePic objectAtIndex:cnt] ]];
		NSData *imgData = [ NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		UIImage *img = [UIImage imageWithData:imgData];
		
		curCnt = cnt;
		curImage = img;
		[self performSelectorOnMainThread:@selector(setIndividualImage) withObject:nil waitUntilDone:YES];
		
		if (loadThread.isCancelled) break;
	}
	
	[tmpPool release];
}

-(void)setIndividualImage {
	if (imageViews.count>curCnt)
		[[imageViews objectAtIndex:curCnt] setImage:curImage];	
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

-(void)viewWillAppear:(BOOL)animated {
    for(int tog=0;tog<appDelegate.faceDatabaseDelegate.faces.count;tog++) toggles[tog] = NO;
	[super viewWillAppear:animated];
}

-(void)doSelection:(int) ii {
	if (ii<0 || ii>= appDelegate.fbc.friendNames.count || selectionViews.count<=ii) return;
	int cnt=-1;
	for(UIImageView *uiv in imageViews){
		cnt++;
		if (cnt!=ii) uiv.image = nil;
	}
	
	UIImageView *sel = [selectionViews objectAtIndex:ii];
	if ([sel alpha] == 0) {
		[sel setAlpha:0.4];
		toggles[ii] = YES;
		selcnt++;
	} else {
		[sel setAlpha:0];
		toggles[ii] = NO;
		selcnt--;
	}
	
	if ([appDelegate.fbc.friendBigPic objectAtIndex:ii]== [NSNull null] ) return;
	
	appDelegate.activityText = NSLocalizedString(@"Downloading Photo",@"");
	[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:appDelegate withObject:nil];
	NSURLRequest *request  = [NSURLRequest requestWithURL: [ NSURL URLWithString: [appDelegate.fbc.friendBigPic objectAtIndex:ii] ]];
	NSData *imgData = [ NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	UIImage *img = [UIImage imageWithData:imgData];
	[appDelegate hideActivityViewer];
	
	if (delegate) 
		[delegate facebookPickerDone: self image:img name:[appDelegate.fbc.friendNames objectAtIndex:ii]];
	//[navItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"FaceXSelectionKey",@""), selcnt]];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@end
