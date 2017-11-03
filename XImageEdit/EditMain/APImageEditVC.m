//
//  APImageEditVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/6/26.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageEditVC.h"

#import "APImageCutVC.h"
#import "APImageFilterVC.h"
#import "APImageEnhanceVC.h"

#import "APMediaManager.h"
#import "SGInfoAlert.h"

@interface APImageEditVC ()
{
    NSMutableArray *stepList;
    NSInteger curStep;
}
@property (weak, nonatomic) IBOutlet UILabel *labelCut;
@property (weak, nonatomic) IBOutlet UILabel *labelFilter;
@property (weak, nonatomic) IBOutlet UILabel *labelAdjust;
@property (weak, nonatomic) IBOutlet UILabel *labelDrawPan;
@property (weak, nonatomic) IBOutlet UILabel *labelText;


@property (weak, nonatomic) IBOutlet UIImageView *showIV;

@property (nonatomic, strong) UIImage *desImg;
@end

@implementation APImageEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageChanged:) name:@"kAPImageEditChanged" object:nil];
    self.desImg = self.orgImg;
    self.showIV.image = self.orgImg;
    curStep = 0;
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
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)imageChanged:(NSNotification *)notify {
    UIImage *img = (UIImage *)notify.object;
    if (!stepList) {
        stepList = [NSMutableArray array];
    }
    NSString *name = [NSString stringWithFormat:@"stepImg%d.png",curStep];
    NSString *path = [NSTemporaryDirectory()stringByAppendingPathComponent:name];
    NSData *data = UIImagePNGRepresentation(self.desImg);
    if([data writeToFile:path atomically:YES]) {
        [stepList addObject:path];
    }
    self.desImg = img;
    self.showIV.image = img;
    curStep++;
    NSMutableArray *delList = nil;
    for (NSInteger indx = 0; indx < stepList.count; indx++) {
        if (curStep <= indx) {
            if (!delList) {
                delList = [NSMutableArray array];
            }
            [delList addObject:stepList[indx]];
        }
    }
    if (delList) {
        [stepList removeObjectsInArray:delList];
        NSLog(@"redu unable");
        NSLog(@"undu enable");
    }
}
- (void)undo {
    if (curStep > 0) {
        NSString *path = stepList[--curStep];
        UIImage *img = [UIImage imageWithContentsOfFile:path];
        self.showIV.image = img;
    }
    if (curStep == 0) {
        NSLog(@"undu unable");
    }
}

- (void)redu {
    if (curStep < stepList.count - 1) {
        NSString *path = stepList[++curStep];
        UIImage *img = [UIImage imageWithContentsOfFile:path];
        self.showIV.image = img;
    }
    if (curStep == stepList.count - 1) {
        NSLog(@"redu unable");
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)showVC:(NSString *)vcName sbName:(NSString *)sbName {
    id vc = [[UIStoryboard storyboardWithName:sbName bundle:nil]instantiateViewControllerWithIdentifier:vcName];
    [vc setValue:self.desImg forKey:@"imgOrg"];
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - button
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveClicked:(id)sender {
    [[APMediaManager shareInstance]saveImage:self.desImg complete:^(BOOL isOK, NSString *error) {
        if (isOK) {
            [SGInfoAlert showInfo:@"saved" bgColor:[[UIColor lightGrayColor] CGColor] inView:self.view vertical:0.5];
        } else {
            [SGInfoAlert showInfo:error bgColor:[[UIColor lightGrayColor] CGColor] inView:self.view vertical:0.5];
        }
    }];
}
- (IBAction)cutClicked:(id)sender {
    [self showVC:@"APImageCutVC" sbName:@"APImageCut"];
}
- (IBAction)filterClicked:(id)sender {
    [self showVC:@"APImageFilterVC" sbName:@"APImageFilter"];
}
- (IBAction)adjustClicked:(id)sender {
    [self showVC:@"APImageEnhanceVC" sbName:@"APImageEnhance"];
}
- (IBAction)drawPanClicked:(id)sender {
    [self showVC:@"APImageDrawboardVC" sbName:@"APImageDrawboard"];
}
- (IBAction)textClicked:(id)sender {
    [self showVC:@"APImageTextVC" sbName:@"APImageText"];
}

@end
