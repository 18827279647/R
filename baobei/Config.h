//
//  Config.h
//  你点我帮
//
//  Created by admin on 16/5/24.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject
+(NSString*)GetAppType;
+(NSString*)GetHost;
+(NSString*)GetHttpsHostUrl;
+(NSString*)GetBaseUrl;
+(NSString*)GetHostUrl;
+(void)setHttp:(NSString*)string;
+(int)GetApiLevel;
+(NSString*)GetStartBackgroundColor;
+(NSString*)GetPingxxPay;



+(NSString*)GetUMKey;
+(NSString*)GetUMSinaKey;
+(NSString*)GetUMSinaUrl;
+(NSString*)GetUMSinaSecret;
+(NSString*)GetUMWXKey;
+(NSString*)GetUMWXSecret;
+(NSString*)GetUMWXUrl;
+(NSString*)GetUMQQID;
+(NSString*)GetUMQQKey;
+(NSString*)GetUMQQUrl;

+(NSString*)GetNaviBanck;


+(NSString*)GetBaiDuKey;

+(NSString*)GetUmengPushKey;


@end
