//
//  CubeO.m
//  RussianCube
//
//  Created by andy.yao on 12/10/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeO.h"

@implementation CubeO


- (id)init {
    self = [super init];
    if (self) {
        //   口
        //口 口
        //口 口
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeO.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+15;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@5,@14,@15,@24,@25,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}
// 05 -> 26
// 26 -> 34
// 34 -> 13
// 13 -> 05
- (void)rotateCube {
    switch (self.rotateTimes%4) {
        case 0:
            if ([self.subCubes[2] integerValue]%10 != 9) {
                //  顺时针90度  没破右届
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+21)];
                self.rotateTimes++;
            }
            break;
        case 1:
            if ([self.subCubes[3] integerValue]+10 < 200) {
                // 顺时针90度 没破下界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+8)];
                self.rotateTimes++;
            }
            break;
        case 2:
            if ([self.subCubes[1] integerValue]%10 != 0) {
                // 顺时针90度 没破左界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-21)];
                self.rotateTimes++;
            }
            break;
        case 3:
            if ([self.subCubes[1] integerValue]-10 >= 0) {
                // 顺时针90度 没破上界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-8)];
                self.rotateTimes++;
            }
            break;
    }
}

// 05 -> 13
// 26 -> 05
// 34 -> 26
// 13 -> 34
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        switch (self.rotateTimes%4) {
            case 0:
                if ([self.subCubes[1] integerValue]%10 != 0) {
                    // 逆时针90度 没破左界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+8)];
                    self.rotateTimes--;
                }
                break;
            case 1:
                if ([self.subCubes[1] integerValue]-10 >= 0) {
                    // 逆时针转90度 没破上界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-21)];
                    self.rotateTimes--;
                }
                break;
            case 2:
                if ([self.subCubes[2] integerValue]%10 != 9) {
                    // 逆时针转90度 没破右界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-8)];
                    self.rotateTimes--;
                }
                break;
            case 3:
                if ([self.subCubes[4] integerValue]+10 < 200) {
                    // 逆时针转90度 没破下界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+21)];
                    self.rotateTimes--;
                }
                break;
        }
    }
}

@end
