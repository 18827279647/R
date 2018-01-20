//
//  Bluetooth.h
//  你点我帮商户版
//
//  Created by admin on 2016/12/8.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "Status.h"

@interface Bluetooth : NSObject<CBCentralManagerDelegate>

@property(strong,nonatomic)CBCentralManager*manager;

@property(strong,nonatomic)Status*__managerStatus;


+(void)ScanStart:(void(^)(Status*))callback :(int)timeout;

+(bool)IsScan;

+(void)ScanStop:(void(^)(Status*))callback;

+(void)ScanList:(void(^)(Status*,NSMutableArray*))callback;

+(void)ScanReadyList:(void(^)(Status*,NSMutableArray*))callback;

+(void)Connect:(void(^)(Status*))callback :(NSString*)identify;

+(void)Disconnect:(void(^)(Status*))callback;

+(CBPeripheral*)GetconnectPeripheral;



@end
