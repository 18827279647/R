//
//  Request.m
//  你点我帮商户版
//
//  Created by admin on 2016/12/27.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Request.h"
#import "SaveData.h"
#import "Unit.h"
#import "Config.h"
static void(^Callback)(bool);

@implementation Request

+(void)getHttp:(void(^)(bool))callback;
{
        Callback=[callback copy];
            //发起异步post请求
        NSURL*url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/service/extend/ios/query.asp?action=http",[Config GetHttpsHostUrl]]];
        NSMutableURLRequest*request=[[NSMutableURLRequest alloc]initWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSData*crashData=[@"" dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:crashData];
        
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:[[Request alloc] init]];
        [connection start];
}

+(void)view:(bool)test
{
    Callback(test);
}
    //接收到服务器传输数据的时候调用
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString*string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableDictionary*dic=[Unit ParseJSONObject:string];
    [Request view:[Unit JSONBool:dic key:@"value"]];
}
    //网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    [Request view:true];
}
@end
