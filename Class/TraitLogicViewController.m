//
//  TraitLogicViewController.m
//  FaceBlender
//
//  Created by Olaf Janssen on 11/27/08.
//  Copyright 2008 Delft University of Technology. All rights reserved.
//

#import "TraitLogicViewController.h"


@implementation TraitLogicViewController
@synthesize traitsTable, appDelegate, textView, notButton, andButton, orButton;
@synthesize toggles,togglesOpen,togglesLocal, curOperator;
@synthesize notOperator, curTrait, isDone;
@synthesize logicString, logicString2;
@synthesize segControl,firstTime,toolbar,isEmpty,chosenUids;
@synthesize rowsInSection, facesPerTrait;

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
    	
    // set the delegate and source of the table to self
    traitsTable.delegate = self;
    traitsTable.dataSource = self;
    textView.delegate = self;
    
    appDelegate = (FaceBlenderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // initialize toggles
    toggles = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
    togglesOpen = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
    togglesLocal = malloc(sizeof(BOOL)*appDelegate.faceDatabaseDelegate.faces.count);
    
    isDone = NO;
	chosenUids = [[NSMutableIndexSet alloc] init];

	rowsInSection = [[NSMutableArray alloc] initWithCapacity:appDelegate.faceDatabaseDelegate.traitSections.count+1];
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traitSections.count+1;c++){
		[rowsInSection addObject:[NSNumber numberWithInt:-1]];
	}
	facesPerTrait = [[NSMutableArray alloc] initWithCapacity:appDelegate.faceDatabaseDelegate.traits.count+1];
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traits.count+1;c++){
		[facesPerTrait addObject:[NSNumber numberWithInt:-1]];
	}
	
	[self setTitle:NSLocalizedString(@"SelectTraitKey",@"")];

	[notButton setTitle:NSLocalizedString(@"NOTKey",@"")];
}

-(void)viewWillAppear {
    isDone = NO;
	firstTime = YES;
//	[chosenUids removeAllIndexes];
	//[segControl setHidden:YES];
//	[segControl removeAllSegments];
}


// Handles the continuation of a touch.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{  
	[super touchesBegan:touches withEvent:event];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int cnt=0;
	isEmpty = NO;
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traitSections.count;c++) {
		if ([self rowsInSection:c] > 0) cnt++;
	}
	if (cnt == 0){
		cnt=1; isEmpty = YES;
	}
	return cnt;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isEmpty) return 1; else
	return [self rowsInSection:[self realSection:section]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  	if (isEmpty) return nil; else {
		Trait *trait = nil;
		if (appDelegate.faceDatabaseDelegate.traitSections.count>[self realSection:section])
			trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex: [self realSection:section]];
		if (trait)
			return  NSLocalizedString( trait.description, @"");
		else
			return @"";
	}
}


-(NSInteger)realSection:(NSInteger) section {
	int cnt=0;
	for (int c=0;c<appDelegate.faceDatabaseDelegate.traitSections.count;c++) {
		if ([self rowsInSection:c] == 0) continue;
		cnt++;
		if (section+1 == cnt) return c;
	}
	return 0;
}

-(NSInteger)facesPerTrait:(Trait *)trait {
	NSInteger cached = -1;
	if(facesPerTrait.count>trait.uniqueId)
		cached = [[facesPerTrait objectAtIndex:trait.uniqueId] intValue];
	if (cached != -1) return cached;
	
	int gcnt = 0;
	for (Face *f in appDelegate.faceDatabaseDelegate.faces){
		if (trait.description)
			if ([ [f traits] rangeOfString:trait.description].location==NSNotFound) continue;
		gcnt++;
	}
	
	if (facesPerTrait.count>trait.uniqueId)
		[facesPerTrait replaceObjectAtIndex:trait.uniqueId withObject:[NSNumber numberWithInt:gcnt]];
	
	return gcnt;
}


-(NSInteger)rowsInSection:(NSInteger) section {
	NSInteger cached = -1;
	if (rowsInSection.count>section)
		cached = [[rowsInSection objectAtIndex:section] intValue];
	if (cached != -1) return cached;
	
	int offset = 0;
	for (int c=0;c<section;c++){
		if (appDelegate.faceDatabaseDelegate.traitSections.count>c)
			offset += (int)[(Trait *)[appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:c] uniqueId];
	}
	
	Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>section)
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:section];
	if (!trait) return 0;
	
	int cnt=0;
	for (int c=offset;c<offset+trait.uniqueId;c++){
		Trait *t = nil;
		if (appDelegate.faceDatabaseDelegate.traits.count>c)
			t = [appDelegate.faceDatabaseDelegate.traits objectAtIndex:c];
		if(!t) continue;
		
		int gcnt = 0;
		for (Face *f in appDelegate.faceDatabaseDelegate.faces){
			if (t.description)
				if ([ [f traits] rangeOfString:t.description].location==NSNotFound) continue;
			gcnt++; break;
		}
		if (gcnt>0) cnt++;
	}
	
	if (rowsInSection.count>section)
		[rowsInSection replaceObjectAtIndex:section withObject:[NSNumber numberWithInt:cnt]];
	
	return cnt;
}

-(Trait *)traitForIndexPath:(NSIndexPath *)indexPath {
	// offset from section
	int section = (int)[self realSection:indexPath.section];
	int offset = 0;
	for (int c=0;c<section;c++){
		if (appDelegate.faceDatabaseDelegate.traitSections.count>c)
			offset += (int)[(Trait *)[appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:c] uniqueId];
	}
	
	// find row belonging to non-empty trait
	Trait *trait = nil;
	if (appDelegate.faceDatabaseDelegate.traitSections.count>section)
		trait = [appDelegate.faceDatabaseDelegate.traitSections objectAtIndex:section];
	if (!trait) return nil;
	
	int cnt=0; int tcnt = 0;
	for (int c=offset;c<offset+trait.uniqueId;c++){
		Trait *t = nil;
		if (appDelegate.faceDatabaseDelegate.traits.count>c)
			t = [appDelegate.faceDatabaseDelegate.traits objectAtIndex:c];
		if (!t) continue;
		
		int gcnt = 0;
		for (Face *f in appDelegate.faceDatabaseDelegate.faces){
			if (t.description)
				if ([ [f traits] rangeOfString:t.description].location==NSNotFound) continue;
			gcnt++; break;
		}
		if (gcnt>0) cnt++;
		if (cnt == indexPath.row+1) {
			tcnt = c;
			break;
		}
	}
	if (appDelegate.faceDatabaseDelegate.traits.count>tcnt)
		return [appDelegate.faceDatabaseDelegate.traits objectAtIndex:tcnt];
	else
		return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if (isEmpty) {
		[cell.textLabel setText:NSLocalizedString(@"NoFacesFoundKey",@"")];
		return cell;
	}
	
	Trait *trait = [self traitForIndexPath:indexPath];
	
	int gcnt = (int)[self facesPerTrait:trait];
	if (gcnt>0){
			if ([[trait.description substringToIndex:1] compare:@"@"]==NSOrderedSame){
				[cell.textLabel setText:[NSString stringWithFormat:@"%@ (%d)", [trait.description substringFromIndex:1],gcnt]];
			} else		
				[cell.textLabel setText:[NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(trait.description,@""), gcnt]];
		}
			else
		[cell.textLabel setText: NSLocalizedString( trait.description, @"")];
	
	if ( [chosenUids containsIndex:trait.uniqueId]) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];	
	else [cell setAccessoryType:UITableViewCellAccessoryNone];
	
	[Trait release];
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    return cell;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [traitsTable deselectRowAtIndexPath:indexPath animated:YES];
    if(isDone || isEmpty) return;
    
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    curTrait = [self traitForIndexPath:indexPath];
		
	[chosenUids addIndex:curTrait.uniqueId];
	
	if (firstTime) {
		andButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ANDKey",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(ANDbutton)];
		[andButton setWidth:80];
		
		orButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ORKey",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(ORbutton)];
		[orButton setWidth:80];
		
		NSMutableArray *items = [NSMutableArray arrayWithArray:toolbar.items];
		[items insertObject:orButton atIndex:0];
		[items insertObject:andButton atIndex:0];
		[toolbar setItems:items animated:YES];
		
		curOperator = NO;
		firstTime = NO;
	}
	
	if (logicString.length > 1){
	if (!curOperator) {
		[logicString appendString: [NSString stringWithFormat:@" %@ ",NSLocalizedString(@"ORKey",@"")]];
		[logicString2 appendString:[NSString stringWithFormat:@"\n%@\n",NSLocalizedString(@"ORKey",@"")]];
	} else {
		[logicString appendString:[NSString stringWithFormat:@" %@ ",NSLocalizedString(@"ANDKey",@"")]];
		[logicString2 appendString:[NSString stringWithFormat:@" %@ ",NSLocalizedString(@"ANDKey",@"")]];
	}
	if (notButton.style == UIBarButtonItemStyleDone){
		[logicString appendString:[NSString stringWithFormat:@"%@ ",NSLocalizedString(@"NOTKey",@"")]];
		[logicString2 appendString:[NSString stringWithFormat:@"%@ ",NSLocalizedString(@"NOTKey",@"")]];
	}
    }
	
		if ([[curTrait.description substringToIndex:1] compare:@"@"]==NSOrderedSame){
			[logicString appendString: [curTrait.description substringFromIndex:1]];
			[logicString2 appendString: [curTrait.description substringFromIndex:1]];
		} else {				
			[logicString appendString: NSLocalizedString( curTrait.description, @"")];
			[logicString2 appendString: NSLocalizedString( curTrait.description, @"")];
		}

    // obtain togglesLocal and do logic steps
    for(int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
        Face *face = nil;
		if(appDelegate.faceDatabaseDelegate.faces.count>c)
			face = [appDelegate.faceDatabaseDelegate.faces objectAtIndex:c];
		if (!face) continue;
		if (curTrait.description){
			if ([face.traits rangeOfString:curTrait.description].location!=NSNotFound) togglesLocal[c] = YES; else togglesLocal[c] = NO;
        }
        if (notOperator){
         if (togglesLocal[c]) togglesLocal[c] = NO; else togglesLocal[c]= YES;   
        }
		
        if (curOperator){
            togglesOpen[c] = (togglesOpen[c] && togglesLocal[c]);
        } else {
            toggles[c] = (toggles[c] || togglesOpen[c]);
            togglesOpen[c] = togglesLocal[c];
        }
    }
	
	int curCount = 0;
	for(int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
		if (toggles[c] || togglesOpen[c]) curCount++;
	}
		
    // new operator
	UIAlertView *addAlert = [[UIAlertView alloc]
							 initWithTitle: [NSString stringWithFormat:NSLocalizedString(@"XFacesChosenKey",@""), curCount]
							 message:logicString2
							 delegate:self 
							 cancelButtonTitle:nil
							 otherButtonTitles:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:addAlert selector:@selector(dismissWithClickedButtonIndex:animated:) userInfo:nil repeats:NO];
		
	[self ORbutton];
	if (notOperator) [self NOTbutton];
	
    [addAlert show];
	[addAlert release];

}

-(IBAction)DONEbutton {
	[logicString appendString:@""];
	
	// obtain togglesLocal and do logic steps
	for(int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
		toggles[c] = (toggles[c] || togglesOpen[c]);
	}
	
	[self.view removeFromSuperview];
	isDone = YES;

}

-(IBAction)CANCELbutton {
	// obtain togglesLocal and do logic steps
	for(int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
		toggles[c] = 0;
	}

	[self.view removeFromSuperview];
	isDone = YES;

}

-(void)segControlAction {
	if (segControl.selectedSegmentIndex == 1){
//	[orButton setStyle:UIBarButtonItemStyleDone];
//	[andButton setStyle:UIBarButtonItemStyleBordered];
	curOperator = NO;
	} else {
//	[orButton setStyle:UIBarButtonItemStyleBordered];
//	[andButton setStyle:UIBarButtonItemStyleDone];
	curOperator = YES;
	}
}

-(IBAction)ORbutton {
	// switch to or operator
	[orButton setStyle:UIBarButtonItemStyleDone];
	[andButton setStyle:UIBarButtonItemStyleBordered];
	curOperator = NO;
}

-(IBAction)ANDbutton {
	// switch to and operator
	[orButton setStyle:UIBarButtonItemStyleBordered];
	[andButton setStyle:UIBarButtonItemStyleDone];
	curOperator = YES;

}

-(IBAction)NOTbutton {
	// toggle not operator
	if (notButton.style == UIBarButtonItemStyleDone){
		[notButton setStyle:UIBarButtonItemStyleBordered];
		notOperator = NO;
	}
	else {
		[notButton setStyle:UIBarButtonItemStyleDone];
		notOperator = YES;
	}
	
//	[self doNotOperator];
}

-(void)startLogic {
    for (int c=0;c<appDelegate.faceDatabaseDelegate.faces.count;c++){
        toggles[c] = 0;
        togglesLocal[c] = 0;
        togglesOpen[c] = 0;
    }
    
    logicString = [[NSMutableString alloc] init];
    [logicString appendString:@""];

	logicString2 = [[NSMutableString alloc] init];

    curOperator = NO; // NO = or, YES = and
	notOperator = NO;
	
	isDone = NO;
	firstTime = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	appDelegate = nil;
	curTrait = nil;
	[logicString release]; logicString = nil;
	[logicString2 release]; logicString2= nil;
	[chosenUids release]; chosenUids = nil;
	[rowsInSection release]; rowsInSection = nil;
	[facesPerTrait release]; facesPerTrait = nil;
	if (orButton) [orButton release];
	if (andButton) [andButton release];
    if (toggles) free(toggles); toggles = nil;
	if (togglesOpen) free(togglesOpen); togglesOpen = nil;
	if (togglesLocal) free(togglesLocal); togglesLocal = nil;
    [super dealloc];
}

@end


