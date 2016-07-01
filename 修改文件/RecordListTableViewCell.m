//
//  RecordListTableViewCell.m
//  WuSe2.0
//
//  Created by 刘春明 on 16/3/17.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "RecordListTableViewCell.h"

@implementation RecordListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.labelTitle];
        [self.contentView addSubview:self.labelSubTitle];
        [self.contentView addSubview:self.labelAmount];
//        [self.contentView addSubview:self.labelStatus];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCell:(DrawHistoryObject *)data indexpath:(NSIndexPath *)indexpath type:(TYPE_DRAW_CHARGE_LIST)type
{
    self.labelTitle.frame = CGRectMake(10, 15, 100, 13);
    self.labelSubTitle.frame = CGRectMake(10, 60 -22, 100, 12);
    self.labelAmount.frame = CGRectMake(kScreen_Width -200, 19, 200 -10, 13);
    [self.labelAmount setCenter:CGPointMake(kScreen_Width - 100 -8, 60/2.0)];
    
    if (type == TYPE_DRAW_CHARGE_LIST_CHARGE) {
        self.labelStatus.alpha = 0;
        if (data.status == 3) {//成功
            self.labelAmount.textColor = kColorWhite;
            self.labelTitle.text = [NSString stringWithFormat:@"%@充值成功",(data.channel == 1?@"微信":@"支付宝")];
        }else{//失败
            self.labelAmount.textColor = kColorHexRGB(0x999999);
            self.labelTitle.text = [NSString stringWithFormat:@"%@充值失败",(data.channel == 1?@"微信":@"支付宝")];
        }
        self.labelSubTitle.text = data.createTime;
        self.labelAmount.text = [NSString stringWithFormat:@"%ld元",data.rechargeAmount/100];
    }else{
        self.labelStatus.alpha = 1;
        self.labelTitle.textColor = kColorWhite;
        
        switch (data.state) {
            case 0:{
                self.labelAmount.textColor = kColorHexRGB(0x999999);
                self.labelTitle.text = @"提现申请中";
            }
                break;
            case 1:{
                self.labelTitle.text = @"提现失败";
                self.labelAmount.textColor = kColorHexRGB(0x999999);
            }
                break;
            case 2:{
                self.labelTitle.text = @"提现成功";
                self.labelAmount.textColor = kColorWhite;
            }
                break;
                
            default:
                break;
        }
        
        self.labelSubTitle.text = data.createTime;
        self.labelAmount.text = [NSString stringWithFormat:@"%.0f元",data.fetchAmount/100.0];//(data.fetchDivide/100.0)
    }   
}

-(UILabel *)labelStatus
{
    if (!_labelStatus) {
        _labelStatus = [[UILabel alloc] init];
        _labelStatus.frame = CGRectMake(0, 0, 10, 10);
        _labelStatus.textColor = kColorHexRGB(0x999999);
        _labelStatus.font = kFont(12);
        _labelStatus.textAlignment = NSTextAlignmentLeft;
    }
    return _labelStatus;
}

-(UILabel *)labelSubTitle
{
    if (!_labelSubTitle) {
        _labelSubTitle = [[UILabel alloc] init];
        _labelSubTitle.frame = CGRectMake(0, 0, 10, 10);
        _labelSubTitle.textColor = kColorWhite;
        _labelSubTitle.font = kFont(10);
        _labelSubTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _labelSubTitle;
}
-(UILabel *)labelTitle
{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.frame = CGRectMake(0, 0, 10, 10);
        _labelTitle.textColor = kColorWhite;
        _labelTitle.font = kFont(15);
        _labelTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _labelTitle;
}

-(UILabel *)labelAmount
{
    if (!_labelAmount) {
        _labelAmount = [[UILabel alloc] init];
        _labelAmount.frame = CGRectMake(0, 0, 10, 10);
        _labelAmount.textColor = kColorHexRGB(0xc3c3c3);
        _labelAmount.font = kFont(13);
        _labelAmount.textAlignment = NSTextAlignmentRight;
    }
    return _labelAmount;
}


@end
