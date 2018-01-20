//
//  UnitJson.m
//  你点我帮
//
//  Created by admin on 16/4/23.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Unit.h"

@implementation Unit


+(long)GetMS;
{
    return  [[NSDate date] timeIntervalSince1970]*1000;
}
+(NSString*)String:(NSData*)data;
{

    return  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    

}
+(NSMutableDictionary*)ParseJSONObject:(NSString *)JSONString;
{
    NSMutableDictionary*resJson=nil;
    if(JSONString && ![JSONString isEqualToString:@""]){
        NSError*err=nil;
        NSData*JsonData=[JSONString dataUsingEncoding:NSUTF8StringEncoding];
        resJson=[NSJSONSerialization  JSONObjectWithData:JsonData options:NSJSONReadingMutableContainers error:&err];
        
        if(err){
            resJson=nil;
        }
    }
    
    if (!resJson) {
        return [[NSMutableDictionary alloc]init];
    }else
    {
        return resJson;
    }
}

+(NSMutableArray*)ParseJSONArray:(NSString *)JSONString;
{
    NSMutableArray*resJson=nil;
    if(JSONString && ![JSONString isEqualToString:@""]){
        
        NSError*err=nil;

        NSData*jsonData=[JSONString dataUsingEncoding:NSUTF8StringEncoding];

        resJson=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if (err) {
            
            resJson=nil;
        }
    }
    if (!resJson) {
        
        return [[NSMutableArray alloc]init];
    }else
    {
        return resJson;
    }

}






+(NSString*)FormatJSONObject:(NSMutableDictionary*)dic;
{
    if (dic ==nil) {
        return @"{}";
    }
    NSError*err=nil;
    NSString*jsonString=nil;
    NSData*jsonData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if ([jsonData length]>0&&err==nil)
    {
        jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else
    {
        jsonString=@"{}";
    }
    
    return jsonString ;
}

+(NSString*)FormatJSONArray:(NSMutableArray*)array;
{
    if (array ==nil) {
        return @"[]";
    }
    NSError*err=nil;
    NSString*jsonString=nil;
    NSData*jsonData=[NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&err];
    if ([jsonData length]>0&&err==nil)
    {
       jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }else
    {
        
    jsonString=@"[]";
        
    }
    
    return jsonString ;
}
+(NSString*)JSONString:(NSMutableDictionary*)json key:(NSString*)key;{
    NSString* val=[json objectForKey:key];
    if(!val){
        val=@"";
    }
    return val;
}















+(NSMutableDictionary*)JSONArrayObject:(NSMutableArray*)json key:(int)key;{
    id data=[json objectAtIndex:key];
    if (![data isKindOfClass:[NSMutableDictionary class]])
    {
        data=nil;
    }
    
    if(!data){
        data=[[NSMutableDictionary alloc]init];
    }
    return data;
}
+(NSMutableDictionary*)JSONObject:(NSMutableDictionary*)json key:(NSString*)key;{
    id data=[json objectForKey:key];
    if (![data isKindOfClass:[NSMutableDictionary class]])
    {
        data=nil;
    }
    
    if(!data){
        data=[[NSMutableDictionary alloc]init];
    }
    return data;
}







+(NSMutableArray*)JSONArrayArray:(NSMutableArray*)json key:(int)key;{
    id data=[json objectAtIndex:key];
    if (![data isKindOfClass:[NSMutableArray class]])
    {
        data=nil;
    }
    
    if(!data){
        data=[[NSMutableArray alloc]init];
    }
    return data;
}
+(NSMutableArray*)JSONArray:(NSMutableDictionary*)json key:(NSString*)key;{
    id data=[json objectForKey:key];
    if (![data isKindOfClass:[NSMutableArray class]])
        {
        data=nil;
        }
    
    if(!data){
        data=[[NSMutableArray alloc]init];
    }
    return data;
}











+(bool)JSONBool:(NSMutableDictionary*)json key:(NSString*)key;
{
   bool agrs=[[json objectForKey:key]boolValue];
    return agrs;
}
+(long)JSONLong:(NSMutableDictionary*)json key:(NSString*)key;
{
  long agrs=[[json objectForKey:key]longValue];
    
  return agrs;
        
}
+(double)JSONDouble:(NSMutableDictionary*)json key:(NSString*)key;
{

    double agrs=[[json objectForKey:key]doubleValue];
    
    return agrs;
}
+(int)JSONInt:(NSMutableDictionary*)json key:(NSString*)key;
{
    int agrs=[[json objectForKey:key]intValue];
    
    return agrs;
    
}

+(NSString*)JSONArayString:(NSMutableArray*)json key:(int)key;
{

    NSString*agrs=[NSString stringWithFormat:@"%@",[json objectAtIndex:key]];
    
    return agrs;

}
+(bool)JSONArrayBool:(NSMutableArray*)json key:(int)key;
{
    bool agrs=[[json objectAtIndex:key]boolValue];
    
    return agrs;
 

}
+(long)JSONArrayLong:(NSMutableArray*)json key:(int)key;
{
    long agrs=[[json objectAtIndex:key]longValue];
    
    return agrs;


}
+(double)JSONArrayDouble:(NSMutableArray*)json key:(int)key;
{
    double agrs=[[json objectAtIndex:key]doubleValue];

    return agrs;
}
+(int)JSONArrayInt:(NSMutableArray*)json key:(int)key;
{
    int data=[[json objectAtIndex:key]intValue];
    
    return data;

}

+(long long)longLongFromDate:(NSDate*)date;{
    return [date timeIntervalSince1970] * 1000;
}

+(void)setDic:(NSMutableDictionary*)dic key:(NSString*)key value:(id)value;{
    if (value==nil) {
        value=@"";
    }
    [dic setObject:value forKey:key];
}
@end
