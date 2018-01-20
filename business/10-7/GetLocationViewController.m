//
//  GetLocationViewController.m
//  10-7
//
//  Created by zhaoyaqun on 15/11/5.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import "GetLocationViewController.h"
#import "ViewController.h"
#import "SrocketViewController.h"
#import "AppRequest.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
@interface GetLocationViewController ()<CLLocationManagerDelegate>

{
    NSInteger cunnlocation;

}
@end

@implementation GetLocationViewController

+ (GetLocationViewController*)getViewControllerManager {
    static GetLocationViewController *getView = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        getView = [[self alloc] init];
    });
    return getView;
}
-(void)getLocation
{
    NSLog(@"开  始  定  位");
    
    if ([CLLocationManager locationServicesEnabled])
    {
        _locManager = [[BMKLocationService alloc]init];
        _locManager.delegate = self;
    
        _locManager.desiredAccuracy = kCLLocationAccuracyBest;
        //启动LocationService
        [_locManager startUserLocationService];

    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"无法进行定位操作" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"进入代理方法");
    NSMutableDictionary *locationDict  =[[NSMutableDictionary alloc] init];
    
    NSString *latStr = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    NSString *lngStr = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    
    [locationDict setObject:latStr forKey:@"lat"];
    [locationDict setObject:lngStr forKey:@"lng"];
    [_locManager stopUserLocationService];
    _locManager.delegate=nil;
        // 停止位置更新
    if (locationDict)
        {
        dispatch_queue_t queue=dispatch_get_main_queue();
        dispatch_async(queue, ^{
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"locationDict" object:locationDict];
            
            
        });
        
        }

}

- (void)didFailToLocateUserWithError:(NSError *)error{
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"locationFail" object:nil];
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        
        if (error)
            {
            dispatch_queue_t queue=dispatch_get_main_queue();
            dispatch_async(queue, ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"locationFail" object:@"定位失败"];
            });
            
            }
        
    });
}
}
@end
