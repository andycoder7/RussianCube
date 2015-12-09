//
//  CubeB.m
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeB.h"

@implementation CubeB

- (id)init {
    self = [super init];
    if (self) {
        //Z
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeB.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+15;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@5,@14,@15,@24,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}

// 05 14 15 24 -> 04 05 15 16
// 04 05 15 16 -> 05 14 15 24
- (void)rotateCube {
    if (self.rotateTimes%2 == 0) {
        if ([self.subCubes[2] integerValue]%10 != 9) {
            // | -> - 没破右界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-9)];
            [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
            self.rotateTimes++;
        }
    } else {
        if (([self.subCubes[3] integerValue]+8) < 200) {
            // - -> | 没破下界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+9)];
            [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
            self.rotateTimes++;
        }
    }
}

// 05 14 15 24 -> 04 05 15 16
// 04 05 15 16 -> 05 14 15 24
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        if (self.rotateTimes%2 == 0) {
            if ([self.subCubes[2] integerValue]%10 != 9) {
                // | -> - 没破右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-9)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
                self.rotateTimes--;
            }
        } else {
            if (([self.subCubes[3] integerValue]+8) < 200) {
                // - -> | 没破下界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+9)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
                self.rotateTimes--;
            }
        }
    }
}

@end
