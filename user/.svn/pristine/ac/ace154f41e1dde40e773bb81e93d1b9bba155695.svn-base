//
//  Cmd.h
//  你点我帮
//
//  Created by admin on 16/5/5.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebsocketCmd : NSObject
@property(nonatomic,assign) void(^def)(NSMutableDictionary*);
@property(nonatomic,assign) void(^call)(NSString*,bool);
@property(nonatomic) bool haveReturn;
@property(nonatomic) bool notAutoNumber;
-(WebsocketCmd*)HaveReturn;
-(WebsocketCmd*)NotAutoNumber;
-(WebsocketCmd*)SetDef:(void(^)(NSMutableDictionary*)) def;
-(WebsocketCmd*)SetCall:(void(^)(NSString*,bool)) call;
@end
