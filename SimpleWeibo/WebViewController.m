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
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backBarButtonClicked:)];
    [barButtonItem setTintColor:[UIColor colorWithRed:249 /255.0 green:102 / 255.0 blue:0.0 alpha:1.0]];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    _webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

-(void)backBarButtonClicked:(UIBarButtonItem*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
