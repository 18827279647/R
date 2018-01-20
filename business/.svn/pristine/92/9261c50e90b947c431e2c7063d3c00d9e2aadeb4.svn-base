//
//  AppRequest.h
//  你点我帮
//
//  Created by zhaoyaqun on 15/12/1.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h" 
#import "ViewController.h"
#import "SrocketViewController.h"
//友盟分享
//#import "UMSocial.h"

#import "Cmmotion.h"

#import "Location.h"

@interface AppRequest : NSObject<viewDelegate,UIActionSheetDelegate,UIDocumentInteractionControllerDelegate>
{
    NSCachedURLResponse *cacheResponse;
    NSUserDefaults *defualt ;
    NSMutableDictionary *cachedResponsesDict;
    BOOL isGetImage;
    
    NSMutableDictionary*BlueDic;


}
@property (nonatomic , strong) NSMutableDictionary*requestJson;
@property(nonatomic,strong)NSString*data;
@property (nonatomic ,copy) NSMutableDictionary *saveData;
@property (nonatomic , strong) NSMutableDictionary *argsDic;
@property(nonatomic,strong)void(^Callback)(NSData*);
@property(nonatomic)bool isAsync;

@property(nonatomic,strong)UIDocumentInteractionController*documentCom;



-(AppRequest *)init:(NSString *)jsonStr and:(void(^)(NSData*))callback;
-(AppRequest*)initWithJson:(NSMutableDictionary*)request and:(void (^)(NSData *))callback;
-(bool)hasAction;
-(NSData *)work;

@property (nonatomic , copy) NSDictionary *dic;//请求js得到的参数

@property (strong , nonatomic) ViewController *view;


@property(nonatomic, retain) NSMutableDictionary *responseDictionary;

@property(nonatomic, retain) NSMutableDictionary *saveLocationDict;//保存经纬度

@property(nonatomic,assign)bool scanBarCodebool;

@property(nonatomic,strong)NSTimer*UmengTime;

-(void)cancleSelect;

-(void)pot;
//新订单消息通知，发出催单铃声、震动
-(void)newOrderCuiDanNotice;

-(void)newOrderNotice;

-(void)newMessageNotice;

@end
