//
//  MultipeerCell.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/5.
//  Copyright © 2017年 red. All rights reserved.
//

#import "MultipeerCell.h"
#import "DeviceEntity.h"

@interface MultipeerCell()

@property (weak, nonatomic) IBOutlet UIImageView *connectStatusView;
@property (weak, nonatomic) IBOutlet UIImageView *deviceTypeView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
//
@property (nonatomic, strong) UIView * bottomLineView;/** */
@property (strong,nonatomic) UIActivityIndicatorView* loadingImg;

@end

@implementation MultipeerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
}

#pragma mark - view
-(void)layout{
    _titleLabel.textColor = RGBColor(51, 51, 51);
    _connectLabel.textColor = RGBColor(153, 153, 153);
    [self bottomLineView];
}

-(UIActivityIndicatorView *)loadingImg{
    if(!_loadingImg){
        _loadingImg = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(-1,42.5,30,30)];
        _loadingImg.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _loadingImg.color = [UIColor grayColor];
        _loadingImg.hidesWhenStopped = NO;
        [self addSubview:_loadingImg];
    }
    if(!_loadingImg.hidden){
        [_loadingImg startAnimating];
    }
    return _loadingImg;
}

-(UIView *)bottomLineView{
    if(!_bottomLineView){
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.layer.borderWidth = 0;
        _bottomLineView.backgroundColor = systemGrayColor;
        [self addSubview:_bottomLineView];
        [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.mas_width);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    return _bottomLineView;
}


#pragma mark - self
-(void)loadData:(DeviceEntity*)device{
    [_titleLabel setText:device.name];
    [self loadConnectStatus:device.connectStatus];
    [self loadDeviceType:device.type];
    [self loadSyncStatus:device.syncStatus];
    self.connectLabel.text = [device connectStatusText];
}

-(void)loadReceiveData:(DeviceEntity*)device{
    [_titleLabel setText:device.name];
    [self loadConnectStatus:device.connectStatus];
    [self loadDeviceType:device.type];
    [self loadSyncStatus:device.receiveStatus];
    self.connectLabel.text = [device receiveStatusText];
}

-(void)loadSyncData:(DeviceEntity*)device{
    [_titleLabel setText:device.name];
    [self loadConnectStatus:device.connectStatus];
    [self loadDeviceType:device.type];
    [self loadSyncStatus:device.syncStatus];
    self.connectLabel.text = [device syncStatusText];
}

-(void)loadConnectStatus:(int)val{
    switch (val) {
        case CONNECT_YES:
            self.loadingImg.hidden = YES;
            self.connectStatusView.image = [UIImage imageNamed:@"connect_yes"];
            break;
        default:
            self.loadingImg.hidden = NO;
            self.connectStatusView.image = nil;
            break;
    }
}

-(void)loadDeviceType:(NSString*)val{
    NSString* name;
    name = @"ipad_icon";
    [self.deviceTypeView setImage:[UIImage imageNamed:name]];
}

-(void)loadSyncStatus:(int)val{
    switch (val) {
        case SYNC_ING:{
            CABasicAnimation * rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: - M_PI * 2.0 ];//旋转角度
            rotationAnimation.duration = 2; //旋转周期
            rotationAnimation.cumulative = YES;//旋转累加角度
            rotationAnimation.repeatCount = 1000;//旋转次数
            [_syncStatusView setImage:[UIImage imageNamed:@"sync_ing"]];
            [_syncStatusView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        }
            break;
        case SYNC_YES:{
            [_syncStatusView setImage:[UIImage imageNamed:@"sync_yes"]];
            [_syncStatusView.layer removeAllAnimations];
        }
            break;
    }
}

@end
