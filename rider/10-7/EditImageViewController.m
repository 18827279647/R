//
//  EditImageViewController.m
//  你点我帮
//
//  Created by zhaoyaqun on 15/12/11.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import "EditImageViewController.h"
#import "ViewController.h"
#import "AppRequest.h"
#import "AppDelegate.h"
#import "VPImageCropperViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface EditImageViewController ()<UIActionSheetDelegate,PassImageDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    UIImageView *imageView;
    UIActionSheet *chooseImageSheet;

}
@end

@implementation EditImageViewController

+ (EditImageViewController*)editViewControllerManager {
    static EditImageViewController *editView = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        editView = [[self alloc] init];
    });
    return editView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor blueColor];
}

-(void)getImage:(NSDictionary *)imageDict
{
    self.width = [[imageDict  objectForKey:@"width"] floatValue];
    self.height = [[imageDict  objectForKey:@"height"] floatValue];
    self.MaxWidth=[[imageDict objectForKey:@"maxWidth"]floatValue];
    self.MaxHeight=[[imageDict objectForKey:@"maxHeight"]floatValue];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      
        chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选取相册", nil];
        [chooseImageSheet showInView:self.view];
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"选取相册",nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    switch (buttonIndex) {
        case 1://Take picture
        {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        }else{
            NSLog(@"模拟器无法打开相机");
        }
        [[ViewController viewControllerManager] presentViewController:picker animated:NO completion:nil];
        }
            break;
            
        case 2://From album
        {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [[ViewController viewControllerManager] presentViewController:picker animated:NO completion:nil];
        break;
        }

        default:
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"imagePickerControllerDidCancel" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"imagePickerControllerDidCancel" object:nil];
            [[ViewController viewControllerManager] dismissViewControllerAnimated:NO completion:^{
                
            }];
            
            break;
    }

}
#pragma mark UIActionSheetDelegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    switch (buttonIndex) {
        case 0://Take picture
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
            }else{
                NSLog(@"模拟器无法打开相机");
            }
           [[ViewController viewControllerManager] presentViewController:picker animated:NO completion:nil];
        }
            break;
            
        case 1://From album
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [[ViewController viewControllerManager] presentViewController:picker animated:NO completion:nil];
            break;
        }
        default:
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"imagePickerControllerDidCancel" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"imagePickerControllerDidCancel" object:nil];
            [[ViewController viewControllerManager] dismissViewControllerAnimated:NO completion:^{
                
            }];
            break;
    }
}

#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"imagePickerControllerDidCancel" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"imagePickerControllerDidCancel" object:nil];
    [[ViewController viewControllerManager] dismissViewControllerAnimated:NO completion:^{
        
    }];
}


#pragma 拍照选择照片协议方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *userImage = [info objectForKey:UIImagePickerControllerOriginalImage];
     NSData *imageData = UIImageJPEGRepresentation(userImage, 1);
    UIImage *editImage = [UIImage imageWithData:imageData];
    
    float width=editImage.size.width;
    float height=editImage.size.height;
    
    /**宽高一致 直接返回**/
    if (width==_width&&height==_height)
    {
      [picker dismissViewControllerAnimated:YES completion:^{
       [[NSNotificationCenter defaultCenter] postNotificationName:@"reSizeImage" object:userImage];}];
        return;
    }
    /**宽高都设定了，显示裁剪界面**/
    if (_width != 0 && _height != 0)
    {
    userImage=[self imageByScalingToMaxSize:userImage];

    NSString* isEellor=@"1";
    VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:userImage cropFrame:CGRectMake(0, 100.0f,self.view.frame.size.width,self.view.frame.size.width)limitScaleRatio:10.0 Ratio:CGSizeMake(_width, _height)isError:isEellor];
    imgEditorVC.Passdelegate =self;
    picker.navigationBar.hidden = YES;
    [picker pushViewController:imgEditorVC animated:YES];
    return;
    }
    /**一边不为0，缩放**/
    if(_width!=0 || _height!=0){
        if(_height != 0 )
        {
            NSLog(@"宽为零高不为零");
            
            UIGraphicsBeginImageContext(CGSizeMake(editImage.size.width*_height/editImage.size.height, _height));
            [editImage drawInRect:CGRectMake(0, 0, editImage.size.width*_height/editImage.size.height, _height)];
            UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [picker dismissViewControllerAnimated:YES completion:^{}];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reSizeImage" object:reSizeImage];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reSizeImage" object:reSizeImage];

        }else if (_width !=0)
        {
            UIGraphicsBeginImageContext(CGSizeMake(_width, editImage.size.height*_width/editImage.size.width));
            [editImage drawInRect:CGRectMake(0, 0, _width, editImage.size.height*_width/editImage.size.width)];
            UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [picker dismissViewControllerAnimated:YES completion:^{}];

            NSLog(@"宽不为零高为零");
             [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reSizeImage" object:reSizeImage];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reSizeImage" object:reSizeImage];

            
        }
        return;
    }
    /**宽高都为零，检测最大宽高**/
    bool resize=false;
    
    _width=width;
    _height=height;
    if (self.MaxWidth>0&&_width>self.MaxWidth)
    {
        resize=true;
        _height=_height*self.MaxWidth/_width;
        _width=self.MaxWidth;
    }
    if(self.MaxHeight>0&&_height>self.MaxHeight)
    {
        resize =true;
        _width=_width*self.MaxHeight/_height;
        _height=self.MaxHeight;
    }
    if (resize)
    {
        UIGraphicsBeginImageContext(CGSizeMake(_width,_height));
        [editImage drawInRect:CGRectMake(0, 0,_width,_height)];
        UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [picker dismissViewControllerAnimated:YES completion:^{}];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reSizeImage" object:reSizeImage];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reSizeImage" object:reSizeImage];
        return;
    }
    
    /**宽高都为0直接返回**/
    UIGraphicsBeginImageContext(CGSizeMake(editImage.size.width, editImage.size.height));
    [editImage drawInRect:CGRectMake(0, 0, editImage.size.width, editImage.size.height)];
    UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [picker dismissViewControllerAnimated:YES completion:^{}];
    NSLog(@"宽高都为零");
      [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reSizeImage" object:reSizeImage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reSizeImage" object:reSizeImage];
}
#pragma mark - 图片回传协议方法
-(void)passImage:(UIImage *)image andSize:(CGSize)size
{
    //将截取的图片显示在主界面
    UIGraphicsBeginImageContext(CGSizeMake(size.width,size.height));
    [image drawInRect:CGRectMake(0, 0,size.width,size.height)];
    UIImage *reSizeImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
      [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reSizeImage" object:reSizeImage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reSizeImage" object:reSizeImage];

}
#pragma mark- 缩放图片
-(UIImage *)scaleImageWith:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width,image.size.width*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width,image.size.width *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(UIImage *)scaleImagehieht:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.height,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.height, image.size.height*scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
        {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
            // center the image
        if (widthFactor > heightFactor)
            {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            }
        else
            if (widthFactor < heightFactor)
                {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
                }
        }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
        //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
