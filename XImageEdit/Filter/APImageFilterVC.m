//
//  APImageFilterVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/8/30.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageFilterVC.h"
#import "UIImage_XMImage.h"

#import "APFilterList.h"
#import "APImageFilterModel.h"
#import "APImageFilterCell.h"
#import "APProgressView.h"


@interface APImageFilterVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>
{
    NSInteger curSelIndx;//滤镜选择
    UIImage *orgScaleImg;//原图缩放
    UIImage *temScaleImg;//改变一个参数时候的原图
    UIImage *desImg;//缩放后的目标图
    
    //模糊、暗角参数
    NSDictionary *blurParam;
    NSDictionary *vignetteParam;
    
    APProgressView *proView;
}
@property (weak, nonatomic) IBOutlet UICollectionView *colView;
@property (weak, nonatomic) IBOutlet UIImageView *showIV;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolBtns;

@property (nonatomic, strong) NSArray *list;
@end

@implementation APImageFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.colView.delegate = self;
    self.colView.dataSource = self;
    curSelIndx = 0;
    blurParam = nil;
    vignetteParam = nil;
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:28/255.0 blue:36/255.0 alpha:1];
    CGFloat total = self.imgOrg.size.width * self.imgOrg.size.height;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageChanged:) name:@"kAPImageEditSecondChanged" object:nil];
    
    UIImage *temImg = self.imgOrg;
    if ( total > 500000) {//显示图片用
        CGFloat scale = sqrt( 500000 / total);
        CGSize size = CGSizeMake(scale*self.imgOrg.size.width, scale*self.imgOrg.size.height);
        temImg = [UIImage scaleImage:self.imgOrg toSize:size];
    }
    temScaleImg = orgScaleImg = desImg = temImg;
    self.showIV.image = desImg;
    
    if (total > 100000) {    //滤镜列表用
        CGFloat scale = sqrt( 500000 / total);
        CGSize size = CGSizeMake(scale*self.imgOrg.size.width, scale*self.imgOrg.size.height);
        temImg = [UIImage scaleImage:self.imgOrg toSize:size];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.list = [APFilterList filterList:temImg];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.colView reloadData];
        });
    });
}
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (APImageFilterModel *model in self.list) {
        if ([fm fileExistsAtPath:model.imgPath]) {
            [fm removeItemAtPath:model.imgPath error:nil];
        }
    }
}

- (void)imageChanged:(NSNotification *)notify {
    NSDictionary *dic = (NSDictionary *)notify.object;
    NSInteger type = [dic[@"type"]integerValue];
    if (type == 1) {
        if ([dic[@"none"]boolValue]) {
            blurParam = nil;
        } else {
            blurParam = dic;
            desImg = dic[@"image"];
            self.showIV.image = desImg;
        }
    }
    if (type == 2) {
        if ([dic[@"none"]boolValue]) {
            vignetteParam = nil;
        } else {
            vignetteParam = dic;
            desImg = dic[@"image"];
            self.showIV.image = desImg;
        }
    }
    temScaleImg = [self temImageWithType:0];
}

#pragma mark - private
- (UIImage *)dealWithImage:(UIImage *)img {
    UIImage *des = img;
    if (curSelIndx > 0) {
        des = [APFilterList imageFilter:img WithType:curSelIndx];
    }
    if (blurParam) {
        des = [self imageWithBlur:des];
    }
    if (vignetteParam) {
        des = [self imageWithVignette:des];
    }
    return des;
}

- (UIImage *)temImageWithType:(NSInteger)type {
    UIImage *temImg = orgScaleImg;
    if (type != 0) {
        temImg = [APFilterList imageFilter:temImg WithType:curSelIndx];
    }
    if (type != 1) {
        temImg = [self imageWithBlur:temImg];
    }
    if (type != 2) {
        temImg = [self imageWithVignette:temImg];
    }
    return temImg;
}

- (UIImage *)imageWithBlur:(UIImage *)img {
    NSInteger type = [blurParam[@"type"]integerValue];
    NSInteger blurLevel = [blurParam[@"blurLevel"]integerValue];
    CGPoint drawCenter = CGPointFromString((NSString *)blurParam[@"drawCenter"]);
    CGFloat blurRadius = [blurParam[@"blurRadius"]floatValue];
    CGFloat blurOffset = [blurParam[@"blurOffset"]floatValue];
    if (type == 1) {//圆
        return [UIImage bluerImage:img blurLevel:blurLevel center:drawCenter radius:blurRadius offset:blurOffset];
    }
    CGFloat rotationAngle = [blurParam[@"rotationAngle"]floatValue];
    return [UIImage bluerImage:_imgOrg blurLevel:blurLevel at:drawCenter with:blurRadius rotation:rotationAngle];
}

- (UIImage *)imageWithVignette:(UIImage *)img {
    CGFloat rangeValue = [vignetteParam[@"range"]floatValue];
    CGFloat intensityValue = [vignetteParam[@"intensity"]floatValue];
    return [UIImage vignetteImage:img radius:rangeValue intensity:intensityValue];
}

- (void)showVC:(NSString *)vcName sbName:(NSString *)sbName {
    id vc = [[UIStoryboard storyboardWithName:sbName bundle:nil]instantiateViewControllerWithIdentifier:vcName];
    [vc setValue:temScaleImg forKey:@"imgOrg"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - collection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    APImageFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"APImageFilterCell" forIndexPath:indexPath];
    [cell updateFilterModel:self.list[indexPath.row]];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = self.colView.bounds.size;
    size.width = 75;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (curSelIndx != indexPath.row) {
        NSInteger oldSel = curSelIndx;
        APImageFilterModel *modelOld = self.list[oldSel];
        modelOld.isSel = NO;
        APImageFilterModel *model = self.list[indexPath.row];
        model.isSel = YES;
        NSIndexPath *oldIndxPath = [NSIndexPath indexPathForRow:oldSel inSection:0];
        [self.colView reloadItemsAtIndexPaths:@[oldIndxPath, indexPath]];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *img = [APFilterList imageFilter:temScaleImg WithType:indexPath.row];
            desImg = img;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showIV.image = img;
            });
        });
        curSelIndx = indexPath.row;
    }
}
#pragma mark - button
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)applyFilter:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    proView = [[[NSBundle mainBundle]loadNibNamed:@"APProgressView" owner:nil options:nil]lastObject];
    [self.view addSubview:proView];
    [proView show];
    
    UIImage *img = [self dealWithImage:self.imgOrg];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kAPImageEditChanged" object:img];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [proView hide];
        proView = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)vignetteClicked:(id)sender {
    temScaleImg = [self temImageWithType:2];
    [self showVC:@"APImageVignetteVC" sbName:@"APImageVignette"];
}
- (IBAction)fuzzyClicked:(id)sender {
    temScaleImg = [self temImageWithType:1];
    [self showVC:@"APImageBlurVC" sbName:@"APImageBlur"];
}
- (IBAction)hideOriginImage:(id)sender {
    self.showIV.image = desImg;
}
- (IBAction)showOrginImage:(id)sender {
    self.showIV.image = self.imgOrg;
}

@end
