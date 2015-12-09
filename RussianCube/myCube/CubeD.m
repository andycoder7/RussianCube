//
//  CubeD.m
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeD.h"

@implementation CubeD

- (id)init {
    self = [super init];
    if (self) {
        //横过来的一
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeD.png"]];
        self.previewX = 300+3+5+15;
        self.previewY = 67;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@5,@6,@7,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}

//3 4 5 6 -> 4 14 24 34
- (void)rotateCube {
    if (self.rotateTimes%2 == 0) {
        if ([self.subCubes[1] integerValue]+30 < 10*20) {
            // - -> | 没破下界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+10)];
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+19)];
            [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+28)];
            self.rotateTimes++;
        }
    } else {
        if (([self.subCubes[0] integerValue])%10 != 0 && ([self.subCubes[0] integerValue])%10 < 8 ) {
            // | -> - 没破左界 和 右界
            [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
            [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-10)];
            [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-19)];
            [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-28)];
            self.rotateTimes++;
        }
    }
}

- (void)rotateBack {
    if (self.rotateTimes > 0) {
        if (self.rotateTimes%2 == 0) {
            if ([self.subCubes[1] integerValue]+30 < 10*20) {
                // - -> | 没破下界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+10)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+19)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+28)];
                self.rotateTimes--;
            }
        } else {
            if (([self.subCubes[0] integerValue])%10 != 0 && ([self.subCubes[0] integerValue])%10 < 8 ) {
                // | -> - 没破左界 和 右界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-10)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-19)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-28)];
                self.rotateTimes--;
            }
        }
    }
}

@end
