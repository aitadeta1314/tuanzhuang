//
//  LoginViewController.m
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "UserListView.h"
#import "MainNavigationViewController.h"
#import "SynCodeView.h"

@interface LoginViewController ()

@property (nonatomic, strong)  UIImageView * mascotImg;/** 吉祥物 */
@property (nonatomic, strong) UIImageView * bgImg;/** 背景 */
@property (nonatomic, strong) UILabel * topTitle;/**  */
@property (nonatomic, strong) UIButton * backButton;/**<返回按钮*/
//
@property (nonatomic, strong) IQPreviousNextView * inputBox;/**  */
@property (nonatomic, strong) UIView * company;/**  */
@property (nonatomic, strong) UIView * userName;/**  */
@property (nonatomic, strong) UIButton * userNameButton;/**  */
@property (nonatomic, strong) UIView * userPwd;/**  */
@property (nonatomic, strong) UIButton * submitBtn;/**  */
//
@property (nonatomic, strong) UserListView * userListView;/** 用户列表 */

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self addBackButton];
    [self layoutView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.presentingViewController) {
        self.backButton.hidden = NO;
    } else {
        self.backButton.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 懒加载
-(UIImageView *)mascotImg{
    if(!_mascotImg){
        _mascotImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_mascot"]];
        [self.view addSubview:_mascotImg];
        [_mascotImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(340);
            make.height.mas_equalTo(280);
            make.bottom.equalTo(self.view).offset(-100);
            make.right.equalTo(_inputBox.mas_left).offset(-100).priorityLow();
        }];
    }
    return _mascotImg;
}

-(UIImageView *)bgImg{
    if(!_bgImg){
        _bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg.png"]];
        [self.view addSubview:_bgImg];
        [_bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.top.equalTo(self.view);
            make.height.mas_equalTo(SCREEN_H);
        }];
    }
    return _bgImg;
}

-(UILabel *)topTitle{
    if(!_topTitle){
        _topTitle = [[UILabel alloc] init];
        NSDictionary *dic = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:50],NSParagraphStyleAttributeName:[[NSMutableParagraphStyle alloc] init],NSKernAttributeName:@4.0f};
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:@"欢迎使用酷特智能量体" attributes:dic];
        _topTitle.attributedText = attributeStr;
        _topTitle.textColor = RGBColor(255, 255, 255);
        _topTitle.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_topTitle];
        [_topTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.top.equalTo(self.view.mas_top).offset(99);
        }];
    }
    return _topTitle;
}

-(UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [self.view addSubview:_backButton];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.left.equalTo(self.view).offset(0);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

-(UserListView *)userListView{
    if(!_userListView){
        _userListView = [[UserListView alloc] init];
        [_userName addSubview:_userListView];
        _userListView.dataSource = self;
        [_userListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(_userName);
            make.height.mas_equalTo(80);
            make.top.equalTo(_userName.mas_top).offset(50);
        }];
    }
    return _userListView;
}

-(IQPreviousNextView *)inputBox{
    if(!_inputBox){
        _inputBox = [[IQPreviousNextView alloc] init];
        [self.view addSubview:_inputBox];
        [_inputBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(340);
            make.height.mas_equalTo(400);
            make.right.equalTo(self.view).offset(-100).priorityLow();
            make.bottom.equalTo(self.view).priorityLow();
        }];
        self.company.hidden = NO;
        self.userName.hidden = NO;
        self.userListView.hidden = NO;
        self.userPwd.hidden = NO;
        self.submitBtn.hidden = NO;
    }
    return _inputBox;
}

-(UIView *)company{
    if(!_company){
        _company = [self createInput:@"组织名称" leftIcon:@"company_icon"  result:^(UIView *row,UITextField *input) {
            _companyText = input;
            _companyText.autocorrectionType = UITextAutocorrectionTypeNo;
        }];
        [_inputBox addSubview:_company];
        [_company mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.top.left.equalTo(self.inputBox);
            make.height.mas_equalTo(50);
        }];
    }
    return _company;
}

-(UIView *)userName{
    if(!_userName){
        _userName = [self createInput:@"用户名" leftIcon:@"user_icon" result:^(UIView *row,UITextField *input) {
            _userNameText = input;
            _userNameText.autocorrectionType = UITextAutocorrectionTypeNo;
            _userNameButton = [[UIButton alloc] init];
            _userNameButton.hidden = YES;
            [_userNameButton setImage:[UIImage imageNamed:@"drop_down_icon"] forState:UIControlStateNormal];
            [_userNameButton addTarget:self action:@selector(showUsersAction:) forControlEvents:UIControlEventTouchDown];
            input.rightViewMode = UITextFieldViewModeAlways;
            input.rightView = _userNameButton;
            input.rightView.layer.frame = CGRectMake(0,0,50,30);
            //
        }];
        _userName.tag = 0;
        _userName.layer.masksToBounds = YES;
        _userName.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
        [_inputBox addSubview:_userName];
        [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(self.inputBox);
            make.height.mas_equalTo(50).priorityMedium();
            make.top.equalTo(self.company.mas_bottom).offset(30);
        }];
    }
    return _userName;
}

-(UIView *)userPwd{
    if(!_userPwd){
        _userPwd = [self createInput:@"密码" leftIcon:@"pwd_icon" result:^(UIView *row,UITextField *input) {
            input.secureTextEntry = YES;
            _userPwdText = input;
        }];
        [_inputBox addSubview:_userPwd];
        [_userPwd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(self.inputBox);
            make.height.mas_equalTo(50);
            make.top.equalTo(self.userName.mas_bottom).offset(30);
        }];
    }
    return _userPwd;
}

-(UIButton *)submitBtn{
    if(!_submitBtn){
        _submitBtn = [[UIButton alloc] init];
        _submitBtn.titleLabel.textColor = RGBColor(255, 255, 255);
        _submitBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _submitBtn.layer.shadowOffset =  CGSizeMake(.5, .5);
        _submitBtn.layer.shadowOpacity = 0.1;
        _submitBtn.layer.shadowColor =  [UIColor blackColor].CGColor;
        _submitBtn.layer.cornerRadius = 5;
        _submitBtn.tag = 0;
        [_submitBtn setTitle:@"登  录" forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(onSubmit) forControlEvents:UIControlEventTouchDown];
        [_inputBox addSubview:_submitBtn];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(self.inputBox);
            make.height.mas_equalTo(50);
            make.top.equalTo(self.userPwd.mas_bottom).offset(30);
        }];
    }
    if(!_submitBtn.tag){
        _submitBtn.backgroundColor = RGBColor(225, 240, 255);
    }else{
        _submitBtn.backgroundColor = skyColor;
    }
    return _submitBtn;
}

-(void)layoutView{
    self.view.backgroundColor = RGBColor(255, 255, 255);
    self.bgImg.hidden = NO;
    self.topTitle.hidden = NO;
    self.inputBox.hidden = NO;
    self.mascotImg.hidden = NO;
}

- (UIView*)createInput:(NSString*)text leftIcon:(NSString*) icon result:(void(^)(UIView* row,UITextField* input))result{
    UIView* row = [[UIView alloc] init];
    row.layer.borderWidth = 1;
    row.layer.cornerRadius = 5;
    row.layer.borderColor = RGBColor(204, 204, 204).CGColor;
    //
    UITextField* input = [[UITextField alloc] init];
    [input addTarget:self action:@selector(endChangeInputAction:) forControlEvents:UIControlEventEditingChanged];
    [row addSubview:input];
    [input mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(row);
        make.height.mas_equalTo(30);
        make.top.equalTo(row).offset(10).priorityLow();
    }];
    //
    UIImageView *selIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    selIcon.contentMode = UIViewContentModeCenter;
    input.placeholder = text;
    [input setValue:RGBColor(204, 204, 204)  forKeyPath:@"_placeholderLabel.textColor"];
    [input setValue:[UIFont systemFontOfSize:16.0] forKeyPath:@"_placeholderLabel.font"];
    input.textColor = RGBColor(51, 51, 51);
    input.leftView = selIcon;
    input.leftView.layer.frame = CGRectMake(0,0,50,30);
    input.leftViewMode = UITextFieldViewModeAlways;
    input.layer.masksToBounds = YES;
    input.layer.borderWidth = 0;
    [input setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    result(row,input);
    return row;
}


#pragma mark - action
-(void)backButtonAction{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)delUserAction:(NSDictionary*)info{
    [self confirmDialog:@"" content:[NSString stringWithFormat:@"确定删除用户%@？",[info objectForKey:@"uname"]] result:^(NSInteger i, id obj) {
        if(i){
            [UserManager delUser:info];
            [self endChangeInputAction:_companyText];
        }
    }];
}

-(void) showUsersAction:(UIButton*)sel {
    if(_userName.tag){
        [UIView animateWithDuration:.3 animations:^{
            CGAffineTransform tran = CGAffineTransformMakeRotation(0);
            [sel setTransform:tran];
            //
            [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(50).priorityHigh();
            }];
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            CGAffineTransform tran = CGAffineTransformMakeRotation(M_PI);
            [sel setTransform:tran];
            //
            [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(130).priorityHigh();
            }];
        }];
    }
    //
    _userName.tag = !_userName.tag;
}

-(void) selectUser:(NSDictionary*)one{
    NSString* name = [one objectForKey:@"uname"];
    self.selectUser = one;
    self.userNameText.text = name;
    self.userName.tag = 1;
    [self.userNameButton sendActionsForControlEvents:UIControlEventTouchDown];
}

-(void) endChangeInputAction:(id)sender{
    // 刷新按钮样式
    NSString* v1 = [_companyText text];
    NSString* v2 = [_userNameText text];
    NSString* v3 = [_userPwdText text];
    if([v1 length]<=0 || [v2 length]<=0 || [v3 length]<=0){
        _submitBtn.tag = 0;//失败
    }else{
        _submitBtn.tag = 1;//成功
    }
    [self submitBtn];
    // change: 用户名称
    if([sender isEqual:_userNameText]){
        self.selectUser = nil;
    }
    // change：组织名称
    if([v1 length]>0 && [sender isEqual:_companyText]){
        NSArray* arr = [UserManager getLoginUsers:v1];
        // 隐藏
        if(_userName.tag){
            [self showUsersAction:_userNameButton];
        }
        // 刷新数据
        if(arr.count){
            [_userListView loadData:arr];
            _userNameButton.hidden = NO;
        }else{
            _userNameButton.hidden = YES;
        }
    }
}

-(void) onSubmit {
    if(!_submitBtn.tag){return;}
    NSString* cname = [_companyText text];
    NSString* uname = [_userNameText text];
    NSString* upwd = [_userPwdText text];
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setValue:@{@"code":cname} forKey:@"sOrganization"];
    [param setValue:uname forKey:@"usercode"];
    [param setValue:self.userPwdText.text forKey:@"password"];
    [param setValue:@"ios" forKey:@"device"];
    [self showLoadingWith:@"正在登录..."];
    [NetworkOperation postWithHost:[NSString stringWithFormat:@"%@suser/login",HTTP_HEADER] andToken:@"" andType:JSONOBJECT andParameters:param andSuccess:^(id rootobject) {
        [self hideLoading];
        [UserManager saveUser:@{
                                @"multiName":[NSString stringWithFormat:@"%@(%@)",[rootobject valueForKey:@"userName"],[SynCodeView randomString]],
                                @"userId":[rootobject valueForKey:@"userId"],
                                @"orgId":[rootobject valueForKey:@"organizationCode"],
                                @"cname":cname,
                                @"uname":uname,
                                @"upwd":upwd,
                                @"token":[rootobject valueForKey:@"tokenId"],
                                @"showname":[rootobject valueForKey:@"userName"]
                                }];
        MainNavigationViewController * homeVc = VCFromBundleWithIdentifier(@"MainNavigationViewController");
        [self presentViewController:homeVc animated:YES completion:^{}];
    } andFailure:^(NSError *error, NSString *errorMessage) {
        [self hideLoading];
        [self showHUDMessage:errorMessage];
    }];
}

-(void) onSubmit_error{
    [self confirmDialog:@"" content:[NSString stringWithFormat:@"密码错误"] result:^(NSInteger i, id obj) {}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
