//
//  Request.h
//  你点我帮商户版
//
//  Created by admin on 2016/12/27.
//  Copyright © 2016年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject

+(void)getHttp:(void(^)(bool))callback;

@end
