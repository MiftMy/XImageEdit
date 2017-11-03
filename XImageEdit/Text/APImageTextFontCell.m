//
//  APImageTextFontCell.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/6.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageTextFontCell.h"
#import "APImageTextFontModel.h"

@interface APImageTextFontCell()
@property (weak, nonatomic) IBOutlet UILabel *showText;

@end

@implementation APImageTextFontCell
- (void)updateCellWithModel:(APImageTextFontModel *)model {
    self.showText.text = @"字体";
    self.showText.font = [UIFont fontWithName:model.fontName size:model.fontSize];
    UIColor *color;
    if (model.isSel) {
        color = [UIColor colorWithRed:0 green:136/255.0 blue:1 alpha:1];
    } else {
        color = [UIColor colorWithRed:57/255.0 green:60/255.0 blue:71/255.0 alpha:1];
    }
    self.showText.backgroundColor = color;
}
@end
