//
//  playAudio.m
//  你点我帮
//
//  Created by admin on 2017/6/28.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import "playAudio.h"
#import "Notice.h"
#import "Unit.h"
#import "SaveData.h"

static void(^Callback)(bool ,NSString*);

@implementation playAudio


+(instancetype)getplayAudio
{
    static playAudio *play = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        play = [[self alloc] init];
    });
    return play;
}
-(void)playAudio:(void(^)(bool,NSString*))callback :(NSMutableArray*)data voice:(int)voice vibrate:(int)vibate;
{
    
    Callback=[callback copy];
    
    NSMutableDictionary*settings=[Unit ParseJSONObject:[SaveData getData:@"Settings_playSounds"]];
    if ([Notice canVibrate:settings and:vibate])
        {
        [Notice vibrate];
        
        }
    self.arrayOfTracks=[NSMutableArray arrayWithArray:data];
    self.currrntTranckNumber=0;
   

    if ([Notice canVoice:settings and:voice])
        {
            if (self.audio==nil) {
                [self playaa];
            }else{
                 [[playAudio getplayAudio] stop];
                [self playaa];
            }
            Callback(true,@"");
        }
    else{
        Callback(false,@"播放次数超限");
        [[playAudio getplayAudio] stop];
    }
}
-(void)playaa
{
    
    NSString*path=nil;
    NSURL*url=nil;
        //沙盒或者本地
    NSString*value=[[self.arrayOfTracks objectAtIndex:self.currrntTranckNumber]pathExtension];
    if ([value isEqualToString:@"caf"]) {
        path=[self.arrayOfTracks objectAtIndex:self.currrntTranckNumber];
    }else{
        path=[[NSBundle mainBundle]pathForResource:[self.arrayOfTracks objectAtIndex:self.currrntTranckNumber] ofType:@"caf"];
         path=[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    url=[NSURL URLWithString:path];
    
    self.audio=[[playAudio getplayAudio] initWithContentsOfURL:url error:nil];
    self.audio.delegate=self;
    
    [self.audio play];
}

    //播放完成在播下一个
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        if (self.currrntTranckNumber < [self.arrayOfTracks count]- 1) {
            self.currrntTranckNumber++;
            [self playaa];
        }
    }
}
    // 解码错误
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    Callback(false,@"解码错误");
}

    // 当音频播放过程中被中断时
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
        // 当音频播放过程中被中断时，执行该方法。比如：播放音频时，电话来了！
        // 这时候，音频播放将会被暂停。
    Callback(false,@"播放被打断");
    
}


@end
