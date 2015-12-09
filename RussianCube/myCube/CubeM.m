//
//  CubeM.m
//  RussianCube
//
//  Created by andy.yao on 12/9/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeM.h"

@implementation CubeM

- (id)init{
    self = [super init];
    if (self) {
        //口 口 口 口
        //口
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeM.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@3,@4,@5,@6,@13,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}

// 23 24 25 26 33 -> 13 14 24 34 44
// 13 14 24 34 44 -> 15 22 23 24 25
// 15 22 23 24 25 -> 04 14 24 34 35
// 04 14 24 34 35 -> 23 24 25 26 33
- (void)rotateCube {
    switch (self.rotateTimes%4) {
        case 0:
            if ([self.subCubes[0] integerValue]-10 >= 0 && [self.subCubes[4] integerValue]+11 < 200) {
                //  顺时针90度  没破上界和下届
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-10)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-10)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+11)];
                self.rotateTimes++;
            }
            break;
        case 1:
            if ([self.subCubes[0] integerValue]%10 != 0 && [self.subCubes[1] integerValue]%10 != 9) {
                // 顺时针90度 没破左界和右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+2)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+8)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-10)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-19)];
                self.rotateTimes++;
            }
            break;
        case 2:
            if ([self.subCubes[0] integerValue]-10 >= 0 && [self.subCubes[4] integerValue]+10 < 200) {
                // 顺时针90度 没破上界和下界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-11)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-8)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+10)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+10)];
                self.rotateTimes++;
            }
            break;
        case 3:
            if ([self.subCubes[0] integerValue]%10 != 0 && [self.subCubes[4] integerValue]%10 != 9) {
                // 顺时针90度 没破左界和右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+19)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+10)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-2)];
                self.rotateTimes++;
            }
            break;
    }
}

// 23 24 25 26 33 -> 04 14 24 34 35
// 13 14 24 34 44 -> 23 24 25 26 33
// 15 22 23 24 25 -> 13 14 24 34 44
// 04 14 24 34 35 -> 15 22 23 24 25
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        switch (self.rotateTimes%4) {
            case 0:
                if ([self.subCubes[0] integerValue]-19 >= 0) {
                    // 逆时针90度 没破上界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-19)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-10)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+2)];
                    self.rotateTimes--;
                }
                break;
            case 1:
                if ([self.subCubes[1] integerValue]%10 < 8) {
                    // 逆时针转90度 没破右界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+10)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+10)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-11)];
                    self.rotateTimes--;
                }
                break;
            case 2:
                if ([self.subCubes[3] integerValue]+20 < 200) {
                    // 逆时针转90度 没破下界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-2)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-8)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+10)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+19)];
                    self.rotateTimes--;
                }
                break;
            case 3:
                if ([self.subCubes[0] integerValue]%10 > 1) {
                    // ___| 逆时针转90度 没破左界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+11)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+8)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-10)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-10)];
                    self.rotateTimes--;
                }
                break;
        }
    }
}
@end
