//
//  SettingsViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 11/19/08.
//

#import <UIKit/UIKit.h>
#import "FaceBlenderAppDelegate.h"
#import "AboutViewController.h"
#import "IconMaker.h"
#import "FBConnect/FBConnect.h"
#import "DownloadController.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    FaceBlenderAppDelegate *appDelegate;
    IBOutlet UIView *headerView;
    IBOutlet UITableView *tableView;
    NSMutableArray *tableArray;
	NSMutableArray *settings;
	
	UISwitch *demoSwitch;
	UISwitch *tipsSwitch;
	UISwitch *cropSwitch;
	UISegmentedControl *resControl;
	int itemSelected;
	BOOL isLoaded;
    int keyRes;
    BOOL keyTips;
	BOOL keyCrop;
    BOOL keyDemo;
	FBLoginButton *loginButton;
}

@property ( retain) FaceBlenderAppDelegate *appDelegate;
@property ( retain) IBOutlet UIView *headerView;
@property ( retain) IBOutlet UITableView *tableView;
@property ( retain) NSMutableArray *tableArray;
@property ( retain) NSMutableArray *settings;
@property ( retain) UISwitch *demoSwitch;
@property ( retain) UISwitch *tipsSwitch;
@property ( retain) UISwitch *cropSwitch;
@property ( retain) UISegmentedControl *resControl;
@property ( assign) int itemSelected;
@property ( assign) BOOL isLoaded;
@property ( assign) int keyRes;
@property ( assign) BOOL keyCrop;
@property ( assign) BOOL keyTips;
@property ( assign) BOOL keyDemo;

- (void) switchedOption;
- (void) switchedDemoOption;
-(void)makeIconSmall:(Face *) face;


@end
