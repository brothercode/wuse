//
//  LivingVideoViewController.m
//  WuSe2.0
//
//  Created by 潘嘉尉 on 16/3/3.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "LivingVideoViewController.h"


@interface LivingVideoViewController()


@end

@implementation LivingVideoViewController

- (id)initWithStreamUrl:(NSString *)streamUrl withChannelId:(NSString *)channelId
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
        _streamUrl = streamUrl;
        _channelId = channelId;
        [self initViews];
//        [self setNELivePlayerWithUrl:_streamUrl withChannelId:_channelId];
//        [self initNotification];
        
        self.reLinkAgain = NO;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [_liveplayer shutdown]; //退出播放并释放相关资源
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerDidPreparedToPlayNotification object:_liveplayer];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerLoadStateChangedNotification object:_liveplayer];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerPlaybackFinishedNotification object:_liveplayer];
}

- (void)setNELivePlayerWithUrl:(NSString *)streamUrl withChannelId:(NSString *)channelId{
    _channelId = channelId;
    _streamUrl = streamUrl;
    [self removeNELivePlayer];
    self.view.hidden = NO;
    [_connectView startAnimation];
    _liveplayer = [[NELivePlayerController alloc] initWithContentURL:[NSURL URLWithString:streamUrl]];
    _liveplayer.view.backgroundColor = [UIColor clearColor];
    _liveplayer.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    [_liveplayer setScalingMode:NELPMovieScalingModeAspectFill];
    [_videoView addSubview:_liveplayer.view];
    [_liveplayer SetBufferStrategy:NELPLowDelay];
    [_liveplayer setShouldAutoplay:YES];
    [_liveplayer setHardwareDecoder:YES];
    [_liveplayer setPauseInBackground:NO];
    if (streamUrl.length > 0) {
       [_liveplayer prepareToPlay];
        [self initNotification];
    }
}

- (void)removeNELivePlayer{
    if (_liveplayer) {
        [_liveplayer shutdown];
        [_liveplayer.view removeFromSuperview];
        _liveplayer = nil;
        [self removeNotification];
    }
}

-(void)hideVideoWhenLogout
{
    [_liveplayer stop];
}

#pragma mark - 播放器初始化视频文件完成后的消息通知
- (void)NELivePlayerDidPreparedToPlay:(NSNotification*)notification{
    [_liveplayer play];
    [_connectView stopAnimation];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.view.hidden = NO;
}

#pragma makr - 播放器加载状态发生改变时的消息通知
- (void)NeLivePlayerloadStateChanged:(NSNotification*)notification{
    
    NSInteger errorInteger = [[[notification userInfo] valueForKey:MPMoviePlayerLoadStateDidChangeNotification] intValue];
    NSLog(@"%ld",(long)errorInteger);
}

#pragma mark - 播放器播放完成或播放发生错误时的消息通知
- (void)NELivePlayerPlayBackFinished:(NSNotification*)notification{
    if (!self.reLinkAgain) {
        [self setNELivePlayerWithUrl:_streamUrl withChannelId:_channelId];
        self.reLinkAgain = YES;
        return;
    }
    
    [_connectView stopAnimation];
    NSInteger errorInteger = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    WS(weakSelf)
    switch (errorInteger) {
        case NELPMovieFinishReasonPlaybackEnded:{
            weakSelf.view.hidden = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerMediaErrorNoti" object:_channelId];
        }
            break;
        case NELPMovieFinishReasonPlaybackError:{
            weakSelf.view.hidden = YES;
            [SVProgressHUD showErrorWithStatus:@"直播加载失败"];
        }
            break;
        case NELPMovieFinishReasonUserExited:{
            //自己退出
            
        }
            break;
            
        default:
            break;
    }
}

- (void)NELivePlayerFirstVideoDisplayed:(NSNotification*)notification
{
    NSLog(@"first video frame rendered!");
}

- (void)NELivePlayerReleaseSuccess:(NSNotification*)notification
{
    NSLog(@"resource release success!");
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerReleaseSueecssNotification object:_liveplayer];
}

- (void)initViews{
    _connectView = [[ConnectAnimationView alloc] initWithFrame:CGRectMake((kScreen_Width - 143)/2, (kScreen_Height - 71)/2, 143, 71)];
    _connectView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_connectView];
    
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    _videoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_videoView];
}

- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerDidPreparedToPlay:)
                                                 name:NELivePlayerDidPreparedToPlayNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NeLivePlayerloadStateChanged:)
                                                 name:NELivePlayerLoadStateChangedNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerPlayBackFinished:)
                                                 name:NELivePlayerPlaybackFinishedNotification
                                               object:_liveplayer];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(NELivePlayerFirstVideoDisplayed:)
//                                                 name:NELivePlayerFirstVideoDisplayedNotification
//                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerReleaseSuccess:)
                                                 name:NELivePlayerReleaseSueecssNotification
                                               object:_liveplayer];
    REGISTER_NOTIFICATION(hideVideoWhenLogout, kNotification_Logout);
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NELivePlayerDidPreparedToPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NELivePlayerLoadStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NELivePlayerPlaybackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerReleaseSueecssNotification object:_liveplayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Logout object:nil];
}

@end
