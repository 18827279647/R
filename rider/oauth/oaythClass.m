//
//  oaythClass.m
//  你点我帮
//
//  Created by admin on 2017/12/1.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import "oaythClass.h"
#import "Unit.h"
#import "UMSocial.h"
#import "ViewController.h"
@implementation oaythClass

+(oaythClass*)getoaythClass{
    
    static oaythClass *oayth = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        oayth= [[self alloc] init];
        
    });
    return oayth;
}
-(void)getoauthQQ:(NSMutableArray*)array;{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"oauthQQNotification" object:nil];
    if ([TencentOAuth iphoneQQInstalled]) {
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
        snsPlatform.loginClickHandler([ViewController viewControllerManager],[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                //成功
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
                UMSocialAccountEntity *resp = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
                    //数据
                [Unit setDic:dic key:@"access_token" value:resp.accessToken];
                [Unit setDic:dic key:@"expirationDate" value:[NSNumber numberWithLongLong:[Unit longLongFromDate:resp.expirationDate]]];
                [Unit setDic:dic key:@"openId" value:resp.openId];
                [Unit setDic:dic key:@"redirectURI" value:@""];
                [Unit setDic:dic key:@"appId" value:@""];
                [Unit setDic:dic key:@"uin" value:@""];
                [Unit setDic:dic key:@"skey" value:@""];
                [Unit setDic:dic key:@"passData" value:@""];
                
                [self returndic:dic Success:@"success" Message:@"" Notification:@"oauthQQNotification"];
            }else if(response.responseCode== UMSResponseCodeCancel) {
                    //取消
                [self returndic:nil Success:@"cancel" Message:@"取消授权" Notification:@"oauthQQNotification"];
            }else{
                    //失败
                [self returndic:nil Success:@"fail" Message:@"授权失败" Notification:@"oauthQQNotification"];
            }
        });
    }else{
        //调用返回
        [self returndic:nil Success:@"fail" Message:@"用户未安装" Notification:@"oauthQQNotification"];
    }
   
}








//返回回调
-(void)returndic:(NSMutableDictionary*)dic Success:(NSString*)success Message:(NSString*)message Notification:(NSString*)notioc{
    
    if (dic.count==0) {
        dic=[[NSMutableDictionary alloc]init];
    }
    [dic setObject:success forKey:@"success"];
    [dic setObject:message forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:notioc object:dic];
}









-(void)getoauthWeixin:(NSMutableArray*)array;{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"oauthWeixinNotification" object:nil];

    if ([WXApi isWXAppInstalled]) {
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
        snsPlatform.loginClickHandler([ViewController viewControllerManager],[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
                //成功
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
                UMSocialAccountEntity *resp = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToWechatSession];
                    //数据
                [Unit setDic:dic key:@"access_token" value:resp.accessToken];
                [Unit setDic:dic key:@"openid" value:resp.openId];
                [Unit setDic:dic key:@"refresh_token" value:resp.refreshToken];
                [Unit setDic:dic key:@"expires_in" value:[NSNumber numberWithLongLong:[Unit longLongFromDate:resp.expirationDate]]];
                [Unit setDic:dic key:@"unionid" value:resp.unionId];
                
                [Unit setDic:dic key:@"scope" value:@""];
                [Unit setDic:dic key:@"AllData" value:@""];
                
                [self returndic:dic Success:@"success" Message:@"" Notification:@"oauthWeixinNotification"];
            }else if(response.responseCode== UMSResponseCodeCancel) {
                    //取消
                [self returndic:nil Success:@"cancel" Message:@"取消授权" Notification:@"oauthWeixinNotification"];
            }else{
                    //失败
                [self returndic:nil Success:@"fail" Message:@"授权失败" Notification:@"oauthWeixinNotification"];
            }
        });

    }else{
        //调用返回
        [self returndic:nil Success:@"fail" Message:@"用户未安装" Notification:@"oauthWeixinNotification"];
    }
}







-(void)getoauthWeibo:(NSMutableArray*)array;{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"oauthWeiboNotification" object:nil];

    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.loginClickHandler([ViewController viewControllerManager],[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        //成功
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
            UMSocialAccountEntity *resp = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
                //数据
            [Unit setDic:dic key:@"access_token" value:resp.accessToken];
            [Unit setDic:dic key:@"userid" value:resp.usid];
            [Unit setDic:dic key:@"refresh_token" value:resp.refreshToken];
            [Unit setDic:dic key:@"expires" value:[NSNumber numberWithLongLong:[Unit longLongFromDate:resp.expirationDate]]];
            [Unit setDic:dic key:@"AllData" value:@""];
            
            [self returndic:dic Success:@"success" Message:@"" Notification:@"oauthWeiboNotification"];
        }else if(response.responseCode== UMSResponseCodeCancel) {
                //取消
             [self returndic:nil Success:@"cancel" Message:@"取消授权" Notification:@"oauthWeiboNotification"];
        }else{
                //失败
              [self returndic:nil Success:@"fail" Message:@"授权失败" Notification:@"oauthWeiboNotification"];
        }
    });
}

-(void)getoauthAlipayVer;{
    
}

-(void)getoauthTaobao;{
    
}











@end
