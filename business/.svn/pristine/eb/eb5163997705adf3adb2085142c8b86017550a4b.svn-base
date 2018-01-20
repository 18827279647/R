//
//  Status.m
//  你点我帮商户版
//
//  Created by admin on 2016/12/8.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Status.h"


@implementation Status


-(instancetype)init
{
    self.Data=[[NSMutableDictionary alloc]init];
    [self Normal];
    return self;
}

-(Status*)_set:(int)code message:(NSString*)message
{
    self.code=code;
    self.message=message;
    [self.Data setObject:[NSNumber numberWithInt:self.code] forKey:@"code"];
    
    return self;
}
-(int)Code;
{
    return self.code;
}
-(NSString*)Message;
{
    return self.message;
}
-(bool)IsNormal;
{
    return self.code==0;
}
-(Status*)Normal;
{
   return [self _set:0 message:@""];
}

-(Status*)Unknown:(NSString*)message;
{
  return [self _set:1 message:message];
}


-(Status*)NotSupport;
{

     return  [self _set:2 message:@"不支持蓝牙"];

}
-(Status*)NotOpen;
{
   return  [self _set:3 message:@"蓝牙未打开"];
}

-(Status*)NotConnect;
{
  return [self _set:4 message:@"无法连接到蓝牙设备"];
    
}
-(Status*)NotSupportPrint;
{

  return [self _set:5 message:@"当前蓝牙设备不支持打印"];
}

-(Status*)FillResult:(NSMutableDictionary*)json;
{
    [json setObject:self.Data forKey:@"value"];
    [json setObject:self.message forKey:@"message"];
    return self;
}

-(Status*)Copy;
{
    Status*status=[[Status alloc]init];
    [status _set:self.code message:self.message];
    return status;
}
@end
