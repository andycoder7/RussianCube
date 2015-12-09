//
//  CubeG.m
//  RussianCube
//
//  Created by andy.yao on 12/4/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeG.h"

@implementation CubeG


- (id)init {
    self = [super init];
    if (self) {
        //_|-
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeG.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+15;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@14,@15,@25,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}

// 04 14 15 25 -> 15 16 24 25
// 15 16 24 25 -> 04 14 15 25
- (void)rotateCube {
    if (self.rotateTimes%2 == 0) {
        if ([self.subCubes[2] integerValue]%10 != 9) {
            // | -> - 没破右界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+11)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+2)];
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+9)];
            self.rotateTimes++;
        }
    } else {
        if (([self.subCubes[0] integerValue]-11) >= 0) {
            // | -> - 没破上界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-11)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-2)];
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-9)];
            self.rotateTimes++;
        }
    }
}

// 04 14 15 25 -> 15 16 24 25
// 15 16 24 25 -> 04 14 15 25
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        if (self.rotateTimes%2 == 0) {
            if ([self.subCubes[2] integerValue]%10 != 9) {
                // | -> - 没破右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+11)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+2)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+9)];
                self.rotateTimes--;
            }
        } else {
            if (([self.subCubes[0] integerValue]-11) >= 0) {
                // | -> - 没破上界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-11)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-2)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-9)];
                self.rotateTimes--;
            }
        }
    }
}

@end
