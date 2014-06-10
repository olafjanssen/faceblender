#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "FaceBlenderAppDelegate.h"
#import "FaceSelectorScrollView.h"
#import "Face.h"
#import "IconMaker.h"

@interface FaceSelectorViewController : UIViewController <UIScrollViewDelegate> {
	IBOutlet UITableView *tableView;
	FaceBlenderAppDelegate *appDelegate;
	BOOL *toggles;
	UIView *fakeView;
	int selcnt;
	IBOutlet FaceSelectorScrollView *faceMatrix;
	NSMutableArray *imageViews;
	NSMutableArray *selectionViews;
	UINavigationItem *navItem;
	NSAutoreleasePool *pool;
	
	int curCnt;
	UIImage *curImage;
	UIImage *emptyImage;
	NSThread *loadThread;
	
}

@property (retain) IBOutlet UITableView *tableView;
@property (retain) FaceBlenderAppDelegate *appDelegate;
@property (retain) UIView *fakeView;
@property (retain) NSMutableArray *selectionViews;
@property (retain) NSMutableArray *imageViews;
@property (assign) BOOL *toggles;
@property (assign) int selcnt;
@property (retain) UINavigationItem *navItem;
@property (retain) NSAutoreleasePool *pool;
@property (retain) UIImage *curImage;
@property (retain) UIImage *emptyImage;
@property (assign) int curCnt;
@property (retain) NSThread *loadThread;

@property (retain) IBOutlet FaceSelectorScrollView *faceMatrix;

-(void)doSelection:(int) ii;
-(void)makeIcon:(Face *) face;
- (void)viewWillDisappear:(BOOL)animated;
-(void)fillView;

@end
