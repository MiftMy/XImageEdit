//
//  APImageDrawboardVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageDrawboardVC.h"
#import "APImageColorModel.h"
#import "APImageColorList.h"
#import "APImageDrawColorCell.h"
#import "APShowDrawView.h"

#import "APImageDrawboard.h"
//#import "SVProgressHUD.h"

@interface APImageDrawboardVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>
{
    UIImage *desImg;
    CGRect imgRect;//图片在UIImageView的位置大小
    
    NSInteger toolType;//功能
    NSInteger curSelColor;//当前选择颜色引索
    CGFloat curPanWidth;//画笔
    CGFloat curErasewidth;//擦除
    
    
    CGPoint offsetScrl;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *colView;

@property (weak, nonatomic) IBOutlet UILabel *sizeText;
@property (weak, nonatomic) IBOutlet UILabel *sizeVal;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
@property (weak, nonatomic) IBOutlet UIView *sizeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeVal_left;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolBtns;
@property (weak, nonatomic) IBOutlet APImageDrawboard *drawBoard;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

@property (nonatomic, strong) NSArray *colorList;
@end

@implementation APImageDrawboardVC
#pragma mark - implementation
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    toolType = 0;
    curSelColor = 0;
    curErasewidth = 4;
    curPanWidth = 4;
    self.colView.delegate = self;
    self.colView.dataSource = self;
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:28/255.0 blue:36/255.0 alpha:1];
    desImg = self.imgOrg;
    self.drawBoard.orgImg = desImg;
    self.colorList = [APImageColorList colorListMode];
    APImageColorModel *model = self.colorList[0];
    self.drawBoard.strokeColor = model.colorHex;
    self.drawBoard.lineWidth = curPanWidth;
    [self.sizeSlider setThumbImage:[UIImage imageNamed:@"G2_photo_yan"] forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    self.drawBoard.gestureDidBlock = ^{
        weakSelf.applyBtn.enabled = YES;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}
- (void)viewDidAppear:(BOOL)animated {
    [self dealwithToolType:toolType];
}

#pragma mark - private

- (void)dealwithToolType:(NSInteger)type {
    toolType = type;
    self.drawBoard.drawType = type;
    for (UIButton *btn in self.toolBtns) {
        btn.selected = (btn.tag == type);
    }
    switch (type) {
        case 0:
            self.sizeSlider.minimumValue = 5;
            self.sizeSlider.maximumValue = 50;
            self.sizeSlider.value = curPanWidth;
            break;
        case 1:
            self.sizeSlider.minimumValue = 2;
            self.sizeSlider.maximumValue = 50;
            self.sizeSlider.value = curErasewidth;
            break;
        case 2:
            [self.drawBoard undo];
            break;
        default:
            break;
    }
    [self updateSizeValUI];
}
- (void)updateSizeVal:(CGFloat)val {
    switch (toolType) {
        case 0:
            curPanWidth = val;
            break;
        case 1:
            curErasewidth = val;
            break;
        default:
            break;
    }
    self.drawBoard.lineWidth = val;
}
- (void)updateSizeValUI {
    CGFloat maxVal = self.sizeSlider.maximumValue;
    CGFloat minVal = self.sizeSlider.minimumValue;
    CGFloat totalVal = maxVal - minVal;
    CGFloat curVal = self.sizeSlider.value - minVal;
    CGFloat totalLen = self.sizeSlider.bounds.size.width - 30;
    CGFloat curLen = totalLen * curVal / totalVal;
    NSString *str = self.sizeVal.text = [NSString stringWithFormat:@"%.0f", self.sizeSlider.value];
    CGSize size = [str boundingRectWithSize:CGSizeMake(60, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size;
    CGFloat left = curLen - size.width/2 + 14;
    self.sizeVal_left.constant = left;
}
#pragma mark - collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorList.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    APImageDrawColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"APImageDrawColorCell" forIndexPath:indexPath];
    APImageColorModel *model = self.colorList[indexPath.row];
    [cell updateCellWithModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (curSelColor != indexPath.row) {
        NSIndexPath *oldIndxPath = [NSIndexPath indexPathForRow:curSelColor inSection:0];
        APImageColorModel *modelOld = self.colorList[curSelColor];
        modelOld.isSel = NO;
        APImageColorModel *model = self.colorList[indexPath.row];
        model.isSel = YES;
        [self.colView reloadItemsAtIndexPaths:@[oldIndxPath, indexPath]];
        curSelColor = indexPath.row;
        self.drawBoard.strokeColor = model.colorHex;
        NSLog(@"选择字体颜色改变");
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(30, 48);
}

#pragma mark - button
- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self updateSizeVal:slider.value];
    [self updateSizeValUI];
}

- (IBAction)toolChanged:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self dealwithToolType:btn.tag];
}

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)applyClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;

    UIImage *img = self.drawBoard.desImg;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kAPImageEditChanged" object:img];
    btn.enabled = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showOrgImage:(id)sender {
    self.drawBoard.isShowOrg = YES;
}
- (IBAction)showDrawImage:(id)sender {
    self.drawBoard.isShowOrg = NO;
}
@end
