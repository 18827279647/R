//
//  EditImageViewController.h
//  你点我帮
//
//  Created by zhaoyaqun on 15/12/11.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditImageViewController : UIViewController

@property (nonatomic , assign) CGFloat width;
@property (nonatomic , assign) CGFloat height;
@property(nonatomic,assign)CGFloat MaxWidth;
@property(nonatomic,assign)CGFloat MaxHeight;
-(void)getImage:(NSDictionary *)imageDict;//图片的宽高

+ (EditImageViewController*)editViewControllerManager;


@end
