//
//  myCube.m
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "myCube.h"

@implementation myCube

- (id)init {
    if (self != nil) {
        self.speed = 1;
        self.rotateTimes = 0;
        self.cubeImage =[UIImage imageNamed:@"cubeCell.png"];
        self.subCube1 = [[UIImageView alloc] initWithImage:self.cubeImage];
        self.subCube2 = [[UIImageView alloc] initWithImage:self.cubeImage];
        self.subCube3 = [[UIImageView alloc] initWithImage:self.cubeImage];
        self.subCube4 = [[UIImageView alloc] initWithImage:self.cubeImage];
        self.subCubeViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)rotateCube {
}
- (void)rotateBack {
}

@end
