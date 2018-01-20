//
//  SaveFile.m
//  你点我帮
//
//  Created by admin on 2017/6/16.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import "SaveFile.h"
#import "GTMBase64.h"
#import "ViewController.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "SendConnectionViewController.h"
#import "Unit.h"
static bool _test=false;
static NSString*_path=@"";
static NSString*_message=@"";
static NSTimer*OpenTime;
static void(^Callback)(bool ,NSString*,NSString*);
@implementation SaveFile
-(void)save:(void(^)(bool ,NSString*,NSString*))callback name:(NSString*)name :(NSString*)data;
{
    Callback=[callback copy];
    
    
    //文件名
    if ([name isEqualToString:@""]||name==nil) {
        _message=@"文件名为空";
        Callback(_test,_message,_path);
        return;
    }
    //解码
    NSData*flieData=[GTMBase64 decodeString:data];

    if (flieData==nil) {
        _message=@"解码失败";
        Callback(_test,_message,_path);
        return;
    }
    //判断是否是图片
    uint8_t c;
    [flieData getBytes:&c length:1];
    if (c==0xFF||c==0x89||c==0x47||c==0x49||c==0x4D) {
          [self getImage:flieData fileName:name];
    }else{
        [self getAllFile:flieData fileName:name];
    }

}






//图片文件
-(void)getImage:(NSData*)data fileName:(NSString*)name
{
    ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
    if (author==ALAuthorizationStatusRestricted ||author==ALAuthorizationStatusDenied) {
        [self getNOAuth:data fileName:name];
        return;
    }
    [self getYESAuth:data fileName:name];
 
}

//无权限
-(void)getNOAuth:(NSData*)data fileName:(NSString*)name;{
    //        return NO;  //权限未开就按其他文件
    [self getAllFile:data fileName:name];
}


//有权限
-(void)getYESAuth:(NSData*)data fileName:(NSString*)name;{
    
    UIImage *image = [UIImage imageWithData:data];
 UIImageWriteToSavedPhotosAlbum(image,self,@selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),nil);
}


- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:  (NSError*)error contextInfo:(id)contextInfo
{
    if (!error) {
        _test=true;
    }else{
        _message=@"保存相册失败";
    }
    Callback(_test,_message,_path);
}









//其他文件
-(void)getAllFile:(NSData*)data fileName:(NSString*)name
{
    //存入时间
    if (OpenTime != nil) {
        [OpenTime invalidate];
        OpenTime=nil;
    }

    OpenTime=[NSTimer scheduledTimerWithTimeInterval:160.0 target:self selector:@selector(closeFlie) userInfo:nil repeats:NO];
        //沙盒文件存储路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
        //拼接新的路径
    _path=[documentsDirectory stringByAppendingPathComponent:name];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_path]) {

    [fileManager createFileAtPath:_path contents:data attributes:nil];
    _test=true;
    
    }
    Callback(_test,_message,_path);
}
-(void)closeFlie
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [fileManager removeItemAtPath:documentsDirectory error:nil];
    
}
@end
