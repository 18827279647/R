//
//  Config.m
//  你点我帮
//
//  Created by admin on 16/5/24.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Config.h"

@implementation Config
static bool Debug=true;

static NSString *AppType=@"User";
static NSString *protocol=@"https";
static NSString *HOST  = @"baobei.nidianwobang.com";
static NSString *HOSTDebug  = @"192.168.1.254:8109";
static NSString *HOSTDebugHTTPS  = @"192.168.1.254:4409";
static int ApiLevel = 6;


static NSString *UMKey=@"5a4dfaaab27b0a0bc7000043";
static NSString *UMSinaKey=@"1000928195";
static NSString*UMSinaSecet=@"b80e9e050ee44ad9f8efc7d098b22f1d";

static NSString *UMSinaUrl=@"http://sns.whalecloud.com/sina2/callback";
static NSString *UMWXKey=@"wx4f23766a0f005411";
static NSString *UMWXSecret=@"acb79b41a1732751f4010d99ad137e7c";
static NSString *UMWXUrl=@"http://www.nidianwobang.com/";
static NSString *UMQQID=@"1106561328";
static NSString *UMQQKey=@"lmJJwTMTDYjPhNaS";
static NSString *UMQQUrl=@"http://www.nidianwobang.com/";

static NSString *StartBackgroundColor=@"34ad78";

static NSString *PingxxPay=@"wx4f23766a0f005411";

static NSString*NavieBanck=@"23252D";


static NSString*BaiDuKey=@"s5Y7G0ct2pGesMNjuh5IqURTALlAhydk";


static NSString*UmengPush=@"5a4dfaaab27b0a0bc7000043";



+(NSString*)GetAppType{
    return AppType;
}
+(void)setHttp:(NSString*)string;
{
    protocol=string;
}
    //本地不支持https请求
+(NSString*)GetHttpsHostUrl;
{
    NSString*url=[NSString stringWithFormat:@"https://%@",HOST];
    if (Debug) {
        url=[NSString stringWithFormat:@"http://%@",HOSTDebug];
    }
    return url;
}
+(NSString*)GetHostUrl;
{
    return [NSString stringWithFormat:@"%@://%@",protocol,[Config GetHost]];
}
+(NSString*)GetHost{
    if (Debug) {
        if ([protocol isEqualToString:@"http"]) {
            return HOSTDebug;
        }else{
            return HOSTDebugHTTPS;
        }
    }else{
        return HOST;
    }
}
+(NSString*)GetBaseUrl{
    return [NSString stringWithFormat:@"%@/app/init/init.html",[Config GetHostUrl]];
}
+(int)GetApiLevel{
    return ApiLevel;
}
+(NSString*)GetStartBackgroundColor;
{
    return StartBackgroundColor;
}
+(NSString*)GetUMSinaSecret;
{
    return UMSinaSecet;
}
+(NSString*)GetPingxxPay
{
    return PingxxPay;
}

+(NSString*)GetUMKey
{
    return UMKey;
}
+(NSString*)GetUMSinaKey
{
    return UMSinaKey;
}
+(NSString*)GetUMSinaUrl
{
    return UMSinaUrl;
}
+(NSString*)GetUMWXKey
{
    return UMWXKey;
}
+(NSString*)GetUMWXSecret
{
    return UMWXSecret;
}
+(NSString*)GetUMWXUrl
{
    return UMWXUrl;
}
+(NSString*)GetUMQQID
{
    return UMQQID;
}
+(NSString*)GetUMQQKey
{
    return UMQQKey;
}
+(NSString*)GetUMQQUrl
{
    return UMQQUrl;
}
+(NSString*)GetNaviBanck;
{
    return NavieBanck;
}
+(NSString*)GetBaiDuKey;
{
    return BaiDuKey;
}
+(NSString*)GetUmengPushKey;
{
    return UmengPush;
}
@end
