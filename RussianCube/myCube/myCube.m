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
        self.subCubeViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)rotateCube {
}
- (void)rotateBack {
}

@end
