//
//  UnitJson.h
//  你点我帮
//
//  Created by admin on 16/4/23.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Unit : NSObject

+(NSMutableDictionary*)ParseJSONObject:(NSString *)JSONString;

+(NSMutableArray*)ParseJSONArray:(NSString *)JSONString;

+(NSString*)FormatJSONArray:(NSMutableArray*)array;

+(NSString*)FormatJSONObject:(NSMutableDictionary*)dic;

+(long)GetMS;

+(NSString*)String:(NSData*)data;


+(NSMutableDictionary*)JSONObject:(NSMutableDictionary*)json key:(NSString*)key;
+(NSMutableArray*)JSONArray:(NSMutableDictionary*)json key:(NSString*)key;
+(NSString*)JSONString:(NSMutableDictionary*)json key:(NSString*)key;
+(bool)JSONBool:(NSMutableDictionary*)json key:(NSString*)key;
+(long)JSONLong:(NSMutableDictionary*)json key:(NSString*)key;
+(double)JSONDouble:(NSMutableDictionary*)json key:(NSString*)key;
+(int)JSONInt:(NSMutableDictionary*)json key:(NSString*)key;



+(NSMutableDictionary*)JSONArrayObject:(NSMutableArray*)json key:(int)key;
+(NSMutableArray*)JSONArrayArray:(NSMutableArray*)json key:(int)key;
+(NSString*)JSONArayString:(NSMutableArray*)json key:(int)key;
+(bool)JSONArrayBool:(NSMutableArray*)json key:(int)key;
+(long)JSONArrayLong:(NSMutableArray*)json key:(int)key;
+(double)JSONArrayDouble:(NSMutableArray*)json key:(int)key;
+(int)JSONArrayInt:(NSMutableArray*)json key:(int)key;

+(long long)longLongFromDate:(NSDate*)date;
+(void)setDic:(NSMutableDictionary*)dic key:(NSString*)key value:(id)value;
@end
