#import <UIKit/UIKit.h>
#import <Capacitor/Capacitor.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwipeBackControlPlugin : CAPPlugin

- (void)enableSwipeBack:(CAPPluginCall *)call;
- (void)disableSwipeBack:(CAPPluginCall *)call;

@end

NS_ASSUME_NONNULL_END 