#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(SipCall, RCTEventEmitter)

RCT_EXTERN_METHOD(initialize)
RCT_EXTERN_METHOD(login:(NSDictionary *)options)
RCT_EXTERN_METHOD(logout)
RCT_EXTERN_METHOD(call:(NSDictionary *)options)
RCT_EXTERN_METHOD(endCall)
RCT_EXTERN_METHOD(listener: (RCTResponseSenderBlock)callback)
@end
