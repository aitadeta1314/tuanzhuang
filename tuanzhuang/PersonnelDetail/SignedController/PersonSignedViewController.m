//
//  PersonSignedViewController.m
//  tuanzhuang
//
//  Created by zhang gaotang on 2018/1/24.
//  Copyright © 2018年 red. All rights reserved.
//

#import "PersonSignedViewController.h"
#import "PositionSizeRangeModel.h"
#import "SignLayoutManager.h"
#import "signView.h"
#import "generatePicture.h"
#import "PersonnelModel+Helper.h"
#import "CategoryModel+Helper.h"

typedef enum : NSUInteger {
    SIGN_STATUS_WAITING,    //等待签名
    SIGN_STATUS_COMPLETED   //完成签名
} SIGN_STATUS;

#define COLOR_FOR_REQUIRED  [UIColor redColor]
#define COLOR_FOR_ICON      [UIColor colorWithRed:0.149 green:0.624 blue:0.839 alpha:1.00]

static const CGFloat ParagraphSpacing_H1        = 20.0f;
static const CGFloat ParagraphSpacing_H2        = 14.0f;
static const CGFloat ParagraphSpacing_Section   = 16.0f;
static const CGFloat ParagraphSpacing_Text      = 10.0f;

static const CGFloat Font_Size_H1               = 23.0f;
static const CGFloat Font_Size_H2               = 18.0f;
static const CGFloat Font_Size_Text             = 15.0f;

static const CGFloat Line_Height_H1             = 28.0f;
static const CGFloat Line_Height_H2             = 22.0f;
static const CGFloat Line_Height_Text           = 18.0f;

static const NSInteger MaxColumn_BodySize       = 8;
static const NSInteger MaxColumn_Addtion        = 3;
static const NSInteger MaxColumn_ClothesSize    = 4;

#define Size_Draw_Button                        CGSizeMake(50, 50)
#define Color_Activity_Button                   RGBColorAlpha(0, 176, 224, 0.8)
#define Color_No_Activity_Button                RGBColorAlpha(204, 204, 204, 0.8)

@interface PersonSignedViewController (){
    CGFloat _height;
}

@property(nonatomic,strong) UIView      *contentView;
@property(nonatomic,strong) UITextView  *textView;
@property(nonatomic,strong) signView    *drawView;

@property(nonatomic,strong) UIImage     *signImage;

@property (nonatomic, strong) UIButton * writeBtn;/**<“写”按钮*/
@property (nonatomic, strong) UIButton * clearBtn;/**<“清空”按钮*/

@property(nonatomic,assign) SIGN_STATUS    status;     //状态

@end

@implementation PersonSignedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"签字确认";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    [self layoutCustomSubviews];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.signImage = [UIImage imageWithData:self.personModel.sign scale:[UIScreen mainScreen].scale];
    
    if (self.signImage) {
        [self setStatus:SIGN_STATUS_COMPLETED];
    }else{
        [self setStatus:SIGN_STATUS_WAITING];
    }
    
}

-(void)layoutCustomSubviews{
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(TOPNAVIGATIONBAR_H, 0, 0, 0));
    }];
    
    [self.contentView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.drawView = [[signView alloc] initWithFrame:self.view.bounds];
    self.drawView.backgroundColor = [UIColor clearColor];
    self.drawView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.drawView];
    
    [self.view addSubview:self.writeBtn];
    [self.view addSubview:self.clearBtn];
    [self.writeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30 + TOPNAVIGATIONBAR_H);
        make.right.offset(-20);
        make.size.mas_equalTo(Size_Draw_Button);
    }];
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.writeBtn);
        make.top.equalTo(self.writeBtn.mas_bottom).with.offset(15);
        make.size.mas_equalTo(Size_Draw_Button);
    }];
    
    [self setWriteButtonSelectedStatus:NO];
    
    self.writeBtn.hidden = YES;
    self.clearBtn.hidden = YES;
}

-(void)setupSaveButtonItem{
    //保存按钮
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveSignImageAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

-(void)setupResignButtonItem{
    //重新签名
    UIBarButtonItem *signButton = [[UIBarButtonItem alloc] initWithTitle:@"重新签名" style:UIBarButtonItemStylePlain target:self action:@selector(reSignAction)];
    self.navigationItem.rightBarButtonItem = signButton;
}

/**
 * 配置TextView数据
 */
-(void)setupTextViewAttributedString{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:[self generateTitle]];
    [attributedString appendAttributedString:[self generatePersonMessage]];
    [attributedString appendAttributedString:[self generateBodySize]];
    [attributedString appendAttributedString:[self generateAddtion]];
    
    [attributedString appendAttributedString:[self generateClothesSize]];
    
    CGFloat width = self.textView.bounds.size.width;
    
    _height = [attributedString boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
    
    self.textView.attributedText = attributedString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getting Methods
-(UITextView *)textView{
    
    if (!_textView) {
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeZero];
        
        SignLayoutManager *layoutManager = [[SignLayoutManager alloc] init];
        [layoutManager addTextContainer:container];
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] init];
        [textStorage addLayoutManager:layoutManager];
        
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:container];
        _textView.textColor = [UIColor blackColor];
        _textView.editable = NO;
    }
    
    return _textView;
}

-(UIButton *)writeBtn
{
    if (_writeBtn == nil) {
        _writeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_writeBtn];
        _writeBtn.imageView.contentMode = UIViewContentModeScaleToFill;
        [_writeBtn setBackgroundColor:Color_Activity_Button];
        [_writeBtn setImage:[UIImage imageNamed:@"pencil_icon_unslected"] forState:UIControlStateNormal];
        [_writeBtn setImage:[UIImage imageNamed:@"pencil_icon_selected"] forState:UIControlStateSelected];
        [_writeBtn addTarget:self action:@selector(drawAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _writeBtn;
}


-(UIButton *)clearBtn
{
    if (_clearBtn == nil) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_clearBtn];
        [_clearBtn setBackgroundColor:Color_No_Activity_Button];
        [_clearBtn setImage:[UIImage imageNamed:@"empty_icon_unselected"] forState:UIControlStateNormal];
        [_clearBtn setImage:[UIImage imageNamed:@"empty_icon_selected"] forState:UIControlStateSelected];
        [_clearBtn addTarget:self action:@selector(drawAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearBtn;
}

#pragma mark - Setting Methods
-(void)setStatus:(SIGN_STATUS)status{
    
    switch (status) {
        case SIGN_STATUS_WAITING:{
            [self setupSaveButtonItem];
            self.writeBtn.hidden = NO;
            self.clearBtn.hidden = NO;
            self.drawView.userInteractionEnabled = YES;
            [self setWriteButtonSelectedStatus:NO];
            
            [self setupTextViewAttributedString];
            break;
        }
        case SIGN_STATUS_COMPLETED:{
            [self setupResignButtonItem];
            self.writeBtn.hidden = YES;
            self.clearBtn.hidden = YES;
            self.drawView.hidden = NO;
            self.drawView.userInteractionEnabled = NO;
            
            if (self.signImage) {
                self.textView.text = @"";
                self.drawView.image = self.signImage;
            }
        }
            
        default:
            break;
    }
    
}

#pragma mark - Generate Attributed String

-(NSAttributedString *)generateAttributedString{
    
    NSMutableAttributedString *contentAttribuedStr = [[NSMutableAttributedString alloc] init];
    
    return contentAttribuedStr;
}

/***
 * 生成用户基本信息文本
 ***/
-(NSAttributedString *)generateTitle{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    NSString *title = @"请仔细确认一下量体数据: ";
    NSString *content = @"(*以下量体数据均由本人确认无误，若造成其他后果，均由本人自行承担，与我司量体师无关)\n";
    
    NSDictionary *titleAttrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_H1]};
    NSDictionary *contentAttrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_Text],NSForegroundColorAttributeName:COLOR_FOR_REQUIRED};
    
    NSAttributedString *titleAttrStr = [[NSAttributedString alloc] initWithString:title attributes:titleAttrDic];
    NSAttributedString *contentAttrStr = [[NSAttributedString alloc] initWithString:content attributes:contentAttrDic];
    
    [attributedString appendAttributedString:titleAttrStr];
    [attributedString appendAttributedString:contentAttrStr];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.paragraphSpacingBefore = ParagraphSpacing_H1;
    paragraphStyle.paragraphSpacing = ParagraphSpacing_H1;
    paragraphStyle.minimumLineHeight = Line_Height_H1;
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    
    
    return attributedString;
}

-(NSAttributedString *)generatePersonMessage{
    
    //公司信息
    NSMutableString *companyLineStr = [NSMutableString stringWithFormat:@"公司：%@\t",self.companyModel.companyname];
    [companyLineStr appendString:[NSString stringWithFormat:@"部门：%@\n",self.personModel.department]];
    
    //个人基本数据
    NSMutableString *personLineStr = [NSMutableString stringWithFormat:@"姓名：%@\t",self.personModel.name];
    NSString *sex = self.personModel.gender ? @"男" : @"女";
    [personLineStr appendString:[NSString stringWithFormat:@"性别：%@\n",sex]];
    
    //个人量体基本数据
    NSMutableString *personInfoLineStr = [NSMutableString stringWithFormat:@"身高*：%.1fcm\t",self.personModel.height];
    [personInfoLineStr appendString:[NSString stringWithFormat:@"体重*：%.1fkg\t",self.personModel.weight]];
    
    [personInfoLineStr appendFormat:@"配置*：%@\n",[self.personModel getCategoryConfigDescription]];
    
    NSTextTab *tab_first = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:200 options:@{}];
    
    NSTextTab *tab_second = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:400.0 options:@{}];
    
    //公司属性样式
    NSMutableParagraphStyle *companyParagraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    companyParagraph.tabStops = @[tab_second];
    companyParagraph.minimumLineHeight = Line_Height_H2;
    companyParagraph.paragraphSpacing = ParagraphSpacing_H2;
    NSAttributedString *companyAttrStr = [[NSAttributedString alloc] initWithString:companyLineStr attributes:@{NSParagraphStyleAttributeName:companyParagraph}];
    
    //个人基本数据属性样式
    NSMutableParagraphStyle *personParagraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    personParagraph.tabStops = @[tab_first,tab_second];
    personParagraph.minimumLineHeight = Line_Height_H2;
    personParagraph.paragraphSpacing = ParagraphSpacing_H2;
    NSAttributedString *personAttrStr = [[NSAttributedString alloc] initWithString:personLineStr attributes:@{NSParagraphStyleAttributeName:personParagraph}];
    
    //个人量体基本数据属性样式
    NSAttributedString *personInfoAttrStr = [[NSAttributedString alloc] initWithString:personInfoLineStr attributes:@{NSParagraphStyleAttributeName:personParagraph,NSForegroundColorAttributeName:COLOR_FOR_REQUIRED}];
    
    
    NSDictionary *attributesDic = @{NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_H2]};
    NSMutableAttributedString *contentAttributedStr = [[NSMutableAttributedString alloc] init];
    [contentAttributedStr appendAttributedString:companyAttrStr];
    [contentAttributedStr appendAttributedString:personAttrStr];
    [contentAttributedStr appendAttributedString:personInfoAttrStr];
    
    [contentAttributedStr addAttributes:attributesDic range:NSMakeRange(0, contentAttributedStr.length)];
    
    return contentAttributedStr;
}

//生成净体尺寸
-(NSAttributedString *)generateBodySize{
    
    NSMutableAttributedString *contentAttrStr  = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *titleAttrStr = [self getTitleAttributedString:@"净体尺寸"];
    
    //获取净体尺寸数据
    [contentAttrStr appendAttributedString:[self getFormatterBodySize_AttributedString]];
    
    NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.tabStops = [self getTextTabArrayByMaxColumn:MaxColumn_BodySize];
    paragraph.minimumLineHeight = Line_Height_Text;
    paragraph.paragraphSpacing = ParagraphSpacing_Text;
    
    NSDictionary *attributesDic = @{NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_Text],NSParagraphStyleAttributeName:paragraph};
    
    [contentAttrStr addAttributes:attributesDic range:NSMakeRange(0, contentAttrStr.length)];
    
    //添加标题
    [contentAttrStr insertAttributedString:titleAttrStr atIndex:0];

    return contentAttrStr;
}

/***
 * 生成附加的加放量信息数据
 **/
-(NSAttributedString *)generateAddtion{
    
    //获取加放量信息的格式化信息
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:[self getFormatterAddtion_String]];
    
    //生成AttrbutesDictionary
    NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.tabStops = [self getTextTabArrayByMaxColumn:MaxColumn_Addtion];
    paragraph.minimumLineHeight = Line_Height_Text;
    paragraph.paragraphSpacing = ParagraphSpacing_Text;
    
    NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraph,NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_Text],NSForegroundColorAttributeName:COLOR_FOR_REQUIRED};
    
    [contentString addAttributes:attributes range:NSMakeRange(0, contentString.length)];
    
    return contentString;
}

-(NSAttributedString *)generateClothesSize{
    
    NSMutableAttributedString *contentAttributedStr = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *titleAttr = [self getTitleAttributedString:@"成衣尺寸"];
    
    [contentAttributedStr appendAttributedString:titleAttr];
    
    NSArray *categoryArray = [self getClothesSizeCategory];
    
    if ([categoryArray count] <= MaxColumn_ClothesSize) {
        [contentAttributedStr appendAttributedString:[self getFormatterClothesSize_AttributedString:categoryArray]];
    }else{
        NSUInteger count = [categoryArray count] / MaxColumn_ClothesSize;
        
        if ([categoryArray count] % MaxColumn_ClothesSize == 0) {
            count ++ ;
        }
        
        NSAttributedString *attr1 = [self getFormatterClothesSize_AttributedString:[categoryArray subarrayWithRange:NSMakeRange(0, MaxColumn_ClothesSize)]];
        NSAttributedString *attr2 = [self getFormatterClothesSize_AttributedString:[categoryArray subarrayWithRange:NSMakeRange(MaxColumn_ClothesSize-1, [categoryArray count]-MaxColumn_ClothesSize)]];
        
        [contentAttributedStr appendAttributedString:attr1];
        [contentAttributedStr appendAttributedString:attr2];
        
    }
    
    return contentAttributedStr;
}

#pragma mark - Draw Sign Action Methods

/**
 * 签名绘图操作
 **/
-(void)drawAction:(id)sender{
    
    if (sender == self.writeBtn) {
        [self setWriteButtonSelectedStatus:!self.writeBtn.selected];
    }else if (sender == self.clearBtn){
        [self.drawView clearImage];
    }
    
}

-(void)setWriteButtonSelectedStatus:(BOOL)selected{
    self.writeBtn.selected = selected;
    self.drawView.hidden = !selected;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    UIColor *backgroundColor = Color_No_Activity_Button;
    if (selected) {
        transform = CGAffineTransformMakeScale(1.2, 1.2);
        backgroundColor = Color_Activity_Button;
    }
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.writeBtn.transform = transform;
        self.writeBtn.backgroundColor = backgroundColor;
    } completion:nil];
}

/**
 * 重新签名图片
 */
-(void)reSignAction{
    
    self.personModel.sign = nil;
    [self.drawView clearImage];
    [self setStatus:SIGN_STATUS_WAITING];
}

/**
 * 保存签名图片
 **/
-(void)saveSignImageAction{
    
    if (PERSON_STATUS_COMPLETED != self.personModel.status) {
        [self showHUDMessage:@"请在量体完成状态下，继续签名确认" andDelay:2.0];

        return;
    }
    
    [self showLoading];
    
    self.signImage = [self getSignImageByScreenShots];
    
    self.personModel.sign = UIImagePNGRepresentation(self.signImage);
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self hideLoading];
    
    [self setStatus:SIGN_STATUS_COMPLETED];
    
}

/**
 * 通过截屏获取签名图片
 */
-(UIImage *)getSignImageByScreenShots{
    
    UIImage *signImage;
    
    CGRect frame_old = self.view.frame;
    
    CGSize size_old = self.contentView.bounds.size;
    CGSize newSize = size_old;
    
    if (_height > self.view.bounds.size.height) {
        newSize = self.textView.contentSize;
        newSize.height = _height;
    }
    
    self.view.bounds = CGRectMake(0, 0, newSize.width, newSize.height + TOPNAVIGATIONBAR_H);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);

    [self.contentView drawViewHierarchyInRect:CGRectMake(0, 0, newSize.width, newSize.height) afterScreenUpdates:YES];

    signImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    self.view.bounds = frame_old;
    
    return signImage;
}

#pragma mark - Private Helper Methods

/**
 * 根据列数，获取Tab的数组
 **/
-(NSArray *)getTextTabArrayByMaxColumn:(NSInteger)column{
    
    NSMutableArray *tabArray = [NSMutableArray array];
    
    CGFloat itemWidth = self.textView.contentSize.width / column;
    
    for (int i=1; i<column; i++) {
        CGFloat location = i * itemWidth;
        NSTextTab *tab = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:location options:@{}];
        
        [tabArray addObject:tab];
    }
    
    return tabArray;
}

/**
 * 获取内容标题
 */
-(NSAttributedString *)getTitleAttributedString:(NSString *)title{
    
    UIImage *icon = [self getTitleIcon];
    NSTextAttachment *iconAttachment = [[NSTextAttachment alloc] init];
    iconAttachment.image = icon;
    iconAttachment.bounds = CGRectMake(0, 0, 10, 22);
    NSAttributedString *iconAttr = [NSAttributedString attributedStringWithAttachment:iconAttachment];
    
    NSMutableAttributedString *titleAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n",title] attributes:nil];
    [titleAttrStr insertAttributedString:iconAttr atIndex:0];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = Line_Height_H2;
    paragraphStyle.paragraphSpacingBefore = ParagraphSpacing_Section;
    paragraphStyle.paragraphSpacing = ParagraphSpacing_Text;
    
    NSDictionary *attributesDic = @{NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_H2],NSParagraphStyleAttributeName:paragraphStyle};
    
    [titleAttrStr addAttributes:attributesDic range:NSMakeRange(0, titleAttrStr.length)];
    
    return titleAttrStr;
}

/**
 * 获取格式化后的净体数据
 ***/
-(NSAttributedString *)getFormatterBodySize_AttributedString{
    
    NSMutableAttributedString *formatterString = [[NSMutableAttributedString alloc] init];
    
    NSArray *sizeRangeArray = [PositionSizeRangeModel getBodyPositionSizeRangeArrayBySex:self.personModel.gender andMTM:self.personModel.mtm];
    NSArray *bodyCategoryArray = [self.personModel getCategorySizeType:CategorySizeType_Body];
    
    for (int i=0; i<[sizeRangeArray count]; i++) {
        PositionSizeRangeModel *rangeModel = sizeRangeArray[i];
        
        NSMutableString *positionStr = [[NSMutableString alloc] initWithString:rangeModel.position];
        
        BOOL isRequired = [rangeModel isRequiredForBodySizeCategorys:bodyCategoryArray];
        
        NSString *blcode = rangeModel.blcode;
        if (0 == self.personModel.gender) {
            blcode = rangeModel.blcode;
        }
        
        NSInteger size = [self.personModel getBodyPositionSizeByCode:blcode];
        [positionStr appendFormat:@"：%ldcm",size];
        
        if (i%MaxColumn_BodySize == (MaxColumn_BodySize - 1) || (i+1) == [sizeRangeArray count]) {
            //每行的最后一个和最后一个，添加回车
            [positionStr appendString:@"\n"];
        }else{
            [positionStr appendString:@"\t"];
        }
        
        NSDictionary *attributesDic;
        if (isRequired) {
            [positionStr insertString:@"*" atIndex:rangeModel.position.length];
            attributesDic = @{NSForegroundColorAttributeName:COLOR_FOR_REQUIRED};
        }
        
        NSAttributedString *positionAttributedStr = [[NSAttributedString alloc] initWithString:positionStr attributes:attributesDic];
        
        [formatterString appendAttributedString:positionAttributedStr];
    }
    
    return formatterString;
}

-(NSAttributedString *)getFormatterClothesSize_AttributedString:(NSArray *)categoryArray{
    
    NSMutableAttributedString *contentAttributedStr = [[NSMutableAttributedString alloc] init];
    
    NSString *formatterStr = [self getFormatterClothesSize_String_ByCategorys:categoryArray];
    
    NSArray *tempArray = [formatterStr componentsSeparatedByString:@"\n"];
    
    if ([tempArray count]>0) {
        NSString *titleStr = [NSString stringWithFormat:@"%@\n",tempArray[0]];
        
        NSArray *titleArray = [titleStr componentsSeparatedByString:@"\t"];
        
        NSArray *tabArray = [self getTextTabArrayByMaxColumn:[titleArray count]];
        
        NSMutableParagraphStyle *titleParagraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        titleParagraph.tabStops = tabArray;
        titleParagraph.paragraphSpacing = ParagraphSpacing_Section;
        
        NSAttributedString *titleAttrStr = [[NSAttributedString alloc] initWithString:titleStr attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineByWord | NSUnderlineStyleThick),NSParagraphStyleAttributeName:titleParagraph,NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_H2],NSUnderlineColorAttributeName:COLOR_FOR_ICON}];
        
        for (int i=1; i<[tempArray count]; i++) {
            //处理内容行
            NSString *lineString = [NSString stringWithFormat:@"%@\n",tempArray[i]];
            NSMutableAttributedString *lineAttributedStr = [[NSMutableAttributedString alloc] init];
            
            NSArray *itemArray = [lineString componentsSeparatedByString:@"\t"];
            
            for (int j = 0; j<[itemArray count]; j++) {
                
                NSDictionary *itemAttributes;
                NSString *itemString = itemArray[j];
                
                if ([itemString containsString:@"*"]) {
                    itemAttributes = @{NSForegroundColorAttributeName:COLOR_FOR_REQUIRED};
                }
                
                if ((j+1) < [itemArray count]) {
                    itemString = [NSString stringWithFormat:@"%@\t",itemString];
                }
                
                [lineAttributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:itemString attributes:itemAttributes]];
            }
            
            [contentAttributedStr appendAttributedString:lineAttributedStr];
        }
        
        NSMutableParagraphStyle *paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraph.tabStops = tabArray;
        paragraph.paragraphSpacing = ParagraphSpacing_Text;
        [contentAttributedStr addAttributes:@{NSParagraphStyleAttributeName:paragraph,NSFontAttributeName:[UIFont systemFontOfSize:Font_Size_Text]} range:NSMakeRange(0, contentAttributedStr.length)];
        
        [contentAttributedStr insertAttributedString:titleAttrStr atIndex:0];
    }
    
    return contentAttributedStr;
}

-(NSString *)getFormatterClothesSize_String_ByCategorys:(NSArray *)categoryArray{

    NSMutableArray *titleArray = [NSMutableArray array];
    NSMutableArray *contentArray = [NSMutableArray array];
    
    //获取内容行初始化字符串
    NSString *contentLineInitialStr = @"";
    for (int i = 1;i<MaxColumn_ClothesSize; i++) {
        contentLineInitialStr = [NSString stringWithFormat:@"%@\t",contentLineInitialStr];
    }
    
    [titleArray addObjectsFromArray:[contentLineInitialStr componentsSeparatedByString:@"\t"]];
    
    for (int column = 0; column<[categoryArray count]; column++) {
        CategoryModel *category = categoryArray[column];
        
        titleArray[column] = category.name;
        if ([category.name containsString:@"衬衫"]) {
            titleArray[column] = @"衬衫";
        }
        
        NSArray *rangeArray = [PositionSizeRangeModel getClothesPositionSizeRangeArray:category.cate bySex:self.personModel.gender andMTM:self.personModel.mtm];
        
        for (int row = 0; row<[rangeArray count]; row++) {
            
            PositionSizeRangeModel *rangeModel = rangeArray[row];
            
            NSString *contentLineString = contentLineInitialStr;
            
            if ([contentArray count] <= row) {
                [contentArray addObject:contentLineString];
            }else{
                contentLineString = contentArray[row];
            }
            
            //内容分组
            NSMutableArray *contentLineItemArray = [NSMutableArray arrayWithArray:[contentLineString componentsSeparatedByString:@"\t"]];
            
            //设置改组的尺寸内容
            NSString *blcode = rangeModel.blcode;
            
            if (0 == self.personModel.gender) {
                blcode = rangeModel.wblcode;
            }
            
            PositionModel *position = [self.personModel getPositionByCode:blcode atCategory:category];
            
            NSMutableArray *itemArray = [NSMutableArray array];
            
            NSString *positionName = [NSString stringWithFormat:@"%@:",rangeModel.position];
            
            if ([rangeModel.required isEqualToString:category.cate]) {
                positionName = [NSString stringWithFormat:@"*%@",positionName];
            }
            
            [itemArray addObject:positionName];
            
            if (position) {
                
                BOOL hasSummer,hasWinter;
                [self Category_HasSummer:&hasSummer hasWinter:&hasWinter withCategory:category];
                
                if (hasWinter) {
                    [itemArray addObject:[NSString stringWithFormat:@"(冬) %d cm",position.size_winter]];
                }
                
                if (hasSummer) {
                    [itemArray addObject:[NSString stringWithFormat:@"(夏) %d cm",position.size]];
                }
            }
            
            contentLineItemArray[column] = [itemArray componentsJoinedByString:@" "];
            
            contentLineString = [contentLineItemArray componentsJoinedByString:@"\t"];
            
            contentArray[row] = contentLineString;
        }
        
    }
    
    NSString *titleString = [titleArray componentsJoinedByString:@"\t"];
    if (titleString.isValidString) {
        titleString = [NSString stringWithFormat:@"%@\n",titleString];
    }
    
    NSString *contentString = [contentArray componentsJoinedByString:@"\n"];
    
    
    return [NSString stringWithFormat:@"%@%@",titleString,contentString];
}


/**
 * 获取格式化后的加放量信息
 ***/
-(NSString *)getFormatterAddtion_String{
    
    NSMutableArray *titleArray = [NSMutableArray array];
    NSMutableArray *addtionArray = [NSMutableArray array];
    
    NSArray *bodyCategorys = [self.personModel getCategorySizeType:CategorySizeType_Body];
    //获取所有的加放量数据与标题
    for (CategoryModel *category in bodyCategorys) {
        
        for (int i=0; i<[category.addition count]; i++) {
            NSString *title = [NSString stringWithFormat:@"%@%d",category.name,i];
            [titleArray addObject:title];
        }
        
        [addtionArray addObjectsFromArray:[category.addition sortedArrayUsingDescriptors:@[]]];
    }
    
    
    NSMutableString *titleString = [[NSMutableString alloc] init];
    NSMutableString *addtionString = [[NSMutableString alloc]init];
    
    for (int i=0; i<[titleArray count]; i++) {
        NSString *title = [NSString stringWithFormat:@"*%@",titleArray[0]];
        AdditionModel *addition = addtionArray[i];
        
        [titleString appendString:title];
        [addtionString appendFormat:@"    %@",addition.description];
        
        if (i%MaxColumn_Addtion == (MaxColumn_Addtion-1) || (i+1) == [titleArray count]) {
            //一行的最后一个 与 整体的最后一个 ，加回车符
            [titleString appendString:@"\n"];
            [addtionString appendString:@"\n"];
        }else{
            [titleString appendString:@"\t"];
            [addtionString appendString:@"\t"];
        }
    }
    
    NSArray *titleLineArray = [titleString componentsSeparatedByString:@"\n"];
    NSArray *addtionLineArray = [addtionString componentsSeparatedByString:@"\n"];
    
    NSMutableString *contentString = [NSMutableString string];
    for (int i=0; i<[titleLineArray count]; i++) {
        
        NSString *title = titleLineArray[i];
        
        if (!title.isValidString) {
            continue;
        }
        [contentString appendFormat:@"%@\n",title];
        [contentString appendFormat:@"%@\n",addtionLineArray[i]];
    }
    
    return contentString;
}

-(UIImage *)getTitleIcon{
    UIImage *icon;
    UIGraphicsBeginImageContext(CGSizeMake(2, 2));
    
    [COLOR_FOR_ICON setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 2, 2)];
    [path fill];
    
    icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [icon resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5) resizingMode:(UIImageResizingModeTile)];
}

/**
 * 获取成衣尺寸的
 ***/
-(NSArray *)getClothesSizeCategory{
    NSMutableArray *categoryArray = [NSMutableArray arrayWithArray:[self.personModel getCategorySizeType:CategorySizeType_Clothes]];
    
    int flag = 0;
    for (CategoryModel *category in categoryArray) {
        if ([@[Category_Code_CD,Category_Code_CY] containsObject:category.cate]) {
            flag++;
        }
        
        if (flag > 1) {
            [categoryArray removeObject:category];
            break;
        }
    }
    
    return categoryArray;
}

-(void)Category_HasSummer:(BOOL *)hasSummer hasWinter:(BOOL *)hasWinter withCategory:(CategoryModel *)category{
    
    *hasSummer = NO;
    *hasWinter = NO;
    
    [self clothesSizeCategory:category hasSummer:hasSummer hasWinter:hasWinter];
    
    NSArray *containArray = @[Category_Code_CY,Category_Code_CD];
    
    if ([containArray containsObject:category.cate] && (!(*hasSummer) || !(*hasWinter))) {
        NSArray *categoryArray = [self.personModel getCategorySizeType:CategorySizeType_Clothes];
        for (CategoryModel *itemModel in categoryArray) {
            if ([containArray containsObject:itemModel.cate]) {
                [self clothesSizeCategory:itemModel hasSummer:hasSummer hasWinter:hasWinter];
            }
        }
    }
}

-(void)clothesSizeCategory:(CategoryModel *)category hasSummer:(BOOL *)hasSummer hasWinter:(BOOL *)hasWinter{
    if (category.summerCount > 0) {
        *hasSummer = YES;
    }
    
    if (category.winterCount > 0) {
        *hasWinter = YES;
    }
}


@end
