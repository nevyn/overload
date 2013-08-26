//
//  RootViewController.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "RootViewController.h"
#import "BoardViewController.h"
#import "FlipsideViewController.h"
#import "OLPurchasesController.h"

@interface RootViewController () <UIPopoverControllerDelegate, ADBannerViewDelegate>
{
	BOOL _adShown;
}
@property(nonatomic) BOOL adShown;
@end


@implementation RootViewController

@synthesize infoButton;
@synthesize mainViewController;
@synthesize flipsideViewController;
@synthesize ipadInfoPopover;
@synthesize banner;

- (void)viewDidLoad {
	BoardViewController *viewController = [[[BoardViewController alloc] init] autorelease];
	self.mainViewController = viewController;
	
    [mainViewController viewWillAppear:NO];
	[self.view insertSubview:mainViewController.view belowSubview:infoButton];
    [mainViewController viewDidAppear:NO];
    
    mainViewController.view.frame = self.view.bounds;
    mainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	
	if([ADBannerView class] && [[OLPurchasesController sharedController] shouldShowAds]) {
		self.banner = [[[ADBannerView alloc] initWithFrame:CGRectZero] autorelease];
		self.banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		self.banner.delegate = self;
		[self.view addSubview:self.banner];
		_adShown = YES;
		[self setAdShown:NO animated:NO];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldShowAdsChanged) name:OLPurchasesAdsStatusChangedNotification object:nil];
}

- (void)shouldShowAdsChanged
{
	if([[OLPurchasesController sharedController] shouldShowAds])
		return;
	if(!banner)
		return;
	
	banner.delegate = nil;
	[self setAdShown:NO animated:YES];
	[self performSelector:@selector(killAds) withObject:nil afterDelay:0.5];
}
- (void)killAds
{
	[banner removeFromSuperview];
	self.banner = nil;
}


- (void)loadFlipsideViewController {
	
	FlipsideViewController *viewController = [[[FlipsideViewController alloc] initWithNibName:@"FlipsideView"
                                                                                     bundle:nil
                                                                             rootController:self
                                                                             mainController:self.mainViewController] autorelease];
	self.flipsideViewController = viewController;
	
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		viewController.view.frame = mainViewController.view.frame;
		viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	}
}


- (IBAction)toggleView {	
	/*
	 This method is called when the info or Done button is pressed.
	 It flips the displayed view from the main view to the flipside view and vice-versa.
	 */
	if (flipsideViewController == nil) {
		[self loadFlipsideViewController];
	}
    
    if(ipadInfoPopover) {
        [ipadInfoPopover dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:ipadInfoPopover];
        return;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.ipadInfoPopover = [[UIPopoverController alloc] initWithContentViewController:flipsideViewController];
        [ipadInfoPopover setPopoverContentSize:CGSizeMake(320, 460) animated:NO];
        [ipadInfoPopover presentPopoverFromRect:infoButton.frame inView:infoButton.superview permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        ipadInfoPopover.delegate = self;
        return;
    }
	
	BOOL appearanceIsAutomatic = [UIViewController instancesRespondToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)] || [UIViewController instancesRespondToSelector:@selector(shouldAutomaticallyForwardAppearanceMethods)];
	
	UIView *mainView = mainViewController.view;
	UIView *flipsideView = flipsideViewController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
	if ([mainView superview] != nil) {
		if(!appearanceIsAutomatic) {
			[flipsideViewController viewWillAppear:YES];
			[mainViewController viewWillDisappear:YES];
		}
		[mainView removeFromSuperview];
        [infoButton removeFromSuperview];
		[self.view addSubview:flipsideView];
		if(!appearanceIsAutomatic) {
			[mainViewController viewDidDisappear:YES];
			[flipsideViewController viewDidAppear:YES];
		}

	} else {
		if(!appearanceIsAutomatic) {
			[mainViewController viewWillAppear:YES];
			[flipsideViewController viewWillDisappear:YES];
		}
		[flipsideView removeFromSuperview];
		[self.view addSubview:mainView];
		[self.view insertSubview:infoButton aboveSubview:mainViewController.view];
		if(!appearanceIsAutomatic) {
			[flipsideViewController viewDidDisappear:YES];
			[mainViewController viewDidAppear:YES];
		}
	}
	[UIView commitAnimations];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
{
    self.ipadInfoPopover = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[infoButton release];
	[mainViewController release];
	[flipsideViewController release];
	[banner release];
	[super dealloc];
}

#pragma mark iAds

- (IBAction)toggleAds:(id)sender
{
	[self setAdShown:!_adShown animated:YES];
}

- (void)setAdShown:(BOOL)adShown animated:(BOOL)animated;
{
	if(adShown == _adShown)
		return;
	_adShown = adShown;
	
	CGRect screen = [[UIScreen mainScreen] applicationFrame];
	CGRect mainFrame = CGRectMake(0, 0, screen.size.width, screen.size.height - banner.frame.size.height);
	CGRect bannerFrame = (CGRect){.origin = {0, mainFrame.size.height}, .size = banner.frame.size};
	
	if(!adShown) {
		mainFrame = (CGRect){.size = screen.size};
		bannerFrame = (CGRect){.origin = {0, mainFrame.size.height}, .size = bannerFrame.size};
	}
	
	CGRect infoFrame = (CGRect){.origin = {
		screen.size.width - infoButton.frame.size.width - 20,
		bannerFrame.origin.y - infoButton.frame.size.height - 20
	}, .size = infoButton.frame.size };
	
	if(animated)
		[UIView beginAnimations:@"animateAdBanner" context:NULL];
	
	mainViewController.view.frame = mainFrame;
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		flipsideViewController.view.frame = mainFrame;
	}
	banner.frame = bannerFrame;
	infoButton.frame = infoFrame;
	
	if(animated)
		[UIView commitAnimations];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	if([[OLPurchasesController sharedController] shouldShowAds])
		[self setAdShown:YES animated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
{
	[self setAdShown:NO animated:YES];
}
@end
