//
//  Service.h
//  你点我帮
//
//  Created by admin on 2016/12/19.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject

+(void)ServerSharedAppConfig:(void(^)(bool))callback;

+(long)VersionCode:(NSString*)version;

@end
