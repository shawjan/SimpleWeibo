//
//  LoginViewController.m
//  SimpleWeibo
//
//  Created by shawjan on 16/4/19.
//  Copyright © 2016年 shawjan. All rights reserved.
//

#import "LoginViewController.h"
#import <WeiboSDK/WeiboSDK.h>

@interface LoginViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,NSURLSessionDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *accountTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIImageView *accountImg;
@property (strong, nonatomic) IBOutlet UIImageView *passwordImg;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIImageView *avatorImg;
@property (strong, nonatomic) IBOutlet UIView *accountTFCV;
@property (strong, nonatomic) IBOutlet UIView *passwordTFCV;

@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) NSArray *hasLoginAccounts;
@property(nonatomic, strong) NSArray *postfixArray;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSString *prefix;
@property (strong, nonatomic) IBOutlet UIView *containtView;


@end

@implementation LoginViewController

-(NSArray *)postfixArray
{
    return @[@"@163.com", @"@126.com", @"@188.com", @"@yeah.net", @"@vip.163.com", @"@vip.126.com"];
}

-(NSMutableArray *)tableViewData
{
    if(!_tableViewData){
        _tableViewData = [[NSMutableArray alloc] init];
    }
    return _tableViewData;
}

-(NSArray *)hasLoginAccounts
{
    if (!_hasLoginAccounts) {
        //没有取到邮箱权限
//        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        NSMutableArray *array = [NSMutableArray array];
//        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:Weibo_UserLoginHistory];
//        NSArray *keyArray = [dic allKeys];
//        for (NSString *string in keyArray) {
//            [array addObject:string];
//        }
//        _hasLoginAccounts = [array copy];
    }
    return @[@"LW-fsj@163.com"];
}

#define tableViewRowHeight 30

-(UITableView *)tableView
{
    if(!_tableView){
        //CGRect frame = self.accountTFCV.frame;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.passwordTFCV.frame.origin.y, self.view.frame.size.width, 0)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.cornerRadius = 5;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor grayColor];
        _tableView.allowsSelection = YES;
        [self.containtView addSubview:_tableView];
        [self.containtView bringSubviewToFront:_tableView];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SJDropDownViewCellIdentifier"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)awakeFromNib
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    [view addGestureRecognizer:tapGesture];
    [self.containtView insertSubview:view belowSubview:self.loginButton];
    //[self.view addGestureRecognizer:tapGesture];
    //self.view.userInteractionEnabled = YES;
    self.accountTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissLoginVC:) name:DismissLoginVC object:nil];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DismissLoginVC object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.avatorImg.clipsToBounds = YES;
    self.avatorImg.layer.masksToBounds = YES;
    self.avatorImg.layer.cornerRadius = self.avatorImg.frame.size.height / 4;
}

-(void)dismissLoginVC:(NSNotification*)noti
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tapClicked:(UIGestureRecognizer*)sender
{
    if([self.accountTextField isFirstResponder]){
        [self.accountTextField resignFirstResponder];
    }else if([self.passwordTextField isFirstResponder]){
        [self.accountTextField resignFirstResponder];
    }
}
- (IBAction)loginButtonClicked:(id)sender {
    //新浪关闭了Basic Auth认证，因此只能通过oauth2.0访问
    /*NSString *authStr = @"jianzhelizhi@163.com:******";
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodeStr = [authData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", encodeStr];
    NSString *urlString = @"http://api.t.sina.com.cn/update.xml";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = @{@"Authorization":authValue};
    request.HTTPMethod = @"GET";
    //NSString *bodyStr = [NSString stringWithFormat:@"source=%@&status=api test"];
    //request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
            NSLog(@"success:%@ \n %@", data, response);
        }
    }];
    [dataTask resume];*/
    
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = App_REDIRECT_URL;
    request.scope = @"all";
    request.shouldShowWebViewForAuthIfCannotSSO = YES;
    [WeiboSDK sendRequest:request];
}

#define gapBetweenTextField (tableViewRowHeight * 3)

-(void)keyboardWillShow:(NSNotification*)noti
{
    CGSize size = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat keyboardYAix = self.view.frame.size.height - size.height;
    CGFloat gapHeight = 0.0;
    BOOL shouldAdjust = NO;
    if([self.accountTextField isFirstResponder]){
        gapHeight = self.accountTFCV.frame.origin.y + self.accountTFCV.frame.size.height - keyboardYAix;
        if(gapHeight > -gapBetweenTextField){
            shouldAdjust = YES;
        }
    }else if([self.passwordTextField isFirstResponder]){
        gapHeight = self.passwordTFCV.frame.origin.y + self.passwordTFCV.frame.size.height - keyboardYAix;
        if(gapHeight > -gapBetweenTextField){
            shouldAdjust = YES;
        }
    }
    if (shouldAdjust) {
        [self.scrollView setContentOffset:CGPointMake(0, gapHeight + gapBetweenTextField) animated:YES];
    }
}

-(void)keyboardWillHide:(NSNotification*)noti
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([self.accountTextField isFirstResponder]){
        [self.passwordTextField becomeFirstResponder];
    }else if([self.passwordTextField isFirstResponder]){
        [self loginButtonClicked:nil];
    }
    return YES;
}

-(void)textFieldDidChanged:(NSNotification*)noti
{
    if([self.passwordTextField isFirstResponder]){
        return;
    }
    NSRange range = [self.accountTextField.text localizedStandardRangeOfString:@"@"];
    if(range.location != NSNotFound){
        self.prefix = [self.accountTextField.text substringToIndex:range.location];
        NSString *postifx = [self.accountTextField.text substringFromIndex:range.location];
        [self.tableViewData removeAllObjects];
        for (NSString *str in self.postfixArray) {
            if([str isEqualToString:postifx] || (str.length > postifx.length && [str hasPrefix: postifx]) )
            {
                [self.tableViewData addObject:str];
            }
        }
    }else{
        self.prefix = self.accountTextField.text;
        [self.tableViewData removeAllObjects];
        for (NSString *str in self.postfixArray) {
            [self.tableViewData addObject:str];
        }
    }
    CGRect frame = self.tableView.frame;
    if([self.prefix isEqualToString:@""]){
        frame.size.height = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.tableView.frame = frame;
        [UIView commitAnimations];
    }else{
        [self.tableView reloadData];
        //CGRect aTFFrame = self.accountTFCV.frame;
        frame.origin.y = self.passwordTFCV.frame.origin.y;
        frame.size.height = gapBetweenTextField;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.tableView.frame = frame;
        [UIView commitAnimations];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.hasLoginAccounts count] + [self.tableViewData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableViewRowHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJDropDownViewCellIdentifier" forIndexPath:indexPath];
    if(indexPath.row < self.hasLoginAccounts.count){
        cell.textLabel.text = self.hasLoginAccounts[indexPath.row];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@", self.prefix, [self.tableViewData objectAtIndex:indexPath.row - self.hasLoginAccounts.count]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.hasLoginAccounts.count){
        self.accountTextField.text = self.hasLoginAccounts[indexPath.row];
    }else{
        self.accountTextField.text = [NSString stringWithFormat:@"%@%@", self.accountTextField.text, [self.tableViewData objectAtIndex:indexPath.row - self.hasLoginAccounts.count]];
    }
    
    CGRect frame = self.tableView.frame;
    frame.size.height = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.tableView.frame = frame;
    [UIView commitAnimations];
};

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
