//
//  companyCell.m
//  tuanzhuang
//
//  Created by red on 2017/11/29.
//  Copyright © 2017年 red. All rights reserved.
//

#import "companyCell.h"
#import "companyModel.h"
#import "UILabel+sizetofit_w_h.h"

@interface companyCell ()
@property (strong, nonatomic) UILabel * companyNameLabel;//公司名称
@property (strong, nonatomic) UILabel * uploadDateLabel;//上传日期
@property (strong, nonatomic) UILabel * downloadTimesLabel;//下载次数
@property (strong, nonatomic) UIView * pointView;//圆点
@property (strong, nonatomic) UILabel * statusLabel;//量体状态
@property (strong, nonatomic) UIImageView * selectImageView;//选中状态
@property (nonatomic, strong) UIImageView * finishImageView;/**<完成状态*/
@property (strong, nonatomic) UIButton * downloadButton;//下载
@property (strong, nonatomic) UIView * bottomLineView;//底部线条
@property (nonatomic, strong) UIActivityIndicatorView * loadView;/**<加载圈*/
@property (assign, nonatomic) NSInteger index;//

@end

@implementation companyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - 懒加载
//公司名
-(UILabel *)companyNameLabel
{
    if (_companyNameLabel == nil) {
        _companyNameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_companyNameLabel];
    }
    return _companyNameLabel;
}

//上传日期
-(UILabel *)uploadDateLabel
{
    if (_uploadDateLabel == nil) {
        _uploadDateLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_uploadDateLabel];
    }
    return _uploadDateLabel;
}

//下载次数
-(UILabel *)downloadTimesLabel
{
    if (_downloadTimesLabel == nil) {
        _downloadTimesLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_downloadTimesLabel];
    }
    return _downloadTimesLabel;
}

//圆点
-(UIView *)pointView
{
    if (_pointView == nil) {
        _pointView = [[UIView alloc] init];
        [self.contentView addSubview:_pointView];
    }
    return _pointView;
}

//量体状态
-(UILabel *)statusLabel
{
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_statusLabel];
    }
    return _statusLabel;
}

//选中状态
-(UIImageView *)selectImageView
{
    if (_selectImageView == nil) {
        _selectImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_selectImageView];
    }
    return _selectImageView;
}

//完成状态
-(UIImageView *)finishImageView
{
    if (_finishImageView == nil) {
        _finishImageView = [[UIImageView alloc] init];
//        _finishImageView.image = [UIImage imageNamed:@"finish.png"];
        [self.contentView addSubview:_finishImageView];
    }
    return _finishImageView;
}

//下载按钮
-(UIButton *)downloadButton
{
    if (_downloadButton == nil) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_downloadButton];
    }
    return _downloadButton;
}

//底部线条
-(UIView *)bottomLineView
{
    if (_bottomLineView == nil) {
        _bottomLineView = [[UIView alloc] init];
        [self.contentView addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

-(UIActivityIndicatorView *)loadView
{
    if (_loadView == nil) {
        _loadView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_loadView];
    }
    return _loadView;
}

#pragma mark - 填充数据
-(void)cellWithData:(companyModel *)model showSelect:(BOOL)show keyWords:(NSString *)keywords andIndex:(NSInteger)index
{
    CGFloat height = 84;
    CGFloat label_h = 16;
    CGFloat space = 10;
    CGFloat selecticon_size = 20;
    CGFloat x = 20;
    CGFloat y = (height - label_h - 14 - space)/2.0;
    
    _index = index;
    
    self.selectImageView.hidden = !show || model.status >= 3;
    weakObjc(self);
    if (model.selected) {
        self.selectImageView.image = [UIImage imageNamed:@"checked"];
    } else {
        self.selectImageView.image = [UIImage imageNamed:@"uncheck"];
    }
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.contentView).offset(32);
        make.right.mas_equalTo(weakself.contentView).offset(-25);
        make.size.mas_equalTo(CGSizeMake(selecticon_size, selecticon_size));
    }];

    [self.companyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.contentView).offset(y);
        make.left.mas_equalTo(weakself.contentView).offset(y);
        make.height.mas_equalTo(label_h);
    }];
    self.companyNameLabel.text = model.companyname;
    self.companyNameLabel.textColor = RGBColor(34, 34, 34);
    self.companyNameLabel.font = [UIFont systemFontOfSize:16];
    if (keywords.length>0) {
        NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:model.companyname];
        [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[model.companyname rangeOfString:keywords]];
        [self.companyNameLabel setAttributedText:attributeString];
    }

    [self.uploadDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.companyNameLabel.mas_bottom).offset(space);
        make.left.mas_equalTo(weakself.companyNameLabel);
        make.height.mas_equalTo(14);
    }];
    self.uploadDateLabel.text = [NSString stringWithFormat:@"更新时间：%@",model.updatetime];
    self.uploadDateLabel.textColor = RGBColor(153, 153, 153);
    self.uploadDateLabel.font = [UIFont systemFontOfSize:14];
    
    [self.downloadTimesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.uploadDateLabel);
        make.left.mas_equalTo(weakself.uploadDateLabel.mas_right).offset(60);
        make.height.mas_equalTo(weakself.uploadDateLabel);
    }];
    self.downloadTimesLabel.text = [NSString stringWithFormat:@"下载次数：%d",model.downloadtimes];
    self.downloadTimesLabel.textColor = RGBColor(153, 153, 153);
    self.downloadTimesLabel.font = [UIFont systemFontOfSize:14];
    
    CGFloat pointsize = 10;
    [self.pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.downloadTimesLabel.mas_right).offset(60);
        make.size.mas_equalTo(CGSizeMake(pointsize, pointsize));
        make.centerY.mas_equalTo(weakself.downloadTimesLabel.mas_centerY);
    }];
    self.pointView.layer.cornerRadius = 5.0;
    self.pointView.backgroundColor = model.yiliang ? RGBColor(0, 255, 0) : RGBColor(153, 153, 153);
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakself.downloadTimesLabel);
        make.left.mas_equalTo(weakself.pointView.mas_right).offset(8);
        make.height.mas_equalTo(label_h);
    }];
    self.statusLabel.text = model.yiliang ? @"已量体" : @"未量体";
    self.statusLabel.textColor = RGBColor(153, 153, 153);
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    
    CGFloat download_w = 30;
    CGFloat download_h = 30*15.0/17.0;
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(download_w, download_h));
        make.center.mas_equalTo(weakself.selectImageView);
    }];
    [self.downloadButton setImage:[UIImage imageNamed:@"download_icon"] forState:UIControlStateNormal];
    self.downloadButton.hidden = show || model.status >= 3;
    
    [self.finishImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(download_w, download_w));
        make.center.mas_equalTo(weakself.downloadButton);
    }];
    
    if (model.status == 3) {
        self.finishImageView.image = [UIImage imageNamed:@"finish.png"];
    } else if (model.status == 4) {
        self.finishImageView.image = [UIImage imageNamed:@"fail.png"];
    }
    self.finishImageView.hidden = model.status < 3;
    
    [self.loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(download_w, download_w));
        make.center.mas_equalTo(weakself.downloadButton);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakself.contentView).offset(x);
        make.bottom.mas_equalTo(weakself.contentView);
        make.right.mas_equalTo(weakself.contentView).offset(-x);
        make.height.mas_equalTo(1);
    }];
    self.bottomLineView.backgroundColor = RGBColor(238, 238, 238);
    
    if (model.status == 2) {
        self.selectImageView.hidden = YES;
        self.downloadButton.hidden = YES;
        [self.loadView startAnimating];
    } else {
        [self.loadView stopAnimating];
    }
}

//点击下载手势方法
-(void)downloadAction
{
    if (_block) {
        _block(_index);
    }
}

static downloadBlock _block;
+(void)downloadWithBlock:(downloadBlock)block
{
    _block = block;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)startload
{
    [self.loadView startAnimating];
}

-(void)stopload
{
    [self.loadView stopAnimating];
}

@end
