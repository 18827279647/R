//
//  Location.h
//  你点我帮
//
//  Created by admin on 2017/5/19.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
@interface Location : CLLocationManager<CLLocationManagerDelegate>

+ (Location*)getLocationManager;
-(void)openLocation;
-(void)closeLocation;
@end
