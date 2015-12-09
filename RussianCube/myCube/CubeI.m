//
//  CubeI.m
//  RussianCube
//
//  Created by andy.yao on 12/9/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "CubeI.h"

@implementation CubeI

- (id)init{
    self = [super init];
    if (self) {
        //  十
        self.previewCube = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeI.png"]];
        self.previewX = 300+3+5;
        self.previewY = 67+30;
        self.subCubes = [[NSMutableArray alloc] initWithObjects:@4,@13,@14,@15,@24,nil];
        for (int i = 0; i < [self.subCubes count]; i++) {
            [self.subCubeViews addObject:[[UIImageView alloc] initWithImage:self.cubeImage]];
        }
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
