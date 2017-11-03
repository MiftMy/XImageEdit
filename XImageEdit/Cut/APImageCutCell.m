//
//  APImageCutCell.m
//  AreoxPlay
//
//  Created by mifit on 2017/8/31.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageCutCell.h"
#import "APImageCutModel.h"

@interface APImageCutCell()
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *scaleTitle;

@end
@implementation APImageCutCell

- (void)updateCellWithModel:(APImageCutModel *)model {
    self.scaleTitle.text = model.scaleName;
    if (model.isSel) {
        self.scaleTitle.textColor = [UIColor colorWithRed:83/255.0 green:86/255.0 blue:86/255.0 alpha:1];
    } else {
        self.scaleTitle.textColor = [UIColor colorWithRed:0 green:136/255.0 blue:1 alpha:1];
    }
    if (model.isSel) {
        self.img.image = [UIImage imageNamed:model.iamgeSelName];
    } else {
        self.img.image = [UIImage imageNamed:model.iamgeName];
    }
}
@end
