//
//  CubeC.m
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeC.h"

@implementation CubeC

- (id)init {
    self = [super init];
    if (self) {
        //山字形
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeC.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+15;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@5,@14,@15,@16,nil];
    }
    return self;
}
// 05 14 15 16 -> 05 15 16 25
// 05 15 16 25 -> 14 15 16 25
// 14 15 16 25 -> 05 14 15 25
// 05 14 15 25 -> 05 14 15 16
- (void)rotateCube {
    switch (self.rotateTimes%4) {
        case 0:
            if ([self.subCubes[2] integerValue]+10 < 10*20) {
                // _|_ -> |- 没破下界
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+9)];
                self.rotateTimes++;
            }
            break;
        case 1:
            if ([self.subCubes[0] integerValue]%10 != 0) {
                // |- -> -.- 没破左界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+9)];
                self.rotateTimes++;
            }
            break;
        case 2:
            if ([self.subCubes[0] integerValue]-9 > 0) {
                // -.- -> -| 没破上界
                [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-9)];
                [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-1)];
                [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                self.rotateTimes++;
            }
            break;
        case 3:
            if ([self.subCubes[3] integerValue]%10 != 9) {
                // -| -> _|_ 没破右界
                [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-9)];
                self.rotateTimes++;
            }
            break;
    }
    
}

// 05 14 15 16 -> 05 14 15 25
// 05 15 16 25 -> 05 14 15 16
// 14 15 16 25 -> 05 15 16 25
// 05 14 15 25 -> 14 15 16 25
- (void)rotateBack {
    if (self.rotateTimes > 0) {
        switch (self.rotateTimes%4) {
            case 0:
                if ([self.subCubes[2] integerValue]+10 < 10*20) {
                    // _|_ -> -| 没破下界
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]+9)];
                    self.rotateTimes--;
                }
                break;
            case 1:
                if ([self.subCubes[0] integerValue]%10 != 0) {
                    // |- -> _|_ 没破左界
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-1)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]-1)];
                    [self.subCubes replaceObjectAtIndex:3 withObject:@([self.subCubes[3] integerValue]-9)];
                    self.rotateTimes--;
                }
                break;
            case 2:
                if ([self.subCubes[0] integerValue]-9 > 0) {
                    // -.- -> |- 没破上界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-9)];
                    self.rotateTimes--;
                }
                break;
            case 3:
                if ([self.subCubes[0] integerValue]%10 != 9) {
                    // -| -> -.- 没破右界
                    [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+9)];
                    [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+1)];
                    [self.subCubes replaceObjectAtIndex:2 withObject:@([self.subCubes[2] integerValue]+1)];
                    self.rotateTimes--;
                }
                break;
        }
    }
}


@end
