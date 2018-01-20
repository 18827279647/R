//
//  SendConnectionViewController.m
//  你点我帮
//
//  Created by zhaoyaqun on 15/11/23.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import "SendConnectionViewController.h"

@interface SendConnectionViewController ()

@end

@implementation SendConnectionViewController

+ (SendConnectionViewController*)sendViewControllerManager {
    static SendConnectionViewController *sendView = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sendView = [[self alloc] init];
    });
    return sendView;
}

+(NSData *)sendRequest:(NSURLRequest *)urlRequest
{
    NSURLResponse *urlResponse = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:nil];
    if (urlData) {
        return urlData;
    }else
    {
        return nil;
    }
}

@end
