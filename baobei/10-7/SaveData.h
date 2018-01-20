//
//  SaveData.h
//  10-7
//
//  Created by zhaoyaqun on 15/11/18.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@interface SaveData : NSObject

+(NSString*)getVersion;
+(void)getRemove:(NSString*)key;
+(NSString *) getData:(NSString *)key;
+(void)setData:(NSString *)key andValue:(NSString *)value;

//value为long类型
+(void)setData:(NSString *)key andLongValue:(long)value;
//value为int类型
+(void)setData:(NSString *)key andIntValue:(int)value;
//返回int类型
+(int)getDataInt:(NSString*)key;
//返回long类型
+(long)getDataLong:(NSString*)key;
+(BOOL)AllowCacheHost:(NSString *)host;
+(void)addCacheHost:(NSString *)host;
+ (void)saveCache:(NSString *)type andResponse:(NSHTTPURLResponse *)response andString:(NSData *)data;
+ (NSMutableDictionary *)getCache:(NSString *)type andID:(int)_id;
//清理缓存
+(void)deleteFile;
+(void)setLastModified:(long)lastModified;
+(long)getLastModified;


+(void)showMessage:(NSString *)message;

+(UIColor*)getUiColor:(NSString*)hexColorString;


//获取UserAgent
+(NSString*)getUserAgent;

@end
