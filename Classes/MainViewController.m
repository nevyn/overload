//
//  MainViewController.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "BoardTile.h"

static const NSUInteger BoardWidth = 320;
static const NSUInteger BoardHeight = 372;
static const NSUInteger TileWidth = 32;
static const NSUInteger TileHeight = 31;
static const NSUInteger WidthInTiles = 10; //BoardWidth/TileWidth
static const NSUInteger HeightInTiles = 12; //BoardHeight/TileHeight

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;

	return self;
}



- (void)viewDidLoad {
    for(unsigned y = 0; y < HeightInTiles; y++) {
        for (unsigned x = 0; x < WidthInTiles; x++) {
            BoardTile *tile = [[BoardTile alloc] initWithFrame:CGRectMake(x*TileWidth, y*TileHeight, TileWidth, TileHeight)];
            [self.view addSubview:tile];
        }
    }
}
 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
