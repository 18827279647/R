//
//  Cmmotion.m
//  你点我帮
//
//  Created by admin on 2017/5/2.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import "Cmmotion.h"
#import "ViewController.h"

static CLLocationManager*mar=nil;
@implementation Cmmotion

+ (Cmmotion*)getCmmotionManager;
{
    static Cmmotion *cmmotion = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        cmmotion = [[self alloc] init];
        mar=[[CLLocationManager alloc]init];
    });
    return cmmotion;
}

-(void)openCmmotion;
{
    if ([self isDeviceMotionAvailable]) {
    
        [self startDeviceMotionUpdates];
        self.deviceMotionUpdateInterval =0.2;
        mar.delegate=self;
        [mar startUpdatingHeading];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{

    double x=-self.deviceMotion.attitude.pitch*(180.0/M_PI);
    double y=self.deviceMotion.attitude.roll*(180.0/M_PI);
    double z=newHeading.magneticHeading;
    if(x<0){
        x=360.0+x;
    }
    if(y<0){
        y=360.0+y;
    }
    [[ViewController viewControllerManager]excode:[NSString stringWithFormat:@"AppRequest.Orientation(%f,%f,%f)",z,x,y]];

}
-(void)closeCmmotion;
{
    [self stopDeviceMotionUpdates];
    [mar stopUpdatingHeading];

}



@end
