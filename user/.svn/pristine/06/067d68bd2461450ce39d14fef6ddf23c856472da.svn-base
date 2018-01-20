//
//  SrocketViewController.h
//  rongxu
//
//  Created by admin on 16/4/14.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"
#import "SRWebSocket.h"
#import "AppDelegate.h"


@interface SrocketViewController : ViewController<SRWebSocketDelegate>
{
    SRWebSocket *webSocket;
    NSInputStream*stream;
    NSTimer *timer;
}
//设置一个定时器
@property(nonatomic,strong)NSTimer* HeartbeatTimer;

//新增一个消息通知超时定时器
@property(nonatomic,strong)NSTimer*EventTimer;

+(SrocketViewController*)Instance;


+(void)AppStop;

+(void)AppRun;
+(bool)AppIsRun;

// 初始化
-(void)Init;
-(bool)Available;
-(void)ExecUserMessageRequest:(NSString*)jsonArrStr;
-(void)ExecChatMessageRequest:(NSString*)jsonArrStr;
-(void)ExecSystemMessageRequest:(NSString*)jsonArrStr;

-(void)sendCmd:(NSString*) cmd
          args:(NSString*)args
          data:(NSString*)data
      callback:(void(^)(NSString*,bool))callback;

@end
