//
//  Cmmotion.h
//  你点我帮
//
//  Created by admin on 2017/5/2.
//  Copyright © 2017年 zhaoyaqun. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
@interface Cmmotion : CMMotionManager<CLLocationManagerDelegate>

+(Cmmotion*)getCmmotionManager;

-(void)openCmmotion;

-(void)closeCmmotion;


@end
