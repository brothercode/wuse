//
//  SearchFriendTextView.m
//  WuSe
//
//  Created by 刘春明 on 16/1/9.
//  Copyright © 2016年 jiawei. All rights reserved.
//

#import "SearchFriendTextView.h"

@interface SearchFriendTextView()<UITextFieldDelegate>

@property (nonatomic ,retain) UILabel *labelPlaceholder;

@property (nonatomic ,retain) UIButton *btnCancelSearch;

@property (nonatomic ,retain) UIView *viewTextBack;

@property (nonatomic ,assign) BOOL isKeyboardUp;

@property (nonatomic ,assign) BOOL isEdited;

@end

@implementation SearchFriendTextView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.textField.center = CGPointMake((kScreen_Width -20 -30)/2.0, 20+ (rect.size.height -20)/2.0);
    self.viewTextBack.center = self.textField.center;
    self.labelPlaceholder.center = self.textField.center;
    self.btnCancelSearch.center = CGPointMake(kScreen_Width - 86/2/2 -9, 20+ (rect.size.height -20)/2.0);
}

-(SearchFriendTextView *)initSearchViewWithDelegate:(id<SearchFriendTextViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self addSubview:self.textField];
        
        [self addSubview:self.labelPlaceholder];
        [self addSubview:self.btnCancelSearch];
        REGISTER_NOTIFICATION(keboardwillHide,UIKeyboardWillHideNotification);
        REGISTER_NOTIFICATION(keboarddidshow,UIKeyboardDidShowNotification);
        
    }
    return self;
}
-(void)keboarddidshow{
    if (self.isKeyboardUp) {
        return;
    }
    
    self.isKeyboardUp = YES;
}
-(void)keboardwillHide
{
//    [self animateWithLabelplaceholder];
    self.isKeyboardUp = NO;
}

-(void)cancelSearching
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchTextfieldCancelSearching)]) {
        [_delegate searchTextfieldCancelSearching];
    }
    [self animateAppearPlaceholder];
    [self endEditing:YES];
}


-(void)animateAppearPlaceholder
{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.labelPlaceholder.alpha = 1;
        self.textField.text = @"";
//        self.textField.frame = CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.textField.frame.size.width +50, 30);
        self.labelPlaceholder.center = self.textField.center;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)animateHidePlaceholder
{
    [UIView animateWithDuration:0.25 animations:^{
        self.labelPlaceholder.center = CGPointMake(0, self.labelPlaceholder.center.y);
        self.labelPlaceholder.alpha = 0;
    } completion:^(BOOL finished) {
        self.btnCancelSearch.alpha = 1;
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchTextfieldShouldBeginEditing:)]) {
        [_delegate searchTextfieldShouldBeginEditing:textField];
    }
    [self animateHidePlaceholder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchTextfieldTextFieldDidEndEditing:)]) {
        [_delegate searchTextfieldTextFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchTextfieldShouldClear:)]) {
        [_delegate searchTextfieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""] || textField.text == nil) {
        return YES;
    }
    [self endEditing:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(searchTextfieldTextFieldShouldReturn:)]) {
        [_delegate searchTextfieldTextFieldShouldReturn:textField];
    }
    return YES;
}// call

-(UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.frame = CGRectMake(0, 0, kScreen_Width - 40 -86/2, 30);
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeyGo;
        _textField.backgroundColor = kColorClear;
        _textField.textColor = kColorWhite;
        _textField.tintColor = kColorWhite;
        _textField.font = kFont(14);
        _textField.clipsToBounds = NO;
        //描边
        UIView *viewTextBack = [[UIView alloc] init];
        viewTextBack.bounds = CGRectMake(0, 0, _textField.frame.size.width +10, _textField.frame.size.height);
        viewTextBack.center = CGPointMake(_textField.frame.size.width/2.0, _textField.frame.size.height/2.0 +20);
        [self addSubview:viewTextBack];
//        [_textField sendSubviewToBack:viewTextBack];
        
        [viewTextBack.layer setBorderWidth:1];//设置边界的宽度
        //设置按钮的边界颜色
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGColorRef color = CGColorCreate(colorSpaceRef, (CGFloat[]){1,1,1,1});
        [viewTextBack.layer setBorderColor:color];
        CGColorRelease(color);
        viewTextBack.layer.cornerRadius = 3;
        self.viewTextBack = viewTextBack;
        
        UIImageView *imgView2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"center_search_delete.png"]];
        imgView2.frame=CGRectMake(0, 500, 15, 15);
        imgView2.tag = 2;
        _textField.rightView=imgView2;
        _textField.rightViewMode=UITextFieldViewModeWhileEditing;
        imgView2.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearTextFieldtext:)];
        [imgView2 addGestureRecognizer:gesture];
        
    }
    return _textField;
}


-(void)clearTextFieldtext:(UITapGestureRecognizer *)gesture
{
    _textField.text = @"";
}

-(UILabel *)labelPlaceholder
{
    if (!_labelPlaceholder) {
        _labelPlaceholder = [[UILabel alloc] init];
        _labelPlaceholder.bounds = CGRectMake(0, 0, 150, 40);
        _labelPlaceholder.center = _textField.center;
        _labelPlaceholder.textAlignment = NSTextAlignmentCenter;
        _labelPlaceholder.text = @"请输入用户名";
        _labelPlaceholder.font = kFont(13);
        _labelPlaceholder.textColor = kColorWhite;
    }
    return _labelPlaceholder;
}

-(UIButton *)btnCancelSearch
{
    if (!_btnCancelSearch) {
        _btnCancelSearch = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnCancelSearch.frame = CGRectMake(0, 0, 86/2, 30);
        
        _btnCancelSearch.titleLabel.font= kFont(15);
        [_btnCancelSearch setTitleColor:kColorHexRGB(0xdedede) forState:UIControlStateNormal];
        [_btnCancelSearch setTitle:@"取消" forState:UIControlStateNormal];
        [_btnCancelSearch addTarget:self action:@selector(cancelSearching) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancelSearch;
}

@end
