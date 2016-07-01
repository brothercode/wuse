//
//  HomeshareHomeSharedView.m
//  DatingShooting
//
//  Created by xiaoxuan on 15/7/23.
//  Copyright (c) 2015年 潘嘉尉. All rights reserved.
//

#import "HomeSharedView.h"
#import "DatingAccountInfo.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApi.h>



#define kTagShareView 1998

typedef void (^ErrorBlock)(NSError *error);


@interface HomeSharedView()


@property (nonatomic ,retain) UINavigationController *naviFrom;

@property (nonatomic ,retain) UIView *viewBackground;

@property (nonatomic ,retain) UIView *viewBottom;

@property (nonatomic ,retain) UIView *shareView;

@property (nonatomic ,assign) CGSize sharesize;

@property (nonatomic ,retain) DatingAccountInfo *userInfo;

@property (nonatomic ,assign) TYPE_SHARE_CATEGORY type;

@property (nonatomic ,assign) long long dynId;

@property (nonatomic ,retain) NSString *channelId;

@property (nonatomic ,copy) ErrorBlock errorBlock;


@end


@implementation HomeSharedView
IMPLEMENTATION_SINGLETON(HomeSharedView)


-(void)showShareViewWithType:(TYPE_SHARE_CATEGORY)type user:(DatingAccountInfo *)user dynId:(long long)dynId channelID:(NSString *)channelId
{
    if (!self.userInfo) {
        self.userInfo = [[DatingAccountInfo alloc] init];
    }
    self.userInfo = user;
    self.type = type;
    self.channelId = self.channelId;
    [self showShareView:nil];
}

-(void)showShareViewWithType:(TYPE_SHARE_CATEGORY)type user:(DatingAccountInfo *)user dynId:(long long)dynId
{
    if (!self.userInfo) {
        self.userInfo = [[DatingAccountInfo alloc] init];
    }
    self.userInfo = user;
    self.type = type;
    self.dynId = dynId;
    [self showShareView:nil];
}

-(void)showShareViewWithType:(TYPE_SHARE_CATEGORY)type user:(DatingAccountInfo *)user
{
    if (!self.userInfo) {
        self.userInfo = [[DatingAccountInfo alloc] init];
    }
    self.userInfo = user;
    self.type = type;
    [self showShareView:nil];
}

-(void)showShareViewWithType:(TYPE_SHARE_THIRD)type user:(DatingAccountInfo *)user dynId:(long long)dynId complition:(void(^)(NSError * error))complition
{
    if (!self.userInfo) {
        self.userInfo = [[DatingAccountInfo alloc] init];
    }
    self.userInfo = user;
    self.type = TYPE_SHARE_CATEGORY_LIVE;
    self.dynId = dynId;
    self.errorBlock = complition;
    [self shareWithType:type];
}

-(id)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.viewBackground];
        [self addSubview:self.viewBottom];
    }
    return self;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *tou = [touches anyObject];
    CGPoint point = [tou locationInView:self.viewBottom];
    if (point.x >0 && point.y >0) {
        
    }else{
        [self hideShareView];
    }
}

-(void)showOnTopViewcontroller
{
    [UIView animateWithDuration:0.25 animations:^{
//        self.viewBackground.alpha = 0.8;
        self.viewBottom.frame = CGRectMake(0, kScreen_Height - 140, kScreen_Width, 140);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideShareView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.viewBottom.frame = CGRectMake(0, kScreen_Height, kScreen_Width, 140);
        self.viewBackground.alpha = 0;
    } completion:^(BOOL finished) {
        [HomeSharedView shareHomeSharedView].alpha = 0;
    }];
}

-(void)showShareView:(UIView *)obj
{
    UIViewController *appRootViewController;
    UIWindow *window;
    
    window = [UIApplication sharedApplication].keyWindow;
    
    appRootViewController = window.rootViewController;
    
    UIViewController *topViewController = appRootViewController;
    while (topViewController.presentedViewController != nil)
    {
        topViewController = topViewController.presentedViewController;
    }
    
    if ([topViewController.view viewWithTag:kTagShareView]) {
        [[topViewController.view viewWithTag:kTagShareView] removeFromSuperview];
    }
    
    self.frame = topViewController.view.bounds;
    
    [topViewController.view addSubview:self];
    
    self.alpha = 1;
    [self showOnTopViewcontroller];
}

-(void)shareWithType:(SHARE_TYPE_WUSE)type
{
    ShareType shareTemp = 0;
    NSString *title = @"";
    switch (type) {
        case SHARETYPE_WECHAT:
        {
            shareTemp = ShareTypeWeixiSession;
        }
            break;
        case SHARETYPE_WECHATCIRCLE:
        {
            shareTemp = ShareTypeWeixiTimeline;
        }
            break;
        case SHARETYPE_WEIBO:
        {
            shareTemp = ShareTypeSinaWeibo;
        }
            break;
        case SHARETYPE_QQ:
        {
            shareTemp = ShareTypeQQ;
            title = @"物色";
        }
            break;
            
        default:
            break;
    }
    if (shareTemp == 0) {
        return;
    }
    
    NSString *strurl = @"";
    NSString *stringTitle = @"";
    switch (self.type) {
        case TYPE_SHARE_CATEGORY_LIVE:
        {
            stringTitle = [NSString stringWithFormat:@"拒绝浮夸，我的直播听我说，%@正在直播，一起来观看！",self.userInfo.userNickName];
            strurl = [NSString stringWithFormat:@"http://%@/detail.html?objId=%lld&category=14",WUSE_SERVER_URL,self.dynId];
        }
            break;
        case TYPE_SHARE_CATEGORY_DYNAMIC_VIDEO:
        {
            stringTitle = @"拒绝浮夸，我的大片我做主，赶快来围观！";
            strurl = [NSString stringWithFormat:@"http://%@/videoDyn.html?objId=%lld&category=12",WUSE_SERVER_URL,self.dynId];
        }
            break;
        case TYPE_SHARE_CATEGORY_DYNAMIC_PICTURE:
        {
            stringTitle = @"拒绝浮夸，我的大片我做主，赶快来围观！";
            strurl = [NSString stringWithFormat:@"http://%@/photoDyn.html?objId=%lld&category=12",WUSE_SERVER_URL,self.dynId];
        }
            break;
        case TYPE_SHARE_CATEGORY_BODY:
        {
            stringTitle = [NSString stringWithFormat:@"拒绝浮夸，%@在物色等你一起直播！",self.userInfo.userNickName];
            return;
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"--%@",strurl);
    
    NSLog(@"--%@",stringTitle);
    
    if (shareTemp == ShareTypeWeixiTimeline) {
        title = stringTitle;
    }else if (shareTemp == ShareTypeSinaWeibo){
        stringTitle = [NSString stringWithFormat:@"%@  %@",stringTitle,strurl];
    }
    
    
    id<ISSContent> publishContent = [ShareSDK content:stringTitle
                                       defaultContent:stringTitle
                                                image:[ShareSDK pngImageWithImage:kImageName(@"icon_60.png")]
                                                title:title
                                                  url:strurl
                                          description:@"descrip"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    if (shareTemp == ShareTypeSinaWeibo) {
        //自定义腾讯微博分享菜单项
        [ShareSDK shareContent:publishContent
                          type:ShareTypeSinaWeibo
                   authOptions:nil
                 statusBarTips:YES
                        result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                            
                            [self soulveBackContent:state error:error];
                            
                            if (state == SSPublishContentStateSuccess)
                            {
                                [ProgressHUDManager showSuccessWithMessage:@"分享成功"];
                            }else if (state == SSPublishContentStateFail){
                                [ProgressHUDManager showSuccessWithMessage:@"分享失败"];
                            }else{
                                
                            }
                        }];
        return;
    }
    
    
    [ShareSDK showShareViewWithType:shareTemp
                          container:nil
                            content:publishContent
                      statusBarTips:NO
                        authOptions:nil
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:@"物色"
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES
                                                    wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:self
                                                       friendsViewDelegate:self
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 [self soulveBackContent:state error:error];
                             }];
}

-(void)soulveBackContent:(SSResponseState)state error:(id<ICMErrorInfo> )error{
    if (state == SSPublishContentStateSuccess)
    {
        NSLog(@"发表成功");
        [HomeSharedView hide];
        
        if (self.errorBlock) {
            self.errorBlock(nil);
        }
    }else if (state == SSPublishContentStateCancel){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"is a error test"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:@"fail" code:1 userInfo:userInfo];;
        if (self.errorBlock) {
            self.errorBlock(aError);
        }
    }
    else if (state == SSPublishContentStateFail)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"is a error test"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:@"fail" code:2 userInfo:userInfo];
        if (self.errorBlock) {
            self.errorBlock(aError);
            return;
        }
        
        NSLog(@"%@",[error errorDescription]);
        NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
        [ProgressHUDManager showFailWithMessage:@"分享失败" maskType:ProgressHUDMaskTypeBlack];
        if ([[error errorDescription] isEqualToString:@"尚未安装微信"])
        {
            
        }else if ([[error errorDescription] isEqualToString:@"尚未安装微博"])
        {
            
        }else if ([[error errorDescription] isEqualToString:@"尚未安装QQ"])
        {
            
        }
    }else if (state == SSPublishContentStateBegan){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"is a error test"                                                                      forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:@"fail" code:2 userInfo:userInfo];
        
        
        NSLog(@"%@",[error errorDescription]);
    }
}


+ (void)hide
{
    [[HomeSharedView shareHomeSharedView] hide];
}

- (void)hide
{
    if ([HomeSharedView shareHomeSharedView].alpha == 1) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                                
                                [HomeSharedView shareHomeSharedView].alpha = 0;
                                
                            }completion:^(BOOL finished){
                                [[HomeSharedView shareHomeSharedView] removeFromSuperview];
                                
                            }];
    }
}

-(void)share:(UIButton *)sender
{
    NSLog(@"--%f--%f",self.sharesize.width,self.sharesize.height);
    
    [self hideShareView];
    [self shareWithType:sender.tag];
}

-(UIView *)viewBackground
{
    if (!_viewBackground) {
        _viewBackground = [[UIView alloc] init];
        _viewBackground.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        _viewBackground.backgroundColor = kColorClear;
        _viewBackground.alpha = 1;
        
        UIImageView *imagev = [[UIImageView alloc] init];
        imagev.frame = _viewBackground.bounds;
        imagev.userInteractionEnabled = YES;
        [_viewBackground addSubview:imagev];
        
        
        
    }
    return _viewBackground;
}

-(UIView *)viewBottom
{
    if (!_viewBottom) {
        _viewBottom = [[UIView alloc] init];
        _viewBottom = [[UIView alloc] init];
        _viewBottom.frame = CGRectMake(0, kScreen_Height, kScreen_Width, 140);
        _viewBottom.backgroundColor = kColorClear;
        _viewBottom.userInteractionEnabled = YES;
        
        UILabel *labelTitle = [[UILabel alloc] init];
        labelTitle.frame = _viewBottom.bounds;
        labelTitle.backgroundColor = kColorHexRGB(0x02070a);
        [_viewBottom addSubview:labelTitle];
        labelTitle.alpha = 0.9;
        
        CGFloat width = kScreen_Width>320 ?60:50;
        CGFloat deg = (kScreen_Width -width*4 -40)/3.0;
        
        NSMutableArray *arrayTemp =[NSMutableArray new];
        for (int i =0; i<4; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.frame = CGRectMake(20 +i*(width +deg), 20, width, width);
            [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"shared_item_%d.png",i+1]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
//            [_viewBottom addSubview:btn];
            
            if (i == 0){
                if (![WXApi isWXAppInstalled]) {
                    
                }else{
                    btn.tag = 1;
                    [arrayTemp addObject:btn];
                }
            }else if (i == 1){
                if (![WXApi isWXAppInstalled]) {
                    
                }else{
                    btn.tag = 2;
                    [arrayTemp addObject:btn];
                }
            }else if (i == 2){
                if (![QQApi isQQInstalled]) {
                    
                }else{
                    btn.tag = 3;
                    [arrayTemp addObject:btn];
                }
            }else{
                btn.tag = 4;
                [arrayTemp addObject:btn];
            }
        }
        
        CGFloat widthView = 0;
        UIView *viewThi = [[UIView alloc] init];
        for (int i =0; i<arrayTemp.count; i++) {
            UIButton *btntemp = arrayTemp[i];
            btntemp.frame = CGRectMake(i*(width +deg), 10, width, width);
            [viewThi addSubview:btntemp];
            if (i == 0) {
                widthView +=width;
            }else{
                widthView +=width +deg;
            }
        }
        viewThi.bounds = CGRectMake(0, 0, widthView, width);
        viewThi.center = CGPointMake(kScreen_Width/2.0, _viewBottom.frame.size.height - 60 -44);
        [_viewBottom addSubview:viewThi];
        
        UILabel *labelLine = [[UILabel alloc] init];
        labelLine.bounds = CGRectMake(0, _viewBottom.frame.size.height -44, kScreen_Width -20, 0.5);
        labelLine.center =CGPointMake(kScreen_CenterX, _viewBottom.frame.size.height -44);
        labelLine.textAlignment = NSTextAlignmentCenter;
        labelLine.backgroundColor = kColorHexRGB(0x535353);
        [_viewBottom addSubview:labelLine];
        
        
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        btnCancel.frame = CGRectMake(0, _viewBottom.frame.size.height -44, kScreen_Width, 44);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal]
        ;
        [btnCancel setTitleColor:kColorWhite forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(hideShareView) forControlEvents:UIControlEventTouchUpInside];
        [_viewBottom addSubview:btnCancel];
    }
    return _viewBottom;
}


- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType{
//    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPhoneNavigationBarBG.png"]];
}

@end
