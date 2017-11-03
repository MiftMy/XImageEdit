//
//  APImageDrawColorCell.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageDrawColorCell.h"
#import "APImageColorModel.h"
#import "UIColor_XMColor.h"
@interface APImageDrawColorCell()
@property (weak, nonatomic) IBOutlet UIImageView *selImage;


@end


@implementation APImageDrawColorCell
- (void)updateCellWithModel:(APImageColorModel *)model {
    self.backgroundColor = [UIColor colorWithHexString:model.colorHex];
    self.selImage.hidden = !model.isSel;
}

@end
