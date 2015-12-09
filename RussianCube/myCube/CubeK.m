//
//  CubeK.m
//  RussianCube
//
//  Created by andy.yao on 12/10/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeK.h"

@implementation CubeK

- (id)init {
    self = [super init];
    if (self) {
        //口
        //口 口
        //口 口
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeK.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+15;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@14,@15,@24,@25,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}
// 04 -> 16
// 16 -> 35
// 35 -> 23
// 23 -> 04
- (void)rotateCube {
    switch (self.rotateTimes%4) {
        case 0:
            if ([self.subCubes[2] integerValue]%10 != 9) {
                //  顺时针90度  没破右届
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+12)];
                self.rotateTimes++;
            }
            break;
        case 1:
            if ([self.subCubes[3] integerValue]+10 < 200) {
                // 顺时针90度 没破下界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+19)];
                self.rotateTimes++;
            }
            break;
        case 2:
            if ([self.subCubes[1] integerValue]%10 != 0) {
                // 顺时针90度 没破左界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-12)];
                self.rotateTimes++;
            }
            break;
        case 3:
            if ([self.subCubes[1] integerValue]-10 >= 0) {
                // 顺时针90度 没破上界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-19)];
                self.rotateTimes++;
            }
            break;
    }
}

// 04 -> 23
// 16 -> 04
// 35 -> 16
// 23 -> 35
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        switch (self.rotateTimes%4) {
            case 0:
                if ([self.subCubes[1] integerValue]%10 != 0) {
                    // 逆时针90度 没破左界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+19)];
                    self.rotateTimes--;
                }
                break;
            case 1:
                if ([self.subCubes[1] integerValue]-10 >= 0) {
                    // 逆时针转90度 没破上界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-12)];
                    self.rotateTimes--;
                }
                break;
            case 2:
                if ([self.subCubes[2] integerValue]%10 != 9) {
                    // 逆时针转90度 没破右界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-19)];
                    self.rotateTimes--;
                }
                break;
            case 3:
                if ([self.subCubes[4] integerValue]+10 < 200) {
                    // 逆时针转90度 没破下界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+12)];
                    self.rotateTimes--;
                }
                break;
        }
    }
}
@end
