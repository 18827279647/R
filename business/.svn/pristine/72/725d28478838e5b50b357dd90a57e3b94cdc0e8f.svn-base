//
//  Config.m
//  你点我帮
//
//  Created by admin on 16/5/24.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Config.h"

@implementation Config
static bool Debug=false;

static NSString *AppType=@"Business";
static NSString *protocol=@"https";
static NSString *HOST  = @"www.nidianwobang.com";
static NSString *HOSTDebug  = @"192.168.1.254:8009";
static NSString *HOSTDebugHTTPS  = @"192.168.1.254:4309";
static int ApiLevel = 6;



static NSString *UMKey=@"56f1f2cbe0f55ae370004266";
static NSString *UMSinaKey=@"3108987516";
static NSString*UMSinaSecet=@"fb45f9fc10fa654e7ba7fb493ece6775";

static NSString *UMSinaUrl=@"http://sns.whalecloud.com/sina2/callback";
static NSString *UMWXKey=@"wxdef726d0dddfeb39";
static NSString *UMWXSecret=@"22f06dbac9cb01cac8198e8bd5058aa5";
static NSString *UMWXUrl=@"http://www.nidianwobang.com/";
static NSString *UMQQID=@"1105200518";
static NSString *UMQQKey=@"g9KpySPtO0K2G1C0";
static NSString *UMQQUrl=@"http://www.nidianwobang.com/";

static NSString *StartBackgroundColor=@"736aed";



static NSString *PingxxPay=@"wxdef726d0dddfeb39";

static NSString*NavieBanck=@"23252D";


static NSString*BaiDuKey=@"qKUSdvKreghxcAZTn7b0DLMwnWqSrnal";


static NSString*UmengPush=@"56f1f2cbe0f55ae370004266";



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
