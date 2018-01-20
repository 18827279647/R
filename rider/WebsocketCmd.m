//
//  Cmd.m
//  你点我帮
//
//  Created by admin on 16/5/5.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "WebsocketCmd.h"

@implementation WebsocketCmd

-(WebsocketCmd*)HaveReturn{
    self.haveReturn=true;
    return self;
}
-(WebsocketCmd*)NotAutoNumber{
   self.notAutoNumber=true;
    return self;
}
-(WebsocketCmd*)SetDef:(void(^)(NSMutableDictionary*)) def{
    self.def=def;
    return self;
}
-(WebsocketCmd*)SetCall:(void(^)(NSString* data,bool isError)) call{
    self.call=call;
    return self;
}
@end
