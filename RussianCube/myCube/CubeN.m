//
//  CubeN.m
//  RussianCube
//
//  Created by andy.yao on 12/10/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeN.h"

@implementation CubeN

- (id)init{
    self = [super init];
    if (self) {
        //口
        //口 口 口 口
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeN.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@3,@13,@14,@15,@16,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}

// 13 23 24 25 26 -> 14 15 24 34 44
// 14 15 24 34 44 -> 22 23 24 25 35
// 22 23 24 25 35 -> 04 14 24 33 34
// 04 14 24 33 34 -> 13 23 24 25 26
- (void)rotateCube {
    switch (self.rotateTimes%4) {
        case 0:
            if ([self.subCubes[4] integerValue]+20 < 200) {
                //  顺时针90度  没破下届
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-8)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+9)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+18)];
                self.rotateTimes++;
            }
            break;
        case 1:
            if ([self.subCubes[0] integerValue]%10 > 1) {
                // 顺时针90度 没破左界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+8)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+8)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-9)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-9)];
                self.rotateTimes++;
            }
            break;
        case 2:
            if ([self.subCubes[0] integerValue]-20 >= 0) {
                // 顺时针90度 没破上界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-18)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-9)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-1)];
                self.rotateTimes++;
            }
            break;
        case 3:
            if ([self.subCubes[0] integerValue]%10 < 8) {
                // 顺时针90度 没破右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+9)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+9)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
                [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-8)];
                self.rotateTimes++;
            }
            break;
    }
}

// 13 23 24 25 26 -> 04 14 24 33 34
// 14 15 24 34 44 -> 13 23 24 25 26
// 22 23 24 25 35 -> 14 15 24 34 44
// 04 14 24 33 34 -> 22 23 24 25 35
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        switch (self.rotateTimes%4) {
            case 0:
                if ([self.subCubes[0] integerValue]-10 >= 0 && [self.subCubes[1] integerValue]+10 < 200) {
                    // 逆时针90度 没破上界和下界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-9)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-9)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+8)];
                    self.rotateTimes--;
                }
                break;
            case 1:
                if ([self.subCubes[0] integerValue]%10 != 0 && [self.subCubes[1] integerValue]%10 != 9) {
                    // 逆时针转90度 没破左界和右界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+8)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-9)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]-18)];
                    self.rotateTimes--;
                }
                break;
            case 2:
                if ([self.subCubes[0] integerValue]-10 >= 0 && [self.subCubes[4] integerValue]+10 < 200) {
                    // 逆时针转90度 没破上界和下界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-8)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-8)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+9)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+9)];
                    self.rotateTimes--;
                }
                break;
            case 3:
                if ([self.subCubes[3] integerValue]%10 != 0 && [self.subCubes[1] integerValue]%10 != 9) {
                    // 逆时针转90度 没破左界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+18)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+9)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
                    [self.subCubes replaceObjectAtIndex:4 withObject:@([self.subCubes[4] integerValue]+1)];
                    self.rotateTimes--;
                }
                break;
        }
    }
}

@end
