//
//  MainWindowViewController.h
//  FaceBlender
//
//  Created by Olaf Janssen on 4/15/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainWindowViewController : UITabBarController <UITabBarControllerDelegate> {
	IBOutlet UITabBar *tabBar;
}

@property(retain) IBOutlet UITabBar *tabBar;

@end
