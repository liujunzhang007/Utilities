//
//  IMWebSocketManager.m
//  IM for iOS-WebSoket
//
//  Created by shishizu on 2020/5/13.
//  Copyright © 2020 shishizu. All rights reserved.
//

#import "IMWebSocketManager.h"

#define dispatch_main_async_safe_ws(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WSHeartBeatTime 20.0

static  NSString * Khost = @"192.168.31.43";
static const uint16_t Kport = 8989;
static NSString *kPath = @"BSQS/websocket/{2}";


@interface IMWebSocketManager()<SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSTimer *heartBeatTimer;
@end

@implementation IMWebSocketManager{
    NSInteger reConnectTime;
}

+(IMWebSocketManager *)getInstance{
    static IMWebSocketManager *Instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Instance = [[IMWebSocketManager alloc]init];
    });
    return Instance;
}

- (void)webSocketOpen{
    if (self.socket != nil) {
        return;
    }
    [self initSRSocket];
    [self.socket open];
}
-(void)webSocketClose{
    if (self.socket){
        [self.socket closeWithCode:disConnectByUser reason:@"Closed by User"];
        self.socket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
}
- (void)webSocketReconnect{
    [self webSocketClose];
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self initSRSocket];
    });
    //重连时间2的指数级增长
    if (reConnectTime == 0) {
        reConnectTime = 2;
    }else{
        reConnectTime *= 2;
    }
}

- (void)sendMessageWithDict:(NSDictionary *)jsonStrDict{

    NSError *error = nil;
    //将dict转换为data
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonStrDict options:NSJSONWritingPrettyPrinted error:&error];
    //转化为字符串格式
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [self sendString:jsonStr];

}


#pragma mark -Private

- (void)initSRSocket{
    if (self.socket != nil) {
        return;
    }

    NSLog(@"initial WebSocket。。。");

    NSString *urlStr = [NSString stringWithFormat:@"ws://%@:%d/%@", Khost, Kport,kPath];
//    urlStr = @"ws://123.207.136.134:9010/ajaxchattest";//WS测试地址
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    self.socket = [[SRWebSocket alloc]initWithURL:url];
    self.socket.delegate = self;
    //设置代理线程queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;
    [self.socket setDelegateOperationQueue:queue];
}
/**
初始化心跳包方法
*/
- (void) initHeartBeat{
    dispatch_main_async_safe_ws(^{
        [self destoryHeartBeat];
        self->_heartBeatTimer = [NSTimer timerWithTimeInterval:WSHeartBeatTime target:self selector:@selector(ping) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:self->_heartBeatTimer forMode:NSRunLoopCommonModes];
    })
}
/**
销毁心跳包
*/
- (void)destoryHeartBeat
{
    dispatch_main_async_safe_ws(^{
        if (self->_heartBeatTimer) {
            [self->_heartBeatTimer invalidate];
            self->_heartBeatTimer = nil;
        }
    })
   
}
/**
 发送心跳包
 */
- (void)ping{
    if(self.socket.readyState == SR_OPEN){
        NSLog(@"发送ping回调...");
        [self.socket sendPing:nil error:nil];
    }
}
/**
 发送方法-NSString
 */
- (void)sendString:(NSString *)jsonStr{
     __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (weakself.socket != nil) {
                    // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
                    if (weakself.socket.readyState == SR_OPEN) {
                        [weakself.socket sendString:jsonStr error:nil];//发送String数据
                    } else if (weakself.socket.readyState == SR_CONNECTING) {
                        [self webSocketReconnect];
                    } else if (weakself.socket.readyState == SR_CLOSING || weakself.socket.readyState == SR_CLOSED) {
                        // websocket 断开了，调用 reConnect 方法重连
                        [self webSocketReconnect];
                    }
                }
                else{
                    //如果在发送数据，但是socket已经关闭，可以在再次打开
                    [self webSocketOpen];
                }
            });
}
/**
发送方法-NSData
*/
- (void)sendData:(NSData *)data{
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (weakself.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakself.socket.readyState == SR_OPEN) {
                [weakself.socket sendData:data error:nil];    // 发送数据
            } else if (weakself.socket.readyState == SR_CONNECTING) {
                [self webSocketReconnect];
            } else if (weakself.socket.readyState == SR_CLOSING || weakself.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                [self webSocketReconnect];
            }
        }
        else{
            //如果在发送数据，但是socket已经关闭，可以在再次打开
            [self webSocketOpen];
        }
    });
}

#pragma mark -SRDelegate
/**
 收到WS服务器返回的消息
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"服务器返回收到消息:%@",message);
}
/**
WS服务器连接成功
*/
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"连接成功");
    
    //连接成功了开始发送心跳
    [self initHeartBeat];
}
/**
WS服务器连接失败
*/
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"连接失败.....\n%@",error);
    
    //失败了就去重连
    [self webSocketReconnect];
}
/**
WS网络连接中断被调用
*/
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{

//    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    //如果是被用户自己中断的那么直接断开连接，否则开始重连
    if (code == disConnectByUser) {
        NSLog(@"被用户关闭连接，不重连");
        [self webSocketClose];
    }else{
        NSLog(@"其他原因关闭连接，开始重连...");
        [self webSocketReconnect];
    }
    
    //断开连接时销毁心跳
//    [self destoryHeartBeat];//销毁心跳的方法不必重复调用

}
/**
sendPing的时候，如果网络通的话，则会收到回调，但是必须保证ScoketOpen，否则会crash
*/
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"收到ping回调!!!");
}


@end
