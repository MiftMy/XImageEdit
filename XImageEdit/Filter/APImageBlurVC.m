//
//  APImageFuzzyVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/5.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageBlurVC.h"

#import "UIImage_XMImage.h"
#import "APImageBlurBoard.h"

@interface APImageBlurVC ()
{
    UIImage *desImg;
    
    NSInteger blurType;
    CGFloat blurRadius;     // 半径，单位像素。透明区域
    CGFloat blurOffset;     // 半径向外偏移，单位像素。半透明区域
    CGPoint drawCenter;      // 图片中心，单位像素
    NSInteger blurLevel;    //模糊强度
    CGSize sizeImg;         //图片大小
    CGFloat rotationAngle;  //旋转角度
    
    CGPoint grBegin;    //屏幕点击区域
}
@property (weak, nonatomic) IBOutlet APImageBlurBoard *blurBoard;
@property (weak, nonatomic) IBOutlet UILabel *rangeText;
@property (weak, nonatomic) IBOutlet UILabel *rangeVal;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;

@property (weak, nonatomic) IBOutlet UILabel *intensityText;
@property (weak, nonatomic) IBOutlet UILabel *intensityVal;
@property (weak, nonatomic) IBOutlet UISlider *intensitySlider;

@property (weak, nonatomic) IBOutlet UIImageView *showIV;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *range_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *intensity_left;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolBtns;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *board_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *board_right;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *board_bottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *board_top;

@end

@implementation APImageBlurVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    desImg = self.imgOrg;
    self.showIV.image = desImg;
    self.showIV.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:28/255.0 blue:36/255.0 alpha:1];
    [self.rangeSlider setThumbImage:[UIImage imageNamed:@"G2_photo_yan"] forState:UIControlStateNormal];
    [self.intensitySlider setThumbImage:[UIImage imageNamed:@"G2_photo_yan"] forState:UIControlStateNormal];
    [self resetBlurData];
    
    self.rangeSlider.minimumValue = 10;
    self.rangeSlider.maximumValue = MAX(sizeImg.width, sizeImg.height);
    self.rangeSlider.value = blurRadius;
    
    self.intensitySlider.minimumValue = 0;
    self.intensitySlider.maximumValue = 100;
    self.intensitySlider.value = blurLevel;
    
    [self updateImage];
    
    [self updateBlurboardFrame];
    [self updateCoordinatesFromImage2V];
    __weak typeof(self) weakSelf = self;
    self.blurBoard.touchBeginBlock = ^{
        self.showIV.image = self.imgOrg;
    };
    self.blurBoard.touchEndBlock = ^{
        [self updateCoordinatesFromV2Image];
        self.rangeSlider.value = blurRadius;
        [self updateRange];
        [weakSelf updateImage];
    };
    
    [self updateRange];
    [self updateIntensity];
}
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateBlurBtnState];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)resetBlurData {
    blurType = 0;
    blurLevel = 50;
    rotationAngle = 0.0;
    sizeImg = _imgOrg.size;
    blurRadius = sizeImg.width/2;
    CGFloat minVal = MIN(sizeImg.width, sizeImg.height);
    blurOffset = minVal * 0.3;
    if (blurOffset > 150) {
        blurOffset = 150;
    }
    drawCenter = CGPointMake(sizeImg.width/2, sizeImg.height/2);
}

- (void)updateImage {
    switch (blurType) {
        case 0:
            desImg = _imgOrg;
            break;
        case 1:
            desImg = [UIImage bluerImage:_imgOrg blurLevel:blurLevel center:drawCenter radius:blurRadius offset:blurOffset];
            break;
        case 2:
            desImg = [UIImage bluerImage:_imgOrg blurLevel:blurLevel at:drawCenter with:blurRadius rotation:rotationAngle];
            break;
        default:
            break;
    }
    self.showIV.image = desImg;
}

- (void)updateIntensity {
    CGFloat curVal = self.intensitySlider.value;
    NSString *str = [NSString stringWithFormat:@"%.0f", curVal];
    self.intensityVal.text = str;
    CGSize size = [str boundingRectWithSize:CGSizeMake(60, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    CGFloat minVal = self.intensitySlider.minimumValue;
    CGFloat maxVal = self.intensitySlider.maximumValue;
    CGFloat totalWidth = self.intensitySlider.bounds.size.width - 30;
    CGFloat persent = curVal / (maxVal - minVal);
    CGFloat curWidth = persent * totalWidth;
    CGFloat left = curWidth - size.width/2 + 14;
    self.intensity_left.constant = left;
}
- (void)updateRange {
    CGFloat curVal = self.rangeSlider.value;
    NSString *str = [NSString stringWithFormat:@"%.0f", curVal];
    self.rangeVal.text = str;
    CGSize size = [str boundingRectWithSize:CGSizeMake(60, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    CGFloat minVal = self.rangeSlider.minimumValue;
    CGFloat maxVal = self.rangeSlider.maximumValue;
    CGFloat totalWidth = self.rangeSlider.bounds.size.width - 30;
    CGFloat persent = curVal / (maxVal - minVal);
    CGFloat curWidth = persent * totalWidth;
    CGFloat left = curWidth - size.width/2 + 14;
    self.range_left.constant = left;
}
#pragma mark - private
- (void)updateBlurboardFrame {
    CGSize sizeBB = self.blurBoard.bounds.size;
    CGFloat scaleW = sizeImg.width / sizeBB.width;
    CGFloat scaleH = sizeImg.height / sizeBB.height;
    CGSize size = sizeBB;
    if (scaleH < scaleW) {
        size.height = sizeImg.height / sizeImg.width * sizeBB.width;
        CGFloat offset = (sizeBB.height - size.height)/2;
        self.board_top.constant = offset;
        self.board_bottom.constant = -offset;
    } else {
        size.width = sizeImg.width / sizeImg.height * sizeBB.height;
        CGFloat offset = (sizeBB.width - size.width)/2;
        self.board_left.constant = offset;
        self.board_right.constant = -offset;
    }
}
//画板坐标转到图像坐标
- (void)updateCoordinatesFromV2Image {
    CGSize boardSize = self.blurBoard.bounds.size;
    CGFloat scale = sizeImg.width / boardSize.width;
    blurRadius = self.blurBoard.radius * scale;
    CGFloat h = self.blurBoard.bounds.size.height;
    drawCenter = CGPointMake(self.blurBoard.drawCenter.x*scale, (h-self.blurBoard.drawCenter.y)*scale);
    blurOffset = self.blurBoard.gradientWith * scale;
    rotationAngle = self.blurBoard.rotationAngle;
}
//图像坐标转到画板坐标
- (void)updateCoordinatesFromImage2V {
    CGSize boardSize = self.blurBoard.bounds.size;
    CGFloat scale = sizeImg.width / boardSize.width;
    CGFloat vRadius = blurRadius / scale;
    CGFloat vOffset = blurOffset / scale;
    CGFloat h = self.blurBoard.bounds.size.height;
    CGPoint vCenter = CGPointMake(drawCenter.x/scale, h-drawCenter.y/scale);
    self.blurBoard.drawCenter = vCenter;
    self.blurBoard.radius = vRadius;
    self.blurBoard.gradientWith = vOffset;
    self.blurBoard.rotationAngle = rotationAngle;
}
- (void)updateBlurImage {
    [self updateCoordinatesFromImage2V];
    [self updateImage];
}

- (void)updateBlurBtnState {
    for (UIButton *btn in self.toolBtns) {
        btn.selected = blurType==btn.tag;
    }
    self.sliderView.hidden = (blurType == 0);
    self.applyBtn.enabled = (blurType != 0);
}
#pragma mark - button
- (IBAction)rangeValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    blurRadius = slider.value;
    [self updateBlurImage];
    [self updateRange];
}
- (IBAction)intensityValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    blurLevel = slider.value;
    [self updateBlurImage];
    [self updateIntensity];
}

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)noneFilter:(id)sender {
    if (blurType != 0) {
        blurType = 0;
        [self updateBlurImage];
        [self updateBlurBtnState];
    }
}
- (IBAction)circlyFuzzy:(id)sender {
    if (blurType != 1) {
        blurType = 1;
        self.blurBoard.type = APBlurTypeCircle;
        [self.blurBoard hideMask];
        [self updateBlurImage];
        [self updateBlurBtnState];
    }
}
- (IBAction)lineFuzzy:(id)sender {
    if (blurType != 2) {
        blurType = 2;
        self.blurBoard.type = APBlurTypeLine;
        [self.blurBoard hideMask];
        [self updateBlurImage];
        [self updateBlurBtnState];
    }
}
- (IBAction)applyClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    /*
     NSInteger blurType;
     CGFloat blurRadius;     // 半径，单位像素。透明区域
     CGFloat blurOffset;     // 半径向外偏移，单位像素。半透明区域
     CGPoint drawCenter;      // 图片中心，单位像素
     NSInteger blurLevel;    //模糊强度
     CGSize sizeImg;         //图片大小
     CGFloat rotationAngle;  //旋转角度
     */
    NSDictionary *dic = @{@"type":@(1), @"none":@(blurType==0), @"image":desImg, @"blurType":@(blurType), @"blurOffset":@(blurOffset), @"blurRadius":@(blurRadius), @"drawCenter":NSStringFromCGPoint(drawCenter), @"blurLevel":@(blurLevel), @"rotationAngle":@(rotationAngle)};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kAPImageEditSecondChanged" object:dic];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)showFilterImage:(id)sender {
    self.showIV.image = desImg;
}
- (IBAction)showOrgImage:(id)sender {
    self.showIV.image = self.imgOrg;
}
@end
