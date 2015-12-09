//
//  CubeH.m
//  RussianCube
//
//  Created by andy.yao on 12/9/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeH.h"

@implementation CubeH

- (id)init{
    self = [super init];
    if (self) {
        // 口
        // 口 口
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeH.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+30;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@14,@15,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}

// 04 14 15 -> 04 05 14
// 04 05 14 -> 04 05 15
// 04 05 15 -> 05 14 15
// 05 14 15 -> 04 14 15
- (void)rotateCube {
    switch (self.rotateTimes%4) {
        case 0:
            // L 顺时针90度
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-9)];
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
            self.rotateTimes++;
            break;
        case 1:
            // |—— 顺时针90度
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
            self.rotateTimes++;
            break;
        case 2:
            // -| 顺时针90度
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+9)];
            self.rotateTimes++;
            break;
        case 3:
            // ___| -> |_ 没破上界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
            self.rotateTimes++;
            break;
    }
}

// 04 14 15 -> 05 14 15
// 04 05 14 -> 04 14 15
// 04 05 15 -> 04 05 14
// 05 14 15 -> 04 05 15
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        switch (self.rotateTimes%4) {
            case 0:
                //  L 逆时针转90度
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
                self.rotateTimes--;
                break;
            case 1:
                // |—— 逆时针转90度
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+9)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                self.rotateTimes--;
                break;
            case 2:
                // -| 逆时针转90度 没破右界
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                self.rotateTimes--;
                break;
            case 3:
                // ___| 逆时针转90度 没破下界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-9)];
                self.rotateTimes--;
                break;
        }
    }
}

@end
