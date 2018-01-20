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

static NSString *AppType=@"Rider";
static NSString *protocol=@"https";
static NSString *HOST  = @"www.nidianwobang.com";
static NSString *HOSTDebug  = @"192.168.1.254:8009";
static NSString *HOSTDebugHTTPS  = @"192.168.1.254:4309";
static int ApiLevel = 6;



static NSString *UMKey=@"59e8395bc62dca4a43000348";
static NSString *UMSinaKey=@"980329147";
static NSString*UMSinaSecet=@"a1a080fa32258169f44a389ba0575cfe";

static NSString *UMSinaUrl=@"http://sns.whalecloud.com/sina2/callback";
static NSString *UMWXKey=@"wx03f339657b16fd6d";
static NSString *UMWXSecret=@"ea01e46c9ff533ca7203d1c1e6254b14";
static NSString *UMWXUrl=@"http://www.nidianwobang.com/";
static NSString *UMQQID=@"1106521824";
static NSString *UMQQKey=@"ofkMTGlVuULqrlQM";
static NSString *UMQQUrl=@"http://www.nidianwobang.com/";

static NSString *StartBackgroundColor=@"ff6600";



static NSString *PingxxPay=@"TODO Not Support";

static NSString*NavieBanck=@"23252D";


static NSString*BaiDuKey=@"VUwb1KCQL0HAmNn8ckz4X4nvQrGBF5wp";


static NSString*UmengPush=@"59e8395bc62dca4a43000348";



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
