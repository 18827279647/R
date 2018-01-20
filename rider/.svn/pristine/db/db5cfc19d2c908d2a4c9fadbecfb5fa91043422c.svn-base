//
//  Location.m
//  你点我帮
//
//  Created by admin on 2017/5/19.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import "Location.h"
#import "ViewController.h"
#import "Unit.h"
static long openTime=0;
static long didTime=0;
@implementation Location

+ (Location*)getLocationManager;
{
    static Location *location = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        location = [[self alloc] init];
    });
    return location;
}

-(void)openLocation;
{
    long t=didTime-openTime;
    if(t<0 && t>-5000){
        return;
    }
    openTime=[Unit GetMS];
    if ([CLLocationManager locationServicesEnabled])
        {
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
                {
                    //获取授权认证
                    [self requestWhenInUseAuthorization];
            
                }
        self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.delegate = self;
        [self startUpdatingLocation];
        
        }else{
                //不需要操作
        }


}
    // 地理位置发生改变时触发
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    didTime=[Unit GetMS];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(manager.location.coordinate.latitude,manager.location.coordinate.longitude);//原始坐标
    //转换国测局坐标（google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标）至百度坐标
    NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_COMMON);
    
        //转换WGS84坐标至百度坐标(加密后的坐标)
    testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
    CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
    
    NSString *latStr = [NSString stringWithFormat:@"%f",baiduCoor.latitude];
    NSString *lngStr = [NSString stringWithFormat:@"%f",baiduCoor.longitude];
    
    // 停止位置更新
    [self closeLocation];
    if (latStr||lngStr)
        {
        dispatch_queue_t queue=dispatch_get_main_queue();
        dispatch_async(queue, ^{
            
            [[ViewController viewControllerManager]excode:[NSString stringWithFormat:@"AppRequest.Location(%@,%@)",lngStr,latStr]];
        });
        
        }
}
-(void)closeLocation;
{
    openTime=0;
    [self stopUpdatingLocation];
    self.delegate=nil;
    NSLog(@"关闭定位。。。。。。。。");
}

@end
