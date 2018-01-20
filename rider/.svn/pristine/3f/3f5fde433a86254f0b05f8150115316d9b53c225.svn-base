//
//  Bluetooth.m
//  你点我帮商户版
//
//  Created by admin on 2016/12/8.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import "Bluetooth.h"

static Bluetooth*Instance=nil;
static NSMutableArray*scanList;
static bool isReady=false;

static bool isScan=false;

static NSTimer*scanTimer;


static NSTimer*connectTimer;
static void(^connectCallback)(Status*);
static NSString*connectIdentify=nil;
static CBPeripheral*connectPeripheral;
static NSTimer*disconnectTimer;
static void(^disconnectCallback)(Status*);

static NSMutableArray*queryCallbacks;

@implementation Bluetooth

+(void)Init:(void(^)(Status*))callback;
{
    if (Instance==nil)
    {
      Instance=[[Bluetooth alloc]init];
    }
    [Instance query:[callback copy]];
}








+(bool)IsScan;
{
    return isScan;
}
+(void)ScanStart:(void(^)(Status*))callback :(int)timeout;
{
    scanList=[[NSMutableArray alloc]init];
    [Bluetooth Init:^(Status*status)
    {
        if(![[Instance getStatus] IsNormal]){
            callback([Instance getStatus]);
            return;
        }
        [Bluetooth Disconnect:^(Status *statusA) {
            [Bluetooth ScanStop:^(Status*statusB)
             {
                 isScan=true;
                 [Instance.manager scanForPeripheralsWithServices:nil options:nil];
                 scanTimer=[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(_ScanTimeout) userInfo:nil repeats:NO];
                callback(status);
            }];
        }];
    }];
}
+(void)_ScanTimeout
{
    [Bluetooth ScanStop:^(Status*status){}];
}
+(void)ScanStop:(void(^)(Status*))callback;
{
    [Bluetooth Init:^(Status*status)
     {
        isScan=false;
        if (scanTimer!=nil) {
            [scanTimer invalidate];
            [Instance.manager stopScan];
            scanTimer=nil;
        }
        callback(status);
     }];
}
#pragma mark - 一旦一个peripheral被搜寻到，这个代理方法被调用，查到外设后的方法 peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (!isReady) {
        return;
    }
         bool isFind=false;
    if (isScan) {
        for (CBPeripheral*p in scanList) {
            if ([peripheral.identifier.UUIDString isEqualToString:p.identifier.UUIDString])
            {
                isFind=true;
            }
        }
        if(!isFind){
            [scanList addObject:peripheral];
        
        }
    }else{
        if ([peripheral.identifier.UUIDString isEqualToString:connectIdentify])
        {
            [Bluetooth _ConnectScanFind:peripheral];

        }
    }
}

+(void)ScanList:(void(^)(Status*,NSMutableArray*))callback;
{
    [Bluetooth Init:^(Status *status) {
        callback(status,[scanList copy]);
    }];
}

+(void)ScanReadyList:(void(^)(Status*,NSMutableArray*))callback;
{
    [Bluetooth Init:^(Status *status) {
        callback(status,[[NSMutableArray alloc]init]);
    }];
}











+(void)Connect:(void(^)(Status*))callback :(NSString*)identify;
{
    connectPeripheral=nil;
    [Bluetooth Init:^(Status *status) {
        if (![status IsNormal]) {
            callback(status);
            return ;
        }
        
        [Bluetooth Disconnect:^(Status *status) {
        [Bluetooth ScanStop:^(Status *status) {
                connectCallback=callback;
                connectIdentify=identify;
                connectTimer=[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(_ConnectTimeout) userInfo:nil repeats:NO];
                [Instance.manager scanForPeripheralsWithServices:nil options:nil];
            }];
        }];
    }];
}

+(CBPeripheral*)GetconnectPeripheral;
{
    return connectPeripheral;
}
+(void)_ConnectCallback:(Status *)status
{
    if (connectCallback!=nil) {
        connectCallback(status);
        connectCallback=nil;
    }
}
+(void)_ConnectScanFind:(CBPeripheral*)peripheral
{
    connectPeripheral= [peripheral copy];
    [Bluetooth _ConnectScanStop:^() {
        [Instance.manager connectPeripheral:peripheral options:nil];
    }];
}
+(void)_ConnectTimeout
{
    [Bluetooth _ConnectScanStop:^() {
        [Bluetooth _ConnectCallback:[[[Status alloc]init] NotConnect]];
    }];
}
+(void)_ConnectScanStop:(void(^)())callback;
{
    if (connectTimer!=nil) {
        [connectTimer invalidate];
        [Instance.manager stopScan];
        connectTimer=nil;
    }
    callback();
}
+(void)Disconnect:(void(^)(Status*))callback;
{
    [Bluetooth Init:^(Status *status) {
        if(![[Instance getStatus] IsNormal]){
            callback([Instance getStatus]);
            return;
        }
        [Bluetooth _ConnectScanStop:^{
            if(connectPeripheral==nil)
            {
                callback([[Status alloc]init]);
                return ;
            }
            disconnectCallback=callback;
            disconnectTimer=[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(_DisconnectTimeout) userInfo:nil repeats:NO];
            [Instance.manager cancelPeripheralConnection:connectPeripheral];
        }];
    }];
}
+(void)_DisconnectTimeout
{
    [Bluetooth _DisconnectCallback:[[[Status alloc]init]Unknown:@"断开设备超时"]];
}
+(void)_DisconnectCallback:(Status *)status
{
    connectPeripheral=nil;
    if (disconnectTimer!=nil) {
        [disconnectTimer invalidate];
        disconnectTimer=nil;
    }
    if (connectCallback!=nil) {
        connectCallback(status);
        connectCallback=nil;
    }
}

    //连接设备失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if(!isReady)
    {
        return;
    }
    NSLog(@"连接设备失败");
    [Bluetooth _ConnectCallback:[[[Status alloc]init] NotConnect]];
}
    //连接设备成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if(!isReady)
    {
        return;
    }
    NSLog(@"连接设备成功");
    [Bluetooth _ConnectCallback:[[Status alloc]init]];
}
    //设备断开连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if(!isReady)
    {
        return;
    }
    NSLog(@"设备断开连接");
    [Bluetooth _DisconnectCallback:[[Status alloc]init]];
}



















-(instancetype)init
{
    self.manager=nil;
    queryCallbacks=[[NSMutableArray alloc]init];
    self.__managerStatus=[[Status alloc]init];

    isReady=false;
    scanList=[[NSMutableArray alloc]init];
    
    return self;
}


















-(void)query:(void(^)(Status*))callback;
{
    if (isReady)
    {
         callback([self getStatus]);
         return;
    }
    [queryCallbacks addObject:callback];
  
    if(self.manager==nil){
            //创建中央设备管理者，并检测设备是否支持BLE
        self.manager=[[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    }
}
-(Status*)getStatus;
{
    return [self.__managerStatus Copy];
}
#pragma mark - 设置代理之后，开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    Status*status=self.__managerStatus;
    isReady=true;
    
    switch (central.state) {

        case CBManagerStateResetting:
            
            return;
        case CBManagerStateUnauthorized:
            
            [status Unknown:@"蓝牙当前状态不可用"];
            
        case CBCentralManagerStateUnsupported:
            
            [status NotSupport];
            break;
            
        case CBCentralManagerStatePoweredOff:
            
            [status NotOpen];
            break;
            
        case CBCentralManagerStatePoweredOn:
            
            [status Normal];
            break;
            
        default:
            [status Unknown:@"蓝牙状态未知"];
            break;
    }
    
    NSMutableArray*list=queryCallbacks;
    queryCallbacks=[[NSMutableArray alloc]init];
    for (void(^callback)(Status*) in list)
    {
      callback([self getStatus]);
    }
}

@end
