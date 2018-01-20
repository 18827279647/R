//
//  PlaySounds.h
//  你点我帮
//
//  Created by admin on 2017/6/22.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface PlaySounds : NSObject<AVAudioPlayerDelegate>
{
    NSUInteger currntNumber;
}
@property(strong,nonatomic)AVAudioPlayer*audioplayer;
@property(copy,nonatomic)NSMutableArray*audioArray;
//回调一个执行状态，和错误信息
-(void) play:(void(^)(bool,NSString*))callback :(NSMutableArray*)data voice:(int)voice vibrate:(int)vibate;

@end
