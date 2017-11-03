//
//  APImageTextInputVC.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/7.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageTextInputVC.h"

@interface APImageTextInputVC ()
@property (weak, nonatomic) IBOutlet UITextView *inputText;

@end

@implementation APImageTextInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
//    self.view.backgroundColor = [UIColor clearColor];
    if (self.defalutStr) {
        self.inputText.text = self.defalutStr;
    }
    [self.inputText becomeFirstResponder];
}
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clearClicked:(id)sender {
    self.inputText.text = @"";
}
- (IBAction)backClicked:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
}
- (IBAction)applyClicked:(id)sender {
    if (self.applyBlock) {
        self.applyBlock(self.inputText.text);
    }
    UIButton *btn = (UIButton *)sender;
    btn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self.view removeFromSuperview];
    });
}
//- (void) keyboardWasShown:(NSNotification *) notif
//{
//    NSDictionary *info = [notif userInfo];
//    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGSize keyboardSize = [value CGRectValue].size;
//    
//    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
//    ///keyboardWasShown = YES;
//}
//- (void) keyboardWasHidden:(NSNotification *) notif
//{
//    NSDictionary *info = [notif userInfo];
//    
//    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGSize keyboardSize = [value CGRectValue].size;
//    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
//    // keyboardWasShown = NO;
//    
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
