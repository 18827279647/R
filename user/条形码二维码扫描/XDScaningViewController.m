//
//  XDScaningViewController.m
//  XDQRCode
//
//  Created by DINGYONGGANG on 15/9/26.
//  Copyright (c) 2015年 DINGYONGGANG. All rights reserved.

#import "XDScaningViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ZBarSDK.h"
#import "SaveData.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface XDScaningViewController ()<UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate, XDScanningViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,ZBarReaderDelegate>{

    UIImageView *iv;
    BOOL isTorchOn;
}
@property(nonatomic,strong)AVCaptureDevice *frontCamera;
@property(nonatomic,strong) AVCaptureDevice *backCamera;
@property(nonatomic,strong)AVCaptureSession *session;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic,strong)AVCaptureInput *input;
@property(nonatomic,strong)AVCaptureMetadataOutput *output;

@property (nonatomic, assign) XDScaningWarningTone tone;
@property (nonatomic, strong) XDScanningView *overView;
@property (nonatomic,strong)UIView *XDshareview;
@end

@implementation XDScaningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCapture];
    [self initUI];
    [self addGesture];
    [self config];
    
}

- (void)config{
    _tone = XDScaningWarningToneSound;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initOverView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.overView removeFromSuperview];
    self.overView = nil;
}

- (void)addGesture{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
}
- (void)initUI{
 
    self.XDshareview =[[UIView alloc]initWithFrame:CGRectMake(0,HEIGHT-100,WIDTH,100)];
    self.XDshareview.userInteractionEnabled=YES;
    [self.view addSubview:self.XDshareview];
    self.XDshareview.backgroundColor = [UIColor blackColor];
    self.XDshareview.alpha=0.7;
        NSArray *imageNames = @[@"scan_openimage.png",@"scan_flashlight.png",@"scan_back.png"];
        int i=2;
    
    NSArray *titlelabel = @[@"相册",@"闪光灯",];
    
    for (int i = 0; i<2; i++)
        {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*WIDTH/2, 0, WIDTH/2, WIDTH/2);
        [button addTarget:self action:@selector(buttonsAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=i;
        [self.XDshareview addSubview:button];
        
        iv = [[UIImageView alloc]initWithFrame:CGRectMake((WIDTH/2-44)/2, 15,44,44)];
        iv.layer.cornerRadius =iv.frame.size.width*.5;
        iv.layer.borderColor = [UIColor whiteColor].CGColor;

        iv.layer.borderWidth =0.5;
        iv.alpha=1;
        iv.image = [UIImage imageNamed:imageNames[i]];
        iv.layer.backgroundColor = [UIColor blackColor].CGColor;
        [button addSubview:iv];
        iv.userInteractionEnabled = NO;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(iv.frame)+3, WIDTH/2, 20)];
        label.text =titlelabel[i];
        label.textColor=[UIColor whiteColor];
        label.textAlignment =1;
        label.font =[UIFont systemFontOfSize:14];
        [button addSubview:label];
        label.userInteractionEnabled= YES;
        
        }
    
       [self.view addSubview:self.XDshareview];
        [self.view addSubview:[self buttonWithImage:imageNames[i] tag:i selector:@selector(buttonsAction:)]];
}

- (UIButton *)buttonWithImage:(NSString *)imageName tag:(int)tag selector:(SEL)selector{
    
    UIButton *b = [[UIButton alloc]initWithFrame:CGRectMake(15, 25, ButtonSize.width, ButtonSize.height)];
    [b setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [b addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    b.layer.cornerRadius = ButtonSize.width*.5;
    b.layer.borderColor = [UIColor whiteColor].CGColor;
    b.layer.backgroundColor = [UIColor blackColor].CGColor;
    b.layer.borderWidth =0;
    b.alpha=0.4;
    [b setTag:tag];
    return b;
}

- (void)buttonsAction:(UIButton *)btn{
    
    switch (btn.tag) {
        case 1://灯
            [self openTorch:btn];
            break;
        case 0://相册
            [self selectImageFormAlbum:btn];
            break;
        case 2://返回
            [self returnResult:true isError:true value:@""];
            break;
        default:
            break;
    }
}


- (void)initOverView{
    
    self.overView = [[XDScanningView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.overView.delegate = self;
    [self.view insertSubview:self.overView atIndex:1];
}

- (bool)initCapture{
    

    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in devices) {
        if (camera.position == AVCaptureDevicePositionFront) {
           self.frontCamera = camera;
        }else{
            
            self.backCamera = camera;
        }
        
    }
    if (self.frontCamera==nil&&self.backCamera==nil)
    {
        [self returnResult:false isError:true value:@"无法检测到摄像头"];
        return false;
    }
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:nil];
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    NSLog(@"%f", self.backCamera.activeFormat.videoMaxZoomFactor);
    
    self.output.metadataObjectTypes = @[
    AVMetadataObjectTypeEAN13Code,
    AVMetadataObjectTypeEAN8Code,
    AVMetadataObjectTypeCode128Code,
    AVMetadataObjectTypeQRCode,
    AVMetadataObjectTypeFace,
    AVMetadataObjectTypeUPCECode,
    AVMetadataObjectTypePDF417Code,
    AVMetadataObjectTypeAztecCode,
    AVMetadataObjectTypeInterleaved2of5Code,
    AVMetadataObjectTypeDataMatrixCode,
    AVMetadataObjectTypeUPCECode,
    AVMetadataObjectTypeCode39Mod43Code,
    AVMetadataObjectTypeCode93Code
];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.session startRunning];
    
    
    CGFloat screenHeight = ScreenSize.height;
    CGFloat screenWidth = ScreenSize.width;
    
    CGRect cropRect = CGRectMake((screenWidth - TransparentArea([XDScanningView width], [XDScanningView height]).width) / 2,
                                 (screenHeight - TransparentArea([XDScanningView width], [XDScanningView height]).height) / 2,
                                 TransparentArea([XDScanningView width], [XDScanningView height]).width,
                                 TransparentArea([XDScanningView width], [XDScanningView height]).height);
    
    [self.output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                         cropRect.origin.x / screenWidth,
                                         cropRect.size.height / screenHeight,
                                         cropRect.size.width / screenWidth)];
   
    return true;
}

-(void)returnResult:(bool)isBack isError:(bool)isError value:(NSString*)message{
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [self.session stopRunning];
        [self saveInformation:message];
        [self playSystemSoundWithStyle:_tone];
        self.backValue(isBack,isError,message);
        [self backButtonActioin:nil];
    });
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if (metadataObjects.count > 0) {
        //新增停止扫描
        [self.session stopRunning];
        
        if ([[metadataObjects objectAtIndex:0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
            AVMetadataMachineReadableCodeObject*metadateObject =[metadataObjects objectAtIndex:0];
            stringValue =metadateObject.stringValue;
        }else{
            stringValue=@"false";
        }
        [self readingFinshedWithMessage:stringValue];
    }
    

}

- (void)readingFinshedWithMessage:(NSString *)msg{
    
    if (![msg isEqualToString:@"false"]) {
        [self returnResult:false isError:false value:msg];
    }else
    {
        [self returnResult:false isError:true value:@"扫描异常"];
    }

}



- (void)saveInformation:(NSString *)strValue{
    
    NSMutableArray *history = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"history"]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[strValue, [self getSystemTime]] forKeys:@[@"value",@"time"]];
    if (!history) history = [NSMutableArray array];
    [history addObject:dic];
    [[NSUserDefaults standardUserDefaults]setObject:history forKey:@"history"];
}

- (NSString *)getSystemTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)playSystemSoundWithStyle:(XDScaningWarningTone)tone{
    
    NSString *path = [NSString stringWithFormat:@"%@/scan.wav", [[NSBundle mainBundle] resourcePath]];
    SystemSoundID soundID;
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(filePath), &soundID);
    
    switch (tone) {
        case XDScaningWarningToneSound:
            AudioServicesPlaySystemSound(soundID);
            break;
        case XDScaningWarningToneVibrate:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        case XDScaningWarningToneSoundAndVibrate:
            AudioServicesPlaySystemSound(soundID);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

- (void)view:(UIView *)view didCatchGesture:(UIGestureRecognizer *)gesture{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存不够%@",self.description);
    // Dispose of any resources that can be recreated.
}

- (void)backButtonActioin:(UIButton *)button{
    [self.backCamera lockForConfiguration:nil];
    [self.backCamera setTorchMode:AVCaptureTorchModeOff];
    [self.backCamera unlockForConfiguration];
    iv.image=[UIImage imageNamed:@"scan_flashlight.png"];
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (void)selectImageFormAlbum:(UIButton *)btn{
    
    [self.backCamera lockForConfiguration:nil];

    [self.backCamera setTorchMode:AVCaptureTorchModeOff];
    
    [self.backCamera unlockForConfiguration];
    iv.image=[UIImage imageNamed:@"scan_flashlight.png"];
   
    ZBarReaderController *reader = [ZBarReaderController new];
    reader.allowsEditing = YES;
    reader.readerDelegate = self;
    reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:reader animated:YES completion:^{
        NSLog(@"跳转成功---");
    }];
    
}
-(void)readerControllerDidFailToRead:(ZBarReaderController *)reader withRetry:(BOOL)retry
{
    if (retry == 1)
        {
        [SaveData showMessage:@"不识别二维码或条形码"];
        
        [self dismissViewControllerAnimated:NO completion:nil];

        }




}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    id results =[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"data" object:symbol.data];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
        
    }];
  
}

- (void)openTorch:(UIButton *)button{
    isTorchOn = !isTorchOn;
    [self.backCamera lockForConfiguration:nil];
    if (isTorchOn) {

        iv.image=[UIImage imageNamed:@"scan_flashlight_open.png"];
        [button addSubview:iv];
        [self.backCamera setTorchMode:AVCaptureTorchModeOn];
    }else{
        iv.image=[UIImage imageNamed:@"scan_flashlight.png"];
        [button addSubview:iv];
        [self.backCamera setTorchMode:AVCaptureTorchModeOff];

    }
    [self.backCamera unlockForConfiguration];
}

- (void)pan:(UIPanGestureRecognizer *)pan{

  
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ViewWillDisappearNotification" object:nil];
    if (self.navigationController) { //如果继续隐藏导航栏 注掉此代码即可
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)dealloc{
    NSLog(@"%@dead", self.description);
}

@end

#pragma XDScanningView

@interface XDScanningView ()
@property (strong, nonatomic) UIView *line;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) CGFloat origin;
@property (assign, nonatomic) BOOL isReachEdge;


@property (assign , nonatomic) XDScaningLineMoveMode lineMoveMode;
@property (assign, nonatomic) XDScaningLineMode lineMode;
@property (assign, nonatomic) XDScaningWarningTone warninTone;

@end


@implementation XDScanningView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
    }
    return self;
}


- (void)initConfig{
    
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewWillDisappear:) name:@"ViewWillDisappearNotification" object:nil];
    UIScreenEdgePanGestureRecognizer *g = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(a:)];
    [g setEdges:UIRectEdgeLeft];
    [self addGestureRecognizer:g];
    
    self.lineMode = XDScaningLineModeDeafult;
    self.lineMoveMode = XDScaningLineMoveModeDown;

    self.line = [self creatLine];
    [self addSubview:self.line];
    [self starMove];
    
}


- (void)a:(UIScreenEdgePanGestureRecognizer *)g{
    [self.delegate view:self didCatchGesture:g];
}
- (UIView *)creatLine{
    
    if (_lineMoveMode == XDScaningLineMoveModeNone) return nil;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(ScreenSize.width*.5 - TransparentArea([XDScanningView width], [XDScanningView height]).width*.5, ScreenSize.height*.5 - TransparentArea([XDScanningView width], [XDScanningView height]).height*.5, TransparentArea([XDScanningView width], [XDScanningView height]).width, 2)];
    if (_lineMode == XDScaningLineModeDeafult) {
        line.backgroundColor = LineColor;
        self.origin = line.frame.origin.y;
    }
    
    if (_lineMode == XDScaningLineModeImge) {
        line.backgroundColor = [UIColor clearColor];
        self.origin = line.frame.origin.y;
        UIImageView *v = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line@2x.png"]];
        v.contentMode = UIViewContentModeScaleAspectFill;
        v.frame = CGRectMake(0, 0, line.frame.size.width, line.frame.size.height);
        [line addSubview:v];
    }
    
    if (_lineMode == XDScaningLineModeGrid) {
        line.clipsToBounds = YES;
        CGRect frame = line.frame;
        frame.size.height = TransparentArea([XDScanningView width], [XDScanningView height]).height;
        line.frame = frame;
        UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_net@2x.png"]];
        iv.frame = CGRectMake(0, -TransparentArea([XDScanningView width], [XDScanningView height]).height, line.frame.size.width, TransparentArea([XDScanningView width], [XDScanningView height]).height);
        [line addSubview:iv];
    }

    return line;
}

- (void)starMove{
    
    
    
    if (_lineMode == XDScaningLineModeDeafult) {  //注意！！！此模式非常消耗性能的哦
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.0125 target:self selector:@selector(showLine) userInfo:nil repeats:YES];
        [self.timer fire];
    }
    
    if (_lineMode == XDScaningLineModeImge) {
        
        [self showLine];
    }
    
    if (_lineMode == XDScaningLineModeGrid) {
        
        UIImageView *iv = _line.subviews[0];
        [UIView animateWithDuration:1.5 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            iv.transform = CGAffineTransformTranslate(iv.transform, 0, TransparentArea([XDScanningView width], [XDScanningView height]).height);
        } completion:^(BOOL finished) {
            iv.frame = CGRectMake(0, -TransparentArea([XDScanningView width], [XDScanningView height]).height, _line.frame.size.width, TransparentArea([XDScanningView width], [XDScanningView height]).height);
            [self starMove];
        }];
    }
}

- (void)showLine{
    
    if (_lineMode == XDScaningLineModeDeafult) {
        CGRect frame = self.line.frame;
        self.isReachEdge?(frame.origin.y -= LineMoveSpeed):(frame.origin.y += LineMoveSpeed);
        self.line.frame = frame;
        
        UIView *shadowLine = [[UIView alloc]initWithFrame:self.line.frame];
        shadowLine.backgroundColor = self.line.backgroundColor;
        [self addSubview:shadowLine];
        [UIView animateWithDuration:LineShadowLastInterval animations:^{
            shadowLine.alpha = 0;
        } completion:^(BOOL finished) {
            [shadowLine removeFromSuperview];
        }];
        
        if (_lineMoveMode == XDScaningLineMoveModeDown) {
            if (self.line.frame.origin.y - self.origin >= TransparentArea([XDScanningView width], [XDScanningView height]).height) {
                [self.line removeFromSuperview];
                CGRect frame = self.line.frame;
                frame.origin.y = ScreenSize.height*.5 - TransparentArea([XDScanningView width], [XDScanningView height]).height*.5;
                self.line.frame = frame;
            }
            
        }else if(_lineMoveMode==XDScaningLineMoveModeUpAndDown){
            if (self.line.frame.origin.y - self.origin >= TransparentArea([XDScanningView width], [XDScanningView height]).height) {
                self.isReachEdge = !self.isReachEdge;
            }else if (self.line.frame.origin.y == self.origin){
                self.isReachEdge = !self.isReachEdge;
            }
        }
    }
    
    if (_lineMode == XDScaningLineModeImge) {
            [self imagelineMoveWithMode:_lineMoveMode];
    }
}

- (void)imagelineMoveWithMode:(XDScaningLineMoveMode)mode{
    
    [UIView animateWithDuration:2 animations:^{
        CGRect frame = self.line.frame;
        frame.origin.y +=  TransparentArea([XDScanningView width], [XDScanningView height]).height-2;
        self.line.frame = frame;
    } completion:^(BOOL finished) {
        if (mode == XDScaningLineMoveModeDown) {
            CGRect frame = self.line.frame;
            frame.origin.y = ScreenSize.height*.5 - TransparentArea([XDScanningView width], [XDScanningView height]).height*.5;
            self.line.frame = frame;
            [self imagelineMoveWithMode:mode];
        }else{
            [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect frame = self.line.frame;
                frame.origin.y = ScreenSize.height*.5 - TransparentArea([XDScanningView width], [XDScanningView height]).height*.5;
                self.line.frame = frame;
            } completion:^(BOOL finished) {
                [self imagelineMoveWithMode:mode];
            }];
        }
    }];
    
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 40/255.0, 40/255.0, 40/255.0, .5);
    CGContextFillRect(context, rect);
     NSLog(@"%@", NSStringFromCGSize(TransparentArea([XDScanningView width], [XDScanningView height])));
    CGRect clearDrawRect = CGRectMake(rect.size.width / 2 - TransparentArea([XDScanningView width], [XDScanningView height]).width / 2,
                                      rect.size.height / 2 - TransparentArea([XDScanningView width], [XDScanningView height]).height / 2,
                                      TransparentArea([XDScanningView width], [XDScanningView height]).width,TransparentArea([XDScanningView width], [XDScanningView height]).height);
    
    CGContextClearRect(context, clearDrawRect);
    [self addWhiteRect:context rect:clearDrawRect];
    [self addCornerLineWithContext:context rect:clearDrawRect];
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 83 /255.0, 239/255.0, 111/255.0, 1);//绿色
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

+ (NSInteger)width{
    if (Iphone4||Iphone5) {
        return Iphone45ScanningSize_width;
    }else if(Iphone6){
        return Iphone6ScanningSize_width;
    }else if(Iphone6Plus){
        return Iphone6PlusScanningSize_width;
    }else{
        return Iphone45ScanningSize_width;
    }
}

+ (NSInteger)height{
    if (Iphone4||Iphone5) {
        return Iphone45ScanningSize_height;
    }else if(Iphone6){
        return Iphone6ScanningSize_height;
    }else if(Iphone6Plus){
        return Iphone6PlusScanningSize_height;
    }else{
        return Iphone45ScanningSize_height;
    }
}

- (void)viewWillDisappear:(NSNotification *)noti{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)dealloc{
         NSLog(@"%@dead", self.description);
}



@end
