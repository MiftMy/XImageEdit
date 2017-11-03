//
//  APImageCutVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/8/30.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageCutVC.h"
#import "APImageCutCell.h"
#import "APImageCutModel.h"
#import "APImageCutScaleList.h"
#import "UIImage_XMImage.h"
#import "APMediaManager.h"
#import "SGInfoAlert.h"

#import "APCalibrationView.h"
#import "APCutSelView.h"

@interface APImageCutVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UIScrollViewDelegate
>
{
    CGRect maxFrameRect;//图片裁剪最大裁剪框
    
    NSInteger currentSel;//collection view选中哪个
    CGFloat curScale;//裁剪框宽高比例
    CGFloat rotationAngle;//旋转角度
    
    CGRect imgRectInIV;//图片在ImageView中的位置大小。
    //裁剪区域frame
    CGPoint beginPoint;//点击起始点
    NSInteger frameDir;//点击位置
    CGFloat activeWith;//点击有效宽、高
    CGRect currentRect;//裁剪框当前rect
    
    CGRect frameRect;
    
    BOOL isAppear;
}
@property (weak, nonatomic) IBOutlet UICollectionView *colView;

@property (weak, nonatomic) IBOutlet APCutSelView *imgShowView;


@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

//角度
@property (weak, nonatomic) IBOutlet APCalibrationView *angleView;
@property (weak, nonatomic) IBOutlet UILabel *angleText;

@property (nonatomic, strong) UIImage *imgDes;
@property (nonatomic, strong) NSArray *list;
@end

@implementation APImageCutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.colView.delegate = self;
    self.colView.dataSource = self;
    [self initData];
}
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    isAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    isAppear = NO;
}
#pragma mark - private
- (void)initData {
    currentSel = 0;
    rotationAngle = 0;
    activeWith = 40;
    _imgDes = _imgOrg;
    curScale = -1;
    imgRectInIV = CGRectZero;
    isAppear = NO;
    self.imgShowView.orgImg = _imgOrg;
    self.list = [APImageCutScaleList scaleList];

    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:28/255.0 blue:36/255.0 alpha:1];
    __weak typeof(self) weakSelf = self;
    self.angleView.valueChangedBlock = ^(NSInteger val) {
        if (isAppear) {
            weakSelf.angleText.text = [NSString stringWithFormat:@"%d", val];
            weakSelf.imgShowView.rotationAngle = val/180.0*M_PI;
        }
        
        NSLog(@"%d", val);
        
    };
    
}

- (void)delayDismiss:(CGFloat)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - collection 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    APImageCutCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"APImageCutCell" forIndexPath:indexPath];
    [cell updateCellWithModel:self.list[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger oldSel = currentSel;
    APImageCutModel *modelOld = self.list[oldSel];
    modelOld.isSel = NO;
    APImageCutModel *model = self.list[indexPath.row];
    model.isSel = YES;
    curScale = model.scale;
    if (indexPath.row == 1) {
        curScale = _imgDes.size.width / _imgDes.size.height;
    }
    self.imgShowView.whRate = curScale;
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldSel inSection:0];
    [self.colView reloadItemsAtIndexPaths:@[oldIndexPath, indexPath]];
    self.applyBtn.enabled = YES;
    currentSel = indexPath.row;
}

#pragma mark - button
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)rotationRight:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    rotationAngle += M_PI_2;
    self.imgShowView.transform = CGAffineTransformMakeRotation(rotationAngle);
    self.imgShowView.angle = rotationAngle;
    self.applyBtn.enabled = YES;
    btn.enabled = YES;
}
- (IBAction)rotationLeft:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    self.applyBtn.enabled = YES;
    rotationAngle -= M_PI_2;
    self.imgShowView.transform = CGAffineTransformMakeRotation(rotationAngle);
    self.imgShowView.angle = rotationAngle;
    btn.enabled = YES;
}
- (IBAction)saveClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    [self.imgShowView imageFromCurrent:^(UIImage *img) {
        btn.enabled = YES;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kAPImageEditChanged" object:img];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)mirrorUpDown:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    self.applyBtn.enabled = YES;
    APCutSelView *view = [[APCutSelView alloc]init];
    view.orgImg = self.imgOrg;
    view.rotationAngle = self.imgShowView.rotationAngle;
    view.whRate = self.imgShowView.whRate;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *tem = [UIImage upDownMirror:self.imgDes];
        self.imgDes = tem;
        dispatch_async(dispatch_get_main_queue(), ^{
           
            btn.enabled = YES;
        });
    });
}
- (IBAction)mirrorLeftRight:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    self.applyBtn.enabled = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *tem = [UIImage leftRightMirror:self.imgDes];
        self.imgDes = tem;
        dispatch_async(dispatch_get_main_queue(), ^{
           
            btn.enabled = YES;
        });
    });
}
@end
