//
//  SaveFile.h
//  你点我帮
//
//  Created by admin on 2017/6/16.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDocumentPickerViewController.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
@interface SaveFile : NSObject 
-(void)save:(void(^)(bool ,NSString*,NSString*))callback name:(NSString*)name :(NSString*)data;
@end
