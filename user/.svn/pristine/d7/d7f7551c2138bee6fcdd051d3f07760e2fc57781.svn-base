//
//  CheckNetwork.m
//  Weather
//
//  Created by yangsai on 14-7-1.
//  Copyright (c) 2014年 杨赛. All rights reserved.
//

#import "CheckNetwork.h"

@implementation CheckNetwork
+(int)checkNetwork
{
    //首先检查当前的网络状态
    Reachability * net = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus status = net.currentReachabilityStatus;
    int type = -3;
    if(status==kNotReachable)
         type = 0;
     else if (status ==kReachableViaWWAN)
         type = 1;
     else if(status ==kReachableViaWiFi)
         type = 2;
      else
          type = 0;
    return type;
}

- (int)checkNetWork:(NetworkStatus)status {
    if (status == kNotReachable) {
        return 0;
    }
    else if(status == kReachableViaWWAN) {
        return 1;
    }
    else if(status == kReachableViaWiFi) {
        return 2;
    }
    return -1;
}
@end
