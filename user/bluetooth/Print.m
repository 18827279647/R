//
//  Print.m
//  你点我帮商户版
//
//  Created by admin on 2016/12/8.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Print.h"
#import "Unit.h"
#import "GTMBase64.h"

static unsigned long kLimitLength=100;

static NSData*SendData=nil;

static int SendIndex=0;

static void(^CallSendback)(bool);

@implementation Print
-(void)Open:(void(^)(Status*))callback :(NSString*)identify;
{
    self.isOpen=false;
    self.openNumberDiscover=0;
    [Bluetooth Connect:^(Status *status){
        if (![status IsNormal])
        {
            callback(status);
            return;
        };
        self.openCallback=callback;
        [[Bluetooth GetconnectPeripheral] setDelegate:self];
        [[Bluetooth GetconnectPeripheral] discoverServices:nil];
        self.openTimer=[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(_OpenTimeout) userInfo:self repeats:NO];
    } :identify];
}
-(void)_OpenTimeout
{
    [self _OpenCallback:[[[Status alloc]init]NotConnect]];
   
}
-(void)_OpenCallback:(Status *)status
{
    if (self.openTimer!=nil) {
        [self.openTimer invalidate];
        self.openTimer=nil;
    }
    if (self.openCallback!=nil) {
        self.openCallback(status);
        self.openCallback=nil;
    }
}
//扫描设备的服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        [self _OpenCallback:[[[Status alloc]init]NotConnect]];
        return;
    }
    self.openNumber=(int)peripheral.services.count;
    for (CBService *service in peripheral.services)
    {
       [peripheral discoverCharacteristics:nil forService:service];
    }
}
    //扫描服务的特征值
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if (error)
    {
        [self _OpenCallback:[[[Status alloc]init]NotConnect]];
        return;
    }
        
    for (CBCharacteristic * cha in service.characteristics)
    {
        CBCharacteristicProperties p = cha.properties;
        if (p & CBCharacteristicPropertyWriteWithoutResponse) {
            self.write = cha;
        }

        if (p & CBCharacteristicPropertyWrite) {
            self.writeProperty=cha;
        }
    }
    self.openNumberDiscover++;
    if (self.openNumberDiscover>=self.openNumber)
    {
        if (self.write==nil)
        {
            [self _OpenCallback:[[[Status alloc]init]NotSupportPrint]];
            return;
        }
        if (self.writeProperty==nil) {
            [self _OpenCallback:[[[Status alloc]init]NotSupportPrint]];
            return;
        }
        self.isOpen=true;
        [self _OpenCallback:[[Status alloc]init]];
    }
}























-(void)Close:(void(^)(Status*))callback;
{
    self.isOpen=false;
  [Bluetooth Disconnect:^(Status *status) {
      callback(status);
  }];
}









-(void)Send:(NSMutableData*)dic :(void(^)(Status*))callback;
{
    self.writeNumberDiscover=0;
    self.writeCallback=[callback copy];
    if (!self.isOpen)
    {
        [self _SendCallback:[[[Status alloc]init]NotConnect]];
        return;
    }
    
    self.writeNumber=(int)dic.length/kLimitLength+(dic.length%kLimitLength>0?1:0);
    
    int timeout=self.writeNumber;
    if (timeout<15) {
        timeout=15;
    }
    NSLog(@"打印超时%d",timeout);
    self.closeTimer=[NSTimer  scheduledTimerWithTimeInterval:timeout target:self selector:@selector(_SendTimeOut) userInfo:nil repeats:NO];
    
    
    
    SendData=dic;
    SendIndex=0;
    
    
    
    int  len=(int)kLimitLength;
    if (SendData.length<len) {
        len=(int)SendData.length;
    }
    SendIndex=len;
    
    NSData *subData = [dic subdataWithRange:NSMakeRange(0,len)];
    [[Bluetooth GetconnectPeripheral] writeValue:subData forCharacteristic:self.write  type:[@(CBCharacteristicWriteWithResponse) integerValue]];
    NSLog(@"开始打印%d",self.writeNumber);
}
-(void)_SendCallback:(Status*)status;
{
    if (self.closeTimer!=nil) {
        [self.closeTimer invalidate];
        self.closeTimer=nil;
    }
    if (self.writeCallback!=nil) {
        self.writeCallback(status);
        self.writeCallback=nil;
    }
}

-(void)_SendTimeOut;
{
    NSLog(@"打印超时");
    [self _SendCallback:[[[Status alloc]init] Unknown:@"打印超时"]];
}
-(void)SendDataBOOL:(void(^)(bool number))callback
{
    CallSendback=[callback copy];
}

    //向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if(error){
        SendIndex=(int)SendData.length;
        NSString*message=[NSString stringWithFormat:@"打印失败:%@",error.description];
        NSLog(@"%@",message);
        [self _SendCallback:[[[Status alloc]init] Unknown:message]];
    }else{
        self.writeNumberDiscover++;
        if(SendIndex<SendData.length){
            int len=(int)kLimitLength;
            if (SendIndex+len>=SendData.length) {
                len=(int)SendData.length-SendIndex;
            }
            
            NSData *subData = [SendData subdataWithRange:NSMakeRange(SendIndex,len)];
            SendIndex+=len;
        
            [[Bluetooth GetconnectPeripheral] writeValue:subData forCharacteristic:self.write  type:[@(CBCharacteristicWriteWithResponse) integerValue]];
        }else{
            NSLog(@"打印完成%d",self.writeNumber);
            [self _SendCallback:[[Status alloc]init]];
        }
    }
}



-(void)Print:(NSMutableDictionary*)json :(void(^)(Status*))callback;
{
    NSMutableData*data=[[NSMutableData alloc]init];
    NSStringEncoding enc=0;
    NSString*charset=[[Unit JSONString:json key:@"charset"]lowercaseString];
    NSMutableArray *items =[json objectForKey:@"items"];

    if (items ==nil) {
        callback([[[Status alloc]init]Unknown:@"数据解析失败"]);
        return;
    }
    
    if ([charset isEqualToString:@"gbk"])
    {
        enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

    }
    else if([charset isEqualToString:@"utf-8"])
    {
        enc=NSUTF8StringEncoding;

    }
    else
    {
        callback( [[[Status alloc]init]Unknown:[NSString stringWithFormat:@"不支持编码格式%@",charset]]);
        return;
    }
    
    
    for (NSMutableDictionary*item in items)
    {
        NSString*type=nil;
        //type
        type=[Unit JSONString:item key:@"type"];
        
        if ([type isEqualToString:@"text"]){
            NSString*value=[Unit JSONString:item key:@"value"];
            [data appendData:[value dataUsingEncoding:enc]];
        }else if([type isEqualToString:@"img"]){
            NSData *Originaimgdata=[GTMBase64 decodeString:[Unit JSONString:item key:@"value"]];
            if (Originaimgdata==nil)
            {
                callback( [[[Status alloc]init]Unknown:@"图片解析失败"]);
                return;
            }
            UIImage*Originalimage=[UIImage imageWithData:Originaimgdata];
            int width=[Unit JSONInt:item key:@"width"];
            int height=[Unit JSONInt:item key:@"height"];
            int maxWidth=[Unit JSONInt:item key:@"maxWidth"];
            int maxHeight=[Unit JSONInt:item key:@"maxHeight"];
                //剪切之后的图片
            UIImage*imageData=[Print getImage:Originalimage getWidth:width getHeight:height getMaxWidth:maxWidth getmaxHeight:maxHeight];
            
            [data appendData:[self bitmapData:imageData]];
        }else if([type isEqualToString:@"byte"]){
            NSMutableArray*value=[item objectForKey:@"value"];
            Byte bytes[[value count]];
            
            for (int i=0;i<[value count];i++)
            {
                bytes[i]= [Unit JSONArrayInt:value key:i];
            }
            [data appendData:[NSData dataWithBytes:bytes length:sizeof(bytes)]];
        }else if([type isEqualToString:@"base64"]){
            NSData *imgdata=[GTMBase64 decodeString:[Unit JSONString:item key:@"value"]];
            NSString *value = [[NSString alloc] initWithData:imgdata encoding:NSUTF8StringEncoding];
            [data appendData:[value dataUsingEncoding:enc]];
        }
    }

    [self Send:data :callback];
}

























+(UIImage*)getImage:(UIImage*)image getWidth:(int)width getHeight:(int)height getMaxWidth:(int)maxWidth getmaxHeight:(int)maxHeight;
{
        //图片原始尺寸
    float Imagewidth=image.size.width;
    float Imageheight=image.size.height;
    UIImage*editImage=image;
    
    /**宽高都设定了，将图片缩放到能刚好包含宽高代表的矩形范围，然后裁剪图片中间部分**/
    if (width != 0 && height != 0)
        {
            //设定宽高等于原始图片宽高，直接返回
        if (width==Imagewidth&&height==Imageheight)
            {
            return editImage;
            }
            //缩放
            //固定一边，判断另一边
        if (maxHeight==1) {
            
            int rW=width;
            int rH=Imageheight*rW/Imagewidth;
            int x=0;int y=0;
            if (rH<height)
                {
                rH=height;
                rW=Imagewidth*rH/Imageheight;
                }
                //缩放成设定大小
            UIGraphicsBeginImageContext(CGSizeMake(rW,rH));
            [editImage drawInRect:CGRectMake(x,y,rW,rH)];
            UIImage *Imagett= UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return Imagett;
            
        }
        int rW=width;
        int rH=Imageheight*rW/Imagewidth;
        int x=0;int y=0;
        if (rH<height)
            {
            rH=height;
            rW=Imagewidth*rH/Imageheight;
            }
            //缩放成设定大小
        UIGraphicsBeginImageContext(CGSizeMake(rW,rH));
        [editImage drawInRect:CGRectMake(0,0,rW,rH)];
        UIImage *Imagett= UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (rW==width)
            {
            y=(rH-height)/2;
            NSLog(@"yHHHHHHHH   %d",y);
            
            }else
                {
                x=(rW-width)/2;
                
                NSLog(@"xxxxxxHHHHHHH %d",x);
                }
        
        CGRect myImageRect=CGRectMake(x,y,width,height);
        CGImageRef imageRef =Imagett.CGImage;
        CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
        CGSize size;
        size.width = myImageRect.size.width;
        size.height = myImageRect.size.height;
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, myImageRect, subImageRef);
        UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        return smallImage;
        
        }
    /**一边不为0，缩放**/
    if(width!=0 || height!=0){
        if(height != 0 )
            {
            NSLog(@"宽为零高不为零");
            UIGraphicsBeginImageContext(CGSizeMake(editImage.size.width*height/editImage.size.height, height));
            [editImage drawInRect:CGRectMake(0, 0, editImage.size.width*height/editImage.size.height, height)];
            UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return reSizeImage;
            }else if (width !=0)
                {
                UIGraphicsBeginImageContext(CGSizeMake(width, editImage.size.height*width/editImage.size.width));
                [editImage drawInRect:CGRectMake(0, 0, width, editImage.size.height*width/editImage.size.width)];
                UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                NSLog(@"宽不为零高为零");
                return reSizeImage;
                }
        
    }
    /**宽高都为零，检测最大宽高**/
    bool resize=false;
    
    width=Imagewidth;
    height=Imageheight;
    if (maxWidth>0&&width>maxWidth)
        {
        resize=true;
        height=height*maxWidth/width;
        width=maxWidth;
        }
    if(maxHeight>0&&height>maxHeight)
        {
        resize =true;
        width=width*maxHeight/height;
        height=maxHeight;
        }
    if (resize)
        {
        UIGraphicsBeginImageContext(CGSizeMake(width,height));
        [editImage drawInRect:CGRectMake(0, 0,width,height)];
        UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
        }
    /**直接返回**/
    UIGraphicsBeginImageContext(CGSizeMake(editImage.size.width, editImage.size.height));
    [editImage drawInRect:CGRectMake(0, 0, editImage.size.width, editImage.size.height)];
    UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"宽高都为零");
    return reSizeImage;
    
}


- (NSData *)bitmapData:(UIImage*)image;
{
    
    CGImageRef imageRef =image.CGImage;
    CGContextRef context = [self bitmapRGBA8Context:imageRef];
    if(!context) {
        return nil;
    }
    int width=image.size.width;
    int height=image.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, imageRef);
    uint32_t *bitmapData = (uint32_t *)CGBitmapContextGetData(context);
    if(bitmapData) {
        
        uint8_t *m_imageData = (uint8_t *) malloc(width*(height/8+1)+(height/8+1)*9);
        memset(m_imageData, 0, width*(height/8+1)+(height/8+1)*9);
        int result_index = 0;
        
        for(int loopy = 0; loopy < height; loopy+=24) {
            
            if (loopy>0) {
                
                m_imageData[result_index++] =10;
                
            }
            m_imageData[result_index++] = 27;
            m_imageData[result_index++] = 51;
            m_imageData[result_index++] = 0;
            
            m_imageData[result_index++] = 27;
            m_imageData[result_index++] = 42;
            m_imageData[result_index++] = 33;
            
            m_imageData[result_index++] = width%256;
            m_imageData[result_index++] = width/256;
            int y;
            for(int x = 0; x < width; x++) {
                for(int byteY=0;byteY<3;byteY++)
                    {
                    int value = 0;
                    for (int temp_y = 0 ; temp_y < 8; ++temp_y)
                        {
                        y=loopy+byteY*8+temp_y;
                        int gray=255;
                        if (y<height) {
                            uint8_t *rgbaPixel = (uint8_t *) &bitmapData[y* width + x];
                            gray = 0.29900 * rgbaPixel[3] + 0.58700 * rgbaPixel[2] + 0.11400 * rgbaPixel[1];
                            }
                        if (gray < 128)
                            {
                            value += 1<<(7-temp_y)&255;
                            }
                        
                        }
                    m_imageData[result_index++] = value;
                    
                    }
                
            }
            
        }
        
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
        [data appendBytes:m_imageData length:result_index];
        
        free(bitmapData);
        return data;
    }
    CGContextRelease(context);
    
    return nil ; 
}

- (CGContextRef)bitmapRGBA8Context:(CGImageRef)image
{
    CGImageRef imageRef = image;
    if (!imageRef) {
        return NULL;
    }
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if(!colorSpace) {
        return NULL;
    }
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
          CGColorSpaceRelease(colorSpace);
        return NULL;
    }
     context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    if(!context) {
        free(bitmapData);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
    
}


@end
