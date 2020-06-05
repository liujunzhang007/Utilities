//
//  IMWebSocketManager.h
//  IM for iOS-WebSoket
//
//  Created by shishizu on 2020/5/13.
//  Copyright © 2020 shishizu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    disConnectByServer = 1001,
    disConnectByUser
} DisConnectType;


@interface IMWebSocketManager : NSObject

+ (IMWebSocketManager *)getInstance;
- (void)webSocketOpen;
- (void)webSocketClose;
- (void)webSocketReconnect;
- (void)sendMessageWithDict:(NSDictionary *)jsonStrDict;

@end

NS_ASSUME_NONNULL_END
