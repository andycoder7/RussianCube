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
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@5,@15,@16,nil];
    }
    return self;
}

//4 5 15 16 -> 5 15 14 24
- (void)rotateCube {
    if (self.rotateTimes%2 == 0) {
        if ([self.subCubes[3] integerValue]+8 < 10*20) {
            // - -> | 没破下界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+10)];
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
            [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
            self.rotateTimes++;
        }
    } else {
        if (([self.subCubes[3] integerValue]-8)%10 != 0) {
            // | -> - 没破右界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-10)];
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
            [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
            self.rotateTimes++;
        }
    }
}

- (void)rotateBack {
    if (self.rotateTimes > 0) {
        if (self.rotateTimes%2 == 0) {
            if ([self.subCubes[3] integerValue]+8 < 10*20) {
                // - -> | 没破下界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+10)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+8)];
                self.rotateTimes--;
            }
        } else {
            if (([self.subCubes[3] integerValue]-8)%10 != 0) {
                // | -> - 没破右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-10)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-8)];
                self.rotateTimes--;
            }
        }
    }
}

@end
