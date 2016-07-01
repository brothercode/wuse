//
//  ImproveInfoViewController.m
//  WuSe2.0
//
//  Created by 刘春明 on 16/2/29.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "ImproveInfoViewController.h"
#import "HttpUpdateUserManager.h"
#import "LoginBaseInputView.h"
#import "CameraManager.h"
#import "SecurePerson.h"
#import "WSButton.h"
#import "HttpUploadPhotoFileManager.h"
#import "HttpUploadPortraitUrlManager.h"
#import "WSPickerView.h"
#import "HyLoglnButton.h"
#import "HyTransitions.h"


@interface ImproveInfoViewController () <LoginBaseInputViewDelegate ,WSPickerViewDelegate,UIScrollViewDelegate ,UIActionSheetDelegate ,UIImagePickerControllerDelegate>

@property (nonatomic ,retain) UIScrollView *scrollview;

//头像
@property (nonatomic ,retain) UIImageView *imagePortrait;

@property (nonatomic ,retain) LoginBaseInputView *loginview;

@property (nonatomic ,retain) HyLoglnButton *btnNext;

//验证信息用户
@property (nonatomic ,retain) DatingAccountInfo *secureperson;

@property (nonatomic ,retain) UILabel *labelImprove;

@property (nonatomic ,retain) UIView *selectSexView;

@property (nonatomic ,retain) WSPickerView *picker;

@property (nonatomic ,assign) BOOL isMentionedNickname;

//
@property (nonatomic ,retain) UIImagePickerController*imagePicker;

@property (nonatomic ,retain) UIView *viewback;



@end

@implementation ImproveInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scrollview];    
    
    if (!self.secureperson) {
        self.secureperson = [[DatingAccountInfo alloc] init];
    }
    [self addNaviBarWithTitle:@"完善资料" hasBackBtn:NO withRightBarItemImgStr:nil actionBlock:^(NSInteger btnIndex) {
    }];
    self.navbgView.backgroundColor = kColorClear;
    self.navSingleLine.alpha = 0;
    
    self.imageViewBack.image = self.imageReceive;
    self.imageViewBack.image = [self.imageViewBack.image imgWithBlurWithRadius:5];
    
//    [self.scrollview addSubview:self.labelImprove];
    [self.scrollview addSubview:self.imagePortrait];
    [self.scrollview addSubview:self.loginview];
    [self.scrollview addSubview:self.btnNext];
    [self.view addSubview:self.viewback];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)keyboardWillHide:(NSNotification *)noti
{
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollview.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)keyboardWillShow:(NSNotification *)noti
{
    CGRect rect = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat origy = self.loginview.frame.origin.y +self.loginview.frame.size.height;
    
    if (origy - rect.origin.y > 20) {
        [UIView animateWithDuration:0.25 animations:^{
            _scrollview.frame = CGRectMake(0, -(origy -rect.origin.y) -20, kScreen_Width, kScreen_Height);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.5f isBOOL:true];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.8f isBOOL:false];
}

-(NSUInteger) unicodeLengthOfString: (NSString *) text {
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++) {
        
        
        unichar uc = [text characterAtIndex: i];
        
        asciiLength += isascii(uc) ? 1 : 2;
    }
    return asciiLength;
}

-(void)next:(HyLoglnButton *)button
{
    [self.view endEditing:YES];
    NSString *name = @"";
    NSString *password = @"";
    for (UIView *view in self.loginview.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textfield = (UITextField *)view;
            if (textfield.tag == 1) {
                name = textfield.text;
            }else if (textfield.tag == 2) {
                password = textfield.text;
            }else{
            }
        }
    }
    self.secureperson.userNickName = name;
    
    NSLog(@"usernick==%@",self.secureperson.userNickName);
    NSLog(@"usernick==%@",self.secureperson.userHeadUrl);
    NSLog(@"usernick==%ld",(long)self.secureperson.userSex);
    NSLog(@"usernick==%@",self.secureperson.userTag);
    NSLog(@"usernick==%ld",(long)self.secureperson.uidentity);
    NSLog(@"usernick==%@",self.secureperson.userAge);
    NSLog(@"usernick==%ld",(long)self.secureperson.userArea);
    
    if ([name isEqualToString:@""] || name == nil){
        [self requestFaileWithMessage:@"昵称为必填项"];
        return;
    }else
    {
        if ([self unicodeLengthOfString:name] >24)
        {
            [self requestFaileWithMessage:@"昵称长度不超过24个字符"];
            return;
        }
        
        NSRange range = [name rangeOfString:@" "];
        if (range.length > 0) {
            [self requestFaileWithMessage:@"昵称中不能有空格"];
            return;
        }
    }
    
    if (self.secureperson.userSex == 0) {
        [self requestFaileWithMessage:@"请选择性别"];
        return;
    }
    if ([self.secureperson.userHeadUrl isEqualToString:@""] || self.secureperson.userHeadUrl == nil) {
        [self requestFaileWithMessage:@"请上传头像"];
        return;
    }
    self.viewback.alpha = 1;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [self requestFaileWithMessage:kNotReachableNetwork];
            return;
        }
        HttpUpdateUserManager *manager = [[HttpUpdateUserManager alloc] init];
        
        manager.nickName = self.secureperson.userNickName;
        manager.sex = self.secureperson.userSex;
        manager.userHeadUrl = self.secureperson.userHeadUrl;
        
        [manager loadDataWithsuccessCallback:^(HttpAPIBaseManager *manager) {
            NSMutableDictionary *dict = manager.resultData;
            NSLog(@"==%@",dict);
            
            NSMutableDictionary *d= [[dict objectForKey:@"content"] objectForKey:@"userInfo"];
            NSLog(@"==%@",[d objectForKey:@"userDescript"]);
            NSLog(@"==%@",[[[dict objectForKey:@"content"] objectForKey:@"userInfo"] class]);
            
            DatingUserManager *usermanager = kDatingManagers.userManager;
            
            NSString * state = [[dict objectForKey:@"stat"] stringValue];
            if ([state isEqualToString:@"0"])
            {
                self.viewback.alpha = 0;
                [LoginManager loginYunXinSuccess:^(bool success) {
                    
                    if (success) {
                        [button ExitAnimationCompletion:^{
                            [[NSUserDefaults standardUserDefaults] setInteger:[[[dict objectForKey:@"content"] objectForKey:@"isInfoFull"] integerValue] forKey:kIsInfoFull];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [usermanager updateAccoutInfo:[[dict objectForKey:@"content"] objectForKey:@"userInfo"]];
                            
                            usermanager.hostUser.isInfoFull = [JsonUtils integerOfObject:[dict objectForKey:@"content"] WithKey:@"isInfoFull"];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NTENotificationLoginNoti" object:nil];
                            //完善资料成功
                            [LoginManager hideLoginNavViewWhenLoginYunxinSuccess];
                        }];
                    }else{
                        [[NSUserDefaults standardUserDefaults] setInteger:[[[dict objectForKey:@"content"] objectForKey:@"isInfoFull"] integerValue] forKey:kIsInfoFull];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [usermanager updateAccoutInfo:[[dict objectForKey:@"content"] objectForKey:@"userInfo"]];
                        
                        usermanager.hostUser.isInfoFull = [JsonUtils integerOfObject:[dict objectForKey:@"content"] WithKey:@"isInfoFull"];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NTENotificationLoginNoti" object:nil];
                        //完善资料成功
                        [LoginManager hideLoginNavViewWhenLoginYunxinSuccess];
                    }
                }];
            }else{
                [self requestFaileWithMessage:[dict objectForKey:@"message"]];
            }
        } failCallback:^(HttpAPIBaseManager *manager) {
            [self requestFaileWithMessage:kReqeustFaild];
        }];
    }];
}

- (void)requestFaileWithMessage:(NSString *)faile
{
    self.viewback.alpha = 0;
    [ProgressHUDManager showFailWithMessage:faile maskType:ProgressHUDMaskTypeBlack];
    [self.btnNext ErrorRevertAnimationCompletion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}


#pragma mark -UITapGestureRecognizer
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}
-(void)portraitImageGesture:(UITapGestureRecognizer*)gesture
{
    [self.view endEditing:YES];
    if (![CameraManager isCameraUseable]) {
        return;
    }
   
    if (isAfterIOS8) {
        CameraManager *mana = [[CameraManager alloc] init];
        [mana appearCameraOrLibraryWithViewController:self];
    }else{
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
        [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index = %ld",buttonIndex);
    switch (buttonIndex) {
        case 0:
        {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController: self.imagePicker animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
        {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController: self.imagePicker animated:YES completion:^{
                
            }];

        }
            break;
        case 2:
        {
            
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -imagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    UIImage*imageNew=[UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
    self.imagePortrait.image = imageNew;
    
    WS(weakSelf)
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf uploadPortraitFileImageData:imageNew];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)uploadImageSuccessWithImage:(UIImage *)image  url:(NSString *)url
{
    if (!url) {
        [ProgressHUDManager hideProgressHud];
        [self.imagePortrait sd_setImageWithURL:[NSURL URLWithString:kDatingManagers.userManager.hostUser.accountInfo.userHeadUrl] placeholderImage:kImageName(@"login_add_por.png")];
        return;
    }
    self.secureperson.userHeadUrl = url;
    self.imagePortrait.image = image;
    kDatingManagers.userManager.hostUser.accountInfo.userHeadUrl = url;
    [kDatingManagers.userManager.hostUser saveAccountToNative];
}

//上传头像文件
-(void)uploadPortraitFileImageData:(UIImage *)image
{
    [ProgressHUDManager showWithMessage:@"正在上传" maskType:ProgressHUDMaskTypeBlack];
    
    NSData *data = [image compressionImage:image];
    NSLog(@"-%ld",data.length);
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [self requestFaileWithMessage:kNotReachableNetwork];
            [self uploadImageSuccessWithImage:nil url:nil];
            return;
        }
        HttpUploadPhotoFileManager *manager = [[HttpUploadPhotoFileManager alloc] init];
        manager.uploadfileType = 1;
        manager.fileData = data;
        
        [manager loadDataWithsuccessCallback:^(HttpAPIBaseManager *manager) {
            NSDictionary *dict = manager.resultData;
            NSLog(@"==%@",dict);
            if ([self isGottonDataUsable:dict]){
                //上传图片URL
                if ([[[dict objectForKey:@"content"] objectForKey:@"fileUrl"] isEqualToString:@""]) {
                    [self requestFaileWithMessage:@"上传失败"];
                    [self uploadImageSuccessWithImage:nil url:nil];
                    return ;
                }
                [self uploadPhotoWithPhotoUrl:[[dict objectForKey:@"content"] objectForKey:@"fileUrl"] image:image];
            }else{
                [self requestFaileWithMessage:[dict objectForKey:@"message"]];
                [self uploadImageSuccessWithImage:nil url:nil];
            }
        } failCallback:^(HttpAPIBaseManager *manager) {
            [self uploadImageSuccessWithImage:nil url:nil];
            [self requestFaileWithMessage:kReqeustFaild];
        }];
    }];
}
//上传头像URL
-(void)uploadPhotoWithPhotoUrl:(NSString *)url image:(UIImage *)image
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [ProgressHUDManager hideProgressHud];
            [self requestFaileWithMessage:kNotReachableNetwork];
            [self uploadImageSuccessWithImage:nil url:nil];
            return;
        }
        HttpUploadPortraitUrlManager*manager = [[HttpUploadPortraitUrlManager alloc] init];
        manager.userHeadUrl  = url;
        
        [manager loadDataWithsuccessCallback:^(HttpAPIBaseManager *manager) {
            [ProgressHUDManager hideProgressHud];
            NSMutableDictionary *dict = manager.resultData;
            
            if ([self isGottonDataUsable:dict]){
                if (!url) {
                    [self requestFaileWithMessage:@"上传失败"];
                    [self uploadImageSuccessWithImage:nil url:nil];
                    return;
                }
                
                [self uploadImageSuccessWithImage:image url:url];
            }else{
                [self requestFaileWithMessage:[dict objectForKey:@"message"]];
                [self uploadImageSuccessWithImage:nil url:nil];
            }
        } failCallback:^(HttpAPIBaseManager *manager) {
            [self requestFaileWithMessage:kReqeustFaild];
           [self uploadImageSuccessWithImage:nil url:nil];
        }];
    }];
}

#pragma mark - LoginBaseInputViewDelegate
-(void)nicknameClickAction
{
//    if (!self.isMentionedNickname) {
//        self.isMentionedNickname = YES;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"昵称和性别输入后不可更改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}


#pragma mark -WSPickerViewDelegate
-(void)pickerChangedData:(DatingAccountInfo *)user
{
    for (UIView *view in self.loginview.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textfield = (UITextField *)view;
            if (textfield.tag == 1) {
            }else if (textfield.tag == 2) {
                textfield.text = user.userSex == 1?@"男":@"女";
            }else{
            }
        }
    }
}

-(void)chooseSex
{
    [self.view endEditing:YES];
    WSPickerView *picker = [[WSPickerView alloc] initWithData:self.secureperson delegate:self type:TYPE_PICKER_SEX];
    picker.frame = self.view.bounds;
    [picker showInView:self.view];
    self.picker = picker;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.picker) {
        [self.picker cancelPicker];
    }
    [self.view endEditing:YES];
}

#pragma mark - initviews
-(LoginBaseInputView *)loginview
{
    if (!_loginview) {
        NSArray *array = @[@"昵称(注册后不可修改)",@"性别(注册后不可修改)"];
        _loginview = [[LoginBaseInputView alloc] initViewWithTitlearray:array delegate:self];
        _loginview.frame = CGRectMake(kScaleForSix(58/2), self.imagePortrait.frame.size.height +self.imagePortrait.frame.origin.y +kScaleForSix(10), kScreen_Width -2*kScaleForSix(58/2), (44 +20) *array.count);
        _loginview.center = CGPointMake(kScreen_CenterX, kScreen_CenterY);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, _loginview.frame.size.height/2, _loginview.frame.size.width, _loginview.frame.size.height);
        [btn addTarget:self action:@selector(chooseSex) forControlEvents:UIControlEventTouchUpInside];
        [_loginview addSubview:btn];
    }
    return _loginview;
}

-(UIImageView *)imagePortrait
{
    if (!_imagePortrait) {
        _imagePortrait = [[UIImageView alloc] init];
        _imagePortrait.bounds = CGRectMake(0, 0, kScaleForSix(65), kScaleForSix(65));
        _imagePortrait.center = CGPointMake(kScreen_CenterX, kScaleForSix(150));
        [_imagePortrait sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:kImageName(@"login_add_por.png") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        _imagePortrait.layer.cornerRadius = kScaleForSix(65)/2.0;
        _imagePortrait.clipsToBounds = YES;
        
        
        _imagePortrait.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(portraitImageGesture:)];
        [_imagePortrait addGestureRecognizer:gesture];
    }
    return _imagePortrait;
}


-(HyLoglnButton *)btnNext
{
    if (!_btnNext) {
        _btnNext = [[HyLoglnButton alloc] initWithFrame:CGRectMake((kScreen_Width -kScaleForSix(634/2))/2, self.loginview.frame.origin.y +self.loginview.frame.size.height +40, kScaleForSix(634/2), 40)];
        [_btnNext setBackgroundColor:kColorHexRGB(0xeb0202)];
        [_btnNext setTitle:@"开始" forState:UIControlStateNormal];
        [_btnNext addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
        _btnNext.titleLabel.font = kFont(15);
        _btnNext.layer.cornerRadius = 5;
    }
    return _btnNext;
}

-(UILabel *)labelImprove
{
    if (!_labelImprove) {
        _labelImprove = [[UILabel alloc] init];
        _labelImprove.bounds = CGRectMake(0, 0, 100, 30);
        _labelImprove.center = CGPointMake(kScreen_CenterX, kScaleForSix((kScreen_Height == 480 ?180:242)/2 +10));
        _labelImprove.text = @"完善资料";
        _labelImprove.textColor = kColorWhite;
        _labelImprove.font = [UIFont boldSystemFontOfSize:18];
        _labelImprove.textAlignment = NSTextAlignmentCenter;
    }
    return _labelImprove;
}

-(UIView *)selectSexView{
    if (!_selectSexView) {
        _selectSexView = [[UIView alloc] init];
        _selectSexView.frame = CGRectMake(0, kScreen_Height, kScreen_Width, 200);
        _selectSexView.backgroundColor = kColorWhite;
        
        
    }
    return _selectSexView;
}

-(BOOL)isGottonDataUsable:(NSDictionary *)dict
{
    if ([[dict objectForKey:@"stat"] integerValue] == 0)
    {
        return YES;
    }
    return NO;
}

-(UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        _scrollview.backgroundColor = kColorClear;
        
        UITapGestureRecognizer * singletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singletap setNumberOfTapsRequired:1];
        [_scrollview addGestureRecognizer:singletap];
    }
    return _scrollview;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


-(UIImagePickerController *)imagePicker
{
    if (!_imagePicker)
    {
        _imagePicker = [[UIImagePickerController alloc] init];
        
        _imagePicker.delegate = self;
        
        _imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

-(UIView *)viewback{
    if (!_viewback) {
        _viewback = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        _viewback.backgroundColor = kColorClear;
        _viewback.alpha = 0;
    }
    return _viewback;
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
