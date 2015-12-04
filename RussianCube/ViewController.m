//
//  ViewController.m
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "ViewController.h"
#import "myCube.h"
#import "CubeA.h"
#import "CubeB.h"
#import "CubeC.h"
#import "CubeD.h"

@interface ViewController ()

//游戏难度，用于计算cube下降的时间间隔
@property (nonatomic)int gameLevel;
//游戏得分，用于计算游戏的难度
@property (nonatomic)long gameScore;
@property (nonatomic,strong)UILabel *gameLevelLabelValue;
@property (nonatomic,strong)UILabel *gameScoreLabelValue;
//记录所有10x20个格子中是否已被cube的cell填充，YES/NO
@property (nonatomic,strong)NSMutableArray *cubeIndex;
//用于存储所有cell的UIImageView
@property (nonatomic,strong)NSMutableArray *allCells;
// nextCubeType 0-A 1-B 2-C 3-D
@property (nonatomic)int nextCubeType;
//下一个cube
@property (nonatomic,strong)myCube *nextCube;
//判断是否碰撞了
@property (nonatomic)BOOL crashed;
//当前正在下降的那个cube
@property (nonatomic,strong)myCube *currentCube;
//cube下降的计时器，由于要动态的修改其间隔时间，所以要设为属性
@property (nonatomic,strong)NSTimer *cubeDown;
//对所有cube的旋转、平移、下降操作加锁互斥
@property (nonatomic,strong)NSLock *theLock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameLevel = 1;
    //初始化最初的界面
    [self initUI];
    //初始化cubeIndex，全部为NO
    self.cubeIndex = [[NSMutableArray alloc] initWithCapacity:10*20];
    self.allCells = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10*20; i++) {
        [self.cubeIndex addObject:@NO];
    }
    self.crashed = YES;
    self.currentCube = nil;
    [self resetNextCube];
    self.theLock = [[NSLock alloc] init];
    self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(goDown) userInfo:nil repeats:NO];
    //平移手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCube:)];
    [self.view addGestureRecognizer:pan];
    //轻拍手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotateCube)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initUI {
    //俄罗斯方块的主体盒子
    UIImageView *cubeBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeBox.png"]];
    [self.view addSubview:cubeBox];
    //游戏的标题
    UILabel *gameTitle = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, 25, 200, 40)];
    [gameTitle setText:@"Russian Cube"];
    [gameTitle setTextAlignment:NSTextAlignmentCenter];
    gameTitle.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:gameTitle];
    //游戏级别
    UILabel *gameLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 200, 75, 20)];
    [gameLevelLabel setText:@"- LEVEL -"];
    [gameLevelLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:gameLevelLabel];
    //游戏级别的值
    self.gameLevelLabelValue = [[UILabel alloc] initWithFrame:CGRectMake(300, 220, 75, 20)];
    [self.gameLevelLabelValue setText:[NSString stringWithFormat:@"%d",self.gameLevel]];
    [self.gameLevelLabelValue setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.gameLevelLabelValue];
    //游戏得分
    UILabel *gameScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 250, 75, 20)];
    [gameScoreLabel setText:@"-SCORE-"];
    [gameScoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:gameScoreLabel];
    //游戏得分的值
    self.gameScoreLabelValue = [[UILabel alloc] initWithFrame:CGRectMake(300, 270, 75, 20)];
    [self.gameScoreLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScore]];
    [self.gameScoreLabelValue setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.gameScoreLabelValue];
    //开挂按钮，后期要改掉的
    UIButton *whosyourdaddy = [[UIButton alloc] initWithFrame:CGRectMake(300, 320, 75, 20)];
    [whosyourdaddy setTitle:@"挂逼点此" forState:UIControlStateNormal];
    whosyourdaddy.layer.borderWidth = 1;
    whosyourdaddy.layer.borderColor = [[UIColor blueColor]CGColor];
    [whosyourdaddy setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [whosyourdaddy addTarget:self action:@selector(whosyourdaddy) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:whosyourdaddy];
}

//平移手势中的回调函数，用于获取手势移动的距离，然后判断是否需要平移cube
- (void)moveCube:(UIPanGestureRecognizer *)sender {
    CGPoint deltaPoint = [sender translationInView:self.view];
    if (deltaPoint.x < -15 || deltaPoint.x > 15) {
        [self horizontalMove:(int)(deltaPoint.x)];
        [sender setTranslation:CGPointZero inView:self.view];
    }
    if (deltaPoint.y > 50) {
        [self downToBottom];
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

- (void)rotateCube {
    [self.theLock lock];
    //如果没有crash的判断，会有可能在isDownCrashed判断YES到新的currentCube出现的那个时间间隔，
    //还能操作原来的currentCube，但是就算原来的currentCube在旋转之后可以继续下降，也不会动了，因为新的cube已经出现了。
    if (self.crashed == NO) {
        [self removeCrashFlagOfCube];
        [self.currentCube rotateCube];
        if ([self isCrashed]) {
            [self.currentCube rotateBack];
        }
        [self addCrashFlagOfCube];

    }
    [self.theLock unlock];
    [self setCenterForCube:self.currentCube];
}


- (void)removeCrashFlagOfCube {
    for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
        [self.cubeIndex replaceObjectAtIndex:[self.currentCube.subCubes[i] integerValue] withObject:@NO];
    }
}
- (void)addCrashFlagOfCube {
    for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
        [self.cubeIndex replaceObjectAtIndex:[self.currentCube.subCubes[i] integerValue] withObject:@YES];
    }
}

//直接降到底部
- (void)downToBottom {
    [self.theLock lock];
    while ([self isDownCrashed] == NO) {
        [self removeCrashFlagOfCube];
        for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
            [self.currentCube.subCubes replaceObjectAtIndex:i withObject:@([self.currentCube.subCubes[i] integerValue]+10)];
        }
        [self addCrashFlagOfCube];
    }
    [self.theLock unlock];
    [self setCenterForCube:self.currentCube];
}

//水平移动cube，delta>0则右移，否则左移
- (void)horizontalMove:(int)delta {
    [self.theLock lock];
    if (self.crashed == NO) {
        if (delta > 0) {
            //move right
            if ([self isRightCrashed] == NO) {
                [self removeCrashFlagOfCube];
                for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
                    [self.currentCube.subCubes replaceObjectAtIndex:i withObject:@([self.currentCube.subCubes[i] integerValue]+1)];
                }
                [self addCrashFlagOfCube];
            }
        } else {
            //move left
            if ([self isLeftCrashed] == NO) {
                [self removeCrashFlagOfCube];
                for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
                    [self.currentCube.subCubes replaceObjectAtIndex:i withObject:@([self.currentCube.subCubes[i] integerValue]-1)];
                }
                [self addCrashFlagOfCube];
            }
        }
    }
    [self.theLock unlock];
    [self setCenterForCube:self.currentCube];
}

//掉方块，如果crash了，就新建一个方块
- (void)goDown {
    if (self.crashed) {
        self.currentCube = [self getCurrentCube];
        [self addCrashFlagOfCube];
        //结束判定
        if ([self isDownCrashed]) {
            [self died];
            return;
        }
        //把方块的四个cell添加到界面上
        [self.view addSubview:self.currentCube.subCube1];
        [self.view addSubview:self.currentCube.subCube2];
        [self.view addSubview:self.currentCube.subCube3];
        [self.view addSubview:self.currentCube.subCube4];
        self.crashed = NO;
    } else {
        [self.theLock lock];
        if ([self isDownCrashed]) {
            self.crashed = YES;
            [self checkScore];
        } else {
            [self removeCrashFlagOfCube];
            for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
                [self.currentCube.subCubes replaceObjectAtIndex:i withObject:@([self.currentCube.subCubes[i] integerValue]+10)];
            }
            [self addCrashFlagOfCube];
            [self setCenterForCube:self.currentCube];
        }
        [self.theLock unlock];
    }
    self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:self.currentCube.speed target:self selector:@selector(goDown) userInfo:nil repeats:NO];
}

//检查是否有行满足消去的条件，并改变得分和难度
- (void)checkScore {
    int lineCount = 0;
    for (int i = 199; i > 8; ) {
        if([self.cubeIndex[i-0] boolValue] && [self.cubeIndex[i-1] boolValue] && [self.cubeIndex[i-2] boolValue] &&
           [self.cubeIndex[i-3] boolValue] && [self.cubeIndex[i-4] boolValue] && [self.cubeIndex[i-5] boolValue] &&
           [self.cubeIndex[i-6] boolValue] && [self.cubeIndex[i-7] boolValue] && [self.cubeIndex[i-8] boolValue] &&
           [self.cubeIndex[i-9] boolValue]) {
            for (int j = i; j >= 10; j--) {
                [self.cubeIndex replaceObjectAtIndex:j withObject:self.cubeIndex[j-10]];
            }
            for (int j = 9; j >= 0; j--) {
                [self.cubeIndex replaceObjectAtIndex:j withObject:@NO];
            }
            lineCount++;
        } else {
            i = i - 10;
        }
    }
    if (lineCount != 0) {
        self.gameScore += (2*lineCount-1)*100;
        [self.gameScoreLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScore]];
        self.gameLevel = (int)(self.gameScore/1000+1);
        [self.gameLevelLabelValue setText:[NSString stringWithFormat:@"%d", self.gameLevel]];
        [self refreshCubeBox];
    }
}

// 如果继续下降，是否会碰撞
- (BOOL)isDownCrashed {
    BOOL ret = NO;
    for (int i = 0; i < [self.currentCube.subCubes count]; i++) {
        if ([self.currentCube.subCubes[i] integerValue]+10 >= 10*20) {
            //超过cubebox的下界
            ret = YES;
        } else if (![self.currentCube.subCubes containsObject:@([self.currentCube.subCubes[i] integerValue]+10)]
                   && [self.cubeIndex[[self.currentCube.subCubes[i] integerValue]+10] boolValue]) {
            //如果cell下降之后不在原来的cube中，并且与其他cube的cell重合
            ret = YES;
        }
    }
    return ret;
}

- (BOOL)isRightCrashed {
    BOOL ret = NO;
    for (int i = 0; i < [self.currentCube.subCubes count]; i++) {
        if ([self.currentCube.subCubes[i] integerValue]%10 == 9) {
            //超过cubebox的右边界
            ret = YES;
        } else if (![self.currentCube.subCubes containsObject:@([self.currentCube.subCubes[i] integerValue]+1)]
                   && [self.cubeIndex[[self.currentCube.subCubes[i] integerValue]+1] boolValue]) {
            //如果cell右移之后不在原来的cube中，并且与其他cube的cell重合
            ret = YES;
        }
    }
    return ret;
}
- (BOOL)isLeftCrashed {
    BOOL ret = NO;
    for (int i = 0; i < [self.currentCube.subCubes count]; i++) {
        if ([self.currentCube.subCubes[i] integerValue]%10 == 0) {
            //超过cubebox的左边界
            ret = YES;
        } else if (![self.currentCube.subCubes containsObject:@([self.currentCube.subCubes[i] integerValue]-1)]
                   && [self.cubeIndex[[self.currentCube.subCubes[i] integerValue]-1] boolValue]) {
            //如果cell左移之后不在原来的cube中，并且与其他cube的cell重合
            ret = YES;
        }
    }
    return ret;
}
- (BOOL)isCrashed {
    BOOL ret = NO;
    for (int i = 0; i < [self.currentCube.subCubes count]; i++) {
        if ([self.cubeIndex[[self.currentCube.subCubes[i] integerValue]] boolValue]) {
            //如果cell与其他cube的cell重合
            ret = YES;
        }
    }
    return ret;
}
- (void)whosyourdaddy {
    [self.cubeDown setFireDate:[NSDate distantFuture]];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"确定开挂？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self.cubeDown setFireDate:[NSDate date]];
                                                       }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self.cubeDown setFireDate:[NSDate date]];
                                                         }];
    [alertController addAction:actionSure];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)died {
    [self.cubeDown setFireDate:[NSDate distantFuture]];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"呵呵哒 挂了吧 😄" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"嗯，我挂了 😭"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {

                                                       }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"我怎么可能死 😡"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {

                                                         }];
    [alertController addAction:actionSure];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

//初始化其速度和位置
- (myCube *)getCurrentCube {
    myCube * cube = self.nextCube;
    [self resetNextCube];
    cube.speed = 2.0/(self.gameLevel+1);
    
    //把所有的cell添加到allCell中
    [self.allCells addObject:cube.subCube1];
    [self.allCells addObject:cube.subCube2];
    [self.allCells addObject:cube.subCube3];
    [self.allCells addObject:cube.subCube4];
    
    [self setCenterForCube:cube];
    return cube;
}

//在4种cube种随机选一个
- (void)resetNextCube {
    myCube * cube = [[myCube alloc] init];
    switch (arc4random()%4) {
        case 0:
            cube = [[CubeA alloc]init];
            break;
        case 1:
            cube = [[CubeB alloc]init];
            break;
        case 2:
            cube = [[CubeC alloc]init];
            break;
        case 3:
            cube = [[CubeD alloc]init];
            break;
        default:
            cube = [[CubeA alloc]init];
            break;
    }
    cube.previewCube.frame = CGRectMake(cube.previewX, cube.previewY, cube.previewCube.frame.size.width, cube.previewCube.frame.size.height);
    if (self.nextCube != nil) {
        [self.nextCube.previewCube removeFromSuperview];
    }
    [self.view addSubview:cube.previewCube];
    self.nextCube = cube;
}

- (void)refreshCubeBox {
    for (int i = (int)(self.allCells.count)-1; i >= 0; i--) {
        [(UIImageView *)(self.allCells[i]) removeFromSuperview];
        [self.allCells removeObjectAtIndex:i];
    }
    for (int i = 0; i < 200; i++) {
        if ([self.cubeIndex[i] boolValue] == YES) {
            UIImageView *tempCell = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeCell.png"]];
            tempCell.center = CGPointMake([self getCenterXFromCubeIndex:i], [self getCenterYFromCubeIndex:i]);
            [self.view addSubview:tempCell];
            [self.allCells addObject:tempCell];
        }
    }
}

//把当前cube的每个cell都移动到它对应的位置
- (void)setCenterForCube:(myCube *)c {
    c.subCube1.center = CGPointMake([self getCenterXFromCubeIndex:[c.subCubes[0] integerValue]],
                                    [self getCenterYFromCubeIndex:[c.subCubes[0] integerValue]]);
    c.subCube2.center = CGPointMake([self getCenterXFromCubeIndex:[c.subCubes[1] integerValue]],
                                    [self getCenterYFromCubeIndex:[c.subCubes[1] integerValue]]);
    c.subCube3.center = CGPointMake([self getCenterXFromCubeIndex:[c.subCubes[2] integerValue]],
                                    [self getCenterYFromCubeIndex:[c.subCubes[2] integerValue]]);
    c.subCube4.center = CGPointMake([self getCenterXFromCubeIndex:[c.subCubes[3] integerValue]],
                                    [self getCenterYFromCubeIndex:[c.subCubes[3] integerValue]]);
}

//根据格子的index返回格子中心的X和Y值
- (CGFloat)getCenterXFromCubeIndex:(NSInteger)index {
    return (index%10)*30+15;
}
- (CGFloat)getCenterYFromCubeIndex:(NSInteger)index {
    return (index/10)*30+67+15;
}

@end
