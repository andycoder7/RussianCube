//
//  CubeE.m
//  RussianCube
//
//  Created by andy.yao on 12/4/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeE.h"

@implementation CubeE

- (id)init{
    self = [super init];
    if (self) {
        //L
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeE.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+15;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@14,@24,@25,nil];
    }
    return self;
}

// 04 14 24 25 -> 14 15 16 24
// 14 15 16 24 -> 14 15 25 35
// 14 15 25 35 -> 15 23 24 25
// 15 23 24 25 -> 04 14 24 25
- (void)rotateCube {
    switch (self.rotateTimes%4) {
        case 0:
            if ([self.subCubes[3] integerValue]%10 != 9) {
                // L 顺时针90度  没破右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+10)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-8)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-1)];
                self.rotateTimes++;
            }
            break;
        case 1:
            if ([self.subCubes[3] integerValue]+11 < 200) {
                // |—— 顺时针90度 没破下界
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+9)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+11)];
                self.rotateTimes++;
            }
            break;
        case 2:
            if ([self.subCubes[0] integerValue]%10 != 0) {
                // -| 顺时针90度 没破左界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+8)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-10)];
                self.rotateTimes++;
            }
            break;
        case 3:
            if ([self.subCubes[1] integerValue]-11 >= 0) {
                // ___| -> |_ 没破上界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-11)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-9)];
                self.rotateTimes++;
            }
            break;
    }
}

// 04 14 24 25 -> 15 23 24 25
// 14 15 16 24 -> 04 14 24 25
// 14 15 25 35 -> 14 15 16 24
// 15 23 24 25 -> 14 15 25 35
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        switch (self.rotateTimes%4) {
            case 0:
                if ([self.subCubes[1] integerValue]%10 != 0) {
                    //  L 逆时针转90度 没破左界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+11)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+9)];
                    self.rotateTimes--;
                }
                break;
            case 1:
                if ([self.subCubes[0] integerValue]-10 >= 0) {
                    // |—— 逆时针转90度 没破上界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-10)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-1)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+8)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+1)];
                    self.rotateTimes--;
                }
                break;
            case 2:
                if ([self.subCubes[2] integerValue]%10 != 9) {
                    // -| 逆时针转90度 没破右界
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-9)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-11)];
                    self.rotateTimes--;
                }
                break;
            case 3:
                if ([self.subCubes[3] integerValue]+10 < 200) {
                    // ___| 逆时针转90度 没破下界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-8)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+10)];
                    self.rotateTimes--;
                }
                break;
        }
    }
}

@end
