//
//  Print.h
//  你点我帮商户版
//
//  Created by admin on 2016/12/8.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "Bluetooth.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface Print : NSObject<CBPeripheralDelegate>

@property(nonatomic,strong)NSTimer*openTimer;

@property(nonatomic,strong)NSTimer*closeTimer;

@property(nonatomic,strong)void(^openCallback)(Status*);

@property(nonatomic,strong)void(^writeCallback)(Status*);

@property (strong, nonatomic) CBCharacteristic *write;
@property (strong, nonatomic) CBCharacteristic *writeProperty;

@property(assign,nonatomic)unsigned long  number;


@property(assign,nonatomic)int openNumber;
@property(assign,nonatomic)int openNumberDiscover;


@property(assign,nonatomic)bool isOpen;


@property(assign,nonatomic)int writeNumber;
@property(assign,nonatomic)int writeNumberDiscover;

-(void)Open:(void(^)(Status*))callback :(NSString*)identify;
-(void)Close:(void(^)(Status*))callback;
-(void)Send:(NSMutableData*)dic :(void(^)(Status*))callback;
-(void)Print:(NSMutableDictionary*)json :(void(^)(Status*))callback;
@end
