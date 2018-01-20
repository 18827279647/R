//
//  Notice.h
//  你点我帮
//
//  Created by admin on 16/5/3.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface Notice : NSObject

@property(nonatomic,strong)AVAudioPlayer*player;

@property(nonatomic,strong)Notice*notic;

+(void)NewMessageNotice:(int)voice and:(int)vibrate Volume:(int)Volume;

+(void)NewOrderNotice:(int)voice and:(int)vibrate Volume:(int)Volume;

+(void)NewOrderCuiDanNotice:(int)voice and:(int)vibrate Volume:(int)Volume;

+(void)Notice:(NSMutableDictionary*)data;
    // 取消某个本地推送通知
+(void)CancelNotice:(NSString *)type;

+(void)CanUpdataIconNumber;

+(bool)canNotice;

+(bool)canVoice:(NSMutableDictionary*)settings and:(int)voice;

+(bool)canVibrate:(NSMutableDictionary*)settings and:(int)vibrate;

+(void)vibrate;

@end
