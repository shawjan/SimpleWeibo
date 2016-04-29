//
//  WebViewController.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/27.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController()<UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSURL *url;

@end

@implementation WebViewController

-(instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if(self){
        _url = url;
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}


@end
