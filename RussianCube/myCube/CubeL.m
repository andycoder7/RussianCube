//
//  CubeL.m
//  RussianCube
//
//  Created by andy.yao on 12/9/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeL.h"

@implementation CubeL

- (id)init{
    self = [super init];
    if (self) {
        //   口
        //口
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeL.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+30;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@5,@14,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
    }
    return self;
}

// 05 14 -> 04 15
// 04 15 -> 05 14
- (void)rotateCube {
    if (self.rotateTimes%2 == 0) {
        [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
        [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+1)];
        self.rotateTimes++;
    } else {
        [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
        [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-1)];
        self.rotateTimes++;
    }
}
- (void)rotateBack {
    if (self.rotateTimes%2 == 0) {
        [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]-1)];
        [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]+1)];
        self.rotateTimes--;
    } else {
        [self.subCubes replaceObjectAtIndex:0 withObject:@([self.subCubes[0] integerValue]+1)];
        [self.subCubes replaceObjectAtIndex:1 withObject:@([self.subCubes[1] integerValue]-1)];
        self.rotateTimes--;
    }
}

@end
