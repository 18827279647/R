//
//  MyURLProtocol.h
//  NSURLProtocol
//
//  Created by zhaoyaqun on 15/11/30.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyURLProtocol : NSURLProtocol<NSURLConnectionDelegate>

@property (nonatomic , strong) NSURLConnection *connection;

@property (nonatomic , strong) NSHTTPURLResponse *response;



@end
