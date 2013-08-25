#import "OLPurchasesController.h"
#import <StoreKit/StoreKit.h>

NSString *const OLPurchasesAdsStatusChangedNotification = @"OLPurchasesAdsStatusChangedNotification";

@implementation OLPurchasesController
+ (instancetype)sharedController;
{
	static OLPurchasesController *g;
	if(!g)
		g = [OLPurchasesController new];
	return g;
}

- (BOOL)shouldShowAds
{
	if(![SKPayment class])
		return NO;
	return YES;
}

- (void)purchaseAdRemoval
{
	
}
@end
