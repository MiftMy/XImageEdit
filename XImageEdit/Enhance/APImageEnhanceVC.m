//
//  APImageEnhanceVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/8/30.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageEnhanceVC.h"
#import "APMiddleSlider.h"
#import "SVProgressHUD.h"
#import "APProgressView.h"

typedef NS_ENUM(NSInteger, APImageAdjustType) {
    APImageAdjustTypeBrightness = 1,
    APImageAdjustTypeSaturation,
    APImageAdjustTypeTemperature,
    APImageAdjustTypeContrast,
    APImageAdjustTypeSharpen
};

@interface APImageEnhanceVC ()
{
    APImageAdjustType adjustType;
    UIImage *shotImg;//view截屏
    UIImage *temOrg;//单调原图
    UIImage *desImg;//调整后图
    
    //调整参数
    CGFloat valBrightness;
    CGFloat valSaturation;
    CGFloat valTemperature;
    CGFloat valContrast;
    CGFloat valSharpen;
    
    //滤镜
    CIContext *context;
    CIFilter *colorControls;
    CIFilter *sharpenLuminance;
    CIFilter *temperature;
    
    APProgressView *proView;
}

@property (weak, nonatomic) IBOutlet APMiddleSlider *middleSlider;
@property (weak, nonatomic) IBOutlet UIView *orgSliderView;
@property (weak, nonatomic) IBOutlet UISlider *orgSlider;
@property (weak, nonatomic) IBOutlet UILabel *orgVal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orgVla_left;

@property (weak, nonatomic) IBOutlet UIImageView *showIV;
@property (weak, nonatomic) IBOutlet UILabel *typeTitle;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *adjustBtns;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

@end

@implementation APImageEnhanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    valBrightness = 0;
    valSaturation = 0;
    valContrast = 0;
    valSharpen = 0;
    valTemperature = 0;
    adjustType = APImageAdjustTypeBrightness;
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:28/255.0 blue:36/255.0 alpha:1];
    self.showIV.image = self.imgOrg;
    temOrg = desImg = self.imgOrg;
    [self.orgSlider setThumbImage:[UIImage imageNamed:@"G2_photo_yan"] forState:UIControlStateNormal];
    self.middleSlider.thumbImage = [UIImage imageNamed:@"G2_photo_yan"];
    self.middleSlider.thumbRect = CGRectMake(0, 0, 20, 20);
    [self updateAdjustType];
    [self updateSliderIndicator];
    [self updateAdjustBtnTitle];
    __weak typeof(self) weakSelf = self;
    self.middleSlider.valueChanged = ^(CGFloat val) {
        NSLog(@"%.1f", val);
        [weakSelf dealWithType:adjustType value:val];
        self.applyBtn.enabled = YES;
    };
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
    shotImg = [self shotView:self.showIV];
    temOrg = shotImg;
    self.showIV.image = shotImg;
}

- (UIImage *)shotView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)snapshotView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,[UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - private
- (void)updateAdjustBtnTitle {
    for (UIButton *btn in self.adjustBtns) {
        NSString *str;
        switch (btn.tag) {
            case 1:
                str = @"Brightness";
                break;
            case 2:
                str = @"Saturation";
                break;
            case 3:
                str = @"Temperature";
                break;
            case 4:
                str = @"Contrast";
                break;
            case 5:
                str = @"Sharpen";
                break;
            default:
                break;
        }
        [btn setTitle:str forState:UIControlStateNormal];
    }
}
- (void)updateAdjustType {
    for (UIButton *btn in self.adjustBtns) {
        btn.selected = (btn.tag == adjustType);
    }
    self.middleSlider.hidden = !(adjustType!=APImageAdjustTypeSharpen);
    self.orgSliderView.hidden = (adjustType!=APImageAdjustTypeSharpen);
    NSDictionary *dic = nil;
    switch (adjustType) {
        case APImageAdjustTypeBrightness: //亮度 0
            self.middleSlider.minValue = -100;
            self.middleSlider.maxValue = 100;
            self.middleSlider.value = valBrightness;
            self.typeTitle.text = @"Brightness";
            dic = @{@"contrast":@(valContrast), @"saturation":@(valSaturation), @"sharpen":@(valSharpen), @"temperature":@(valTemperature)};
            break;
        case APImageAdjustTypeTemperature: // 色温
            self.middleSlider.minValue = -100;//1700
            self.middleSlider.maxValue = 100;//27000
            self.middleSlider.value = valTemperature;
            self.typeTitle.text = NSLocalizedString(@"Temperature", nil);
            dic = @{@"brightness":@(valBrightness), @"contrast":@(valContrast), @"saturation":@(valSaturation), @"sharpen":@(valSharpen)};
            break;
        case APImageAdjustTypeSaturation: // 饱和度  1
            self.middleSlider.minValue = -100;//0
            self.middleSlider.maxValue = 100;//2
            self.orgSlider.value = valSaturation;
            self.typeTitle.text = NSLocalizedString(@"Saturation", nil);
            dic = @{@"brightness":@(valBrightness), @"contrast":@(valContrast), @"sharpen":@(valSharpen), @"temperature":@(valTemperature)};
            break;
        case APImageAdjustTypeContrast: // 对比度  1
            self.middleSlider.minValue = -100;//0.25
            self.middleSlider.maxValue = 100;//4
            self.middleSlider.value = valContrast;
            self.typeTitle.text = NSLocalizedString(@"Contrast", nil);
            dic = @{@"brightness":@(valBrightness), @"saturation":@(valSaturation), @"sharpen":@(valSharpen), @"temperature":@(valTemperature)};
            break;
        case APImageAdjustTypeSharpen:// 锐化 0.4
            self.orgSlider.minimumValue = 0;
            self.orgSlider.maximumValue = 100;//2
            self.orgSlider.value = valSharpen;
            self.typeTitle.text = NSLocalizedString(@"Sharpen", nil);
            dic = @{@"brightness":@(valBrightness), @"contrast":@(valContrast), @"saturation":@(valSaturation), @"temperature":@(valTemperature)};
            break;
        default:
            break;
    }
    temOrg = [self adjustImage:shotImg vlaue:dic];
}
//brightness、contrast、temperature、saturation、sharpen
- (void)dealWithType:(APImageAdjustType)type value:(CGFloat)val {
    UIImage *imgTem = desImg;
    NSDictionary *dic = nil;
    switch (type) {
        case APImageAdjustTypeTemperature: // 色温
            valTemperature = val;
            dic = @{@"temperature":@(valTemperature)};
            break;
        case APImageAdjustTypeBrightness: //亮度
            valBrightness = val;
            dic = @{@"brightness":@(valBrightness)};
            break;
        case APImageAdjustTypeSaturation: // 饱和度
            valSaturation = val;
            dic = @{@"saturation":@(valSaturation)};
            break;
        case APImageAdjustTypeContrast: // 对比度
            valContrast = val;
            dic = @{@"contrast":@(valContrast)};
            break;
        case APImageAdjustTypeSharpen:// 锐化
            valSharpen = val;
            dic = @{@"sharpen":@(valSharpen)};
            break;
        default:
            
            break;
    }
    desImg = imgTem = [self adjustImage:temOrg vlaue:dic];
    self.showIV.image = imgTem;
}

- (void)updateSliderIndicator {
    CGFloat curVal = self.orgSlider.value;
    CGFloat minVal = self.orgSlider.minimumValue;
    CGFloat totalVal = self.orgSlider.maximumValue - minVal;
    CGFloat totalWidth = self.orgSlider.frame.size.width-30;//可滑动长度 
    CGFloat curLen = (curVal-minVal) / totalVal * totalWidth;
    NSString *showText = [NSString stringWithFormat:@"%.2f", curVal];
    if (adjustType == APImageAdjustTypeTemperature) {
        showText = [NSString stringWithFormat:@"%.0f", curVal];
    }
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGSize size = [showText boundingRectWithSize:CGSizeMake(60, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat left = curLen - size.width/2+15;
    self.orgVal.text = showText;
    self.orgVla_left.constant = left;
}

- (UIImage *)adjustImage:(UIImage *)src vlaue:(NSDictionary *)value {
    NSNumber *brightnessVal = value[@"brightness"];;
    NSNumber *contrastVal = value[@"contrast"];
    NSNumber *temperatureVal = value[@"temperature"];
    NSNumber *saturationVal = value[@"saturation"];
    NSNumber *sharpenVal = value[@"sharpen"];
    if (!context) {
        context = [CIContext contextWithOptions:nil];
    }
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
    CIFilter *desFilter = nil;
    if (brightnessVal || saturationVal || contrastVal) {
        if (!colorControls) {
            colorControls = [CIFilter filterWithName:@"CIColorControls"];
        }
        //        NSLog(@"%@", colorControls.attributes);
        [colorControls setValue:superImage forKey:kCIInputImageKey];
        if (brightnessVal) {
            CGFloat bVal = [brightnessVal floatValue]/250;
            [colorControls setValue:@(bVal) forKey:@"inputBrightness"];
        }
        if (saturationVal) {
            CGFloat sVal = [saturationVal integerValue] /100.0 + 1;
            [colorControls setValue:@(sVal) forKey:@"inputSaturation"];
        }
        if (contrastVal) {
            NSInteger temVal = [contrastVal integerValue];
            CGFloat cVal = temVal * 0.5 / 100.0 + 1;
            [colorControls setValue:@(cVal) forKey:@"inputContrast"];
        }
        desFilter = colorControls;
    }
    
    if (sharpenVal) {
        if (!sharpenLuminance) {
            sharpenLuminance = [CIFilter filterWithName:@"CISharpenLuminance"];
        }
//        NSLog(@"%@", sharpenLuminance.attributes);
        if (desFilter) {
            [sharpenLuminance setValue:desFilter.outputImage forKey:kCIInputImageKey];
        } else {
            [sharpenLuminance setValue:superImage forKey:kCIInputImageKey];
        }
        CGFloat valTem = [sharpenVal integerValue];
        CGFloat sVal = 0.16 * valTem + 0.4;
        [sharpenLuminance setValue:@(sVal) forKey:@"inputSharpness"];
        desFilter = sharpenLuminance;
    }
    if (temperatureVal) {
        if (!temperature) {
            temperature = [CIFilter filterWithName:@"CITemperatureAndTint"];
        }
        if (desFilter) {
            [temperature setValue:desFilter.outputImage forKey:@"inputImage"];
        } else {
            [temperature setValue:superImage forKey:@"inputImage"];
        }
        NSInteger valTem = [temperatureVal integerValue];
        NSInteger tVal = 0;
        if (valTem >= 0) {
            tVal = 95 * valTem + 6500;
        } else {
            tVal = 40 * valTem + 6500;
        }
        [temperature setValue:[CIVector vectorWithX:6500 Y:0] forKey:@"inputNeutral"]; // Default value: [6500, 0] Identity: [6500, 0]
        [temperature setValue:[CIVector vectorWithX:tVal Y:0] forKey:@"inputTargetNeutral"]; // Default value: [6500, 0] Identity: [6500, 0]
        desFilter = temperature;
    }
    
    CIImage *result = [desFilter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    
    // 得到修改后的图片
    UIImage *myImage = [UIImage imageWithCGImage:cgImage];
    
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}
#pragma mark - button
- (IBAction)touchDownShowOrgImg:(id)sender {
    self.showIV.image = self.imgOrg;
}
- (IBAction)touchUpShowFilterImg:(id)sender {
    self.showIV.image = desImg;
}

- (IBAction)orgValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"%.1f", slider.value);
    [self updateSliderIndicator];
    [self dealWithType:adjustType value:slider.value];
    self.applyBtn.enabled = YES;
}

- (IBAction)adjustImageTypeChanged:(id)sender {
    UIButton *btn = (UIButton *)sender;
    adjustType = (APImageAdjustType)btn.tag;
    [self updateAdjustType];
    [self updateSliderIndicator];
}
- (IBAction)exitClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)applyClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    proView = [[[NSBundle mainBundle]loadNibNamed:@"APProgressView" owner:nil options:nil]lastObject];
    [self.view addSubview:proView];
    [proView show];
    
    NSDictionary *dic = @{@"brightness":@(valBrightness), @"contrast":@(valContrast), @"sharpen":@(valSharpen), @"saturation":@(valSaturation), @"temperature":@(valTemperature)};
    UIImage *img = [self adjustImage:self.imgOrg vlaue:dic];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kAPImageEditChanged" object:img];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [proView hide];
        proView = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
