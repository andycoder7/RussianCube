//
//  myCube.h
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myCube : NSObject 

//cube中单个cell的图片
@property (nonatomic,strong)UIImage *cubeImage;
//cube下降的时间间隔，由gamelevel计算得出
@property (nonatomic)double speed;
//cube的旋转次数
@property (nonatomic)int rotateTimes;
//存储cube中cell的index
@property (nonatomic)NSMutableArray *subCubes;
//cube的四个cell
@property (nonatomic,strong) UIImageView *subCube1;
@property (nonatomic,strong) UIImageView *subCube2;
@property (nonatomic,strong) UIImageView *subCube3;
@property (nonatomic,strong) UIImageView *subCube4;

//用于显示在右侧预览框中
@property (nonatomic)int previewX;
@property (nonatomic)int previewY;
@property (nonatomic,strong)UIImageView* previewCube;

- (void)rotateCube;
- (void)rotateBack;

@end
