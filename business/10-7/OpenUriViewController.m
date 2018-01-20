//
//  OpenUriViewController.m
//  你点我帮
//
//  Created by zhaoyaqun on 15/12/10.
//  Copyright © 2015年 zhaoyaqun. All rights reserved.
//

#import "OpenUriViewController.h"
#import "AppRequest.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
@interface OpenUriViewController ()<NJKWebViewProgressDelegate,UIWebViewDelegate>
{
    UIWebView *myWeb;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    UINavigationBar *navBar;

}
@end

@implementation OpenUriViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    myWeb.backgroundColor = [UIColor redColor];
    myWeb = [[UIWebView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-15)];
    myWeb.scalesPageToFit =YES;
    myWeb.scrollView.alwaysBounceHorizontal = YES;
    //myWeb.delegate = _progressProxy;
    [self.view addSubview:myWeb];
    
    [self.view addSubview:navBar];


    _progressProxy = [[NJKWebViewProgress alloc] init];
    myWeb.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = navBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 40, 20)];
    [backBtn setTitle:@"返回" forState:0];
    [backBtn setTitleColor:[UIColor redColor] forState:0];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openUri:) name:@"openUri" object:nil];
}

-(void)backAction
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)openUri:(NSNotification *)sender
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sender.object]];
    [myWeb loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navBar addSubview:_progressView];
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
