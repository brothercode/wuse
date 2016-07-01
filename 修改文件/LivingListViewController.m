//
//  LivingListViewController.m
//  WuSe2.0
//
//  Created by 潘嘉尉 on 16/4/22.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "LivingListViewController.h"
#import "LivingListTableViewCell.h"
#import "LivingViewController.h"
#import "ZLScrolling.h"
#import "DiscoverySegViewController.h"
#import "LivelistDefaultView.h"
#import "LivingPrepareViewController.h"
#import "WSBannerView.h"
#import "HttpBannerListManager.h"
#import "BannerListModel.h"
#import "BannerModel.h"
#import "BannerContentViewController.h"

@interface LivingListViewController ()<LivelistDefaultViewDelegate>

@property (nonnull ,nonatomic ,retain) LivelistDefaultView *defaultView;

@property (nonnull ,nonatomic ,retain) ZLScrolling *bannerView;

@property (nonnull ,nonatomic ,retain) LivingListHeadView *headView;

@property (nonnull ,nonatomic ,retain) BannerListModel *bannerObject;

@property (nonnull ,nonatomic ,retain) LivingViewController *livingVC;

@end

@implementation LivingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listEntity = [[LivingListEntity alloc] init];
    _currentNavIndex = 1;
    self.livingVC = nil;
    [self initViews];
    [self initNotifications];
    [self addHeader];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//    if (self.livingVC) {
//        if (self.livingVC.livingVideoVC) {
//            if (self.livingVC.livingVideoVC.liveplayer) {
//                [self.livingVC.livingVideoVC.liveplayer stop];
//                [self.livingVC.livingVideoVC.liveplayer shutdown];
//                NSLog(@"shutdown=====================");
//            }
//        }
//    }
}


#pragma mark -LivelistDefaultViewDelegate
-(void)liveListButtonAction
{
    NSLog(@"kaishi");
    if (![self checkVideoRootAndAudioRoot]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"您尚未对摄像头或麦克风进行授权，请进入IOS设置->隐私-中寻找物色来开启。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            LivingPrepareViewController *prepareVC = [[LivingPrepareViewController alloc] init];
            [self.navigationController pushViewController:prepareVC animated:YES];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL    URLWithString:UIApplicationOpenSettingsURLString]]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [alertController addAction:action1];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        LivingPrepareViewController *prepareVC = [[LivingPrepareViewController alloc] init];
        [self.navigationController pushViewController:prepareVC animated:YES];
    }
}

#pragma mark - 检测摄像头和麦克风权限是否全部开启
- (BOOL)checkVideoRootAndAudioRoot{
    BOOL isOpen = YES;
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoStatus == AVAuthorizationStatusRestricted || videoStatus == AVAuthorizationStatusDenied) {
        isOpen = NO;
    }
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioStatus == AVAuthorizationStatusRestricted || audioStatus == AVAuthorizationStatusDenied) {
        isOpen = NO;
    }
    return isOpen;
}

#pragma mark - HomeNaviChooseNoti通知方法
- (void)homeNaviClick:(NSNotification *)noti{
    NSInteger index = [[noti object] integerValue];
    _currentNavIndex = index;
    if (index == 1) {
        [self addHeader];
    }
}

#pragma mark - 登陆成功通知方法
- (void)loginSuccessNoti:(NSNotification *)noti{
    if (_currentNavIndex == 1) {
        [self addHeader];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((670.0/750.0*kScreen_Width) + 70);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _chooseIndex = indexPath.row;
    LivingViewController *livingVC = [[LivingViewController alloc] initWithLivingListEntity:_listEntity withIndex:_chooseIndex];
    self.livingVC = livingVC;
    [self.navigationController pushViewController:livingVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listEntity.conDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentify = @"LivingListTableViewCell";
    LivingListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[LivingListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell updateWithModel:_listEntity.conDataArr[indexPath.row]];
    return cell;
}

- (void)addHeader{
    WS(weakSelf)
    [weakSelf.tableView addHeaderWithCallback:^{
        weakSelf.listEntity.begin = 0;
        weakSelf.listEntity.isFinish = 0;
        [weakSelf.listEntity refreshLivingList:^(NSMutableArray *array) {
            [weakSelf.tableView reloadData];
            [weakSelf.tableView headerEndRefreshing];
            if (array.count > 0) {
                if (array.count >= 3) {
                    [self addFooter];
                }else{
                    [weakSelf.tableView removeFooter];
                }
                _defaultView.alpha = 0;
            }else{
                [weakSelf.tableView removeFooter];
                if (array.count == 0) {
                    _defaultView.alpha = 1;
                }else{
                    _defaultView.alpha = 0;
                }
            }
        }];
    }];
    [_tableView headerBeginRefreshing];
}

- (void)addFooter{
    WS(weakSelf)
    [weakSelf.tableView addFooterWithCallback:^{
        if (weakSelf.listEntity.isFinish != 1) {
            [weakSelf.listEntity refreshLivingList:^(NSMutableArray *array) {
                [weakSelf.tableView reloadData];
                [weakSelf.tableView footerEndRefreshing];
            }];
        }else{
            [weakSelf.tableView footerEndRefreshing];
            [weakSelf.tableView setFooterRefreshingText:@"无更多数据加载"];
        }
    }];
}

- (void)initViews{
    LivingListHeadView *headView = [[LivingListHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Width *4/15.0 +34)];
    
    NSMutableArray * arrayHeaders = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i =0; i<3; i++) {
        WSBannerView *viewbutton = [[WSBannerView alloc] init];
        viewbutton.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Width *4/15.0);
        viewbutton.imageViewMain.tag = i+1;
        viewbutton.backgroundColor = kColorClear;
        [viewbutton.imageViewMain sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"zhiboliebiao-bnanner%d.png",i+1]]];
        [arrayHeaders addObject:viewbutton];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerAction:)];
        [viewbutton.imageViewMain addGestureRecognizer:gesture];
    }
    
    //广告banner
    ZLScrolling *zzzz = [[ZLScrolling alloc] initWithCurrentController:self frame:CGRectMake(0, 0, kScreen_Width, kScreen_Width *4/15.0) photos:arrayHeaders placeholderImage:nil];
    zzzz.timeInterval = 3;
    
    zzzz.view.backgroundColor = kColorClear;
    [headView addSubview:zzzz.view];
    self.bannerView = zzzz;
    self.headView = headView;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TabNaviView_Height, kScreen_Width, kScreen_Height - TabNaviView_Height - 51.5) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = headView;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _defaultView = [[LivelistDefaultView alloc] initLiveListDefaultViewWithDelegate:self];
    _defaultView.frame = CGRectMake(0, kScreen_Width *4/15.0 +34, kScreen_Width, _tableView.frame.size.height);
    [_tableView addSubview:_defaultView];
    _defaultView.alpha = 0;
    
    
    [self fecthBannerList];
//更新banner
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
//    for (int i =0; i<2; i++) {
//        NSString *string = @"http://www.baidu.com";
//        [array addObject:string];
//    }
//    [self updateBannerViewWithUrls:array];
}

-(void)fecthBannerList
{
    WS(weakSelf)
    if (![Reachability reachabilityForInternetConnection].isReachable) {
        kDefineNetworkNotReachable
        return;
    }
    
    HttpBannerListManager* mana = [[HttpBannerListManager alloc] init];
    [mana loadDataWithsuccessCallback:^(HttpAPIBaseManager *manager) {
        NSDictionary *dict = manager.resultData;
        NSLog(@"--%@",dict);
        if ([[dict objectForKey:@"stat"] integerValue] == 0){
            weakSelf.bannerObject = [[BannerListModel alloc] initWithDict:[dict objectForKey:@"content"]];
            
            [self updateBannerViewWithUrls:weakSelf.bannerObject.arrayBanners];
        }else{
//            [ProgressHUDManager showFailWithMessage:[dict objectForKey:@"message"] maskType:ProgressHUDMaskTypeBlack];
        }
    } failCallback:^(HttpAPIBaseManager *manager) {
//        [ProgressHUDManager showFailWithMessage:kReqeustFaild];
    }];
}

//更新banner
-(void)updateBannerViewWithUrls:(NSArray *)array
{
//    [self.bannerView.view removeFromSuperview];
//    self.bannerView.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Width *4/15.0);
    NSMutableArray * arrayHeaders = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i =0; i<array.count; i++) {
        BannerModel *model = [array objectAtIndex:i];
        WSBannerView *viewbutton = [[WSBannerView alloc] init];
        viewbutton.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Width *4/15.0);
        viewbutton.imageViewMain.tag = i+4;
        viewbutton.networkUrl = model.bannerUrl;
        viewbutton.backgroundColor = kColorClear;
        [viewbutton.imageViewMain sd_setImageWithURL:[NSURL URLWithString:model.bannerBgpic] placeholderImage:kImageName(@"")];
        [arrayHeaders addObject:viewbutton];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerAction:)];
        [viewbutton.imageViewMain addGestureRecognizer:gesture];
    }
    
    
    
    for (int i =0; i<3; i++) {
        WSBannerView *viewbutton = [[WSBannerView alloc] init];
        viewbutton.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Width *4/15.0);
        viewbutton.imageViewMain.tag = i+1;
        viewbutton.backgroundColor = kColorClear;
        [viewbutton.imageViewMain sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"zhiboliebiao-bnanner%d.png",i+1]]];
        [arrayHeaders addObject:viewbutton];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerAction:)];
        [viewbutton.imageViewMain addGestureRecognizer:gesture];
    }
    
    
    //广告banner
    ZLScrolling *zzzz = [[ZLScrolling alloc] initWithCurrentController:self frame:CGRectMake(0, 0, kScreen_Width, kScreen_Width *4/15.0) photos:arrayHeaders placeholderImage:nil];
    zzzz.timeInterval = 3;
    
    zzzz.view.backgroundColor = kColorClear;
    self.bannerView = zzzz;
    [self.headView addSubview:zzzz.view];
    _tableView.tableHeaderView = self.headView;
}

-(void)bannerAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.view.tag == 1) {
        DiscoverySegViewController *hotVC = [[DiscoverySegViewController alloc] init];
        [self.navigationController pushViewController:hotVC animated:YES];
    }else if (gesture.view.tag == 2) {
        DiscoverySegViewController *hotVC = [[DiscoverySegViewController alloc] init];
        hotVC.isResistSex = YES;
        [self.navigationController pushViewController:hotVC animated:YES];
    }else if (gesture.view.tag == 3) {
        DiscoverySegViewController *hotVC = [[DiscoverySegViewController alloc] init];
        hotVC.isOfficeAnnoce = YES;
        [self.navigationController pushViewController:hotVC animated:YES];
    }else{
        if ([gesture.view isKindOfClass:[UIImageView class]]) {
            WSBannerView *banner = (WSBannerView *)gesture.view.superview;
            NSURL *url = [NSURL URLWithString:banner.networkUrl];
            
            BannerContentViewController *bannerVC = [[BannerContentViewController alloc] init];
            bannerVC.bannerUrl = banner.networkUrl;
            [self.navigationController pushViewController:bannerVC animated:YES];
        }
    }
}

- (void)initNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeNaviClick:) name:@"HomeNaviChooseNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNoti:) name:kNotification_LoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNoti:) name:@"LivingListShouldRefresh" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
