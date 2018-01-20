//
//  AppDelegate.h
//  10-7
//
//  Created by zhaoyaqun on 15/10/7.
//  Copyright (c) 2015年 zhaoyaqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,AVAudioPlayerDelegate,UNUserNotificationCenterDelegate>

{
      int isRun;
    
}
@property (strong, nonatomic) UIWindow *window;

@property (strong  ,nonatomic) ViewController *view;

@property(assign,unsafe_unretained)UIBackgroundTaskIdentifier  background_task;

@property(nonatomic,strong)NSTimer*myTimer;

@property(nonatomic,strong)NSMutableData*receiveData;

+(void)UmengPush:(bool)test;

@end

