//
//  oaythClass.h
//  你点我帮
//
//  Created by admin on 2017/12/1.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

//qq
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>

//wexin
#import "WXApi.h"

//weibo
#import "WeiboSDK.h"


#import "Config.h"

@interface oaythClass : NSObject


+(oaythClass*)getoaythClass;

-(void)getoauthQQ:(NSMutableArray*)array;

-(void)getoauthWeixin:(NSMutableArray*)array;

-(void)getoauthWeibo:(NSMutableArray*)array;

-(void)getoauthAlipayVer;

-(void)getoauthTaobao;




@end
