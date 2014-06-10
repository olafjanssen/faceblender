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

#import "FBSessionController.h"
#import "FaceBlenderAppDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// This application will not work until you enter your Facebook application's API key here:

static NSString* kApiKey = @"be466ac5e11399be9d56a5a35feb24bd";

// Enter either your API secret or a callback URL (as described in documentation):
static NSString* kApiSecret = @"7761de111a902fcb2205680b2ea9982c";

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FBSessionController
//@synthesize label = _label;
@synthesize uploadPhotoURL,uploadPhotoLink,uploadPhotoDesc;
@synthesize friendNames,friendSquarePic,friendBigPic;

@synthesize isLoggedIn,delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:@"SessionViewController" bundle:nibBundleOrNil]) {
    if (kGetSessionProxy) {
      _session = [[FBSession sessionForApplication:kApiKey getSessionProxy:kGetSessionProxy
                             delegate:self] retain];
    } else {
      _session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
    }
  }
  return self;
}
*/
- (void)dealloc {
  [_session release];
  [super dealloc];
}

-(void)startSession{
	_session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
	if ([_session resume]){
		isLoggedIn = YES;
	} else isLoggedIn = NO;
}

-(BOOL) isConnected {
	[[Reachability sharedReachability] setHostName:@"www.facebook.com"];
	return [[Reachability sharedReachability] internetConnectionStatus];
}

-(void)uploadImage:(UIImage *)image text:(NSString *)caption{
	uploadPhotoDesc = caption;
	NSMutableDictionary *args = [[[NSMutableDictionary alloc] init] autorelease];
	[args setObject:image forKey:@"image"];    
	[args setObject:caption forKey:@"caption"];
	uploadPhotoReq = [FBRequest requestWithDelegate:self];
	[uploadPhotoReq call:@"photos.upload" params:args];
}

-(void)getFriendProfilePhotoList {
	NSString* fql = [NSString stringWithFormat: @"SELECT name,pic_square,pic_big  FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=518361892)", _session.uid]; 
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"]; 
	friendProfileReq = [FBRequest requestWithDelegate:self];
	[friendProfileReq call:@"facebook.fql.query" params:params]; 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidLoad {
  [_session resume];
  isLoggedIn = NO;
//  _loginButton.style = FBLoginButtonStyleWide;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
  NSLog([NSString stringWithFormat:@"Error(%d) %@", error.code, error.localizedDescription]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	// if logged in we need to check the extended permission flag
	isLoggedIn = YES;
	NSString* fql = [NSString stringWithFormat: @"select status_update from permissions where uid == %lld", session.uid]; 
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"]; 
	getPermissionReq = [FBRequest requestWithDelegate:self];
	[getPermissionReq call:@"facebook.fql.query" params:params]; 

}

- (void)sessionDidLogout:(FBSession*)session {
	isLoggedIn = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

- (void)request:(FBRequest*)request didLoad:(id)result {
	if (request == getPermissionReq){
		NSArray *permissions = result;
		NSDictionary *permission = [permissions objectAtIndex:0];
		if (![[permission objectForKey:@"status_update"] boolValue])
			[self askPermission:self];
	}
	else if (request == uploadPhotoReq){
			[self publishFeed];	
	} else if (request == getNameReq){
	} else if (request == friendProfileReq){
		NSArray *profiledata = result;
		friendNames = [[NSMutableArray alloc] init];
		friendBigPic = [[NSMutableArray alloc] init];
		friendSquarePic = [[NSMutableArray alloc] init];
		for (NSDictionary *dict in profiledata){
			if ([dict objectForKey:@"pic_square"]==[NSNull null] || [dict objectForKey:@"pic_big"]==[NSNull null]) continue;
			[friendNames addObject:[NSString stringWithString:[dict objectForKey:@"name"]]];
			[friendSquarePic addObject:[NSString stringWithString:[dict objectForKey:@"pic_square"]]];
			[friendBigPic addObject:[NSString stringWithString:[dict objectForKey:@"pic_big"]]];
		}
		if (delegate) [delegate fillView];
	}
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
  NSLog( [NSString stringWithFormat:@"Error(%d) %@", error.code, error.localizedDescription]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)askPermission:(id)target {
  FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
  dialog.delegate = self;
  dialog.permission = @"status_update";
  [dialog show];
}

- (void)publishFeed {
	// post feed 
	FBFeedDialog* dialog = [[[FBFeedDialog alloc] init] autorelease]; 
	dialog.delegate = self; 
	dialog.templateBundleId = 104727402362;
	
	dialog.templateData = [NSString stringWithFormat:@"{\"oneline\":\"has been blending faces with his iPhone using FaceBlender.\",\"shorttitle\":\"has been blending faces with his iPhone using FaceBlender.\",\"shortbody\":\"I blended together a few faces with the iPhone application FaceBlender that just have to be shared with the world, it is called: '<b>%@</b>'. Check it out in my photo gallery.\",\"images\":[{\"src\":\"%@\",\"href\":\"%@\"}]}", uploadPhotoDesc,uploadPhotoURL,uploadPhotoLink];
	[dialog show];
	[(FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate] hideActivityViewer];
}

@end
