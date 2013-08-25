#import "OLPurchasesController.h"
#import <StoreKit/StoreKit.h>

NSString *const OLPurchasesAdsStatusChangedNotification = @"OLPurchasesAdsStatusChangedNotification";

static NSString *const OLPurchasesAdsDisabledDefaultsKey = @"OLPurchasesDisabledDefaultsKey";

@interface OLPurchasesController () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
	BOOL _awaitingProduct;
}
@property(nonatomic,retain) SKProductsRequest *productRequest;
@property(nonatomic,retain)	SKProduct *product;
@end

@implementation OLPurchasesController
+ (instancetype)sharedController;
{
	static OLPurchasesController *g;
	if(!g)
		g = [OLPurchasesController new];
	return g;
}

- (id)init
{
	if(!(self = [super init]))
		return nil;
	
	_productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"overload_removeAds"]];
	_productRequest.delegate = self;
	[_productRequest start];
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	
	return self;
}

- (BOOL)shouldShowAds
{
	// If IAP doesn't exist, don't show ads. That would be annoying.
	if(![SKPayment class])
		return NO;
	
	// If IAP is down or broken, don't show ads. That would be evil.
	if(!_product && !_productRequest)
		return NO;
	
	// Check if ad removal has been purchased
	return ![[NSUserDefaults standardUserDefaults] boolForKey:OLPurchasesAdsDisabledDefaultsKey];
}

- (void)purchaseAdRemoval
{
	if(!_product) {
		_awaitingProduct = YES;
		return;
	}
	if(![SKPaymentQueue canMakePayments]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payments disabled" message:@"Payments have been disabled on this device. Please re-enable them and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Removing advertisements" message:@"If you have already paid to remove advertisements, you can tap 'restore' to disable them again for free." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove Ads", @"Restore", nil] autorelease];
	[alert show];
}

- (void)unlockAdRemoval
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:OLPurchasesAdsDisabledDefaultsKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:OLPurchasesAdsStatusChangedNotification object:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == [alertView firstOtherButtonIndex] + 1) {
		NSLog(@"Restoring payments...");
		[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	} else if(buttonIndex == [alertView firstOtherButtonIndex]) {
		NSLog(@"Purchasing %@...", _product);
		SKPayment *payment = [SKPayment paymentWithProduct:_product];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	if(response.invalidProductIdentifiers.count > 0 || response.products.count == 0)
		return [self request:request didFailWithError:nil];
		
	self.product = response.products[0];
	self.productRequest = nil;
	if(_awaitingProduct) {
		_awaitingProduct = NO;
		[self purchaseAdRemoval];
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	NSLog(@"SK product fetch failure: %@", error);
	self.productRequest = nil;
	self.product = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:OLPurchasesAdsStatusChangedNotification object:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for(SKPaymentTransaction *transaction in transactions) {
		NSLog(@"Transaction state change: %@ %d %@", transaction, transaction.transactionState, transaction.error);
		
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				[self unlockAdRemoval];
				[[[UIAlertView alloc] initWithTitle:@"Ads removed!" message:@"Thanks for making indie development possible! Your support means a lot to me." delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil] show];
				break;
			case SKPaymentTransactionStateRestored:
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				[self unlockAdRemoval];
				[[[UIAlertView alloc] initWithTitle:@"Ads removed!" message:@"Your purchase has been restored, and ads are now gone from your game once again." delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil] show];
				break;
			case SKPaymentTransactionStateFailed:
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				[[[UIAlertView alloc] initWithTitle:@"Purchase failed" message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:@"Bummer" otherButtonTitles:nil] show];
				break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	[[[UIAlertView alloc] initWithTitle:@"Restore Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


@end
