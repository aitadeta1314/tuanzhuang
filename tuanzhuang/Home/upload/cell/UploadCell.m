//
//  Cell.m
//  tuanzhuang
//
//  Created by zhuang on 2017/12/8.
//  Copyright © 2017年 red. All rights reserved.
//

#import "UploadCell.h"

@implementation UploadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self lineView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - 懒加载
-(UILabel *)titleLabel{
    if(_titleLabel){
        _titleLabel.textColor = RGBColor(51, 51, 51);
    }
    return _titleLabel;
}

-(UILabel *)subTitleLabel{
    if(_subTitleLabel){
        _subTitleLabel.textColor = RGBColor(151, 151, 151);
    }
    return _subTitleLabel;
}

-(UIActivityIndicatorView *)loadingImg{
    if(!_loadingImg){
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _loadingImg = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake( w - 60,(h - 50)/2,50,50)];
        _loadingImg.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _loadingImg.color = [UIColor grayColor];
        _loadingImg.hidden = YES;
        [_loadingImg startAnimating];
        [self addSubview:_loadingImg];
    }
    return _loadingImg;
}

-(ZZCircleProgress *)progressView{
    if(!_progressView){
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _progressView = [[ZZCircleProgress alloc] initWithFrame:CGRectZero pathBackColor:systemGrayColor pathFillColor:skyColor startAngle:0 strokeWidth:8];
        _progressView.frame = CGRectMake( w - 60,(h - 50)/2,50,50);
        _progressView.increaseFromLast = NO;//为YES动画则从上次的progress开始，否则从头开始，默认为NO
        _progressView.animationModel = CircleIncreaseSameTime;//不同的进度条动画时间相同
        _progressView.showPoint = YES;//是否显示光标，默认为YES
        _progressView.showProgressText = NO;//是否显示进度文本，默认为YES
        _progressView.notAnimated = NO;//不开启动画，默认为NO
        _progressView.forceRefresh = YES;//是否在set的值等于上次值时同样刷新动画，默认为NO
        _progressView.progress = .5;//设置完之后给progress的值
        _progressView.hidden = YES;
        [self addSubview:_progressView];
    }
    return _progressView;
}

-(UIView *)lineView{
    if(!_lineView){
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height - 1 ,SCREEN_W,1)];
        _lineView.layer.borderWidth = 0;
        _lineView.backgroundColor = systemGrayColor;
        [self addSubview:_lineView];
    }
    return _lineView;
}

#pragma mark -
-(void)fillWithModel:(UploadModel *)model
{
    self.leftImg.image = [UIImage imageNamed:@"ipad_icon"];
    self.titleLabel.text = model.companymodel.companyname;
    UploadStatus status = model.status;
    switch (status) {
        case UPLOADING:
        {
            self.subTitleLabel.text = @"数据正在上传";
            self.subTitleLabel.textColor = RGBColor(150, 150, 150);
            self.rightImg.hidden = YES;
            self.loadingImg.hidden = NO;
            [self.loadingImg startAnimating];
        }
            break;
        case UPLOADED:
        {
            self.subTitleLabel.text = @"数据已上传";
            self.subTitleLabel.textColor = RGBColor(150, 150, 150);
            self.rightImg.hidden = NO;
            self.rightImg.image = [UIImage imageNamed:@"finish.png"];
            self.loadingImg.hidden = YES;
            [self.loadingImg stopAnimating];
        }
            break;
        case UNFINISH:
        {
            self.subTitleLabel.text = @"存在未完成数据";
            self.subTitleLabel.textColor = [UIColor redColor];
            self.rightImg.hidden = NO;
            self.rightImg.image = [UIImage imageNamed:@"enter_unfinish.png"];
            self.loadingImg.hidden = YES;
            [self.loadingImg stopAnimating];
        }
            break;
        case UPLOADFAILURE:
        {
            self.subTitleLabel.text = @"数据上传失败";
            self.subTitleLabel.textColor = [UIColor redColor];
            self.rightImg.hidden = NO;
            self.rightImg.image = [UIImage imageNamed:@"fail.png"];
            self.loadingImg.hidden = YES;
            [self.loadingImg stopAnimating];
        }
            break;
        case NOUPLOADDATAS:
        {
            self.subTitleLabel.text = @"无可上传数据";
            self.subTitleLabel.textColor = [UIColor redColor];
            self.rightImg.hidden = NO;
            self.rightImg.image = [UIImage imageNamed:@"fail.png"];
            self.loadingImg.hidden = YES;
            [self.loadingImg stopAnimating];
        }
            break;
        default:
            break;
    }
}


@end
