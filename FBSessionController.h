/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import "FBConnect/FBConnect.h"
#import "Reachability.h"

@interface FBSessionController : UIViewController
    <FBDialogDelegate, FBSessionDelegate, FBRequestDelegate> {
/*  IBOutlet UILabel* _label;
  IBOutlet UIButton* _permissionButton;
  IBOutlet UIButton* _feedButton;
  IBOutlet FBLoginButton* _loginButton;*/
  FBSession* _session;
FBRequest *getNameReq;
FBRequest *getPermissionReq;
FBRequest *uploadPhotoReq;
FBRequest *friendProfileReq;

		id delegate;
		BOOL isLoggedIn;	
		NSString *uploadPhotoURL;		
		NSString *uploadPhotoLink;		
		NSString *uploadPhotoDesc;
		NSMutableArray *friendNames;
		NSMutableArray *friendSquarePic;
		NSMutableArray *friendBigPic;		
	}

//@property(nonatomic,readonly) UILabel* label;
@property(assign) BOOL isLoggedIn;
@property(retain) NSString *uploadPhotoURL;
@property(retain) NSString *uploadPhotoLink;
@property(retain) NSString *uploadPhotoDesc;
@property(retain) NSMutableArray *friendNames;
@property(retain) NSMutableArray *friendSquarePic;
@property(retain) NSMutableArray *friendBigPic;		
@property(assign) id delegate;

- (void)askPermission:(id)target;
- (void)publishFeed;
- (void)startSession;
-(BOOL) isConnected;
-(void)uploadImage:(UIImage *)image text:(NSString *)caption;
-(void)getFriendProfilePhotoList;

@end
