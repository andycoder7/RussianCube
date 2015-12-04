//
//  CubeA.m
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeA.h"

@implementation CubeA

- (id)init{
    self = [super init];
    if (self) {
        //方块
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeA.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+30;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@5,@14,@15,nil];
    }
    return self;
}

- (void)rotateCube {
    //不需要做
}
- (void)rotateBack {
    //不需要做
}

@end
