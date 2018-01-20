//
//  Notice.m
//  你点我帮
//
//  Created by admin on 16/5/3.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Notice.h"
#import "Unit.h"    
#import "SaveData.h"
#import "SrocketViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
//新增
#import "PlaySounds.h"

static NSMutableArray*NotiyTimes;

static int NoticeMaxLen=3;
static  NSMutableDictionary*userDict;

@implementation Notice


+(bool)canNotice;
{
    
    if (NotiyTimes==nil) {
        
        NotiyTimes=[[NSMutableArray alloc]init];
    }
    
    bool val=true;

    long now=[Unit GetMS];
    
    int count=0;
    
    for (int i=0;i<NotiyTimes.count;i++)
    {
        long time=[NotiyTimes[i] longLongValue];
        if (now-time<10*1000){
        
            count++;
    
        }
    }
    if (count>=NoticeMaxLen)
    {
        val=false;
    }
    if (val) {
        
        [NotiyTimes addObject:[NSNumber numberWithLong:now]];
        
        int size=(int)NotiyTimes.count;
        
        if (size>NoticeMaxLen) {
            NSMutableArray*NotiySize=[[NSMutableArray alloc]init];
            for (int i=size-NoticeMaxLen;i<size;i++) {
                
                [NotiySize addObject:NotiyTimes[i]];
            }
            NotiyTimes=NotiySize;
        }
    
        
    }
    return val;

}
+(bool)canVoice:(NSMutableDictionary*)settings and:(int)voice;
{
    
    if ([self canNotice]) {
        
        if (voice==0)
            
        {
            if (settings) {
                if ([[settings allKeys]containsObject:@"disableVoice"])
                {
                    if ([settings objectForKey:@"disableVoice"])
                    {
                        voice=-1;
                    }
                    else
                    {
                        voice=1;
                    }
                }
                
            }
        }
        if (voice==0) {
            settings=[Unit ParseJSONObject:[SaveData getData:@"Settings_newMessageNotice"]];
            if ([[settings allKeys]containsObject:@"disableVoice"])
            {
                if ([settings objectForKey:@"disableVoice"])
                {
                    voice=-1;
                }
                else
                {
                    voice=1;
                }
            }
        }
        
        return voice!=-1;

    }
    else
    {
        return false;
    }
    
}


+(bool)canVibrate:(NSMutableDictionary*)settings and:(int)vibrate;
{
    
    if ([self canNotice]) {
        if (vibrate==0) {
            if (settings) {
                if ([[settings allKeys]containsObject:@"disableVibrate"])
                {
                    if ([settings objectForKey:@"disableVibrate"])
                    {
                        vibrate=-1;
                    }
                    else
                    {
                        vibrate=1;
                    }
                }
                
            }
        }
        if (vibrate==0) {
            settings=[Unit ParseJSONObject:[SaveData getData:@"Settings_newMessageNotice"]];
            if ([[settings allKeys]containsObject:@"disableVibrate"])
            {
                if ([settings objectForKey:@"disableVibrate"])
                {
                    vibrate=-1;
                }
                else
                {
                    vibrate=1;
                }
            }
        }
        
        return vibrate!=-1;

    }else
    {
        return false;
    }
}

+(void)vibrate;
{
    //震动
    SystemSoundID sound;
    sound=kSystemSoundID_Vibrate;
    AudioServicesPlaySystemSound(sound);
    
}
-(void)voice:(NSString*)url Volume:(int)Volume;
{
NSURL*uri=[NSURL fileURLWithPath:url];
_player=[[AVAudioPlayer alloc]initWithContentsOfURL:uri error:nil];
[_player prepareToPlay];
[_player setVolume:Volume];
[_player play];

}
+(void)NewMessageNotice:(int)voice and:(int)vibrate Volume:(int)Volume;
{
    [self __NewMessageNotice:voice and:vibrate play:true Volume:Volume];
}
+(NSString*)__NewMessageNotice:(int)voice and:(int)vibrate play:(bool)play Volume:(int)Volume;
{
    NSString* file=nil;
    if ([self canVoice:nil and:voice]) {
        file=@"sms-received1.caf";
        if (play) {
            NSString *path = [@"/System/Library/Audio/UISounds/" stringByAppendingPathComponent:file];
            Notice*notice=[[Notice alloc]init];
            [notice voice:path Volume:Volume];
        }
    }
    if ([self canVibrate:nil and:vibrate])
    {
        [self vibrate];
    }
    return file;
}
+(void)NewOrderNotice:(int)voice and:(int)vibrate Volume:(int)Volume;
{
    [self __NewOrderNotice:voice and:vibrate play:true Volume:Volume];
}
+(NSString*)__NewOrderNotice:(int)voice and:(int)vibrate play:(bool)play Volume:(int)Volume;
{
    NSMutableDictionary*settings=[Unit ParseJSONObject:[SaveData getData:@"Settings_newOrderNotice"]];
    if ([self canVibrate:settings and:vibrate])
        {
        [self vibrate];
        
        }
        NSString*file=nil;
        if ([self canVoice:settings and:voice])
            {
            file=@"neworder";
            if (play)
            {
                Notice*notice=[[Notice alloc]init];
                [notice voice:[[NSBundle mainBundle]pathForResource:file ofType:@"caf"]Volume:Volume];
            }
            file=[NSString stringWithFormat:@"%@.caf",file];
        }
        return file;
}
+(void)NewOrderCuiDanNotice:(int)voice and:(int)vibrate Volume:(int)Volume;
{
    [self __NewOrderCuiDanNotice:voice and:vibrate play:true Volume:Volume];
}
+(NSString*)__NewOrderCuiDanNotice:(int)voice and:(int)vibrate play:(bool)play Volume:(int)Volume;
{
    NSMutableDictionary*settings=[Unit ParseJSONObject:[SaveData getData:@"Settings_newOrderCuiDanNotice"]];
    
    if ([self canVibrate:settings and:vibrate])
        {
        [self vibrate];
        }
        NSString*file=nil;
    
        if ([self canVoice:settings and:voice])
            {
            file=@"cuidan";
            if (play)
                {
                Notice*notice=[[Notice alloc]init];
                [notice voice:[[NSBundle mainBundle]pathForResource:file ofType:@"caf"]Volume:Volume];
        
            }
        file=[NSString stringWithFormat:@"%@.caf",file];
    }
   
    return file;
}
+(void)Noticemesage:(NSString*)meseage andtype:(NSString*)type andtips:(NSString*)tips push:(NSMutableArray*)pushData;
{
    //新增判断app是否允许通知的方法
    bool appIsRun=[SrocketViewController AppIsRun];
    
    if (appIsRun) {
            //新增Puch处理方法
        if (pushData.count!=0) {
            //播放 x_t声音
            PlaySounds*play=[[PlaySounds alloc]init];
            [play play:^(bool type, NSString *string) {
                
            }:pushData voice:0 vibrate:0];
        }else{
            if ([type rangeOfString:@"30:"].location==0) {
               
                  [Notice NewOrderNotice:0 and:0 Volume:1];
            }
            else if ([type rangeOfString:@"31:"].location==0) {
                  [Notice NewOrderCuiDanNotice:0 and:0 Volume:1];
            }
            else{
                [Notice NewMessageNotice:0 and:0 Volume:1];
            }
        }
    }else{//app未运行
        
        if ([meseage isEqualToString:@""]||meseage==nil) {
            meseage=tips;
        }
        UILocalNotification*notification=[[UILocalNotification alloc]init];
        
         if (notification != nil) {
             
            //设置调用时间
             notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:0];//通知触发的时间
             notification.repeatInterval=2;//通知重复次数
             notification.repeatCalendar=[NSCalendar currentCalendar];
             notification.timeZone = [NSTimeZone defaultTimeZone];
        
            //设置通知属性
             notification.alertBody=meseage;//通知主体
             notification.alertAction=nil; //待机界面的滑动动作提示
             notification.applicationIconBadgeNumber=1;
             
            //新增标题处理
             float System=[[[UIDevice currentDevice] systemVersion] floatValue];
             if (System>=8.2) {
                 notification.alertTitle=tips;
             }
    
            //新增Puch处理方法
             if (pushData.count!=0) {
                     //播放 x_t声音
                 PlaySounds*play=[[PlaySounds alloc]init];
                 [play play:^(bool type, NSString *string) {
                     
                 }:pushData voice:0 vibrate:0];
             }else{
                 if ([type rangeOfString:@"30:"].location==0) {
                     notification.soundName=[self __NewOrderNotice:0 and:0 play:true Volume:0];
                 }
                else if ([type rangeOfString:@"31:"].location==0) {
                    notification.soundName=[self __NewOrderCuiDanNotice:0 and:0 play:true Volume:0];
                }
                else{
                    notification.soundName=[self __NewMessageNotice:0 and:0 play:true Volume:0];
                }
             }
        
        //给这个通知增加key 便于半路取消。nfkey这个key是自己随便写的，还有notificationtag也是自己定义的ID。假如你的通知不会在还没到时间的时候手动取消，那下面的两行代码你可以不用写了。取消通知的时候判断key和ID相同的就是同一个通知了。
        
             notification.userInfo=userDict;
             [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
         }
    }
}
    // 取消某个本地推送通知
+(void)CancelNotice:(NSString *)type {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *str = [userInfo objectForKey:@"type"];
            // 如果找到需要取消的通知，则取消
            if ([type isEqualToString:str]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }  
}

+(void)Notice:(NSMutableDictionary*)data;
{
    userDict=data;
    NSString*tips=nil;NSString*messgae=nil;NSString*type=nil;
    long time=[Unit GetMS];
    long now=[SaveData getDataLong:@"Messagetime"];
    if (time-now<6*1000){
        [NSThread sleepForTimeInterval:0.6];
        NSMutableDictionary*nowdict=[Unit ParseJSONObject:[SaveData getData:@"MessageData"]];
        if (nowdict) {
            NSString*nowtype=[nowdict objectForKey:@"type"];
            type=[data objectForKey:@"type"];
            if ([type isEqualToString:nowtype]){
                tips=[data objectForKey:@"tips"];
                messgae=[data objectForKey:@"message"];

            }
        }
    }else
    {
        type=[data objectForKey:@"type"];
        tips=[data objectForKey:@"tips"];
        messgae=[data objectForKey:@"message"];
    }
    [SaveData setData:@"MessageData" andValue:[Unit FormatJSONObject:data]];
    [SaveData setData:@"Messagetime" andLongValue:time];
    
    //新增Eventpush处理
    NSMutableDictionary*PushData=[Unit JSONObject:data key:@"PushData"];
    NSMutableArray*array=nil;
    if (PushData.count!=0) {
        array=[Unit JSONArray:PushData key:@"x_s"];
    }
    
    [self Noticemesage:messgae andtype:type andtips:tips push:array];

}

+(void)CanUpdataIconNumber;
{
    NSInteger bager=[UIApplication sharedApplication].applicationIconBadgeNumber;
    bager--;
    bager=bager>0?bager:0;
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
}
@end
