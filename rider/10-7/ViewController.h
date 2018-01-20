//
//  ViewController.h
//  10-7
//
//  Created by zhaoyaqun on 15/10/7.
//  Copyright (c) 2015年 zhaoyaqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@protocol viewDelegate <NSObject>

-(void)passValue:(bool)isbask and:(bool)isError and:(NSString*)scanstr;
//传入二维码扫描值

@end

@interface ViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic ,retain) UIWebView *webview;

@property (assign , nonatomic) id<viewDelegate>delegate;

@property(nonatomic,assign)bool launchOptionsType;

-(void)GoZbarView;//跳转扫描二维码

-(void)loadRequest:(bool)type;

-(void)reloadWbview;


+ (ViewController*)viewControllerManager;

-(void)excode:(NSString *)code;

-(void)UIViewurl:(NSString*)url andimage:(NSString*)image andcontentStr:(NSString*)contentStr andtither:(NSString*)thther;


-(void)openShake;

-(void)closeShake;

-(void)launchOptions:(NSMutableDictionary*)data;


@end

