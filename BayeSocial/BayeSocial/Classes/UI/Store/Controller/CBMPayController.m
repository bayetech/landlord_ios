//
//  CBMPayController.m
//  Baye
//
//  Created by 左坤 on 16/7/22.
//  Copyright © 2016年 Bayekeji. All rights reserved.
//

#import "CBMPayController.h"
#import <cmbkeyboard/CMBWebKeyboard.h>
#import <cmbkeyboard/NSString+Additions.h>
#import "WKWebViewJavascriptBridge.h"
#import "BayeSocial-Swift.h"
#import <WebKit/WebKit.h>

@interface CBMPayController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@end

@implementation CBMPayController {
    NSURLRequest *_requestUrl;
}

- (void)loadUrl:(NSString*)outerURL
{
    NSURL *url = [NSURL URLWithString: outerURL];
    _requestUrl = [NSURLRequest requestWithURL:url];
}

- (void)loadURLRequest:(NSURLRequest*)requesturl
{
    _requestUrl = requesturl;
}

- (void)reloadWebView
{
    
    [_webView loadRequest: _requestUrl];

    
}
- (void)viewDidLoad
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [super viewDidLoad];
    [self setNav];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
//    _webView.frame = self.view.frame;
    [self.view addSubview:_webView];
//    _webView.delegate = self;
    [self setBridge];
    
}
-(void)setBridge{
    
//    [WebViewJavascriptBridge enableLogging];
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    
//    [_bridge setWebViewDelegate:self];
    [_bridge registerHandler:@"initCmbSignNetPay" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
        responseCallback(@"send JS from OC");
    }];
    
    
    [_bridge callHandler:@"initCmbSignNetPay" data:@{@"asidiaos": @"asdasd"} responseCallback:^(id responseData) {
        NSLog(@"%@",responseData);
    }];
    
    
    
}
-(void)setNav{
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBackOrder)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

-(void)goBackOrder{
    if ([self.delegate respondsToSelector:@selector(cancelPay:)]) {
        [_delegate cancelPay:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[CMBWebKeyboard shareInstance] hideKeyboard];
    
    [self reloadWebView];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[CMBWebKeyboard shareInstance] hideKeyboard];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.host isCaseInsensitiveEqualToString:@"cmbls"]) {
        CMBWebKeyboard *secKeyboard = [CMBWebKeyboard shareInstance];
        [secKeyboard showKeyboardWithRequest:request];
        secKeyboard.webView = webView;
        UITapGestureRecognizer* myTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.view addGestureRecognizer:myTap];
        myTap.delegate = self;
        myTap.cancelsTouchesInView = NO;
        return NO;
    }
    
    if ([request.URL.host isEqualToString:@"backend.bayekeji.com"]) {
        if ([self.delegate respondsToSelector:@selector(goOrderVC:)]){
            [self.delegate goOrderVC:self];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [[CMBWebKeyboard shareInstance] hideKeyboard];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[CMBWebKeyboard shareInstance] hideKeyboard];
    
}




@end
