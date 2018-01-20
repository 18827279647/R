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

static NSString *AppType=@"User";
static NSString *protocol=@"https";
static NSString *HOST  = @"www.nidianwobang.com";
static NSString *HOSTDebug  = @"192.168.1.254:8009";
static NSString *HOSTDebugHTTPS  = @"192.168.1.254:4309";
static int ApiLevel = 6;


static NSString *UMKey=@"565bcba0e0f55ae5d800129b";
static NSString *UMSinaKey=@"1286542312";
static NSString*UMSinaSecet=@"bf2b9c3ebb52dfc54ba010870a24c1a9";

static NSString *UMSinaUrl=@"http://sns.whalecloud.com/sina2/callback";
static NSString *UMWXKey=@"wx4f23766a0f005411";
static NSString *UMWXSecret=@"acb79b41a1732751f4010d99ad137e7c";
static NSString *UMWXUrl=@"http://www.nidianwobang.com/";
static NSString *UMQQID=@"1105035822";
static NSString *UMQQKey=@"ZHjaypwrJML8eFNK";
static NSString *UMQQUrl=@"http://www.nidianwobang.com/";

static NSString *StartBackgroundColor=@"34ad78";

static NSString *PingxxPay=@"wx4f23766a0f005411";

static NSString*NavieBanck=@"23252D";


static NSString*BaiDuKey=@"bUD0SvUzcxoxsvnpKHBp5kg47xgNiR7O";


static NSString*UmengPush=@"565bcba0e0f55ae5d800129b";



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
