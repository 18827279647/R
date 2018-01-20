//
//  CrashExceptioinCatcher.m
//  你点我帮
//
//  Created by admin on 16/5/16.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "CrashExceptioinCatcher.h"
#import "SaveData.h"
#import "Unit.h"
#import "Config.h"



static  NSMutableDictionary*data;


//存数据

static NSString*EventData;

static NSString*DataString;

void uncaughtExceptionHandler(NSException *exception)
{
    
        //得到当前调用栈信息
    NSString*resason=[exception reason];
        //异常类型
    NSString*name=[exception name];
        //崩溃原因
    NSMutableArray*arr=[NSMutableArray arrayWithArray:[exception callStackSymbols]];
  
    
    [CrashExceptioinCatcher getstring:resason getName:name getNarray:arr];
    
   

 }


@implementation CrashExceptioinCatcher

+(void)getstring:(NSString*)resason getName:(NSString*)name getNarray:(NSMutableArray*)array
{
    
    if (data==nil)
        {
        data=[[NSMutableDictionary alloc]init];
        }
    [data setObject:[Unit FormatJSONArray:array] forKey:@"error"];
    [data setObject:resason forKey:@"message"];
    [data setObject:name forKey:@"name"];
    [data  setObject:[NSNumber numberWithBool:false] forKey:@"isSend"];
    long time=[Unit GetMS];
    [data setObject:[NSNumber numberWithLong:time] forKey:@"time"];
    
    
    
    int num=[[SaveData getData:@"CrashDataNumber"]intValue]+1;
    [SaveData setData:@"CrashDataNumber" andIntValue:num];
    NSMutableArray*EventDataArray=[Unit ParseJSONArray:[SaveData getData:@"CrashDataIndex"]];
    [EventDataArray addObject:[NSNumber numberWithInt:num]];
    [SaveData setData:@"CrashDataIndex"andValue:[Unit FormatJSONArray:EventDataArray]];
    EventData=[NSString stringWithFormat:@"CrashData%d",num];
    DataString=[Unit FormatJSONObject:data];
    [SaveData setData:EventData andValue:DataString];
    

    
    
    //邮件
    
    
//    
//    NSString *crashLogInfo = [NSString stringWithFormat:@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name,resason,array];
//    NSString *urlStr = [NSString stringWithFormat:@"mailto://1064779386@qq.com?subject=bug报告&body=感谢您的配合!""错误详情:%@",
//                        crashLogInfo];
//    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[UIApplication sharedApplication] openURL:url];


        //保存完成后
    [data  setObject:[NSNumber numberWithBool:true] forKey:@"isSend"];
    
    DataString=[Unit FormatJSONObject:data];
    
    [SaveData setData:@"CrashCatcher" andValue:DataString];
    [SaveData setData:@"EventData" andValue:EventData];
}

+(void)startCrashExceptionCatah;
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}


//    // 音频播放完成时
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//        // 音频播放完成时，调用该方法。
//        // 参数flag：如果音频播放无法解码时，该参数为NO。
//        //当音频被终端时，该方法不被调用。而会调用audioPlayerBeginInterruption方法
//        // 和audioPlayerEndInterruption方法
//}
//
//    // 解码错误
//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
//}
//
//    // 当音频播放过程中被中断时
//- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
//        // 当音频播放过程中被中断时，执行该方法。比如：播放音频时，电话来了！
//        // 这时候，音频播放将会被暂停。
//    [self Notice];
//    
//}
//
//    // 当中断结束时
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
//    
//        // AVAudioSessionInterruptionFlags_ShouldResume 表示被中断的音频可以恢复播放了。
//        // 该标识在iOS 6.0 被废除。需要用flags参数，来表示视频的状态。
//    [_player play];
//}
//    //音频方法
//-(void)getAudioplayer:(bool)play
//{
//    typeIntrger=1;
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents]; // 让后台可以处理多媒体的事件
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    NSString*  file=@"sms-received1.caf";
//    NSString *path = [@"/System/Library/Audio/UISounds/" stringByAppendingPathComponent:file];
//    NSURL*uri=[NSURL fileURLWithPath:path];
//    _player=[[AVAudioPlayer alloc]initWithContentsOfURL:uri error:nil];
//    _player.delegate=self;
//    [_player prepareToPlay];
//    [_player setVolume:0];
//    if (play) {
//        [_player play];
//    }
//    _player.numberOfLoops=-1;
//    [self configPlayingInfo];
//    
//}
//-(void)Notice
//{
//    typeIntrger=1;
//    UILocalNotification *notification=[[UILocalNotification alloc]init];
//        //设置调用时间
//    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:0];//通知触发的时间
//    notification.repeatInterval=1;//通知重复次数
//    notification.timeZone=[NSTimeZone defaultTimeZone];
//        //设置通知属性
//    notification.alertTitle=@"你点我帮";
//    notification.alertBody=@"您有新的消息";//通知主体
//    notification.alertAction=nil; //待机界面的滑动动作提示
//    notification.applicationIconBadgeNumber=1;
//    notification.soundName=@"sms-received1.caf";
//    [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
//}
//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//    //响应远程音乐播放控制消息
//- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
//    
//    if (receivedEvent.type == UIEventTypeRemoteControl)
//        {
//        if (receivedEvent.type == UIEventTypeRemoteControl) {
//            switch (receivedEvent.subtype) {
//                case UIEventSubtypeRemoteControlPlay:
//                        // 播放
//                    [_player play];
//                    break;
//                    
//                case UIEventSubtypeRemoteControlPause:
//                        //暂停
//                    [_player stop];
//                    break;
//                    
//                case UIEventSubtypeRemoteControlPreviousTrack:
//                        // 播放上一曲按钮
//                    
//                    break;
//                    
//                case UIEventSubtypeRemoteControlNextTrack:
//                        // 播放下一曲按钮
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//        }
//        }
//}
//- (void)configPlayingInfo
//{
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    
//    [dict setObject:@"你点我帮" forKey:MPMediaItemPropertyTitle];
//    [dict setObject:@"演唱者" forKey:MPMediaItemPropertyArtist];
//    [dict setObject:@"专辑名" forKey:MPMediaItemPropertyAlbumTitle];
//    UIImage *newImage = [UIImage imageNamed:@"用户板图片640x1136-1.jpg"];
//    [dict setObject:[[[MPMediaItemArtwork alloc] initWithImage:newImage] autorelease]
//             forKey:MPMediaItemPropertyArtwork];
//    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//}
@end
