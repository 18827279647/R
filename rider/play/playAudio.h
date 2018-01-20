//
//  playAudio.h
//  你点我帮
//
//  Created by admin on 2017/6/28.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@interface playAudio : AVAudioPlayer<AVAudioPlayerDelegate>

@property(nonatomic,strong)NSMutableArray*arrayOfTracks;
@property(nonatomic,strong)AVAudioPlayer*audio;
@property(nonatomic,assign)NSInteger currrntTranckNumber;

-(void)playAudio:(void(^)(bool,NSString*))callback :(NSMutableArray*)data voice:(int)voice vibrate:(int)vibate;
@end
