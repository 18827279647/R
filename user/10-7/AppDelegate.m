//
//  AppDelegate.m
//  10-7
//
//  Created by zhaoyaqun on 15/10/7.
//  Copyright (c) 2015年 zhaoyaqun. All rights reserved.
//

#import "AppDelegate.h"
#import "Cache.h"
#import <SMS_SDK/SMSSDK.h>
#import "MyURLProtocol.h"
//分享
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialSinaHandler.h"
#import "Pingpp.h"
#import "SrocketViewController.h"
#import "AppRequest.h"
#import "SaveData.h"
#import "Unit.h"
#import "Notice.h"
#import <AVFoundation/AVFoundation.h>
#import "Notice.h"
#import "CrashExceptioinCatcher.h"
#import "Config.h"
#import "CheckNetwork.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Service.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import<BaiduMapAPI_Base/BMKBaseComponent.h>
#import "UMessage.h"
#import <UserNotifications/UserNotifications.h>
#import "Unit.h"
#import "Sounds.h"




NSInteger typeIntrger=0;

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSTimer*_timer;
    NSInteger _count;
    BMKMapManager* _mapManager;

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //****TEST************



    
    //*****TEST End********
    
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor=[UIColor whiteColor];
    self.window.userInteractionEnabled=YES;
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];

    //预设一个rootViewController
    UIViewController*myvc=[[UIViewController alloc]initWithNibName:nil bundle:nil];
    self.window.rootViewController=myvc;
    //新增点击通知栏方法
    if (launchOptions.count!=0) {
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSMutableDictionary*dic=[NSMutableDictionary dictionaryWithDictionary:remoteNotification];
        [[ViewController viewControllerManager]launchOptions:dic];
    }
    
    [self getView];
    
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    [UIApplication  sharedApplication].applicationIconBadgeNumber=0;
    
    [CrashExceptioinCatcher startCrashExceptionCatah];
    [NSURLProtocol  registerClass:[MyURLProtocol class]];
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

        //友盟推送点击
    NSMutableDictionary*dic=[NSMutableDictionary dictionaryWithDictionary:userInfo];
        //注册一个推送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"myNotifications" object:dic];
}




- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册
    [UMessage registerDeviceToken:deviceToken];
    NSString *deviceTokenSt = [[[[deviceToken description]
                                 stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                stringByReplacingOccurrencesOfString:@">" withString:@""]
                               stringByReplacingOccurrencesOfString:@" " withString:@""];
      
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceTokenNotification" object:deviceTokenSt];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"deviceTokenNotification" object:deviceTokenSt];
    //本地存一个deviceToken,用于判断是否返回过deviceToken
    [SaveData setData:@"deviceToken" andValue:deviceTokenSt];
}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //本地推送点击
    NSMutableDictionary*data=[NSMutableDictionary dictionaryWithDictionary:notification.userInfo];
    [SaveData setData:@"EventClickData" andValue:[Unit FormatJSONObject:data]];
    [[ViewController viewControllerManager] excode:@"AppRequest.Event()"];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [SrocketViewController AppStop];
    [[ViewController viewControllerManager] excode:@"AppRequest.Background()"];
    [UIApplication  sharedApplication].applicationIconBadgeNumber=0;
    UIApplication*app=[UIApplication sharedApplication];
    __block  UIBackgroundTaskIdentifier bgTask;
    
    bgTask=[app beginBackgroundTaskWithExpirationHandler:^{
       
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (bgTask !=UIBackgroundTaskInvalid) {
                bgTask=UIBackgroundTaskInvalid;
            }
            
        });
    }];
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           if (bgTask !=UIBackgroundTaskInvalid) {
               bgTask=UIBackgroundTaskInvalid;
           }
       });
   });

    //执行后台方法
    self.background_task=[application beginBackgroundTaskWithExpirationHandler:^{
              [self background];
    }];
    if (self.background_task==UIBackgroundTaskInvalid) {
        return;
    }
    self.myTimer=[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timerMethob:) userInfo:nil  repeats:YES];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
    [self.myTimer invalidate];
    [[ViewController viewControllerManager] excode:@"AppRequest.Foreground()"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //进程被干掉了
    NSLog(@"程序退出");

}


// iOS 8 及以下请用这个
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"ios8");
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
            //调用其他SDK，例如支付宝SDK等
        return [Pingpp handleOpenURL:url withCompletion:nil];
        
    }
    return result;
}

// iOS 9 以上请用这个
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    NSLog(@"ios9");
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
            //调用其他SDK，例如支付宝SDK等
        return [Pingpp handleOpenURL:url withCompletion:nil];
        
    }
    return result;

}



-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"内存警告");
    [SaveData setLastModified:[Unit GetMS]];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


//IPV4视图
-(void)getView
{

    self.view = [ViewController viewControllerManager];
    //先把根视图给下
    self.window.rootViewController=self.view;

    //是否注册
    NSString*test=[SaveData getData:@"deviceToken"];
    if ([test isEqualToString:@""]) {
        //没有被注册，不启动
        [AppDelegate UmengPush:false];
    }else{
        [AppDelegate UmengPush:true];
    }

     //短信验证码
        //友盟分享
    [UMSocialData setAppKey:[Config GetUMKey]];
        //    //新浪微博
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:[Config GetUMSinaKey] secret:[Config GetUMSinaSecret] RedirectURL:[Config GetUMSinaUrl]];
        //微信
    [UMSocialWechatHandler setWXAppId:[Config GetUMWXKey] appSecret:[Config GetUMWXSecret] url:[Config GetUMWXUrl]];
        //设置手机QQ 的AppId，Appkey，和分享URL
    [UMSocialQQHandler setQQWithAppId:[Config GetUMQQID] appKey:[Config GetUMQQKey] url:[Config GetUMQQUrl]];
    
    _mapManager = [[BMKMapManager alloc]init];
    
    [_mapManager start:[Config GetBaiDuKey]  generalDelegate:nil];

    //设置一个检测截图的通知
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationUserDidTakeScreenshotNotification object:nil];

    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
        
        NSLog(@"我已经开启通知");
        
    }else{
        
        NSLog(@"我没有开启通知");
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    }
    
}

//标记指定的后台任务完成
-(void)background
{
    [_timer setFireDate:[NSDate distantPast]];
    _count=0;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.myTimer invalidate];// 停止定时器
                // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
                // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
                // 也就是要告诉应用程序：“好借好还”嘛。
                // 标记指定的后台任务完成
            [[UIApplication sharedApplication] endBackgroundTask:self.background_task   ];
                // 销毁后台任务标识符
            strongSelf.background_task = UIBackgroundTaskInvalid;
          
            NSLog(@"fjdksnajkfndkjsnfdkjvnkjdfnbvjkvfdjbvdfalvfdjkbvjdf");
        }
    });
    
}
//后台方法
-(void)timerMethob:(NSTimer*)paramSender
{
        // backgroundTimeRemaining 属性包含了程序留给的我们的时间
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
      
    }
    
}


//执行友盟注册
+(void)UmengPush:(bool)test
{
    if (test){
        [UMessage startWithAppkey:[Config GetUmengPushKey] launchOptions:nil];
        [UMessage registerForRemoteNotifications];
        float System=[[[UIDevice currentDevice] systemVersion] floatValue];
        if (System>10.0) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate=[[AppDelegate alloc]init];
            UNAuthorizationOptions types10=UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
            [center requestAuthorizationWithOptions:types10     completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
        }
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deviceToken" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"myNotifications" object:nil];
    [super dealloc];
}


















@end
