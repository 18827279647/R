//
//  CrashExceptioinCatcher.h
//  你点我帮
//
//  Created by admin on 16/5/16.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashExceptioinCatcher : NSObject<NSURLSessionDataDelegate>

+(void)startCrashExceptionCatah;

+(void)getstring:(NSString*)resason getName:(NSString*)name getNarray:(NSMutableArray*)array;
@end
