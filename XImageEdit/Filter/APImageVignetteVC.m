//
//  APImageVignetteVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/5.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageVignetteVC.h"
#import "UIImage_XMImage.h"

@interface APImageVignetteVC ()
{
    UIImage *desImg;
    UIImage *temOrg;
    CGFloat rangeValue;
    CGFloat intensityValue;
    
    BOOL isNone;
}


@property (weak, nonatomic) IBOutlet UIImageView *showIV;
@property (weak, nonatomic) IBOutlet UIView *sliderView;

@property (weak, nonatomic) IBOutlet UILabel *rangText;
@property (weak, nonatomic) IBOutlet UILabel *rangeVal;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;

@property (weak, nonatomic) IBOutlet UILabel *intensityText;
@property (weak, nonatomic) IBOutlet UILabel *intensityVal;
@property (weak, nonatomic) IBOutlet UISlider *intensitySlider;

@property (weak, nonatomic) IBOutlet UIButton *noneBtn;
@property (weak, nonatomic) IBOutlet UIButton *vignetteBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *range_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *intensity_left;
@end

@implementation APImageVignetteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    desImg = self.imgOrg;
    isNone = NO;
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:28/255.0 blue:36/255.0 alpha:1];
    self.intensitySlider.minimumValue = -1;
    self.intensitySlider.maximumValue = 1;
    self.intensitySlider.value = intensityValue = 0.5;
    [self.rangeSlider setThumbImage:[UIImage imageNamed:@"G2_photo_yan"] forState:UIControlStateNormal];
    [self.intensitySlider setThumbImage:[UIImage imageNamed:@"G2_photo_yan"] forState:UIControlStateNormal];
    rangeValue = self.rangeSlider.value;
    [self updateRangeValPosition];
    [self updateIntensityPostiion];
    self.showIV.image = desImg;
}
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if (!temOrg) {
        temOrg = [self shotView:self.showIV];
        self.rangeSlider.minimumValue = 0;
        
        rangeValue = MAX(temOrg.size.width/2, temOrg.size.height/2);
        self.rangeSlider.maximumValue = rangeValue+50;
        self.rangeSlider.value = MIN(rangeValue, 2000);
    }
    [self updateVignette];
    [self updateRangeValPosition];
}

- (UIImage *)shotView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)updateVignette {
    desImg = [UIImage vignetteImage:temOrg radius:rangeValue intensity:intensityValue];
    self.showIV.image = desImg;
}

- (void)updateRangeValPosition {
    NSString *str = [NSString stringWithFormat:@"%.0f", self.rangeSlider.value];
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGSize size = [str boundingRectWithSize:CGSizeMake(60, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat totalLen = self.rangeSlider.bounds.size.width - 30;
    CGFloat totalVal = self.rangeSlider.maximumValue - self.rangeSlider.minimumValue;
    CGFloat persent = (self.rangeSlider.value - self.rangeSlider.minimumValue )/ totalVal;
    CGFloat positionX = persent * totalLen;
    self.rangeVal.text = str;
    self.range_left.constant = positionX-size.width/2 + 14;
}

- (void)updateIntensityPostiion {
    NSString *str = [NSString stringWithFormat:@"%.2f", self.intensitySlider.value];
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGSize size = [str boundingRectWithSize:CGSizeMake(50, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat totalLen = self.intensitySlider.bounds.size.width - 30;
    CGFloat totalVal = self.intensitySlider.maximumValue - self.intensitySlider.minimumValue;
    CGFloat persent = (self.intensitySlider.value - self.intensitySlider.minimumValue ) / totalVal;
    CGFloat positionX = persent * totalLen;
    self.intensityVal.text = str;
    self.intensity_left.constant = positionX-size.width/2 + 14;
}

#pragma mark - button
- (IBAction)rangeValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    rangeValue = slider.value;
    [self updateVignette];
    [self updateRangeValPosition];
}
- (IBAction)intensityValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    intensityValue = slider.value;
    [self updateVignette];
    [self updateIntensityPostiion];
}

- (IBAction)vignetteClicked:(id)sender {
    self.noneBtn.selected = NO;
    self.vignetteBtn.selected = YES;
    self.showIV.image = desImg;
    self.sliderView.hidden = NO;
    isNone = NO;
}

- (IBAction)noneFilter:(id)sender {
    self.showIV.image = self.imgOrg;
    self.noneBtn.selected = YES;
    self.vignetteBtn.selected = NO;
    self.sliderView.hidden = YES;
    isNone = YES;
}
- (IBAction)showOrgImage:(id)sender {
    self.showIV.image = self.imgOrg;
}
- (IBAction)showFilterImage:(id)sender {
    self.showIV.image = desImg;
}
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)applyClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    /*
     CGFloat rangeValue;
     CGFloat intensityValue;
     */
    NSDictionary *dic = @{@"type":@(2), @"none":@(isNone), @"image":desImg, @"range":@(rangeValue), @"intensity":@(intensityValue)};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kAPImageEditSecondChanged" object:dic];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
@end
