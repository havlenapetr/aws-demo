//
//  Header.h
//  Plugins
//

#import <Foundation/Foundation.h>

#ifndef __PLUGIN_H__
#define __PLUGIN_H__

@protocol Plugin <NSObject>

@required
@property (nonatomic, nullable) NSString *messageTypeId;

@required
- (void)handleMessage:(NSUInteger) messageId
              payload:(NSDictionary * _Nonnull) payload
             response:(void (^ _Nullable)(NSString * _Nullable response))response
                error:(void (^ _Nullable)(NSError * _Nullable error))error;

@optional
- (void) pluginWillRegister;
- (void) pluginDidUnregister;
@end

#endif
