//
//  APImageColorList.m
//  AreoxPlay
//
//  Created by mifit on 2017/9/8.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APImageColorList.h"
#import "APImageColorModel.h"

@implementation APImageColorList
+ (NSArray *)colorListMode {
    NSMutableArray *temList = [NSMutableArray arrayWithCapacity:6];
    NSArray *hexList = @[@"18191b", @"424242", @"757575", @"bdbdbd", @"eeeeee", @"ffffff", @"f0f5f9", @"c9d6de", @"52616a", @"fecdc2", @"e5434e", @"cb1631", @"bb011d", @"fff4c8", @"fee868", @"fbad4c", @"ff7120", @"ff0000", @"fec4de", @"ff9dc9", @"fa6bb8", @"ff3e9a", @"ff0090", @"ff9def", @"f166f2", @"e326e5", @"b100b3", @"71008d", @"918ee3", @"6562c7", @"413ec6", @"2421ae", @"270084", @"80daff", @"45cafb", @"00b4ff", @"0078ff", @"004eff", @"9ee3da", @"6ce3d4", @"0db39f", @"008e7e", @"006b4f", @"bae297", @"a1db5c", @"88ce24", @"7db025", @"648826"];
    for (NSInteger indx = 0; indx < hexList.count; indx++) {
        APImageColorModel *model = [APImageColorModel new];
        model.isSel = NO;
        NSString *hesName = hexList[indx];
        if (indx == 0) {
            model.isSel = YES;
        }
        model.colorHex = hesName;
        [temList addObject:model];
    }
    return temList;
}
@end
