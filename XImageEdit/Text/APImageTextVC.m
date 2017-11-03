//
//  APImageTextVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/6.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageTextVC.h"

#import "APImageTextColorCell.h"
#import "APImageTextFontCell.h"

#import "UIColor_XMColor.h"
#import "UIImage_XMImage.h"
#import "APImageTextModel.h"
#import "APImageTextFontModel.h"
#import "APImageColorModel.h"
#import "APImageColorList.h"

#import "APImageTextList.h"
#import "APMiddleSlider.h"
#import "APImageTextInputVC.h"
#import "APImageLabel.h"
#import "Masonry.h"
#import "XMDrawView.h"
#import "SVProgressHUD.h"
#import "APProgressView.h"

@interface APImageTextVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>
{
    UIImage *desImg;
    //图片在imageview的位置
    CGRect rectImgInIV;
    
    NSInteger selType;
    
    NSInteger curSelFont;
    NSInteger curSelColor;
    NSInteger curSelAlignment;
    
    
    APImageTextInputVC *inputVC;
    APImageLabel *labelView;//当前选中的
    NSInteger panDealType;//手势处理类型
    CGRect orgRect;//label位置大小
    CGPoint orgCenter;//label原始中心
    CGPoint orgRBPoint;//右下角的点坐标
    
    CGPoint labelTapOrgPoint;//移动初始位置
    
    CGFloat imgScaleIV;
//    CGPoint translatePoint;//当前平移多少
//    CGFloat rotationAngle;//当前旋转角度
//    CGFloat scaleWidth;//当前缩放长度
    
    
    APProgressView *proView;
}
@property (nonatomic ,strong) NSArray *fontList;
@property (nonatomic ,strong) NSArray *colorList;

//添加的文本
@property (nonatomic ,strong) NSMutableArray *labelList;
@property (nonatomic ,strong) NSMutableArray *textList;

@property (weak, nonatomic) IBOutlet UIImageView *showIV;
@property (weak, nonatomic) IBOutlet UIView *ivBG;
@property (weak, nonatomic) IBOutlet UICollectionView *colView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolBtns;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;


@property (weak, nonatomic) IBOutlet UILabel *aphaVal;
@property (weak, nonatomic) IBOutlet UILabel *aphaText;
@property (weak, nonatomic) IBOutlet UISlider *aphaSlider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *apha_left;
@property (weak, nonatomic) IBOutlet UIView *aphaView;

@property (weak, nonatomic) IBOutlet APMiddleSlider *middleSlider;
@property (weak, nonatomic) IBOutlet APMiddleSlider *middleSlider2;

@end

@implementation APImageTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.colView.delegate = self;
    self.colView.dataSource = self;
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}
- (void)viewDidAppear:(BOOL)animated {
    [self countScaleInIV];
    [self textFont:nil];
    [self updateAphaVal];
}

- (NSMutableArray *)labelList {
    if (!_labelList) {
        _labelList = [NSMutableArray array];
    }
    return _labelList;
}
- (NSMutableArray *)textList {
    if (!_textList) {
        _textList = [NSMutableArray array];
    }
    return _textList;
}
#pragma mark - private
- (void)initData {
    curSelFont = 0;
    curSelColor = 0;
    curSelAlignment = 0;
    orgRect = CGRectZero;
    orgCenter = CGPointZero;
    desImg = self.imgOrg;
    panDealType = -1;
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:28/255.0 blue:36/255.0 alpha:1];
    self.showIV.image = desImg;
    self.fontList = [APImageTextList fontListMode];
    self.colorList = [APImageColorList colorListMode];
    self.middleSlider2.thumbImage = [UIImage imageNamed:@"G2_photo_wzxj"];
    self.middleSlider2.thumbRect = CGRectMake(0, 0, 20, 20);
    self.middleSlider.thumbImage = [UIImage imageNamed:@"G2_photo_wzzj"];
    self.middleSlider.thumbRect = CGRectMake(0, 0, 20, 20);
    [self.aphaSlider setThumbImage:[UIImage imageNamed:@"G2_photo_yan"] forState:UIControlStateNormal];
    
    self.middleSlider.valueChanged = ^(CGFloat val) {
        if (labelView) {
            APImageTextModel *model = self.textList[labelView.tag];
            model.textZ = val;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = model.textH;
            NSDictionary *dic = @{NSParagraphStyleAttributeName:paragraphStyle,
                                  NSKernAttributeName:@(model.textZ),
                                  NSFontAttributeName:[UIFont fontWithName:model.fontName size:model.fontSize]};
            [labelView setTextAttr:dic];
            [self updateModel:model.text];
        }
    };
    self.middleSlider2.valueChanged = ^(CGFloat val) {
        if (labelView) {
            APImageTextModel *model = self.textList[labelView.tag];
            model.textH = val;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = model.textH;
            NSDictionary *dic = @{NSParagraphStyleAttributeName:paragraphStyle,
                                  NSKernAttributeName:@(model.textZ),
                                  NSFontAttributeName:[UIFont fontWithName:model.fontName size:model.fontSize]};
            [labelView setTextAttr:dic];
            [self updateModel:model.text];
        }
    };
}

- (void)countScaleInIV {
    CGRect rect = self.showIV.bounds;
    CGSize imgSize = self.imgOrg.size;
    CGSize sizeIV = self.showIV.bounds.size;
    CGFloat scaleW = imgSize.width / sizeIV.width;
    CGFloat scaleH = imgSize.height / sizeIV.height;
    CGSize sizeImgInIV = sizeIV;
    imgScaleIV = scaleH;
    if (scaleH < scaleW) {
        imgScaleIV = scaleW;
        sizeImgInIV.height = imgSize.height / imgSize.width * sizeIV.width;
    } else {
        sizeImgInIV.width = imgSize.width / imgSize.height * sizeIV.height;
    }
    CGFloat x = (rect.size.width - sizeImgInIV.width)/2;
    CGFloat y = (rect.size.height - sizeImgInIV.height)/2;
    rectImgInIV = CGRectMake(x, y, sizeImgInIV.width, sizeImgInIV.height);
}

//imageview坐标系转到图片坐标系
- (NSArray *)coordinatorIV2Img:(NSArray *)list {
    NSMutableArray *desList = [NSMutableArray arrayWithCapacity:list.count];
    for (APImageTextModel *model in list) {
        APImageTextModel *newModel = [model copy];
        CGFloat space = 24;
        CGRect rect = CGRectMake(newModel.rect.origin.x-rectImgInIV.origin.x + space, newModel.rect.origin.y-rectImgInIV.origin.y+space, newModel.rect.size.width - space*2, newModel.rect.size.height-space*2);
        newModel.rect = rect;
        [desList addObject:newModel];
    }
    return desList;
}
#pragma mark text label
//全不选label
- (void)unselectAllLabel {
    for (APImageLabel *label in self.labelList) {
        label.isSel = NO;
    }
    labelView = nil;
    panDealType = -1;
    orgRect = CGRectZero;
}
//选中某个label的tag
- (void)selectLabel:(NSInteger)tag {
    for (APImageLabel *label in self.labelList) {
        label.isSel = (label.tag == tag);
    }
}

#pragma mark label add and changed text
//添加label
- (void)addText2Image:(NSString *)str {
    self.applyBtn.enabled = YES;
    [self unselectAllLabel];
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"APImageLabel" owner:nil options:nil];
    APImageLabel *label = [nibView objectAtIndex:0];
    labelView = label;
    APImageTextModel *model = [self defaultTextModel:str];
    label.tag = self.textList.count;
    
    [self.textList addObject:model];
    [self.labelList addObject:label];
    [self.ivBG addSubview:label];
    [self makeLabel:labelView AtRect:model.rect];
    
    __weak typeof(APImageLabel) *weakLabel = label;
    __weak typeof(self) weakSelf = self;
    //缩放旋转
    label.tapType = ^(NSInteger type) {
        panDealType = type;
        if (type == 0) {
            [weakSelf selectLabel:weakLabel.tag];
            labelView = label;
            weakLabel.isSel = YES;
        }
        if (type == 1) {
            
        }
    };
    label.editBlock = ^{
        APImageTextInputVC *vc = [[UIStoryboard storyboardWithName:@"APImageText" bundle:nil]instantiateViewControllerWithIdentifier:@"APImageTextInputVC"];
        vc.applyBlock = ^(NSString *str) {
            [weakSelf updateModel:str];
            inputVC = nil;
        };
        vc.isAdd = NO;
        vc.defalutStr = model.text;
        vc.view.frame = self.view.bounds;
        inputVC = vc;
        [weakSelf.view addSubview:vc.view];
    };
    label.delBlock = ^{
        [self.textList removeObjectAtIndex:weakLabel.tag];
        [self.labelList removeObject:weakLabel];
        if (self.labelList.count <= 0) {
            self.applyBtn.enabled = NO;
        }
        [weakLabel removeFromSuperview];
        labelView = nil;
    };
}

//默认label的model信息
- (APImageTextModel *)defaultTextModel:(NSString *)str {
    APImageTextModel *model = [APImageTextModel new];
    model.text = str;
    model.textH = 0;
    model.textZ = 0;
    model.color = @"ffffff";
    model.colorAlpha = 1.0;
    model.fontName = @".SFUIText";
    model.fontSize = 17;
    model.alignment = 0;
    model.angle = 0;
    model.scale = 1;
    CGSize size = [str boundingRectWithSize:self.ivBG.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]} context:nil].size;
    CGPoint center = self.ivBG.center;
    CGFloat space = 24;
    CGRect rect = CGRectMake(center.x-size.width/2-space*2, 100, size.width+space*2, size.height+space*2);
    model.rect = rect;
    return model;
}

//返回字体size，   指定字间距、行间距
- (CGSize)sizeFromTextModel:(APImageTextModel *)model {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = model.textH;
    NSDictionary *dic = @{NSParagraphStyleAttributeName:paragraphStyle,
                          NSKernAttributeName:@(model.textZ),
                          NSFontAttributeName:[UIFont fontWithName:model.fontName size:model.fontSize]};
    return [model.text boundingRectWithSize:self.ivBG.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
}

//创建label的约束
- (void)makeLabel:(APImageLabel *)label AtRect:(CGRect)rect {
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ivBG).mas_offset(rect.origin.x);
        make.top.equalTo(self.ivBG).mas_offset(rect.origin.y);
        make.right.equalTo(self.ivBG.mas_right).mas_offset(-rect.origin.x);
        make.height.mas_equalTo(rect.size.height);
    }];
    [self.view setNeedsLayout];
}
//更新label的约束
- (void)updateLabel:(APImageLabel *)label AtRect:(CGRect)rect {
    CGFloat total = self.ivBG.bounds.size.width;
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ivBG).mas_offset(rect.origin.x);
        make.top.equalTo(self.ivBG).mas_offset(rect.origin.y);
        make.right.equalTo(self.ivBG.mas_right).mas_offset(-(total - rect.size.width - rect.origin.x));
        make.height.mas_equalTo(rect.size.height);
    }];
    [self.view setNeedsLayout];
}

#pragma mark deal label
//手势处理。移动、旋转和缩放
- (void)dealWith:(CGPoint)point state:(UIGestureRecognizerState)state{
    
    if (state == UIGestureRecognizerStateBegan ) {
        labelTapOrgPoint = point;
        APImageTextModel *model = self.textList[labelView.tag];
        orgRect = model.rect;
        orgCenter = CGPointMake(orgRect.origin.x+orgRect.size.width/2, orgRect.origin.y+orgRect.size.height/2);
        orgRBPoint = CGPointMake(orgRect.origin.x+orgRect.size.width, orgRect.origin.y+orgRect.size.height);
        
    }
    if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded) {
        if (panDealType == 2) {
//            NSLog(@"rotaion：%@", NSStringFromCGPoint(point));
            //三点计算角度、缩放
            CGFloat angle = [self angleFrom3Point:orgCenter p2:orgRBPoint p3:point];//郑玄角度值
            CGFloat scale = [self scaleFrom3Point:orgCenter p2:orgRBPoint p3:point];
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformRotate(transform, angle);
            transform = CGAffineTransformScale(transform, scale, scale);
            labelView.transform = transform;
            // 3点计算缩放和旋转。
            if ( state == UIGestureRecognizerStateEnded) {
                panDealType = -1;
                APImageTextModel *model = self.textList[labelView.tag];
                model.angle = angle;
                model.scale = scale;
            }
        }
        if (panDealType == 1) {
            CGSize size = CGSizeMake(point.x-labelTapOrgPoint.x, point.y-labelTapOrgPoint.y);
            CGPoint orgPoint = orgRect.origin;
            CGPoint desPoint = CGPointMake(orgRect.origin.x+size.width, orgRect.origin.y+size.height);

            [labelView mas_updateConstraints:^(MASConstraintMaker *make) {
                CGFloat total = self.ivBG.bounds.size.width;
                CGFloat offset = total - (desPoint.x + orgRect.size.width);
                make.right.equalTo(self.ivBG.mas_right).mas_offset(-offset);
                make.left.equalTo(self.ivBG).mas_offset(orgPoint.x+size.width);
                make.top.equalTo(self.ivBG).mas_offset(orgPoint.y+size.height);
            }];
            if (state == UIGestureRecognizerStateEnded) {
                orgRect.origin = desPoint;
                APImageTextModel *model = self.textList[labelView.tag];
                model.rect = orgRect;
                panDealType = -1;
            }
        }
    }
}

//中心点   右下角   手指点
- (CGFloat)angleFrom3Point:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 {
    CGPoint v1 = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    CGPoint v2 = CGPointMake(p3.x - p1.x, p3.y - p1.y);
    CGFloat sin = (v1.x*v2.y - v1.y*v2.x) / (sqrt(v1.x*v1.x+v1.y*v1.y) * sqrt(v2.x*v2.x+v2.y*v2.y));
    CGFloat sinAngle = asin(sin);
    return sinAngle;
}

//中心点   右下角   手指点
- (CGFloat)scaleFrom3Point:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 {
    CGPoint v1 = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    CGPoint v2 = CGPointMake(p3.x - p1.x, p3.y - p1.y);
    CGFloat scale = sqrt(v2.x*v2.x+v2.y*v2.y) / sqrt(v1.x*v1.x+v1.y*v1.y);
    return scale;
}

//label坐标系上的点转为父类坐标系上的点
- (CGPoint)labelPointToBG:(CGPoint)p atSuper:(CGRect)rect {
    CGPoint bgPoint = rect.origin;
    return CGPointMake(p.x+bgPoint.x, p.y+bgPoint.y);
}

//更新label的对齐方式
- (void)updateLabelAlignment {
    if (labelView) {
        [labelView nextAlignment];
        curSelAlignment = [labelView textAlignment];
        curSelAlignment--;
        [self updateSelType];
    }
}

//更新某个label和其model的文字
- (void)updateModel:(NSString *)str {
    APImageTextModel *model = self.textList[labelView.tag];
    model.text = str;
    CGRect rect = model.rect;
    CGSize size = [self sizeFromTextModel:model];
    
    CGFloat space = 24;
    rect.size = CGSizeMake(size.width+space*2, size.height+space*2);
    model.rect = rect;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = model.textH;
    NSDictionary *dic = @{NSParagraphStyleAttributeName:paragraphStyle,
                          NSKernAttributeName:@(model.textZ),
                          NSFontAttributeName:[UIFont fontWithName:model.fontName size:model.fontSize]};
    [labelView setText:str attr:dic];
    [self updateLabel:labelView AtRect:rect];
}

//更新model和label的颜色透明度
- (void)updateModelAlpha:(CGFloat)alpha {
    if (labelView) {
        APImageTextModel *model = self.textList[labelView.tag];
        model.colorAlpha = alpha;
        [labelView setTextColorAlpha:alpha];
    }
}

#pragma mark font and color
//更新图名都值
- (void)updateAphaVal {
    CGFloat maxVal = self.aphaSlider.maximumValue;
    CGFloat minVal = self.aphaSlider.minimumValue;
    CGFloat totalVal = maxVal - minVal;
    CGFloat curVal = self.aphaSlider.value - minVal;
    CGFloat totalLen = self.aphaSlider.bounds.size.width - 30;
    CGFloat curLen = totalLen * curVal / totalVal;
    NSString *str = self.aphaVal.text = [NSString stringWithFormat:@"%.2f", self.aphaSlider.value];
    CGSize size = [str boundingRectWithSize:CGSizeMake(60, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size;
    CGFloat left = curLen - size.width/2 + 14;
    self.apha_left.constant = left;
}

//更新tool选项。字体、颜色、对齐方式选中的
- (void)updateSelType {
    UIButton *alignmentBtn = nil;
    self.middleSlider.hidden = self.middleSlider2.hidden = (selType != 0);
    self.aphaView.hidden = (selType != 1);
    for (UIButton *btn in self.toolBtns) {
        btn.selected = btn.tag == selType;
        if (btn.tag == 2) {
            alignmentBtn = btn;
        }
    }
    if (selType == 2) {
        curSelAlignment++;
        curSelAlignment %= 3;
        NSString *selName = nil;
        NSString *normalName = nil;
        switch (curSelAlignment) {
            case 0:
                normalName = @"G2_photo_wzzdq";
                selName = @"G2_photo_wzxzzdq";
                break;
            case 1:
                normalName = @"G2_photo_wzzjdq";
                selName = @"G2_photo_wzxzzjdq";
                break;
            case 2:
                normalName = @"G2_photo_wzydq";
                selName = @"G2_photo_wzxzydq";
                break;
            default:
                break;
        }
        [alignmentBtn setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
        [alignmentBtn setImage:[UIImage imageNamed:selName] forState:UIControlStateSelected];
    }
}
#pragma mark - collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (selType == 1) {
        return self.colorList.count;
    }
    return self.fontList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (selType == 1) {
        APImageTextColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"APImageTextColorCell" forIndexPath:indexPath];
        APImageColorModel *model = self.colorList[indexPath.row];
        [cell updateCellWithModel:model];
        return cell;
    }
    APImageTextFontCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"APImageTextFontCell" forIndexPath:indexPath];
    APImageTextFontModel *model = self.fontList[indexPath.row];
    [cell updateCellWithModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (selType == 0) {
        if (curSelFont != indexPath.row) {
            NSIndexPath *oldIndxPath = [NSIndexPath indexPathForRow:curSelFont inSection:0];
            APImageTextFontModel *modelOld = self.fontList[curSelFont];
            modelOld.isSel = NO;
            APImageTextFontModel *model = self.fontList[indexPath.row];
            model.isSel = YES;
            [self.colView reloadItemsAtIndexPaths:@[oldIndxPath, indexPath]];
            curSelFont = indexPath.row;
            NSLog(@"选择字体改变");
            if (labelView) {
                APImageTextModel *modelText = self.textList[labelView.tag];
                modelText.fontName = model.fontName;
                [labelView setTextFontName:modelText.fontName];
            }
        }
    }
    if (selType == 1) {
        if (curSelColor != indexPath.row) {
            NSIndexPath *oldIndxPath = [NSIndexPath indexPathForRow:curSelColor inSection:0];
            APImageColorModel *modelOld = self.colorList[curSelColor];
            modelOld.isSel = NO;
            APImageColorModel *model = self.colorList[indexPath.row];
            model.isSel = YES;
            [self.colView reloadItemsAtIndexPaths:@[oldIndxPath, indexPath]];
            curSelColor = indexPath.row;
            NSLog(@"选择字体颜色改变");
            if (labelView) {
                APImageTextModel *modelText = self.textList[labelView.tag];
                modelText.color = model.colorHex;
                [labelView setTextColor:[UIColor colorWithHexString:model.colorHex]];
            }
        }
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (selType == 0) {
        return CGSizeMake(54, collectionView.bounds.size.height);
    }
    return CGSizeMake(30, 48);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (selType == 0) {
        return 15;
    }
    return 0;
}
#pragma mark - button
- (IBAction)imgPanHandle:(id)sender {
    UIPanGestureRecognizer *gr = (UIPanGestureRecognizer *)sender;
    CGPoint point = [gr locationInView:self.ivBG];
    if (panDealType > 0) {
        [self dealWith:point state:gr.state];
    }
}
- (IBAction)imgVIewBGTap:(id)sender {
    [self unselectAllLabel];
}

- (IBAction)aphaValueChanged:(id)sender {
    [self updateModelAlpha:self.aphaSlider.value];
    [self updateAphaVal];
}
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)textFont:(id)sender {
    selType = 0;
    [self.colView reloadData];
    [self updateSelType];
}
- (IBAction)textColor:(id)sender {
    selType = 1;
    [self.colView reloadData];
    [self updateSelType];
}
- (IBAction)textAlignment:(id)sender {
    selType = 2;
    [self updateSelType];
    [self updateLabelAlignment];
}
- (IBAction)addText:(id)sender {
    APImageTextInputVC *vc = [[UIStoryboard storyboardWithName:@"APImageText" bundle:nil]instantiateViewControllerWithIdentifier:@"APImageTextInputVC"];
    vc.applyBlock = ^(NSString *str) {
        [self addText2Image:str];
        inputVC = nil;
    };
    vc.isAdd = YES;
    vc.view.frame = self.view.bounds;
    inputVC = vc;
    [self.view addSubview:vc.view];
}
- (IBAction)applyText:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
//    [SVProgressHUD show];
    
    proView = [[[NSBundle mainBundle]loadNibNamed:@"APProgressView" owner:nil options:nil]lastObject];
    [self.view addSubview:proView];
    [proView show];
    
    XMDrawView *temView = [[XMDrawView alloc]init];
//    temView.hidden = YES;
    temView.scaleInImage = imgScaleIV;
    temView.frame = CGRectMake(0, 0, _imgOrg.size.width, _imgOrg.size.height);
    [self.view insertSubview:temView atIndex:-1];
    temView.image = self.imgOrg;
    NSArray *list = [self coordinatorIV2Img:self.textList];
    temView.textList = list;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *img = [temView imgFromView];
        self.showIV.image = img;
        btn.enabled = YES;
        [proView hide];
        proView = nil;
        if (img) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"kAPImageEditChanged" object:img];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}
- (IBAction)showTextImg:(id)sender {
    self.showIV.image = desImg;
}
- (IBAction)showOrgImg:(id)sender {
    self.showIV.image = self.imgOrg;
}
@end
