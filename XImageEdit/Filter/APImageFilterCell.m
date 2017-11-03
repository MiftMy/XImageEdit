//
//  APImageFilterCell.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/4.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageFilterCell.h"
#import "APImageFilterModel.h"

@interface APImageFilterCell()
@property (weak, nonatomic) IBOutlet UILabel *filterName;
@property (weak, nonatomic) IBOutlet UIImageView *showIV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *right;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;

@end
@implementation APImageFilterCell
- (void)updateFilterModel:(APImageFilterModel *)model {
//    self.showIV.image = [UIImage imageNamed:model.imgPath];
    self.showIV.image = [UIImage imageWithContentsOfFile:model.imgPath];
    self.filterName.text = model.name;
    CGFloat val = 5;
    if (model.isSel) {
        val = 0;
    }
    self.right.constant = val;
    self.top.constant = val;
    self.left.constant = val;
//    [self setNeedsDisplay];
}
@end
