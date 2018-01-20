
//  SaveData.m
//  10-7
//
//  Created by zhaoyaqun on 15/11/18.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import "SaveData.h"
#import "Util.h"
#import "Config.h"
#import "ViewController.h"
#import "GTMBase64.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
static NSString* LogTag=@"SaveData";
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation SaveData
+(NSString*)getVersion;
{
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (build==nil) {
        build=@"";
    }
    return build;
}

+(void)getRemove:(NSString*)key
{

    NSUserDefaults *  defualt = [NSUserDefaults standardUserDefaults];

    if (![key isEqualToString:@""])
    {
        [defualt removeObjectForKey:key];
    }
 
}
+(NSString *) getData:(NSString *)key
{
    NSUserDefaults *  defualt = [NSUserDefaults standardUserDefaults];
    
    NSString *value = [defualt stringForKey:key];

    if (!value) {
        value = @"";
    }
    return value;
}

+(void)setData:(NSString *)key andValue:(NSString *)value
{
    NSUserDefaults *  defualt = [NSUserDefaults standardUserDefaults];
    [defualt setObject:value forKey:key];

}
//value为long类型
+(void)setData:(NSString *)key andLongValue:(long)value;
{
    NSUserDefaults *  defualt = [NSUserDefaults standardUserDefaults];
    [defualt setObject:[NSNumber numberWithLong:value] forKey:key];

}
//value为int类型
+(void)setData:(NSString *)key andIntValue:(int)value
{
   
    NSUserDefaults *  defualt = [NSUserDefaults standardUserDefaults];
    [defualt setObject:[NSNumber numberWithInt:value] forKey:key];

}
+(int)getDataInt:(NSString*)key;
{
    NSUserDefaults *  defualt = [NSUserDefaults standardUserDefaults];
    
    int value = [[defualt stringForKey:key]intValue];
    
    return value;


}
//返回long类型
+(long)getDataLong:(NSString*)key;
{
    NSUserDefaults *  defualt = [NSUserDefaults standardUserDefaults];
    
   long value = [[defualt stringForKey:key]longLongValue];
    if ([defualt stringForKey:key]==nil) {
        value=0;
    }
    
    return value;

}

+(BOOL)AllowCacheHost:(NSString *)host
{
    host = [host lowercaseString];
    NSString * hosts =  [self getData:@"AllowCacheHost"];
    if ([hosts length]== 0) {
        [self addCacheHost:@""];
    }
    NSString * hostStr = [NSString stringWithFormat:@",%@,",host];
    return [hosts containsString:hostStr];
}

+(void)addCacheHost:(NSString *)host
{
    host = [host lowercaseString];
    NSString * hosts =  [self getData:@"AllowCacheHost"];
    if ([hosts length]== 0)
    {
        hosts =[NSString stringWithFormat:@",%@,",[Config GetHost]];
    }

    if ([host length ]>0 )
    {
        
        NSString * hostStr = [NSString stringWithFormat:@",%@,",host];
        if (![hosts containsString:hostStr])
        {
            hosts = [NSString stringWithFormat:@"%@%@,",hosts,host];

        }
    }
    NSLog(@"addCacheHost %@",hosts);
    [self setData:@"AllowCacheHost" andValue:hosts];
}

+(void)setLastModified:(long)lastModified
{
    if (lastModified!=[self getLastModified]) {
        
           [self deleteFile];
           [self deleteWebView];
    }
    [self setData:@"LastModified" andValue:[NSString stringWithFormat:@"%ld",lastModified]];
}
+(long)getLastModified
{
    NSString *str = [self getData:@"LastModified"];
    if ([str length]== 0) {
        return 0;
    }
    return [str longLongValue];
}

//保存到沙盒
+(void)saveCache:(NSString *)type andResponse:(NSHTTPURLResponse *)response andString:(NSData *)data
{
    

    if (!response || !data)
    {    NSLog(@"保存到沙盒失败");
        return;
    }
      
        NSString *cachesDir = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
    
        NSString *path = [NSString stringWithFormat:@"%@", cachesDir];
        
        NSString *text = [NSString stringWithFormat:@"%@",[Util md5Hash:type]];
        
        NSString *otherInfoPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-dic",[Util md5Hash:type]]];
        
        NSString *FileName=[path stringByAppendingPathComponent:text];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:response.MIMEType forKey:@"MIMEType"];
        [dict setObject:[NSNumber numberWithLong:[self getLastModified]] forKey:@"LastModified"];
        
        [dict writeToFile:otherInfoPath atomically:YES];
        [data writeToFile:FileName atomically:YES];

}

//读取本地沙盒
+ (NSMutableDictionary *)getCache:(NSString *)type andID:(int)_id
{
    return nil;
//    NSString *cachesDir = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
//    NSString *path = [NSString stringWithFormat:@"%@", cachesDir];
//    NSString *readPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[Util md5Hash:type]]];
//    
//    NSString *otherInfoPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-dic",[Util md5Hash:type]]];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:readPath])
//        {
//        NSMutableDictionary *otherInfo = [NSMutableDictionary dictionaryWithContentsOfFile:otherInfoPath];
//        
//        if ([[otherInfo objectForKey:@"LastModified"] longValue]==[self getLastModified])
//            
//            {
//            NSData *data = [NSData dataWithContentsOfFile:readPath];
//            
//            NSMutableDictionary *getDataDict= [[NSMutableDictionary alloc]init];
//            if (data) {
//                
//                [getDataDict setObject:data forKey:@"data"];
//            }else{
//                return nil;
//            }
//            
//            if (otherInfo)
//                {
//                [getDataDict setObject:otherInfo forKey:@"otherInfo"];
//                }else{
//                    return nil;
//                }
//            
//            return getDataDict;
//            }
//        }
//    
//    
//    return nil;

}
//清理缓存
+(void)deleteFile;
{

    NSFileManager* fileManager=[NSFileManager defaultManager];

    //文件名
    NSString *folder=[NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
    NSLog(@"%@.deleteFile:%@",LogTag,folder);

    BOOL exists=[[NSFileManager defaultManager] fileExistsAtPath:folder];
    if (!exists) {
        NSLog(@"%@.deleteFile:文件夹不存在",LogTag);
        return ;
    }else {
        BOOL blDele= [fileManager removeItemAtPath:folder error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
        
    }
}
+(void)showMessage:(NSString *)message
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake((window.frame.size.width- LabelSize.width - 20)/2,window.frame.size.height- 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:0.5 animations:^{
        showview.alpha = 0.8;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.5 animations:^{
        showview.alpha = 0.0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
    }];

}
+(UIColor*)getUiColor:(NSString*)hexColorString;
{
    unsigned int red,green,blue;
        //切割字符
    NSRange range;
        //长度2
    range.length=2;
        //从0位开始
    range.location=0;
        //获得红色
    [[NSScanner scannerWithString:[hexColorString substringWithRange:range]]scanHexInt:&red];
        //获得绿色
    range.location=2;
    [[NSScanner scannerWithString:[hexColorString substringWithRange:range]]scanHexInt:&green];
        //获得蓝色
    range.location=4;
    [[NSScanner scannerWithString:[hexColorString substringWithRange:range]]scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}
//清理webview的缓存
+(void)deleteWebView
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [ViewController viewControllerManager].webview.delegate =nil;
    });
//    [[ViewController viewControllerManager].webview removeFromSuperview];
// [[ViewController viewControllerManager].webview release];
    [[NSURLCache sharedURLCache]removeAllCachedResponses];
    NSLog(@"清理webview的缓存");
}


//获取UserAgent
+(NSString*)getUserAgent;
{
    UIWebView* b = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [b stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        //获取getApiLevel
    NSInteger getApiLevel = [Config GetApiLevel];
    
    NSString*AppType=[Config GetAppType];
    
        //获取版本号
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *keyValue = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        //App For 不同平台名称，和配置名称一致不区分大小写，Version平台app版本号，Channel打包渠道ID，没有就为0，ClientID客户端唯一编码，可以使用IMEI或uuid，必须保证唯一，ApiLevel客户端ApiLevel[2016-03-29]，参考getApiLeval
    NSString *uuidStr = [NSString stringWithFormat:@"%@ (From/%@/App For IOS; Version/%@; Channel/0; ClientID/%@; ApiLevel/%ld)",secretAgent,AppType,build,keyValue,(long)getApiLevel];
    
    
    return uuidStr;

}


@end
