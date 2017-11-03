//
//  APImageTextColorCell.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/6.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageTextColorCell.h"
#import "APImageColorModel.h"
#import "UIColor_XMColor.h"

@interface APImageTextColorCell()
@property (weak, nonatomic) IBOutlet UIImageView *selImg;

@end
@implementation APImageTextColorCell
- (void)updateCellWithModel:(APImageColorModel *)model {
    self.selImg.hidden = !model.isSel;
    self.backgroundColor = [UIColor colorWithHexString:model.colorHex];
}
@end
