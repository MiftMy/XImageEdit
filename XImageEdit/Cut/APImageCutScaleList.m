//
//  APImageCutScaleList.m
//  AreoxPlay
//
//  Created by mifit on 2017/8/31.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageCutScaleList.h"
#import "APImageCutModel.h"


@implementation APImageCutScaleList
+ (NSArray *)scaleList {
    NSMutableArray *temLit = [NSMutableArray array];
    for (NSInteger indx = 0; indx < 9; indx++) {
        APImageCutModel *model = [APImageCutModel new];
        model.isSel = NO;
        switch (indx) {
            case 0:
                model.isSel = YES;
                model.iamgeName = @"G2_photo_czzy";
                model.iamgeSelName = @"G2_photo_czxzzy";
                model.scaleName = @"free";
                model.scale = -1;
                break;
            case 1:
                model.iamgeName = @"G2_photo_czyt";
                model.iamgeSelName = @"G2_photo_czxzyt";
                model.scaleName = @"filter_none";
                model.scale = 0;
                break;
            case 2:
                model.iamgeName = @"G2_photo_cz11";
                model.iamgeSelName = @"G2_photo_czxz11";
                model.scaleName = @"1:1";
                model.scale = 1;
                break;
            case 3:
                model.iamgeName = @"G2_photo_cz23";
                model.iamgeSelName = @"G2_photo_czxz23";
                model.scaleName = @"2:3";
                model.scale = 2.0/3;
                break;
            case 4:
                model.iamgeName = @"G2_photo_cz45";
                model.iamgeSelName = @"G2_photo_czxz45";
                model.scaleName = @"4:5";
                model.scale = 4.0/5;
                break;
            case 5:
                model.iamgeName = @"G2_photo_cz34";
                model.iamgeSelName = @"G2_photo_czxz34";
                model.scaleName = @"3:4";
                model.scale = 3.0/4;
                break;
            case 6:
                model.iamgeName = @"G2_photo_cz43";
                model.iamgeSelName = @"G2_photo_czxz43";
                model.scaleName = @"4:3";
                model.scale = 4.0/3;
                break;
            case 7:
                model.iamgeName = @"G2_photo_cz1610";
                model.iamgeSelName = @"G2_photo_czxz1610";
                model.scaleName = @"16:10";
                model.scale = 16.0/10;
                break;
            case 8:
                model.iamgeName = @"G2_photo_cz169";
                model.iamgeSelName = @"G2_photo_czxz169";
                model.scaleName = @"16:9";
                model.scale = 16.0/9;
                break;
            default:
                break;
        }
        [temLit addObject:model];
    }
    return temLit;
}
@end
