//
//  AboutViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 2/18/09.
//  Copyright 2009 Awoken Well. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController
//@synthesize text, text2;
//@synthesize titleLabel;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(210,140,100,30)];
	[versionLabel setTextColor:[UIColor whiteColor]];
	[versionLabel setBackgroundColor:[UIColor clearColor]];
	versionLabel.text = @"V1.1.000";
	[self.view addSubview:versionLabel];
	[versionLabel release];
	
	UIImage *logo = [UIImage imageNamed: @"HEADER.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
	[self.view addSubview:imageView];
	[imageView setFrame:CGRectMake(180,5,120,30)];
	[imageView release];
	
/*
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(175,0,160,40)];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:[UIFont fontWithName:@"Arial" size:23]];
	titleLabel.text = @"FaceBlender";
	[self.view addSubview:titleLabel];
	[titleLabel release];
*/
	
	UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(5,315,310,45)];
	[text setTextColor:[UIColor whiteColor]];
	[text setBackgroundColor:[UIColor clearColor]];
	[text setFont:[UIFont fontWithName:@"Arial" size:9.8]];
	text.text = NSLocalizedString(@"AboutDisclaimKey",@"");
	[self.view addSubview:text];
	[text release];
	
	UITextView *text2 = [[UITextView alloc] initWithFrame:CGRectMake(165,40,160,200)];
	[text2 setTextColor:[UIColor whiteColor]];
	[text2 setBackgroundColor:[UIColor clearColor]];
	[text2 setFont:[UIFont fontWithName:@"Arial" size:10]];
	text2.text = NSLocalizedString(@"AboutTextKey",@"");
	[self.view addSubview:text2];
	[text2 release];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
