//
//  Status.h
//  你点我帮商户版
//
//  Created by admin on 2016/12/8.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Status : NSObject

@property(nonatomic,assign)int code;

@property(nonatomic,strong)NSString*message;

@property(nonatomic,strong)NSMutableDictionary*Data;

-(int)Code;

-(NSString*)Message;

-(bool)IsNormal;

-(Status*)Normal;

-(Status*)Unknown:(NSString*)message;

-(Status*)NotSupport;

-(Status*)NotOpen;

-(Status*)NotConnect;

-(Status*)NotSupportPrint;

-(Status*)FillResult:(NSMutableDictionary*)json;

-(Status*)Copy;

@end
