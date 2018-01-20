//
//  Service.m
//  你点我帮
//
//  Created by admin on 2016/12/19.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Service.h"
#import "SaveData.h"
#import "Config.h"
#import "Unit.h"
static void(^Callback)(bool);
@implementation Service

+(void)ServerSharedAppConfig:(void(^)(bool))callback;
{
        Callback=[callback copy];
        long saveVersion=[Service getVersion:[Unit ParseJSONObject:[SaveData getData:@"ServerSharedAppConfig"]]];
        if(saveVersion>0){
            [Service view:saveVersion];
        }else{
            
            NSString*string=[Config GetAppType];
            NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                //发起异步post请求
            NSURL*url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/service/extend/ios/query.asp?action=query&typeName=%@&version=%@",[Config GetHttpsHostUrl],string,build]];
            NSMutableURLRequest*request=[[NSMutableURLRequest alloc]initWithURL:url];
            [request setHTTPMethod:@"POST"];
            NSData*crashData=[@"" dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:crashData];
            
            NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:[[Service alloc] init]];
            [connection start];
        }

}
+(void)view:(long)version
{
    bool test=false;
    if(version==0){
        test=true;
    }
     NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if(!test && [Service VersionCode:build]>version){
        test=true;
    }

    Callback(test);
}
+(long)getVersion:(NSMutableDictionary*)data
{
    NSMutableDictionary*Platform=[Unit JSONObject:data key:@"Platform"];
    NSMutableDictionary*ios=[Unit JSONObject:Platform  key:@"ios"];
    NSString*version=[Unit JSONString:ios key:@"version"];
    return [Service VersionCode:version];
}
+(long)VersionCode:(NSString*)version
{
    long code=0; long x=1000000000000;
    NSArray*array=[version componentsSeparatedByString:@"."];
    for (NSString*a  in array) {
        code=code+[a intValue]*x;
        x=x/1000;
    }
    
    return code;
}
//接收到服务器传输数据的时候调用
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString*string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableDictionary*dic=[Unit ParseJSONObject:string];
    if (![[Unit JSONString:dic key:@"status"] isEqualToString:@"success"]) {
        [Service view:0];
    }
    else{
        long version=[Service getVersion:[Unit JSONObject:dic key:@"value"]];
        [Service view:version];
    }
}
    //网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    [Service view:0];
}
@end
