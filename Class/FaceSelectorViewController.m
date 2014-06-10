#import "FaceSelectorViewController.h"

@implementation FaceSelectorViewController
@synthesize tableView,appDelegate,toggles;
@synthesize faceMatrix,selectionViews,fakeView,selcnt, navItem;
@synthesize pool,curCnt,curImage,emptyImage,loadThread,imageViews;

-(void)viewDidLoad {
	[super viewDidLoad];
    
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];

    // initialize toggles
    selcnt = 0;
	toggles = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
    for(int tog=0;tog<appDelegate.faceDatabaseDelegate.faces.count;tog++) toggles[tog] = NO;
	
	emptyImage = [UIImage imageNamed:@"EmptyIcon2.png"];
	
	[faceMatrix setDelegate:self];
	
	[self fillView];

	
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
	
	int cnt = -1;
	float buf = 2;
	float sz = (320 - 2*buf)/4;
	
	//add fakeView
	fakeView = [[ UIView alloc] initWithFrame:CGRectMake(0,0,320,buf+(cnt/4)*sz)];
	[faceMatrix addSubview:fakeView];
	
	NSString *prevLetter = @"";
	
	for (Face *face in appDelegate.faceDatabaseDelegate.faces ){
		cnt++;
		
		UIImageView *iv = [[UIImageView alloc] init ];
		[iv setFrame:CGRectMake(2*buf+(cnt%4)*sz,2*buf+(cnt/4)*sz,sz-2*buf,sz-2*buf)];
		
	if (face.icon) 
			[iv setImage:face.icon]; 
	else 
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
		
		NSString *firstChar;
		if (face.name.length>0) firstChar = [face.name substringToIndex:1]; else firstChar = @"#";
		
		if ([prevLetter compare:firstChar]!=NSOrderedSame){
			UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(buf+(cnt%4)*sz+5,buf+(cnt/4)*sz+5,20,20)];
			letterLabel.text = firstChar;
			letterLabel.backgroundColor = [UIColor clearColor];
			[letterLabel setShadowOffset:CGSizeMake(1,1)];
			letterLabel.shadowColor = [UIColor whiteColor];
			[letterLabel setFont:[UIFont fontWithName:@"Verdana" size:20]];
			[faceMatrix addSubview:letterLabel];
			[letterLabel release];
		}
		prevLetter = firstChar;
		firstChar = nil;
		

//		}		
	}
	
	[faceMatrix setContentSize:CGSizeMake(320,5+((cnt+12)/4)*80)];
	
//	loadThread = [[NSThread alloc] init];
	loadThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImages) object:nil];
	[loadThread start];
    
}

-(void)loadImages{
	NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
	
	int cnt = -1;
	for (Face *face in appDelegate.faceDatabaseDelegate.faces ){
		cnt++;
		if ([[NSThread currentThread] isCancelled]) break;
		if(!face.icon) {
			[self makeIcon:face];
			//[IconMaker makeIconFace:face];
		}
		//UIImageView *iv = [imageViews objectAtIndex:cnt];
		curCnt = cnt;
		curImage = face.icon;
		//[iv performSelectorOnMainThread:@selector(setImage) withObject:face.icon waitUntilDone:YES];
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
	//NSLog(tmbpath);
	if ([fileManager fileExistsAtPath:tmbpath]){
		UIImage *icon = [[UIImage alloc] initWithContentsOfFile:tmbpath];
		face.icon = icon;
		[icon release];
	} else [IconMaker makeIconFace:face];
	
}

-(void)viewWillAppear:(BOOL)animated {
    for(int tog=0;tog<appDelegate.faceDatabaseDelegate.faces.count;tog++) toggles[tog] = NO;
	[super viewWillAppear:animated];
}

-(void)doSelection:(int) ii {
	if (ii<0 || ii>= appDelegate.faceDatabaseDelegate.faces.count || selectionViews.count<=ii) return;
	
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
	
	[navItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"FaceXSelectionKey",@""), selcnt]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@end
