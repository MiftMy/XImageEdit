//
//  APFilterList.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/5.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APFilterList.h"
#import "APImageFilterModel.h"

#import "BeautyFilter.h"
#import "CoolFilter.h"
#import "CrayonFilter.h"
#import "EarlyBirdFilter.h"
#import "FairytaleFilter.h"
#import "InkwellFilter.h"
#import "SketchFilter.h"
#import "WarmFilter.h"
#import "WhitecatFilter.h"

@implementation APFilterList

+ (NSArray *)filterList:(UIImage *)img {
    NSMutableArray *temList = [NSMutableArray arrayWithCapacity:9];
    for (NSInteger indx = 0; indx < 9; indx++) {
        APImageFilterModel *model = [APImageFilterModel new];
        UIImage *imgTem = [APFilterList imageFilter:img WithType:indx];
        NSString *path = [NSString stringWithFormat:@"filterImg%d.png", indx];
        model.imgPath = path = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
        NSData *temData = UIImagePNGRepresentation(imgTem);
        BOOL isOK = [temData writeToFile:path atomically:YES];
        model.isSel = NO;
        switch (indx) {
            case 0:
                model.name = @"filter_original";
                model.isSel = YES;
                break;
            case 1:
                model.name = @"filter_beauty";
                break;
            case 2:
                model.name = @"filter_fairytale";
                break;
            case 3:
                model.name = @"filter_warm";
                break;
            case 4:
                model.name = @"filter_cool";
                break;
            case 5:
                model.name = @"filter_sketch";
                break;
            case 6:
                model.name = @"filter_whitecat";
                break;
            case 7:
                model.name = @"filter_crayon";
                break;
            case 8:
                model.name = @"filter_inkwell";
                break;
            default:
                break;
        }
        [temList addObject:model];
    }
    return temList;
}

+ (UIImage *)imageFilter:(UIImage *)imgOrg WithType:(NSInteger)type {
    UIImage *desImg = nil;
    switch (type) {
        case 0:
            desImg = imgOrg;
            break;
        case 1:
        {
            BeautyFilter *filter = [[BeautyFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        case 2:
        {
            FairytaleFilter *filter = [[FairytaleFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        case 3:
        {
            WarmFilter *filter = [[WarmFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        case 4:
        {
            CoolFilter *filter = [[CoolFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        case 5:
        {
            SketchFilter *filter = [[SketchFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        case 6:
        {
            WhitecatFilter *filter = [[WhitecatFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        case 7:
        {
            CrayonFilter *filter = [[CrayonFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        case 8:
        {
            InkwellFilter *filter = [[InkwellFilter alloc]init];
            filter.image = imgOrg;
            desImg = [UIImage imageWithContentsOfFile:[filter filterImage]];
        }
            break;
        default:
            break;
    }
    
    return desImg;
}
@end
