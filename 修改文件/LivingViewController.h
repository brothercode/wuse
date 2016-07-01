//
//  LivingViewController.h
//  WuSe2.0
//
//  Created by 潘嘉尉 on 16/2/26.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "BaseViewController.h"
#import "LivingVideoViewController.h"
#import "LivingRoomViewController.h"
#import "LivingUserHelpView.h"


//@protocol LivingViewControllerDelegate <NSObject>
//
//-(void)hideVideoPlayerWhenEnterLivingList:(LivingViewController *)vc;
//
//@end

@interface LivingViewController : BaseViewController <NIMChatManagerDelegate,LivingOrUserListVCDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    NSInteger _lastIndexPage;
}

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) LivingVideoViewController *livingVideoVC;

@property (nonatomic, retain) LivingRoomViewController *livingRoomVC;

@property (nonatomic, retain) LivingListEntity *livingListEntity;

@property (nonatomic, retain) UIImageView *defaultImgView;

@property (nonatomic, retain) UIButton *startLivingBtn;

@property (nonatomic ,assign) BOOL isShutDownVideo;


- (id)initWithLivingListEntity:(LivingListEntity *)entity withIndex:(NSInteger)index;

@end
