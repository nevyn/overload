//
//  OLMainMenu.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-06-14.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "OLMainMenu.h"
#import "Beacon+OptIn.h"
#import "GVCHotseat.h"

@implementation OLMainMenu

-(id)init;
{
	if( ! [super initWithNibName:@"OLMainMenu" bundle:nil] ) return nil;
	
	return self;
}

- (void)dealloc {
	[super dealloc];
}





- (void)viewDidLoad {
  [super viewDidLoad];
	// Todo: Push the previous game to the stack if there was one
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction)playAI:(id)sender;
{
	[[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Local AI Game" timeSession:YES];

}
-(IBAction)playHotSeat:(id)sender;
{
	[[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Local 2P Game" timeSession:YES];
	[self.navigationController pushViewController:[[[GVCHotseat alloc] init] autorelease] animated:YES];
}
-(IBAction)playOnline:(id)sender;
{
	
}

-(IBAction)settings:(id)sender;
{
	
}

@end
