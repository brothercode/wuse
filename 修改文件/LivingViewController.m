//
//  LivingViewController.m
//  WuSe2.0
//
//  Created by 潘嘉尉 on 16/2/26.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "LivingViewController.h"
#import "LivingTableViewCell.h"
#import "LivingListRoomModel.h"
#import "LivingRoomDetailModel.h"
#import "UserCenterViewController.h"
#import "LivingPrepareViewController.h"

#import "RedPackageListViewController.h"
#import "LiveHistoryObject.h"

@interface LivingViewController ()

@end

@implementation LivingViewController

- (id)initWithLivingListEntity:(LivingListEntity *)entity withIndex:(NSInteger)index{
    self = [super init];
    if (self) {
        _livingListEntity = entity;
        [[[NIMSDK sharedSDK] chatManager] addDelegate:self];
        [self initViews];
        LivingListRoomModel *model = _livingListEntity.conDataArr[index];
        
        WS(weakSelf)
        [_livingListEntity getLivingRoomDetailModel:model.channelId with:^(LivingRoomDetailModel *detailModel) {
           [weakSelf updateLivingVideoVC];
            [weakSelf changeLivingRoom];
        }];
        [_tableView setContentOffset:CGPointMake(0, kScreen_Height*index)];
        _lastIndexPage = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _lastIndexPage = 0;
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pangesture:)];
    [self.view addGestureRecognizer:gesture];
}

-(void)pangesture:(UIPanGestureRecognizer *)gesture
{
    NSLog(@"pan=================");
    switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
        {
            
        }
            case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
            
        default:
            break;
    }
    CGPoint translatedPoint = [gesture translationInView:gesture.view];
    if (translatedPoint.x > 100) {
        if ([Reachability reachabilityForInternetConnection].isReachable) {
            if (self.livingVideoVC) {
                if (self.livingVideoVC.liveplayer) {
                    if (self.isShutDownVideo) {
                        return;
                    }
                    self.isShutDownVideo = YES;
                    [self.livingVideoVC.liveplayer stop];
                }
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _livingVideoVC.view.hidden = NO;
    _livingRoomVC.chatNIMManager.delegate = _livingRoomVC;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _livingVideoVC.view.hidden = YES;
//    if (_delegate && [_delegate respondsToSelector:@selector(hideVideoPlayerWhenEnterLivingList:)]) {
//        [_delegate hideVideoPlayerWhenEnterLivingList:self];
//    }
}

#pragma mark - LivingOrUserListVCDelegate
- (void)updateCurrentLiving:(LivingOrUserListEntity *)conEntity withIndex:(NSInteger)index{
    _livingListEntity.conDataArr = conEntity.conDataArr;
    _livingListEntity.begin = conEntity.begin;
    _livingListEntity.isFinish = conEntity.isFinish;
    _livingListEntity.totalNum = conEntity.totalNum;
    _lastIndexPage = index;
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(0, kScreen_Height * _lastIndexPage) animated:NO];
    [self changeLivingRoom];
    [_livingRoomVC.listVC removeListVC];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreen_Height;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _livingListEntity.conDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndntity = @"LivingTableViewCell";
    LivingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndntity];
    if (!cell) {
        cell = [[LivingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndntity];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LivingListRoomModel *model = _livingListEntity.conDataArr[indexPath.row];
    if (model) {
        [cell updateWithLivingRoomDetailModel:model];
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_livingRoomVC.textView.textField resignFirstResponder];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger indexPage = scrollView.contentOffset.y/kScreen_Height;
    if (indexPage != _lastIndexPage) {
         _lastIndexPage = indexPage;
        [self changeLivingRoom];
    }
}

#pragma mark - 切换房间
- (void)changeLivingRoom{
    if (_livingListEntity.conDataArr.count <= _lastIndexPage) {
//        UIView *view = [[UIView alloc] init];
//        view.frame = CGRectMake(0, 0, kScreen_Width, 300);
//        view.backgroundColor = kColorRed;
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        [window addSubview:view];
        return;
    }
    if (!_livingListEntity) {
//        UIView *view = [[UIView alloc] init];
//        view.frame = CGRectMake(0, 0, kScreen_Width, 300);
//        view.backgroundColor = kColorBlue;
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        [window addSubview:view];
        return;
    }
    
    if (!_livingListEntity.conDataArr) {
//        UIView *view = [[UIView alloc] init];
//        view.frame = CGRectMake(0, 0, kScreen_Width, 300);
//        view.backgroundColor = kColorBlue;
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        [window addSubview:view];
        return;
    }
    
    //重新去更换播放器的坐标和聊天直播室等信息
    WS(weakSelf)
    LivingListRoomModel *model = _livingListEntity.conDataArr[_lastIndexPage];
    [self.livingRoomVC.animationView removeAllAnimationView];
    [self.livingRoomVC.roomBarrageView removeAllBarrageView];
    [self.livingRoomVC.moneyAnimationBgView removeAllAnimation];
    self.livingRoomVC.chatViewVC.view.hidden = YES;
    [weakSelf.livingListEntity getLivingRoomDetailModel:model.channelId with:^(LivingRoomDetailModel *detailModel) {
        [weakSelf.livingVideoVC setNELivePlayerWithUrl:weakSelf.livingListEntity.roomDetailModel.httpPullUrl withChannelId:weakSelf.livingListEntity.roomDetailModel.channelId];
        _livingVideoVC.reLinkAgain = NO;
        [weakSelf.livingVideoVC.view setFrameY:(_lastIndexPage*kScreen_Height)];
        [weakSelf.livingRoomVC.view setFrameY:(_lastIndexPage*kScreen_Height)];
        [weakSelf.livingRoomVC updateLivingRoomModel:weakSelf.livingListEntity.roomDetailModel];
    }];
}

- (void)updateLivingVideoVC{
    self.isShutDownVideo = NO;
    if (_livingListEntity.conDataArr.count > 0) {
        if (!_livingVideoVC) {
            //测试拉流地址
            _livingVideoVC = [[LivingVideoViewController alloc] initWithStreamUrl:_livingListEntity.roomDetailModel.httpPullUrl withChannelId:_livingListEntity.roomDetailModel.channelId];
            [_tableView addSubview:_livingVideoVC.view];
            
            _livingRoomVC = [[LivingRoomViewController alloc] init];
            _livingRoomVC.viewSuperVC = self;
            [_tableView addSubview:_livingRoomVC.view];
        }else{
            [_livingVideoVC setNELivePlayerWithUrl:_livingListEntity.roomDetailModel.httpPullUrl withChannelId:_livingListEntity.roomDetailModel.channelId];
            [_livingVideoVC.view setFrameY:0];
            [_livingRoomVC.view setFrameY:0];
        }
        [_livingRoomVC initRoomUsermodel:_livingListEntity.roomDetailModel];
//        [_livingRoomVC updateLivingRoomModel:_livingListEntity.roomDetailModel];
    }else{
        if (_livingVideoVC) {
            [_livingVideoVC.view setFrameY:kScreen_Height*2];
            [_livingRoomVC.view setFrameY:kScreen_Height*2];
            [_tableView setContentSize:CGSizeMake(kScreen_Width, kScreen_Height)];
        }
    }
}

- (void)showLivingList:(UIButton *)sender{
    [_livingRoomVC showLivingList];
}

- (void)startLiving:(UIButton *)sender{
    LivingPrepareViewController *prepareVC = [[LivingPrepareViewController alloc] init];
    [self.navigationController pushViewController:prepareVC animated:YES];
}

- (void)initViews{
    _defaultImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    _defaultImgView.image = [UIImage imageNamed:@"no_living_bg.png"];
    _defaultImgView.hidden = YES;
    [self.view addSubview:_defaultImgView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.pagingEnabled = YES;
    _tableView.scrollsToTop = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    _startLivingBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width - 210)/2, (kScreen_Height - 60)/2 + 80, 210, 60)];
    _startLivingBtn.hidden = YES;
    [_startLivingBtn addTarget:self action:@selector(startLiving:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startLivingBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
