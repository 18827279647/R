//
//  AppRequest.m
//  你点我帮
//
//  Created by zhaoyaqun on 15/12/1.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import "AppRequest.h"
#import "ViewController.h"
#import "CheckNetwork.h"
#import "GetLocationViewController.h"
#import "EditImageViewController.h"
#import "GTMBase64.h"
#import "SaveData.h"
#import "Util.h"
#import "CheckNetwork.h"
#import "alertLabel.h"
#import "Pingpp.h"
#import "SendConnectionViewController.h"
#import "OpenUriViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "Unit.h"
#import "Notice.h"
#import "SrocketViewController.h"

#import "PlaySounds.h"
//蓝牙接口

#import "Print.h"
#import "Bluetooth.h"
#import "Status.h"

//短信验证
#import <SMS_SDK/SMSSDK.h>

//友盟分享
#import "WeiboSDK.h"
#import "Config.h"
#import "UMessage.h"


//3.0新增
#import "WXApi.h"


#import "oaythClass.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)

#import "SaveFile.h"




static NSTimer*ShakeTime;

static NSTimer*OrignTime;

static NSTimer*LocationTime;

static NSTimer*getLocationTime;



@implementation AppRequest

-(AppRequest *)init:(NSString *)jsonStr and:(void(^)(NSData*))callback
{
    [self initWithJson:[Unit ParseJSONObject:jsonStr] and:callback];
    return self;
}
-(AppRequest*)initWithJson:(NSMutableDictionary*)request and:(void (^)(NSData *))callback
{
    self.requestJson=request;
    self.Callback=callback;
    self.isAsync=false;
    _saveData = [[NSMutableDictionary alloc] init];
    BlueDic=[[NSMutableDictionary alloc]init];
    [_saveData setObject:@"" forKey:@"status"];
    [_saveData setObject:@"" forKey:@"message"];
    [_saveData setObject:@"" forKey:@"callback"];
    [_saveData setObject:@"" forKey:@"value"];
    return self;
}

//请求数据，并转成json。
-(NSData *)work
{
 
        [_saveData setObject:[self.requestJson objectForKey:@"callback"] forKey:@"callback"];
        self.argsDic = [self.requestJson objectForKey:@"args"];
        NSString *action = [self.requestJson objectForKey:@"action"];
        SEL selector = NSSelectorFromString(action);
        if ([self respondsToSelector:selector])
        {
            [self performSelector:selector withObject:nil];

        }else {
            NSLog(@"AppReqeuest.%@未实现",action);
        }
    
    
    return [self getResultData];
}
-(bool)hasAction;
{
    NSString *action = [self.requestJson objectForKey:@"action"];
    SEL selector = NSSelectorFromString(action);
    return [self respondsToSelector:selector];
}
-(NSData *)getResultData
{
    
    return [NSJSONSerialization dataWithJSONObject:_saveData options:NSJSONWritingPrettyPrinted error:nil];
}

-(void)success
{
    [_saveData setObject:@"success" forKey:@"status"];
}
-(void)fail:(NSString *)errorStr
{
    NSLog(@"请求失败");
    [_saveData setObject:errorStr forKey:@"message"];
    [_saveData setObject:@"" forKey:@"status"];
}
-(void)callback
{

    NSData *data  = [self getResultData];
    self.Callback(data);

}
-(void)getNetworkType
{
    NSLog(@"2222");
    int netWork = [CheckNetwork checkNetwork];
    NSString *value = @"";
    if (netWork == 1)
    {
        value = @"mobile";
    
    }else if (netWork == 2)
    {
        value = @"wifi";
    }
    [_saveData setObject:value forKey:@"value"];
    NSLog(@"iiiiiiiiiiiii%@",[_saveData objectForKey:@"value"]);
    [self success];

}

//重新加载app，比如可以重启应用或者重新加载首页
-(void)reload
{
    [[ViewController viewControllerManager] reloadWbview];
    [self success];
}
//功能退出应用
-(void)exit;
{
  ////退出应用,系统方法。
    exit(0);

}

-(void)getApiLeval
{
    
    [_saveData setValue:[NSNumber numberWithInt:[Config GetApiLevel]] forKey:@"value"];
    
    [self success];

}

//获取经纬度
-(void)getLocation
{
    self.isAsync=true;
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        [[GetLocationViewController getViewControllerManager] getLocation];
        
    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getLoctionValue:) name:@"locationDict" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoctionValueFail:) name:@"locationFail" object:nil];
    
}
//通知获取经纬度
-(void)getLoctionValue:(NSNotification *)sender
{
    if (sender!=nil) {
    [_saveData setValue:sender.object forKey:@"value"];
    [self success];
    [self callback];   
   }
     [[NSNotificationCenter defaultCenter]removeObserver:self name:@"locationDict" object:nil];
}

//定位失败通知
-(void)getLoctionValueFail:(NSNotification *)sender
{
    [_saveData setObject:@"定位失败" forKey:@"message"];
    [self callback];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"locationFail" object:nil];
}

//是否支持扫描二维码
-(void)supportScanQRCode
{
    [_saveData setObject:[NSNumber numberWithBool:true] forKey:@"value"];
    [self success];
}
//扫描二维码z
//扩展属性(boolean)failByBack:如果是用户退出扫描，必须返回failByBack=true，否则会认为扫描异常
-(void)scanQRCode
{
    self.isAsync=true;
    self.scanBarCodebool=false;
    self.view = [ViewController viewControllerManager];
    self.view.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanImageValue:) name:@"data" object:nil];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
          [self.view GoZbarView];
    });
}
//是否支持扫描条形码
-(void)supportScanBarCode
{
    [_saveData setObject:[NSNumber numberWithBool:true] forKey:@"value"];
    [self success];
}
-(void)scanBarCode
{
    self.isAsync=true;
    self.scanBarCodebool=true;
    self.view = [ViewController viewControllerManager];
    self.view.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanImageValue:) name:@"data" object:nil];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [self.view GoZbarView];
    });
}
#pragma viewDelegate
-(void)passValue:(bool)isbask and:(bool)isError and:(NSString*)scanstr;
{
     if (isbask)
    {
        [_saveData setObject:[NSNumber numberWithBool:isbask] forKey:@"failByBack"];
        [self callback];
    }
    else
    {
            if (isError) {
            [_saveData setObject:scanstr forKey:@"message"];
        }else{

            if (self.scanBarCodebool)
            {
                bool isBool;
                isBool=[self isPureInt:scanstr];

                if (isBool)
                {
                    [_saveData setObject:scanstr forKey:@"value"];
                    [self success];

                }else
                {
                    [_saveData setObject:@"条码识别有误" forKey:@"message"];
                }
            }else
            {
            [_saveData setObject:scanstr forKey:@"value"];
            [self success];
            }
        }
    

        [self callback];
    }
}
//判断字符串是不是int
- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

-(void)scanImageValue:(NSNotification *)sender
{
    if (sender.object)
    {
        [_saveData setObject:sender.object forKey:@"value"];
    
        [self success];
        [self callback];
    }
    
}
//获得版本号
-(void)getVersion
{
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (build==nil) {
        
         build=@"1.0";
        
    }
    [_saveData setObject:build forKey:@"value"];
    [self success];

 }


//隐藏键盘
-(void)hideKeyboard
{
    NSLog(@"隐藏键盘");
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
           [[ViewController viewControllerManager].view endEditing:true];
    });
}
//界面上提示一段文字信息，过段时间自动消失
-(void)tips
{
    NSString * message = [self.argsDic objectForKey:@"message"];
    
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
    [[[alertLabel alloc] init] alertLabelShowTitle:message view:[ViewController viewControllerManager].view];
    });
}
//获取应用截图
-(void)getViewImage
{
    self.isAsync=true;
    //已注册的通知进行实现
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}
//监听截图
-(void)userDidTakeScreenshot:(NSNotification*)notification
{
    NSLog(@"检测到截屏");
    
    UIImage*image=[self imageWithScreenshot];
    
    if (image)
    {
        //压缩0.8  0.0-1.0图片质量从低到高
        NSData *imageData = UIImageJPEGRepresentation(image, 0.3f);
        
        NSString *userImageData = [GTMBase64  stringByEncodingData:imageData];
        
        NSMutableDictionary *imageDict  =[[NSMutableDictionary alloc] init];
        [imageDict setValue:userImageData forKey:@"data"];
        [imageDict setValue:@"image/png" forKey:@"mime"];
        if ([_saveData objectForKey:@"value"]) {
            
            [_saveData setValue:imageDict forKey:@"value"];
            [self success];
            [self callback];
            _saveData = [[NSMutableDictionary alloc]init];
        }
        
    }else
    {
        [_saveData setValue:[NSNumber numberWithBool:true] forKey:@"failByBack"];
        [self callback];
    }

}
//
-(NSData*)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
    
    
}
-(UIImage*)imageWithScreenshot;
{
    NSData *imageData=[self dataWithScreenshotInPNGFormat];
    
    return [UIImage imageWithData:imageData];
    
}
//执行页面跳转的方法
-(void)animCreate
{
    [self success];
    
}
//显示执行界面动画
-(void)animStart
{
    self.isAsync=true;
    [self success];
}
//获取应用当前版本运行次数，如果本版本未设置运行次数返回0，应用什么情况下判定为启动过一次由服务器控制
-(void)getVersionStartCount
{
    [_saveData setObject:[NSNumber numberWithInt:[self readVersionStartCount]] forKey:@"value"];
    [self success];
}
//增加应用当前版本运行次数+1，应用什么情况下判定为启动过一次由服务器控制
-(void)incrementVersionStartCount
{
    [self saveVersionStartCount:[self readVersionStartCount]+1];
    [self success];
}
-(int)readVersionStartCount;{
    //获取原来的，判断过了不会为nil
    NSString *oldVersion=[SaveData getData:@"VersionStartPrev"];
    //得到系统版本号
    NSString *systemVersion=[SaveData getVersion];
    [SaveData setData:@"VersionStartPrev" andValue:systemVersion];
    int count=0;
    if([systemVersion isEqualToString:oldVersion]){
        count=[[SaveData getData:@"VersionStartCount"] intValue];
    }else{
        [self saveVersionStartCount:count];
    }
    return count;
}
-(void)saveVersionStartCount:(int) count;
{
    [SaveData setData:@"VersionStartCount" andValue:[NSString stringWithFormat:@"%d",count]];
}
//获取应用缓存页面数据的最后修改时间
-(void)getLastModified
{
    [_saveData setObject:[NSNumber numberWithLong:[SaveData getLastModified]] forKey:@"value"];
    [self success];
}
//设置应用缓存页面数据的最后修改时间
-(void)setLastModified
{
    [SaveData setLastModified:[[self.argsDic objectForKey:@"lastModified"] integerValue]];
    [self success];
}

//设置应用背景颜色
-(void)setBackgroundColor
{
    NSString * setBackgroundColor = [self.argsDic objectForKey:@"color"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"viewchange" object:setBackgroundColor];
    [self success];
}

//获取应用启动时背景颜色
-(void)getStartBackgroundColor
{
    NSString *string=[defualt objectForKey:@"setStartBackgrond"];
    if (string==nil) {
        NSString*get=[Config GetStartBackgroundColor];
        defualt=[NSUserDefaults standardUserDefaults];
        //把这个数值存起来
        [defualt setObject:get forKey:@"getStartBackgroundColor"];
        //同步
        [defualt synchronize];

        [_saveData setObject:get forKey:@"value"];
        [self success];

    }
    else
    {
        defualt=[NSUserDefaults standardUserDefaults];
        //把这个数值存起来
        [defualt setObject:string forKey:@"getStartBackgroundColor"];
        //同步
        [defualt synchronize];
        [_saveData setObject:string forKey:@"value"];
        [self success];
    }
}
//设置应用启动时背景颜色，应用启动时app应该自动使用上次设置的值，如果未设置，固定使用配置中的背景颜色值
-(void)setStartBackgroundColor
{
         NSString*setStartBackground=[self.argsDic objectForKey:@"color"];
        //归档
        defualt=[NSUserDefaults standardUserDefaults];
        //把这个数值存起来
        [defualt setObject:setStartBackground forKey:@"setStartBackgrond"];
        //同步
        [defualt synchronize];
  
    
}
//设置可以缓存请求数据的主机地址，如果访问未设置的主机不进行缓存操作，程序默认要缓存本应用地址
-(void)allowCacheHost
{
    [SaveData addCacheHost:[_argsDic objectForKey:@"host"]];
}
//获取存储字段值，通过平台实现永久存储
-(void)getStorage
{
    NSString * getStorageValue = [SaveData getData:[self.argsDic objectForKey:@"key"]];
    [_saveData setValue:getStorageValue forKey:@"value"];
    [self success];
}

//设置存储字段值，通过平台实现永久存储
-(void)setStorage
{
    defualt = [NSUserDefaults standardUserDefaults];
    NSString *setStorageValue = [self.argsDic objectForKey:@"value"];
    NSString *setStorageKey = [self.argsDic objectForKey:@"key"];
    [SaveData setData:setStorageKey andValue:setStorageValue];
    [self success];
 
}

-(void)supportChoiceImage
{
    [_saveData setObject:[NSNumber numberWithBool:true]forKey:@"value"];
    [self success];
}
-(void)choiceImage
{
    self.isAsync=true;
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{

            [[EditImageViewController editViewControllerManager] getImage:self.argsDic];
    });
    //获得图片的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetUserimage:) name:@"reSizeImage" object:nil];
    ;
    //获得取消的回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pot) name:@"imagePickerControllerDidCancel" object:nil];
}
-(void)pot
{
    [_saveData setValue:[NSNumber numberWithBool:true] forKey:@"failByBack"];
    [self callback];

}
//获取用户裁剪后的头像
-(void)GetUserimage:(NSNotification *)sender
{
  
    NSLog(@"savedata %@",[_saveData objectForKey:@"callback"]);
    if (sender.object)
    {
        //压缩0.8  0.0-1.0图片质量从低到高
        NSData *imageData = UIImageJPEGRepresentation(sender.object,0.8f);
        
        NSString *userImageData = [GTMBase64  stringByEncodingData:imageData];
        
        NSMutableDictionary *imageDict  =[[NSMutableDictionary alloc] init];
        
        [imageDict setValue:userImageData forKey:@"data"];
        [imageDict setValue:@"image/jpg" forKey:@"mime"];
        
        NSLog(@"%@   njnwjibcdhsacbhd  jnebfce  我是图片选择",[_saveData objectForKey:@"value"]);
        if ([[_saveData objectForKey:@"value"] isEqualToString:@""]) {
        
            [_saveData setValue:imageDict forKey:@"value"];
            [self success];
            [self callback];
            _saveData = [[NSMutableDictionary alloc]init];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reSizeImage" object:nil];

        }
       
    }else
    {
        [_saveData setValue:[NSNumber numberWithBool:true] forKey:@"failByBack"];
        [self callback];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reSizeImage" object:nil];

    }
    
    if (isGetImage == false)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reSizeImage" object:nil];
        
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reSizeImage" object:nil];
}

//用户选择照片取消选择
-(void)cancleSelect
{
    NSLog(@"取消回调");
}
-(void)supportSendSMSCaptcha
{
    [_saveData setObject:[NSNumber numberWithBool:true] forKey:@"value"];
    [self success];
}

//发送短信验证码
-(void)sendSMSCaptcha
{
    NSLog(@"发送短信验证码");
    self.isAsync=true;
    NSString *telNumber =[Unit JSONString:self.argsDic key:@"tel"];
    NSString *zone  =[Unit JSONString:self.argsDic key:@"zone"];
    NSString *tryCountStr =[Unit JSONString:self.argsDic key:@"tryCount"];
    NSString*key=[Unit JSONString:self.argsDic key:@"key"];
    NSString*secrect=[Unit JSONString:self.argsDic key:@"secret"];
    
    [SMSSDK registerApp:key withSecret:secrect];
    
    int tryCount = [tryCountStr intValue];
    
    NSLog(@"tryCount %d %@ %@",tryCount,key,secrect);
    
    int method;//调用发送验证码的方法 0为短信发送  1为语音发送
    
    if (tryCount <= 2)
    {
        method = 0;
    }else
    {
        method = 1;
    }
    NSLog(@"code  主线程%@",[NSThread currentThread]);
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        [SMSSDK getVerificationCodeByMethod:method phoneNumber:telNumber zone:zone customIdentifier:nil result:^(NSError *error) {
            if (!error)
            {
                NSLog(@"验证码发送成功");
                [_saveData setObject:[NSNumber numberWithBool:true] forKey:@"value"];
                [self success];
            }
            else
            {
                NSLog(@"发送错误");
                [_saveData setObject:[NSNumber numberWithBool:false]forKey:@"value"];
            }
            [self callback];
        }];
    });
}

//是否支持支付宝支付，
-(void)supportPingxxPayAlipay
{
    [_saveData setObject:[NSNumber numberWithBool:true] forKey:@"value"];
    [self success];
}

//是否支持微信支付
-(void)supportPingxxPayWeixin
{
    [_saveData setObject:[NSNumber numberWithBool:true] forKey:@"value"];
    [self success];
    
}

//客户端调用支付 异步 , 这个有回调可以运行
-(void)pingxxPay
{
    self.isAsync=true;
    NSString *charge = [_argsDic objectForKey:@"charge"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [Pingpp createPayment:charge viewController:nil appURLScheme:[Config GetPingxxPay] withCompletion:^(NSString *result, PingppError *error) {
            NSLog(@"completion block: %@", result);
            if ([result isEqualToString:@"cancel"])//取消支付
            {
                [_saveData setObject:@(true) forKey:@"failByBack"];
                
            }else if ([result isEqualToString:@"success"])//支付成功
            {
                //支付成功返回true
                [_saveData setObject:@(true) forKey:@"value"];
                [self success];
            }else if (error)
            {
                //支付失败返回false
                [_saveData setValue:@(false)forKey:@"value"];
                [self success];
            }
            [self callback];
        }];
    });
}
//用外部应用打开uri，比如浏览器打开url地址
-(void)openURI
{
    NSString * openUrl = [_argsDic objectForKey:@"uri"];
    if (openUrl)
    {
        //打开系统浏览器
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
    }
   
}

//是否支持分享
-(void)supportShare
{
    [_saveData setObject:[NSNumber numberWithBool:true] forKey:@"value"];
    [self success];
}

//分享
-(void)share
{  
      self.isAsync=true;
        //分享内容
    NSString *contentStr = [_argsDic objectForKey:@"content"];
        //分享图片地址
    NSString *imageUrlStr =[_argsDic objectForKey:@"imageUrl"];
        //分享地址
    NSString *urlStr =[_argsDic objectForKey:@"url"];
    
    NSString*tiher=[_argsDic objectForKey:@"title"];

    
[[ViewController viewControllerManager] UIViewurl:urlStr andimage:imageUrlStr andcontentStr:contentStr andtither:tiher];
        //分享成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareGetUMSocial:) name:@"shareGetUMSocial" object:nil];
    ;
        //分享失败回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(FinishGetUMSocial:) name:@"FinishGetUMSocial" object:nil];
        //分享取消回调
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CencelGetUMSocial:) name:@"CancelGetUMSocial" object:nil];

    
   }
-(void)shareGetUMSocial:(NSNotification*)obj;
{
    
    [_saveData setObject:[NSString stringWithFormat:@"已成功分享到%@",obj.object] forKey:@"value"];
    [self success];
    [self callback];
}

-(void)FinishGetUMSocial:(NSNotification*)obj;
{
    [_saveData setObject:[NSString stringWithFormat:@"分享到%@失败",obj.object] forKey:@"value"];
    [self callback];
}
-(void)CencelGetUMSocial:(NSNotification*)obj;{
    
    [_saveData setObject:[NSString stringWithFormat:@"已取消分享到%@",obj.object] forKey:@"value"];
    [_saveData setValue:[NSNumber numberWithBool:true] forKey:@"failByBack"];
    [self callback];
}


//设置socket地址，设置后应该立即重启socket连接处理逻辑
-(void)setSocketUrl
{
    //获取设置的url
    NSString * url= [Unit JSONString:self.argsDic key:@"url"];
    [SaveData setData:@"WebSocketUrl" andValue:url];

    [[SrocketViewController Instance]Init];
    
    [_saveData setObject:url forKey:@"value"];
    [self success];
}
//获取设置的socket地址
-(void)getSocketUrl
{
    NSString*string=[SaveData getData:@"WebSocketUrl"];
    [_saveData setObject:string forKey:@"value"];
    [self success];
    
}
//检测socket是否已可以用，可以收发数据
-(void)socketAvailable
{
    [_saveData setObject:[NSNumber numberWithBool:[[SrocketViewController Instance] Available]] forKey:@"value"];
    [self success];
}
//调用socket发送服务器命令，相当于app自己调用相应命令，和AppCmd类似，回调需要处理的必须处理（可以共用一套处理逻辑），然后把服务器返回的数据字符串返回
-(void)socketCmd
{
    self.isAsync=true;
    NSString*cmd=[self.argsDic objectForKey:@"cmd"];
    NSString*data=[self.argsDic objectForKey:@"data"];
    NSString*args=[self.argsDic objectForKey:@"args"];
    void(^callback)(NSString*,bool);
    callback=^(NSString*data,bool isError)
    {
        if (isError) {
            [_saveData setObject:data forKey:@"message"];
        }else{
            [_saveData setObject:data forKey:@"value"];
            [self success];
        }
        [self callback];
    };
    [[SrocketViewController Instance]sendCmd:cmd args:args data:data callback:callback];
}
//每10秒通知app软件正在正常运行，如果上次通知时间和当前时间超过13秒认为软件不在正常运行
-(void)appRun;
{
    [SrocketViewController AppRun];
}
//支持WebSocket的版本号，老版本为1，支持wss为2
-(void)socketVersion
{
        //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:2] forKey:@"value"];
    [self success];


}
//蓝牙打印版本，当前为1
-(void)bluetoothPrinterVersion
{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:1] forKey:@"value"];
    [self success];
}
//尝试打开蓝牙开关设置界面用户，让用户打开蓝牙
-(void)viewBluetoothOpenSetting
{

    float System=[[[UIDevice currentDevice] systemVersion] floatValue];
  
    if (System<10.0) {
         NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }

    }
    else
    {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
        [[UIApplication sharedApplication] openURL:url];
        }
    }
    //version  默认为1
    [_saveData setObject:[NSNumber numberWithBool:true]  forKey:@"value"];
    [self success];


}
//开始扫描蓝牙设备【异步】
-(void)startBluetoothScan

{
   
    int timeout=[Unit JSONInt:self.argsDic key:@"timeout"];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        [Bluetooth ScanStart:^(Status *status) {
            [status FillResult:_saveData];
            [self success];
            [self callback];
        } :timeout];
    });

}
//停止扫描蓝牙设备【异步】
-(void)stopBluetoothScan
{
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
       [Bluetooth ScanStop:^(Status *status) {
           [status FillResult:_saveData];
           [self success];
           [self callback];
       }];
    });
   
}
//获取当前这次扫描已经得到的蓝牙设备列表
-(void)getBluetoothScanList
{
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{

        [Bluetooth ScanList:^(Status *status, NSMutableArray *array) {
            
            [status.Data setObject:[NSNumber numberWithBool:[Bluetooth IsScan]] forKey:@"isRun"];
            [status.Data setObject:[self _getBluetoothList:array] forKey:@"items"];
            
            [status FillResult:_saveData];
            [self success];
            [self callback];

        }];
        
    });
}
-(NSMutableArray*)_getBluetoothList:(NSMutableArray*)array
{
    NSMutableArray*items=[[NSMutableArray alloc]init];
    for (CBPeripheral*p in array)
    {
        //返回类型
        NSString*name=@"";
        NSString*UUId=@"";
        if (p.name!=nil) {
            name=p.name;
        }
        if (p.identifier.UUIDString!=nil) {
            UUId=p.identifier.UUIDString;
        }
        NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
        [dic setObject:name forKey:@"name"];
        [dic setObject:UUId forKey:@"identify"];
        [dic setObject:@"" forKey:@"type"];
        [items addObject:dic];
    }
    return items;
}
//已经连上过的蓝牙列表【异步】
-(void)getReadyBluetoothList
{
    
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [Bluetooth ScanReadyList:^(Status *status, NSMutableArray *array) {
            [status.Data setObject:[self _getBluetoothList:array] forKey:@"items"];
            
            [status FillResult:_saveData];
            [self success];
            [self callback];
            
        }];
    });

}

//测试指定设备是否是蓝牙打印机，并且可以打印，如果不符合要，给出状态码【异步】
-(void)testBluetoothPrint
{
    
    NSString*identify=[Unit JSONString:self.argsDic key:@"identify"];
        dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
         Print*print=[[Print alloc]init];
        [print Open:^(Status *status) {
            [status FillResult:_saveData];
            [self success];
            [self callback];

        [print Close:^(Status *xxx) {}];
        } :identify];
    
    });
}

//打印数据
-(void)bluetoothPrint
{
    
    NSString*identify=[Unit JSONString:self.argsDic key:@"identify"];
      dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
 
        Print*print=[[Print alloc]init];
        [print Open:^(Status *status) {
            if (![status IsNormal]) {
                [status FillResult:_saveData];
                [self success];
                [self callback];
                return ;
            }
            [print Print:[Unit JSONObject:self.argsDic key:@"data"] :^(Status *status) {
                sleep(10);
                [status FillResult:_saveData];
                [self success];
                [self callback];
                [print Close:^(Status *xxx) {}];
            }];
        } :identify];
    });
    
}
   //复制粘贴版本，当前为1
-(void)copyPasteVersion;
{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:1] forKey:@"value"];
    [self success];
}
//复制内容到剪贴板，出错时message=给用户的错误提示
-(void)setCopyPaste
{
    //文本
    NSMutableDictionary*data=[Unit JSONObject:self.argsDic key:@"data"];

    NSString*type=[data objectForKey:@"type"];
    NSString*value=[data objectForKey:@"value"];

    if ([type isEqualToString:@"text"])
    {
       UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string =value;
    
    }
    [self success];
  }
//获取剪贴板内容，出错时message=给用户的错误提示
-(void)getCopyPaste;
{

    NSString*type=[Unit JSONString:self.argsDic key:@"type"];

    if ([type isEqualToString:@"text"])
    {
        UIPasteboard *pasteboard =[UIPasteboard generalPasteboard];
        NSString*value= pasteboard.string;

        [_saveData setObject:value forKey:@"value"];

    }
    else
    {

     [_saveData setObject:@"文本格式出错" forKey:@"message"];
    }

     [self success];
     [self callback];

}
//传感器版本
-(void)sensorVersion
{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:1] forKey:@"value"];
    [self success];
}
//如果打开了，在10秒内没有再次调用，自动关闭相应的传感器监听。
-(void)openSensor
{
    NSString*sensor=[Unit JSONString:self.argsDic key:@"sensor"];
    
    if ([sensor isEqualToString:@"shake"]) {
        
        if (ShakeTime == nil) {
            [ShakeTime invalidate];
            ShakeTime=nil;
        }

        [[ViewController viewControllerManager]openShake];
        ShakeTime=[NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(shaketime) userInfo:nil  repeats:NO];
    }
    if ([sensor isEqualToString:@"orientation"]) {
        
        if (OrignTime == nil) {
            [OrignTime invalidate];
            OrignTime=nil;
        }

        [[Cmmotion getCmmotionManager]openCmmotion];

        OrignTime=[NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(origntime) userInfo:nil  repeats:NO];
    }
    if ([sensor isEqualToString:@"location"]) {
        
        if (LocationTime == nil) {
            [LocationTime invalidate];
            LocationTime=nil;
        }
        [[Location getLocationManager]openLocation];
        LocationTime=[NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(locationtime) userInfo:nil  repeats:NO];
        
        if (getLocationTime==nil) {
            getLocationTime=[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(getlocationtime) userInfo:nil  repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:getLocationTime forMode:NSDefaultRunLoopMode];

        }
    }
}
-(void)getlocationtime
{
    if (getLocationTime!=nil) {
         [[Location getLocationManager]openLocation];
    }

}
-(void)shaketime{

        if (ShakeTime!=nil) {
            [ShakeTime invalidate];
            ShakeTime=nil;
        }
    [[ViewController viewControllerManager]closeShake];

}
-(void)origntime
{

        if (OrignTime!=nil) {
            [OrignTime invalidate];
            OrignTime=nil;
        }
       [[Cmmotion getCmmotionManager]closeCmmotion];

}
-(void)locationtime
{
        if (LocationTime!=nil) {
            [LocationTime invalidate];
            LocationTime=nil;
        }
        if (getLocationTime!=nil) {
            [getLocationTime invalidate];
            getLocationTime=nil;
        }
        [[Location getLocationManager]closeLocation];


}
//关闭相应的传感器监听
-(void)closeSensor
{
    NSString*sensor=[Unit JSONString:self.argsDic key:@"sensor"];
    if ([sensor isEqualToString:@"shake"]) {
        if ( ShakeTime!=nil) {
            [ShakeTime invalidate];
            ShakeTime=nil;
        }
        [[ViewController viewControllerManager]closeShake];
    }
    if ([sensor isEqualToString:@"orientation"]) {
        if (OrignTime!=nil) {
            [OrignTime invalidate];
            OrignTime=nil;
        }
        [[Cmmotion getCmmotionManager]closeCmmotion];
    }
    if ([sensor isEqualToString:@"location"]) {
        if (LocationTime!=nil) {
            [LocationTime invalidate];
            LocationTime=nil;
        }
        if (getLocationTime!=nil) {
            [getLocationTime invalidate];
            getLocationTime=nil;
        }
        [[Location getLocationManager]closeLocation];
    }
}
//保存文件版本
-(void)saveFileVersion
{
    float System=[[[UIDevice currentDevice] systemVersion] floatValue];
    //version  默认为1
    int value=1;
    if (System<7.0) {
        value=0;
    }
    [_saveData setObject: [NSNumber numberWithInt:value] forKey:@"value"];
    [self success];


}
//保存文件数据，到一个通用的文件，比如用户文档里面
-(void)saveFile
{
    float System=[[[UIDevice currentDevice] systemVersion] floatValue];
        //version  默认为1
  
    if (System<7.0) {
        [_saveData setObject: [NSNumber numberWithInt:0] forKey:@"value"];
        [_saveData setObject:[NSString stringWithFormat:@"不支持保存文件"] forKey:@"message"];
        [self callback];
        
        return;
    }

    
   
    NSString*name=[Unit JSONString:self.argsDic key:@"name"];
    NSString*data=[Unit JSONString:self.argsDic key:@"data"];
    NSMutableDictionary*dict=[[NSMutableDictionary alloc]init];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
    SaveFile*saveflie=[[SaveFile alloc]init];
    [saveflie save:^(bool test, NSString *message, NSString *path) {
        if (test) {
            if (![path isEqualToString:@""]) {
                    //回到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.documentCom = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
                    self.documentCom.delegate = self;
                    
                    [self.documentCom presentOpenInMenuFromRect:[ViewController viewControllerManager].view.bounds inView:[ViewController viewControllerManager].view animated:YES];
                });
            }
        }
            [dict setObject:path forKey:@"path"];
            [dict setObject:path forKey:@"viewPath"];
            [_saveData setObject:message forKey:@"message"];
            [_saveData setObject:dict forKey:@"value"];
            [self success];
            [self callback];
        } name:name :data];
    
    });

}
    //新消息通知用户，发出系统消息铃声、震动
-(void)newMessageNotice
{
    
    int voice=[[_argsDic objectForKey:@"voice"]intValue];
    
    int vibrate=[[_argsDic objectForKey:@"vibrate"]intValue];
    
    [Notice NewMessageNotice:voice and:vibrate Volume:1];
}
    //新订单消息通知，发出新订单铃声、震动
-(void)newOrderNotice
{
    int voice=[[_argsDic objectForKey:@"voice"]intValue];
    
    int vibrate=[[_argsDic objectForKey:@"vibrate"]intValue];
    
    [Notice NewOrderNotice:voice and:vibrate Volume:1];
    
}
    //新订单消息通知，发出催单铃声、震动
-(void)newOrderCuiDanNotice
{
    int voice=[[_argsDic objectForKey:@"voice"]intValue];
    
    int vibrate=[[_argsDic objectForKey:@"vibrate"]intValue];
    
    [Notice NewOrderCuiDanNotice:voice and:vibrate Volume:1];
    
}


    //显示事件系统通知
-(void)eventNotify
{
    NSString*from=[self.argsDic objectForKey:@"from"];
    NSString*data=[self.argsDic objectForKey:@"data"];
    
    if([from isEqualToString:@"User"]){
        [[SrocketViewController Instance] ExecUserMessageRequest:data];
    }else if([from isEqualToString:@"Chat"]){
        [[SrocketViewController Instance] ExecChatMessageRequest:data];
    }else if([from isEqualToString:@"System"]){
        [[SrocketViewController Instance] ExecSystemMessageRequest:data];
    }else{
        [_saveData setObject:[NSString stringWithFormat:@"无法识别：%@",from] forKey:@"message"];
    }
    [self success];
}
    //取消事件显示的系统通知
-(void)eventCancelNotify
{
    NSString*type=[self.argsDic objectForKey:@"type"];
    
    [Notice CancelNotice:type];
    [self success];
}
//通知app事件已处理，参考Event
-(void)eventReceive
{
    NSString*data=[self.argsDic objectForKey:@"data"];
    bool useNotify=[Unit JSONBool:self.argsDic key:@"useNotify"];
    if (useNotify) {
        
        [Notice Notice:[Unit ParseJSONObject:data]];
    }
    //设置一个app事件已处理的通知，在客户端打开处接收，判断超时
    [[NSNotificationCenter defaultCenter]postNotificationName:@"eventReceiveNotice" object:nil];
    [self success];
}

//播放声音列表
-(void)playSounds
{
  
    NSMutableArray*array=[Unit JSONArray:self.argsDic key:@"sounds"];
    
    int voice=[[_argsDic objectForKey:@"voice"]intValue];
    
    int vibrate=[[_argsDic objectForKey:@"vibrate"]intValue];
    
    
    NSMutableDictionary*dict=[[NSMutableDictionary alloc]init];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        PlaySounds*playsounds=[[PlaySounds alloc]init];
        [playsounds  play:^(bool type, NSString *message) {
            if (!type) {
                [_saveData setObject:message forKey:@"message"];
            }
            [_saveData setObject:dict forKey:@"value"];
            [self success];
            [self callback];
        } :array voice:voice vibrate:vibrate];
    });
}
-(void)pushVersion
{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:1] forKey:@"value"];
    [self success];
}
//注册推送通道
-(void)regPush
{
    NSMutableArray*array=[Unit JSONArray:self.argsDic key:@"channels"];

    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{

        for (NSString*type in array) {
            if ([type isEqualToString:@"umeng"]){
                    //是否注册
                NSString*test=[SaveData getData:@"deviceToken"];
                if ([test isEqualToString:@""]) {
                    [AppDelegate UmengPush:true];
                }else{
                    [self deviceToken:test];
                }
                    //umeng注册超时
                if (self.UmengTime!=nil) {
                    [self.UmengTime invalidate];
                    self.UmengTime=nil;
                }
                self.UmengTime=[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(deviceTokenTime) userInfo:nil  repeats:NO];
                
            }
        }
    });
    //获得注册的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceTokenNotification:) name:@"deviceTokenNotification" object:nil];
    ;

}
//注册成功的回调
-(void)deviceTokenNotification:(NSNotification*)obj;
{
    [self deviceToken:obj.object];
}
//Umeng注册失败的回调
-(void)deviceTokenTime
{
    //构造返回数据
    NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
    NSMutableArray*array=[[NSMutableArray alloc]init];
    NSMutableDictionary*data=[[NSMutableDictionary alloc]init];
    NSString*channel=@"umeng";
    NSString*id=@"";
    bool isError=true;
    NSString*message=@"设备注册超时";
    
    [dic setObject:channel forKey:@"channel"];
    [dic setObject:id forKey:@"id"];
    [dic setObject:[NSNumber numberWithBool:isError] forKey:@"isError"];
    [dic setObject:message forKey:@"message"];
    
    
    [array addObject:dic];
    
    
    [data setObject:array forKey:@"channels"];
    
    [self.saveData setObject:data forKey:@"value"];
    [self success];
    [self callback];
    
    //定时器取消
    if (self.UmengTime!=nil) {
        [self.UmengTime invalidate];
        self.UmengTime=nil;
    }

}
//Umeng注册成功的回调
-(void)deviceToken:(NSString*)obj;
{
    //构造返回数据
    NSMutableDictionary*dic=[[NSMutableDictionary alloc]init];
    NSMutableArray*array=[[NSMutableArray alloc]init];
    NSMutableDictionary*data=[[NSMutableDictionary alloc]init];
    NSString*channel=@"umeng";
    NSString*id=@"";
    bool isError=false;
    NSString*message=@"";
    if ([obj isEqualToString:@""])
    {
        isError=true;
        message=@"唯一标示为空";
    }else{
        id=obj;
    }
    
    [dic setObject:channel forKey:@"channel"];
    [dic setObject:id forKey:@"id"];
    [dic setObject:[NSNumber numberWithBool:isError] forKey:@"isError"];
    [dic setObject:message forKey:@"message"];
    
    
    [array addObject:dic];
    
    
    [data setObject:array forKey:@"channels"];
    
    [self.saveData setObject:data forKey:@"value"];
    [self success];
    [self callback];
    
        //定时器取消
    if (self.UmengTime!=nil) {
        [self.UmengTime invalidate];
        self.UmengTime=nil;
    }
}

//Level 6
//qq登录版本号，当前为1
-(void)oauthQQVer{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:1] forKey:@"value"];
    [self success];
}
-(void)oauthQQ{
    
    NSMutableArray*array=[Unit JSONArray:self.argsDic key:@"scope"];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [[oaythClass getoaythClass]getoauthQQ:array];
    });
        //获得qq的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFunoction:) name:@"oauthQQNotification" object:nil];
    ;
    
}








//微信登录版本号，当前为1
-(void)oauthWeixinVer{
    [_saveData setObject: [NSNumber numberWithInt:1] forKey:@"value"];
    [self success];
}
-(void)oauthWeixin{
    NSMutableArray*array=[Unit JSONArray:self.argsDic key:@"scope"];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [[oaythClass getoaythClass]getoauthWeixin:array];
    });
    //获得weixin的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFunoction:) name:@"oauthWeixinNotification" object:nil];
    ;
}







//微博登录版本号，当前为1
-(void)oauthWeiboVer{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:1] forKey:@"value"];
    [self success];
}
-(void)oauthWeibo{
    
    NSMutableArray*array=[Unit JSONArray:self.argsDic key:@"scope"];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [[oaythClass getoaythClass]getoauthWeibo:array];
    });
    //获得weibo的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFunoction:) name:@"oauthWeiboNotification" object:nil];
    ;
}



//回调
-(void)getFunoction:(NSNotification*)obj{
    
    NSMutableDictionary*dic=obj.object;
    NSString*success=[dic objectForKey:@"success"];
        //构造返回数据
    NSMutableDictionary*data=[[NSMutableDictionary alloc]init];
    
    if ([success isEqualToString:@"success"]) {
        data=dic;
        [self success];
        [self.saveData setObject:data forKey:@"value"];
        
    }else if([success isEqualToString:@"fail"]){
        
        [_saveData setObject:[dic objectForKey:@"message"] forKey:@"message"];
        
    }else if([success isEqualToString:@"cancel"]){
        [_saveData setValue:[NSNumber numberWithBool:true] forKey:@"failByBack"];
        
    }
    [self callback];
}



//支付宝登录版本号，当前为0，不支持
-(void)oauthAlipayVer{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:0] forKey:@"value"];
    [self success];
}
-(void)oauthAlipay{
    [_saveData setObject:@"当前版本不支持" forKey:@"message"];
    [self callback];
}



//淘宝登录版本号，当前为0，不支持
-(void)oauthTaobaoVer{
    //version  默认为1
    [_saveData setObject: [NSNumber numberWithInt:0] forKey:@"value"];
    [self success];
}
-(void)oauthTaobao{
    [_saveData setObject:@"当前版本不支持" forKey:@"message"];
    [self callback];
}





-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"imagePickerControllerDidCancel" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"locationDict" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"locationFail" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"eventReceiveNotice" object:nil];
    [super dealloc];
}
@end
