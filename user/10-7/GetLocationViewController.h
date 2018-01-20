//
//  GetLocationViewController.h
//  10-7
//
//  Created by zhaoyaqun on 15/11/5.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppRequest.h" 
#import <CoreLocation/CoreLocation.h>

#import<BaiduMapAPI_Location/BMKLocationService.h>

@interface GetLocationViewController : UIViewController<BMKLocationServiceDelegate>

@property (strong, nonatomic) BMKLocationService *locManager;
@property (strong, nonatomic) NSString *currentLatitude; //纬度
@property (strong, nonatomic) NSString *currentLongitude; //经度

+ (GetLocationViewController*)getViewControllerManager ;

-(void)getLocation;

@end
