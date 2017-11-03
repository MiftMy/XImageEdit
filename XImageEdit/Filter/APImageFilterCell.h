//
//  APImageFilterCell.h
//  AreoxPlay
//
//  Created by mifit on 2017/9/4.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APImageFilterModel;

@interface APImageFilterCell : UICollectionViewCell
- (void)updateFilterModel:(APImageFilterModel *)model;
@end
