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
//cube的四个cell
@property (nonatomic,strong) UIImageView *subCube1;
@property (nonatomic,strong) UIImageView *subCube2;
@property (nonatomic,strong) UIImageView *subCube3;
@property (nonatomic,strong) UIImageView *subCube4;

// =====================以下属性和方法需要在子类中初始化和重载=============================
//存储cube中cell的index
@property (nonatomic)NSMutableArray *subCubes;
//用于显示在右侧预览框中
@property (nonatomic)int previewX;
@property (nonatomic)int previewY;
@property (nonatomic,strong)UIImageView* previewCube;

//定义了cube如何旋转
- (void)rotateCube;
//如果旋转后与其他cube冲突，则调用此方法
- (void)rotateBack;
// =================================== END ==========================================

@end
