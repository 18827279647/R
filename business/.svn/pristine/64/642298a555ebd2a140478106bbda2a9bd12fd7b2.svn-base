//
//  PlaySounds.m
//  你点我帮
//
//  Created by admin on 2017/6/22.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import "PlaySounds.h"
#import "Unit.h"
#import "Sounds.h"
#import "Config.h"

#import "playAudio.h"

//储存信息的字典
static NSMutableDictionary*dic=nil;


static void(^Callback)(bool ,NSString*);

static int Voice;

static int Vibrate;


@implementation PlaySounds












//字典按顺序取值
-(void)getArray:(NSMutableDictionary*)dic
{
        //排序数组
    NSMutableArray*array=[[NSMutableArray alloc]init];
    
        //结果数据
    NSMutableArray*data=[[NSMutableArray alloc]init];
    
    for (NSString*key in dic) {

            [array addObject:key];
    }
        //排序
    NSArray *array2 = [array sortedArrayUsingSelector:@selector(compare:)];
    
    for (int i=0;i<array2.count;i++) {
        [data  addObject:[dic objectForKey:[array2 objectAtIndex:i]]];
    }
    //播放音乐
    playAudio*paly=[[playAudio alloc]init];
    [paly playAudio:Callback:data voice:Voice vibrate:Voice];
}








//回调一个执行状态，和错误信息
-(void)play:(void(^)(bool,NSString*))callback :(NSMutableArray*)data voice:(int)voice vibrate:(int)vibate;
{
    Callback=[callback copy];
    Voice=voice;
    Vibrate=vibate;
    //储存信息的字典
    dic=[[NSMutableDictionary alloc]init];
    
    //未下载的声音
    NSMutableArray*Audiofalse=[[NSMutableArray alloc]init];
    

    if (data.count==0) {
        Callback(false,@"数据解析出错");
        return;
    }
    //解析数组
    for (int i=0;i<data.count;i++) {
        //默认字符串，否则为空
        NSString*value=[Sounds getSounds:[data objectAtIndex:i]];
        
        if ([value isEqualToString:@""]) {
            value=[data objectAtIndex:i];
            //未下载的的下标
            [Audiofalse addObject:[NSNumber numberWithInt:i]];
        }
        //下标和字符串
        [dic setObject:value forKey:[NSNumber numberWithInt:i]];
    }
    
    //判断是否下载
    if (Audiofalse.count==0) {
        [self getArray:dic];
    }else{
        [self download:Audiofalse];
    }
}


//下载方法并保存路径
-(void)download:(NSMutableArray*)array;
{
    //沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (int i=0;i<array.count;i++) {
        //根据数组的下标值，取dic的值
        NSString*type=[dic objectForKey:[array objectAtIndex:i]];
        //保存路径
        NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",type]];

        //判断是否有这个文件夹
        BOOL result = [fileManager fileExistsAtPath:filePath];
        if (!result) {
            NSString*urlstr=[NSString stringWithFormat:@"%@/api/pushplaysound?action=load&type=%@",[Config GetHttpsHostUrl],type];
            NSURL*url=[NSURL URLWithString:urlstr];
            NSURLRequest*request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
           
            NSData*data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
         
                    //数据写入
            [fileManager createFileAtPath:filePath contents:data attributes:nil];
            }
    
            //下载成功了，才把路径换成value
        [dic setObject:filePath  forKey:[array objectAtIndex:i]];

    }
    [self getArray:dic];
}


@end
