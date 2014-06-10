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
	[activityLabel setTextAlignment:NSTextAlignmentCenter];
	
	[self.view addSubview:activityLabel];
	[activityLabel release];
	
	//[self fillView];
	
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
		
	loadThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImages) object:nil];
	[loadThread start];
    
	[activityLabel removeFromSuperview];
}

-(void)loadImages{
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
		
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@end
