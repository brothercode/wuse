//
//  DrawCashViewController.m
//  WuSe2.0
//
//  Created by 刘春明 on 16/3/16.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "DrawCashViewController.h"
#import "ChargeViewController.h"
#import "DrawCashInfoViewController.h"
#import "WSPickerView.h"
#import "DrawChargeRecordViewController.h"
#import "HttpUserInfoManager.h"
#import "HttpDrawCashScaleManager.h"
#import "ImageWithLabelView.h"
#import "LabelWithLabelView.h"


@interface DrawCashViewController ()<WSPickerViewDelegate>

@property (nonatomic ,retain) UIView *viewAccount;

@property (nonatomic ,retain) UILabel *sumRedpackage;

@property (nonatomic ,retain) UIButton *btnPublic;


//提现比例
@property (nonatomic ,assign) CGFloat scaleDraw;

//是否获取到提现比例
@property (nonatomic ,assign) BOOL haveScale;

//是否可以充值
@property (nonatomic ,assign) BOOL canCharge;

@property (nonatomic ,retain) LabelWithLabelView *remainLabel;

@property (nonatomic ,retain) LabelWithLabelView *drawLabel;

@property (nonatomic ,assign) BOOL requestSwitch;



@end

@implementation DrawCashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.haveScale = NO;
    self.canCharge = NO;
    
    if (kUserDefine.userType > 0) {
        self.haveScale = YES;
    }
    
    
    WS(weakSelf)
    [self addNaviBarWithTitle:@"我的账户" hasBackBtn:YES withRightBarItemImgStr:@"记录" actionBlock:^(NSInteger btnIndex) {
        if (btnIndex == 10) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            DrawChargeRecordViewController *recordVC = [[DrawChargeRecordViewController alloc] init];
            [weakSelf.navigationController pushViewController:recordVC animated:YES];
        }
    }];
    self.navSingleLine.alpha = 0;
//    [self.view addSubview:self.viewAccount];
//    [self.viewAccount addSubview:self.sumRedpackage];
//    [self.view addSubview:self.btnPublic];
    
   
    
    //获取提现比例参数
    [self getDrawCashScale];
    
    
     [self initViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.sumRedpackage.text = [NSString stringWithFormat:@"账户余额:%ld红包",kUserDefine.userRedPackage];
    
    
    [self updateNumberInfo];
    
    [self requestUserInfo];
}

-(void)updateNumberInfo
{
    [self.remainLabel updateInfoWithTitle:[NSString stringWithFormat:@"%ld",kUserDefine.userRedPackage] subTitle:@""];
    if (self.haveScale) {
        [self.drawLabel updateInfoWithTitle:[NSString stringWithFormat:@"%.2f",kUserDefine.userIncomeRemain/10.0 *kUserDefine.userType/100] subTitle:@""];
        
        NSLog(@"%.2ld",kUserDefine.userIncomeRemain/10 *kUserDefine.userType);
    }else{
        [self.drawLabel updateInfoWithTitle:@"0.00"subTitle:@""];
    }
}

-(void)getDrawCashScale
{
    WS(weakSelf)
    if (![self networkingIsReachable]) {
        return;
    }
    [ProgressHUDManager showInfoStatusWithMessage:@"数据正在加载" maskType:1];
    HttpDrawCashScaleManager* mana = [[HttpDrawCashScaleManager alloc] init];
    
    [mana loadDataWithsuccessCallback:^(HttpAPIBaseManager *manager) {
        
        [ProgressHUDManager hideProgressHud];
        NSDictionary *dict = manager.resultData;
        NSLog(@"--%@",dict);
        if ([weakSelf isGottonDataUsable:manager.resultData])
        {
            NSDictionary *dic = [dict objectForKey:@"content"];
            
            NSInteger  userType = [[dic objectForKey:@"userType"] integerValue];
            NSInteger  rechargeFlag = [[dic objectForKey:@"rechargeFlag"] integerValue];
            if (rechargeFlag == 1) {
                self.canCharge = YES;
            }else{
                self.canCharge = NO;
            }
            
            if (userType >0) {//提现比例
                kUserDefine.userType = userType;
                self.haveScale = YES;
                
            }else{
                kUserDefine.userType = 50;
                self.haveScale = YES;
            }
        }else
        {
            self.canCharge = YES;
            [ProgressHUDManager showFailWithMessage:[dict objectForKey:@"message"] maskType:ProgressHUDMaskTypeBlack];
        }
    } failCallback:^(HttpAPIBaseManager *manager) {
        [ProgressHUDManager showFailWithMessage:kReqeustFaild];
    }];
}

//获取个人信息
-(void)requestUserInfo
{
    WS(weakSelf)
    if (![self networkingIsReachable]) {
        kDefineNetworkNotReachable
        return;
    }
    
    HttpUserInfoManager* mana = [[HttpUserInfoManager alloc] init];
    mana.getUserId = kUserDefine.uid;
    
    [mana loadDataWithsuccessCallback:^(HttpAPIBaseManager *manager) {
        NSDictionary *dict = manager.resultData;
        NSLog(@"--%@",dict);
        if ([weakSelf isGottonDataUsable:manager.resultData])
        {
            NSDictionary *dic = [[dict objectForKey:@"content"] objectForKey:@"userInfo"];
            DatingAccountInfo *user = [[DatingAccountInfo alloc] initWithDictionary:dic];
            if (user.uid >0) {
                kUserDefine.userHeadUrl = user.userHeadUrl;
                kUserDefine.userDescript = user.userDescript;
                kUserDefine.userFansNum = user.userFansNum;
                kUserDefine.userFollowNum = user.userFollowNum;
                kUserDefine.userNickName = user.userNickName;
                kUserDefine.userPayFlag = user.userPayFlag;
                kUserDefine.userRedPackage = user.userRedPackage;
                kUserDefine.userIncomeRemain = user.userIncomeRemain;
                kUserDefine.user_xf_flag = user.user_xf_flag;
                [kDatingManagers.userManager.hostUser saveAccountToNative];
                
                self.sumRedpackage.text = [NSString stringWithFormat:@"账户余额:%ld红包",kUserDefine.userRedPackage];
                
                
                [self updateNumberInfo];
            }
        }else{
            
        }
    } failCallback:^(HttpAPIBaseManager *manager) {
        
    }];
}

#pragma mark -提现
-(void)drawCash
{
    if (kUserDefine.userIncomeRemain  == 0) {
        [ProgressHUDManager showFailWithMessage:@"您的账户余额为0，无法提现"];
        return;
    }
    if (kUserDefine.userIncomeRemain/10.0 *kUserDefine.userType/100 < 100) {
        [ProgressHUDManager showFailWithMessage:@"您的账户余额不足100元，无法提现"];
        return;
    }
    
    if (!self.haveScale) {
        [ProgressHUDManager showFailWithMessage:@"暂时不可提现"];
        return;
    }
    DrawCashInfoViewController *drawCash = [[DrawCashInfoViewController alloc] init];
    [self.navigationController pushViewController:drawCash animated:YES];
}

#pragma mark -充值
-(void)charge
{
    if (![self networkingIsReachable]) {
        [ProgressHUDManager showFailWithMessage:kNotReachableNetwork];
        return;
    }
    if (!self.canCharge) {
        [ProgressHUDManager showFailWithMessage:@"IOS版本充值功能正在开发中"];
        return;
    }
    ChargeViewController *charge =[[ChargeViewController alloc] init];
    [charge pushChargeVCWithTarget:self Complition:^{
        NSLog(@"charged");
    }];
    
    
//    [self.navigationController pushViewController:charge animated:YES];
}

//-(void)selectBank
//{
//    WSPickerView *picker = [[WSPickerView alloc] initWithData:nil delegate:self type:TYPE_PICKER_BANK];
//    picker.frame = self.view.bounds;
//    [picker showInView:self.view];
//}

-(UILabel *)sumRedpackage
{
    if (!_sumRedpackage) {
        _sumRedpackage = [[UILabel alloc] init];
        _sumRedpackage.frame = CGRectMake(10, 0, 200, self.viewAccount.frame.size.height);
        _sumRedpackage.font = kFont(13);
        _sumRedpackage.textColor = kColorWhite;
        _sumRedpackage.text = [NSString stringWithFormat:@"账户余额:%ld红包",kUserDefine.userRedPackage];
    }
    return _sumRedpackage;
}

-(UIView *)viewAccount
{
    if (!_viewAccount) {
        _viewAccount = [[UIView alloc] init];
        _viewAccount.frame = CGRectMake(0, self.navbgView.frame.size.height, kScreen_Width, 44);
        _viewAccount.backgroundColor = kColorClear;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(kScreen_Width - 50, 0, 50, 44);
        [btn setTitle:@"充值 >" forState:UIControlStateNormal];
        [btn setTitleColor:kColorHexRGB(0xeb0202) forState:UIControlStateNormal];
        btn.titleLabel.font = kFont(13);
        [btn addTarget:self action:@selector(charge) forControlEvents:UIControlEventTouchUpInside];
        [_viewAccount addSubview:btn];
        
        UILabel *line = [[UILabel alloc] init];
        line.frame = CGRectMake(0, _viewAccount.frame.size.height -0.5, kScreen_Width, 0.5);
        line.backgroundColor = kColorHexRGB(0x373737);
        [_viewAccount addSubview:line];
        
        
    }
    return _viewAccount;
}

-(UIButton *)btnPublic
{
    if (!_btnPublic) {
        _btnPublic = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnPublic.frame = CGRectMake((kScreen_Width -kScaleForSix(624/2))/2, self.viewAccount.frame.origin.y + self.viewAccount.frame.size.height + 20, kScaleForSix(624/2), 37);
        [_btnPublic setBackgroundColor:HexRGB(0xffa801)];
        [_btnPublic setTitle:@"提现" forState:UIControlStateNormal];
        [_btnPublic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnPublic.titleLabel.font = kFont(18);
        [_btnPublic addTarget:self action:@selector(drawCash) forControlEvents:UIControlEventTouchUpInside];
        _btnPublic.clipsToBounds = YES;
        _btnPublic.layer.cornerRadius = 10;
    }
    return _btnPublic;
}

-(void)initViews
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(kScreen_Width - 44, 20, 40, 44);
    label.text = @"记录";
    label.textColor = kColorWhite;
    label.font = kFont(16);
    [self.navbgView addSubview:label];
    
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navbgView.frame.size.height, kScreen_Width, kScreen_Height - self.navbgView.frame.size.height)];
    [self.view addSubview:scrollview];
    
    UIView *viewAccount = [[UIView alloc] init];
    viewAccount.frame = CGRectMake(0, 0, kScreen_Width, 390/2.0);
    [scrollview addSubview:viewAccount];
    
    UIView *viewRemain = [[UIView alloc] init];
    viewRemain.frame = CGRectMake(0, 0, kScreen_Width/2.0, viewAccount.frame.size.height);
    [viewAccount addSubview:viewRemain];
    
    UIView *viewDraw = [[UIView alloc] init];
    viewDraw.frame = CGRectMake(kScreen_Width/2.0, 0, kScreen_Width/2.0, viewAccount.frame.size.height);
    [viewAccount addSubview:viewDraw];
    
    ImageWithLabelView *imageLabelLef = [[ImageWithLabelView alloc] initImageLabelViewWithImageName:@"draw_cash1.png" label:@"账户余额（红包）"];
    imageLabelLef.center = CGPointMake(viewRemain.frame.size.width/2.0, 64/2.0 +imageLabelLef.frame.size.height/2.0);
    [viewRemain addSubview:imageLabelLef];

    
    LabelWithLabelView *remainSub = [[LabelWithLabelView alloc] initLabelWithLabelViewWithMainTitle:[NSString stringWithFormat:@"%ld",(long)kUserDefine.userRedPackage] subTitle:@""];
    remainSub.mainLabel.textColor = kColorHexRGB(0xffa801);
    remainSub.center = CGPointMake(imageLabelLef.center.x,  imageLabelLef.center.y+imageLabelLef.frame.size.height /2.0 +16 +remainSub.frame.size.height/2.0);
    [viewRemain addSubview:remainSub];
    self.remainLabel = remainSub;
    
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"充值" forState:UIControlStateNormal];
    [btn setBackgroundColor:kColorHexRGB(0xffa801)];
    [btn setTitleColor:kColorWhite forState:UIControlStateNormal];
    btn.titleLabel.font = kFont(15);
    [btn addTarget:self action:@selector(charge) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(remainSub.center.x, remainSub.center.y +remainSub.frame.size.height/2.0 +54/2.0 +30/2.0);
    btn.bounds = CGRectMake(0, 0, 60, 30);
    [viewRemain addSubview:btn];
    btn.layer.cornerRadius = 5;
    
    
    
    
    ImageWithLabelView *imageLabelRig = [[ImageWithLabelView alloc] initImageLabelViewWithImageName:@"draw_cash2.png" label:@"可提取收益（元）"];
    imageLabelRig.center = CGPointMake(viewDraw.frame.size.width/2.0, 64/2.0 +imageLabelRig.frame.size.height/2.0);
    [viewDraw addSubview:imageLabelRig];
    
    LabelWithLabelView *drawSub = [[LabelWithLabelView alloc] initLabelWithLabelViewWithMainTitle:@"0" subTitle:@""];
    drawSub.center = CGPointMake(imageLabelRig.center.x,  imageLabelRig.center.y+imageLabelRig.frame.size.height /2.0 +16 +drawSub.frame.size.height/2.0);
    drawSub.mainLabel.textColor = kColorHexRGB(0xeb0202);
    [viewDraw addSubview:drawSub];
    self.drawLabel = drawSub;
    
    
    UIButton *btnDraw = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnDraw setTitle:@"提现" forState:UIControlStateNormal];
    [btnDraw setTitleColor:kColorWhite forState:UIControlStateNormal];
    btnDraw.titleLabel.font = kFont(15);
    [btnDraw addTarget:self action:@selector(drawCash) forControlEvents:UIControlEventTouchUpInside];
    btnDraw.center = CGPointMake(drawSub.center.x, drawSub.center.y +drawSub.frame.size.height/2.0 +54/2.0 +30/2.0);
    btnDraw.bounds = CGRectMake(0, 0, 60, 30);
    [viewDraw addSubview:btnDraw];
    [btnDraw.layer setBorderWidth:1];//设置边界的宽度
    //设置按钮的边界颜色
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    CGColorRef color = CGColorCreate(colorSpaceRef, (CGFloat[]){1,1,1,1});
    
    CGColorRef color = kColorHexRGB(0xeb0202).CGColor;
    [btnDraw.layer setBorderColor:color];
    btnDraw.layer.cornerRadius = 5;
    
    
    UIView *lineCenter = [[UIView alloc] init];
    lineCenter.frame = CGRectMake(kScreen_Width/2.0 -0.5, 35, 0.5, 230/2.0);
    lineCenter.backgroundColor = kColorHexRGB(0x999999);
    [viewAccount addSubview:lineCenter];
    
    UIImageView *imageText = [[UIImageView alloc] init];
    imageText.image = kImageName(@"draw_cash_rule.png");
    imageText.frame = CGRectMake(15, viewAccount.frame.size.height +15, kScreen_Width -30, (kScreen_Width -30)/(680/756.0));
    [scrollview addSubview:imageText];
    
    scrollview.contentSize = CGSizeMake(kScreen_Width, imageText.frame.origin.y +imageText.frame.size.height +15);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
