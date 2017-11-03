//
//  APImageLabel.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/7.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageLabel.h"
@interface APImageLabel()
@property (weak, nonatomic) IBOutlet UILabel *showText;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet UIButton *adjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *selBtn;
@property (weak, nonatomic) IBOutlet UIView *frameView;


@end
@implementation APImageLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setTextFontName:(NSString *)name {
    CGFloat size = self.showText.font.pointSize;
    [self.showText setFont:[UIFont fontWithName:name size:size]];
}
- (void)setTextColor:(UIColor *)color {
    [self.showText setTextColor:color];
}
- (void)setTextColorAlpha:(CGFloat)alpha {
    UIColor *color = self.showText.textColor;
    UIColor *newColor = [color colorWithAlphaComponent:alpha];
    [self.showText setTextColor:newColor];
}
- (void)nextAlignment {
    NSTextAlignment alignment = self.showText.textAlignment;
    alignment++;
    alignment %= 3;
    self.showText.textAlignment = alignment;
}
- (NSTextAlignment)textAlignment {
    return self.showText.textAlignment;
}
- (void)setText:(NSString *)str attr:(NSDictionary *)dic {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:dic];
    self.showText.attributedText = attributedString;

}
- (void)setTextAttr:(NSDictionary *)dic {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.showText.text attributes:dic];
    self.showText.attributedText = attributedString;
}
- (void)setIsSel:(BOOL)isSel {
    self.frameView.hidden = !isSel;
    self.selBtn.hidden = isSel;
}
- (IBAction)selClicked:(id)sender {
    self.isSel = YES;
    if (self.tapType) {
        self.tapType(0);
    }
}

- (IBAction)delBtnClicked:(id)sender {
    if (self.delBlock) {
        self.delBlock();
    }
}

- (IBAction)editBtnClicked:(id)sender {
    if (self.editBlock) {
        self.editBlock();
    }
}

- (IBAction)adjustTouchDown:(id)sender {
    if (self.tapType) {
        self.tapType(2);
    }
}

- (IBAction)translationTouchDown:(id)sender {
    if (self.tapType) {
        self.tapType(1);
    }
}

@end
