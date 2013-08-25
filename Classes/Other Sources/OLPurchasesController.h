//
//  OLPurchasesController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2013-08-26.
//
//

#import <Foundation/Foundation.h>

extern NSString *const OLPurchasesAdsStatusChangedNotification;

@interface OLPurchasesController : NSObject
+ (instancetype)sharedController;
- (BOOL)shouldShowAds;

- (void)purchaseAdRemoval;
@end
