



#import "QRCodeReaderViewController.h"
#import "ZBarSDK.h"
#import "SaveData.h"
#define mainHeight     [[UIScreen mainScreen] bounds].size.height
#define mainWidth      [[UIScreen mainScreen] bounds].size.width
#define navBarHeight   self.navigationController.navigationBar.frame.size.height

@interface QRCodeReaderViewController () <AVCaptureMetadataOutputObjectsDelegate,ZBarReaderDelegate>
{
    UIButton * flashBtn;
    BOOL isLightOn;
}
@property (strong, nonatomic) UIButton             *cancelButton;
@property (strong, nonatomic) UIImageView          *imgLine;
@property (strong, nonatomic) UILabel              *lblTip;
@property (strong, nonatomic) NSTimer              *timerScan;


@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;
@property (strong, nonatomic) AVCaptureDevice            *frontDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *frontDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (copy, nonatomic) void (^completionBlock) (NSString *);



@end

@implementation QRCodeReaderViewController

- (id)init
{
  return [self initWithCancelButtonTitle:@"取消"];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle
{
  if ((self = [super init])) {
      [self  initButton];

    [self setupAVComponents];
    [self configureDefaultComponents];
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
  }
  return self;
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
  [super viewWillAppear:animated];
  
  [self startScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
  [self stopScanning];
  
  [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    NSLog(@"viewWillLayoutSubviews");
    
  [super viewWillLayoutSubviews];
  
  _previewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

//是否支持屏幕旋转
- (BOOL)shouldAutorotate
{
      return YES;
}

- (void)scanAnimate
{
    _imgLine.frame = CGRectMake(0, 120, mainWidth, 12);
    [UIView animateWithDuration:2 animations:^{
        _imgLine.frame = CGRectMake(_imgLine.frame.origin.x, 300, _imgLine.frame.size.width, 12);
    }];
}


-(void)initButton
{
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, mainHeight-90, mainWidth, 100)];
    downView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:downView];
    

    
    //调取系统相册
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    imageBtn.frame = CGRectMake(mainWidth*3/4-25, mainHeight-60, 50, 50);
    [imageBtn setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [imageBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageBtn];
    
    //打开手电筒
    isLightOn = YES;
    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(mainWidth/4-25, mainHeight-60, 50, 50);
    [flashBtn setImage:[UIImage imageNamed:@"flash.png"] forState:UIControlStateNormal];
    [flashBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(openFlashlight) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
    UIView *upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainWidth, 100)];
    upView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //upView.alpha = 0.7;
    [self.view addSubview:upView];
    
    
    CGFloat c_width = mainWidth - 100;
    CGFloat s_height = mainHeight - 40;
    CGFloat y = (s_height - c_width) / 2 - s_height / 6;
    
    _lblTip = [[UILabel alloc] initWithFrame:CGRectMake(0,y + 90 + c_width, mainWidth, 15)];
    _lblTip.text = @"将二维码放入框内 即可自动扫描";
    _lblTip.textColor = [UIColor whiteColor];
    _lblTip.font = [UIFont systemFontOfSize:13];
    _lblTip.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lblTip];
    
    CGFloat corWidth = 16;
    
    UIImageView* img1 = [[UIImageView alloc] initWithFrame:CGRectMake(49, y + 76, corWidth, corWidth)];
    img1.image = [UIImage imageNamed:@"cor1"];
    [self.view addSubview:img1];
    
    UIImageView* img2 = [[UIImageView alloc] initWithFrame:CGRectMake(35 + c_width, y + 76, corWidth, corWidth)];
    img2.image = [UIImage imageNamed:@"cor2"];
    [self.view addSubview:img2];
    
    UIImageView* img3 = [[UIImageView alloc] initWithFrame:CGRectMake(49, y + c_width + 64, corWidth, corWidth)];
    img3.image = [UIImage imageNamed:@"cor3"];
    [self.view addSubview:img3];
    
    UIImageView* img4 = [[UIImageView alloc] initWithFrame:CGRectMake(35 + c_width, y + c_width + 64, corWidth, corWidth)];
    img4.image = [UIImage imageNamed:@"cor4"];
    [self.view addSubview:img4];
    
    
    _imgLine = [[UIImageView alloc] init];
    _imgLine.image = [UIImage imageNamed:@"QRCodeScanLine"];
    [self.view addSubview:_imgLine];
    
    UIButton *backBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 40, 50, 50);
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];


}

//调取系统次相册
-(void)addImage
{
    
    ZBarReaderController *reader = [ZBarReaderController new];
    reader.allowsEditing = YES;
    reader.readerDelegate = self;
    ZBarImageScanner*scanner=reader.scanner;

    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];

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
    
    return;
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    NSLog(@"===%@",symbol.data);
    
    NSLog(@"%@",info);
    NSLog(@"当前线程  %@",[ NSThread currentThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"data" object:symbol.data];
    
       
    [reader dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
        
    }];
}



//打开手电筒
-(void)openFlashlight
{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (![device hasTorch])
        {
            //没有闪光灯
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"闪光灯" message:@"抱歉，该设备没有闪光灯而无法使用手电筒功能！" delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];

        }else
        {
    if (isLightOn == YES)
    {

        [self turnOnLed:YES];
        isLightOn = NO;

    }else if (isLightOn == NO)
    {
        [self turnOffLed:YES];
        isLightOn = YES;
    }
        }
}

-(void) turnOnLed:(bool)update
{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
    
    
}
-(void) turnOffLed:(bool)update
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}


#pragma mark - Managing the Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  //[_cameraView setNeedsDisplay];
  
  if (self.previewLayer.connection.isVideoOrientationSupported)
  {
    self.previewLayer.connection.videoOrientation = [[self class] videoOrientationFromInterfaceOrientation:toInterfaceOrientation];
  }
}

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  switch (interfaceOrientation) {
    case UIInterfaceOrientationLandscapeLeft:
      return AVCaptureVideoOrientationLandscapeLeft;
    case UIInterfaceOrientationLandscapeRight:
      return AVCaptureVideoOrientationLandscapeRight;
    case UIInterfaceOrientationPortrait:
      return AVCaptureVideoOrientationPortrait;
    default:
      return AVCaptureVideoOrientationPortraitUpsideDown;
  }
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
    self.completionBlock = completionBlock;
}

#pragma mark - Initializing the AV Components


- (void)setupAVComponents
{
  self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  if (_defaultDevice) {
    self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_defaultDevice error:nil];
    self.metadataOutput     = [[AVCaptureMetadataOutput alloc] init];
    self.session            = [[AVCaptureSession alloc] init];
    self.previewLayer       = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
      if (device.position == AVCaptureDevicePositionFront) {
        self.frontDevice = device;
      }
    }
    
    if (_frontDevice) {
      self.frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontDevice error:nil];
    }
  }
}

- (void)configureDefaultComponents
{
  [_session addOutput:_metadataOutput];
  
  if (_defaultDeviceInput) {
    [_session addInput:_defaultDeviceInput];
  }
  
  [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _metadataOutput.metadataObjectTypes=_metadataOutput.availableMetadataObjectTypes;
  if ([[_metadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
    [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code]];
  }
  [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:self.view.layer.bounds];
  if ([_previewLayer.connection isVideoOrientationSupported]) {
    _previewLayer.connection.videoOrientation = [[self class] videoOrientationFromInterfaceOrientation:self.interfaceOrientation];
  }
}

#pragma mark - Catching Button Events

- (void)cancelAction:(UIButton *)button
{
  [self stopScanning];
  
  if ( [_delegate respondsToSelector:@selector(readerDidCancel:)]) {
    [_delegate readerDidCancel:self];
  }
}

#pragma mark - Controlling Reader

- (void)startScanning;
{
  if (![self.session isRunning]) {
    [self.session startRunning];
  }
    
    if(_timerScan)
    {
        [_timerScan invalidate];
        _timerScan = nil;
    }
    
    _timerScan = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(scanAnimate) userInfo:nil repeats:YES];

}

- (void)stopScanning;
{
  if ([self.session isRunning]) {
    [self.session stopRunning];
  }
    if(_timerScan)
    {
        [_timerScan invalidate];
        _timerScan = nil;
    }

}

#pragma mark - AVCaptureMetadataOutputObjects Delegate Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
  for(AVMetadataObject *current in metadataObjects) {
    if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
        && [current.type isEqualToString:AVMetadataObjectTypeQRCode]) {
      NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
      
      if (_completionBlock) {
        _completionBlock(scannedResult);
      }
      
      if (_delegate && [_delegate respondsToSelector:@selector(reader:didScanResult:)]) {
        [_delegate reader:self didScanResult:scannedResult];
      }
      
      break;
    }
  }
}

#pragma mark - Checking the Metadata Items Types

+ (BOOL)isAvailable
{
  @autoreleasepool {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!captureDevice) {
      return NO;
    }
    
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!deviceInput || error) {
      return NO;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    if (![output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
      return NO;
    }
    
    return YES;
  }
}

@end

