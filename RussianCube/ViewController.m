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
#import "CubeE.h"
#import "CubeF.h"
#import "CubeG.h"
#import "CHTumblrMenuView.h"
#import "GameMenuTableViewController.h"

@interface ViewController ()

//一共多少中cube，用于getNextCube的时候需要用到
#define CUBE_TYPE_NUMBER 7

//游戏难度，用于计算cube下降的时间间隔
@property (nonatomic)int gameLevel;
//游戏得分，用于计算游戏的难度
@property (nonatomic)long gameScore;
//游戏得分记录
@property (nonatomic)long gameScoreRecord;
//显示游戏难度的label
@property (nonatomic,strong)UILabel *gameLevelLabelValue;
//显示游戏得分的label
@property (nonatomic,strong)UILabel *gameScoreLabelValue;
//显示游戏得分记录的label
@property (nonatomic,strong)UILabel *gameScoreRecordLabelValue;
//归档的位置
@property (nonatomic,strong)NSString *recordPath;
//记录所有10x20个格子中是否已被cube的cell填充，YES/NO
@property (nonatomic,strong)NSMutableArray *cubeIndex;
//用于存储所有cell的UIImageView
@property (nonatomic,strong)NSMutableArray *allCells;
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
//自定义轻拍手势
@property (nonatomic,strong)UITapGestureRecognizer *tap;
//自定义菜单出现时的轻拍手势
@property (nonatomic,strong)UITapGestureRecognizer *menuTap;
//自定义平移手势
@property (nonatomic,strong)UIPanGestureRecognizer *pan;
//菜单
@property (nonatomic,strong)UIView *gameMenuView;
//游戏
@property (nonatomic,strong)UIView *gameView;
//暂停
@property (nonatomic,strong)UIView *pauseView;
//记录
@property (nonatomic,strong)UIView *recordView;
//成就
@property (nonatomic,strong)UIView *achieveView;
//菜单中tableView的控制类
@property (nonatomic,strong)GameMenuTableViewController *gameMenuTVC;
//开启延迟之后，延迟的次数，初始为10，到0结束
@property (nonatomic)int delayCount;

@end

static NSMutableString *DismissFlag = nil;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //=====初始化属性======
    self.gameLevel = 1;
    self.gameScore = 0;
    DismissFlag = 0;
    self.delayCount = 0;
    //初始化游戏等分记录归档的位置
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.recordPath = [documentPath stringByAppendingPathComponent:@"data.archiver"];
    //读取记录到属性
    self.gameScoreRecord = [self loadGameRecord];
    //初始化cubeIndex，全部为NO
    self.cubeIndex = [[NSMutableArray alloc] initWithCapacity:10*20];
    self.allCells = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10*20; i++) {
        [self.cubeIndex addObject:@NO];
    }
    //初始化菜单控制类
    self.gameMenuTVC = [[GameMenuTableViewController alloc] init];
    self.gameMenuTVC.rootViewController = self;
    
    //初始化最初的界面
    [self initUI];
    
    //初始化碰撞判定为YES，在goDown中用到
    self.crashed = YES;
    self.currentCube = nil;
    self.nextCube = [self getNextCube:CUBE_TYPE_NUMBER];
    self.theLock = [[NSLock alloc] init];
    
    //启动方块降落的计时器
    self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(goDown) userInfo:nil repeats:NO];
    //平移手势
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCube:)];
    [self.gameView addGestureRecognizer:self.pan];
    //轻拍手势
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotateCube)];
    [self.gameView addGestureRecognizer:self.tap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI {
    self.gameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.gameView];
    //俄罗斯方块的主体盒子
    UIImageView *cubeBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeBox.png"]];
    [self.gameView addSubview:cubeBox];
    //游戏的标题
    UILabel *gameTitle = [[UILabel alloc] initWithFrame:CGRectMake((self.gameView.frame.size.width - 200)/2, 25, 200, 40)];
    [gameTitle setText:@"Russian Cube"];
    [gameTitle setTextAlignment:NSTextAlignmentCenter];
    gameTitle.font = [UIFont boldSystemFontOfSize:20];
    [self.gameView addSubview:gameTitle];
    //游戏菜单按钮 (丑！ 还要改！！！)
    UIButton *gameMenu = [[UIButton alloc] initWithFrame:CGRectMake(5, 30, 35, 35)];
    [gameMenu setImage:[UIImage imageNamed:@"gameMenu.png"] forState:UIControlStateNormal];
    [gameMenu addTarget:self action:@selector(showGameMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.gameView addSubview:gameMenu];
    //游戏级别
    UILabel *gameLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 200, 75, 20)];
    [gameLevelLabel setText:@"- LEVEL -"];
    [gameLevelLabel setTextAlignment:NSTextAlignmentCenter];
    [self.gameView addSubview:gameLevelLabel];
    //游戏级别的值
    self.gameLevelLabelValue = [[UILabel alloc] initWithFrame:CGRectMake(300, 220, 75, 20)];
    [self.gameLevelLabelValue setText:[NSString stringWithFormat:@"%d",self.gameLevel]];
    [self.gameLevelLabelValue setTextAlignment:NSTextAlignmentCenter];
    [self.gameView addSubview:self.gameLevelLabelValue];
    //游戏得分
    UILabel *gameScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 250, 75, 20)];
    [gameScoreLabel setText:@"-SCORE-"];
    [gameScoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.gameView addSubview:gameScoreLabel];
    //游戏得分的值
    self.gameScoreLabelValue = [[UILabel alloc] initWithFrame:CGRectMake(300, 270, 75, 20)];
    [self.gameScoreLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScore]];
    [self.gameScoreLabelValue setTextAlignment:NSTextAlignmentCenter];
    [self.gameView addSubview:self.gameScoreLabelValue];
    //游戏最高得分记录
    UILabel *gameScoreRecordLabel = [[UILabel alloc] initWithFrame:CGRectMake(300, 300, 75, 20)];
    [gameScoreRecordLabel setText:@"-Record-"];
    [gameScoreRecordLabel setTextAlignment:NSTextAlignmentCenter];
    [self.gameView addSubview:gameScoreRecordLabel];
    //游戏最高得分记录的值
    self.gameScoreRecordLabelValue = [[UILabel alloc] initWithFrame:CGRectMake(300, 320, 75, 20)];
    [self.gameScoreRecordLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScoreRecord]];
    [self.gameScoreRecordLabelValue setTextAlignment:NSTextAlignmentCenter];
    [self.gameView addSubview:self.gameScoreRecordLabelValue];

    //开挂按钮，后期要改掉的
    UIButton *whosyourdaddy = [[UIButton alloc] initWithFrame:CGRectMake(300, 350, 75, 20)];
    [whosyourdaddy setTitle:@"挂逼点此" forState:UIControlStateNormal];
    whosyourdaddy.layer.borderWidth = 1;
    whosyourdaddy.layer.borderColor = [[UIColor blueColor]CGColor];
    [whosyourdaddy setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [whosyourdaddy addTarget:self action:@selector(whosyourdaddy) forControlEvents:UIControlEventTouchUpInside];
    [self.gameView addSubview:whosyourdaddy];
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
        //判断是否需要更新记录
        if (self.gameScore > self.gameScoreRecord) {
            //更新内存中的值
            self.gameScoreRecord = self.gameScore;
            //更新本地的值
            [self saveGameRecord:self.gameScoreRecord];
            //更新label中的值
            [self.gameScoreRecordLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScoreRecord]];
        }
    }
}

- (void)died {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"呵呵哒 挂了吧 😄" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"嗯，我挂了 😭"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                       }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"我怎么可能死 😡"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self restartGame];
                                                         }];
    [alertController addAction:actionSure];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)restartGame {
    //重置级别和分数
    self.gameLevel = 1;
    [self.gameLevelLabelValue setText:[NSString stringWithFormat:@"%d", self.gameLevel]];
    self.gameScore = 0;
    [self.gameScoreLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScore]];
    
    [self clearCubeBox];
}

- (void)pauseGame {
    //暂停游戏
    [self.cubeDown setFireDate:[NSDate distantFuture]];
    [self.gameView removeGestureRecognizer:self.tap];
    [self.gameView removeGestureRecognizer:self.pan];
}

#pragma mark -- 菜单功能的相关函数

- (void)restartGameForMenu {
    [self closeGameMenu];
    [self restartGame];
}

- (void)pauseGameForMenu {
    [self closeGameMenu];
    [self pauseGame];
    //显示暂停页面
    self.pauseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.pauseView.backgroundColor = [UIColor blackColor];
    self.pauseView.alpha = 0.3;
    [self.view addSubview:self.pauseView];
    //添加继续按钮
    UIButton *continueGameButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height-100)/2, 100, 100)];
    [continueGameButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueGameButton addTarget:self action:@selector(continueGame) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseView addSubview:continueGameButton];
}

- (void)showRecordForMenu {
    // TODO
}

- (void)showAchieveForMenu {
    // TODO
}

# pragma mark --各种selector中的回调函数

//掉方块，如果crash了，就新建一个方块
- (void)goDown {
    if (self.crashed) {
        self.currentCube = [self getCurrentCube];
        [self addCrashFlagOfCube];
        //把方块的四个cell添加到界面上
        [self.gameView addSubview:self.currentCube.subCube1];
        [self.gameView addSubview:self.currentCube.subCube2];
        [self.gameView addSubview:self.currentCube.subCube3];
        [self.gameView addSubview:self.currentCube.subCube4];
        //结束判定
        if ([self isDownCrashed]) {
            [self died];
            return;
        }
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

// 显示游戏菜单
- (void)showGameMenu {
    if (self.gameMenuView) {
        //点击了菜单之后，用户可能会再次点击菜单按钮以试图关闭菜单。
        [self closeGameMenu];
        return;
    }
    //暂停游戏先~
    [self pauseGame];
    
    //创建游戏菜单view
    self.gameMenuView = [[UIView alloc] initWithFrame:CGRectMake(1, 68, 150, 200)]; // 200=20+45x4 150=30+120
    [self.gameMenuView setBackgroundColor:[UIColor grayColor]];
    //创建菜单view中的tableview
    self.gameMenuTVC.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, 150, 180)];
    //关闭回弹效果
    [self.gameMenuTVC.tableView setBounces:NO];
    self.gameMenuTVC.tableView.delegate = self.gameMenuTVC;
    self.gameMenuTVC.tableView.dataSource = self.gameMenuTVC;
    
    [self.gameMenuView addSubview:self.gameMenuTVC.tableView];
    [self.view addSubview:self.gameMenuView];
    //添加关闭菜单的手势
    self.menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeGameMenu)];
    [self.gameView addGestureRecognizer:self.menuTap];
}

//关闭游戏菜单
- (void)closeGameMenu {
    if (self.gameMenuView != nil) {
        [self.gameMenuView removeFromSuperview];
        self.gameMenuView = nil;
    }
    [self.gameView removeGestureRecognizer:self.menuTap];
    //继续游戏
    [self continueGame];
}

- (void)continueGame {
    if (self.pauseView != nil) {
        [self.pauseView removeFromSuperview];
        self.pauseView = nil;
    }
    [self.cubeDown setFireDate:[NSDate date]];
    [self.gameView addGestureRecognizer:self.tap];
    [self.gameView addGestureRecognizer:self.pan];
}
# pragma mark --为其他方法服务的函数

//初始化其速度和位置
- (myCube *)getCurrentCube {
    myCube * cube = self.nextCube;
    self.nextCube = [self getNextCube:CUBE_TYPE_NUMBER];
    if (self.delayCount > 0) {
        cube.speed = 1;
        [self.gameView setAlpha:(1-0.7/10*self.delayCount--)];
    }else {
        cube.speed = 2.0/(self.gameLevel+1);
        [self.gameView setAlpha:1];
    }
    
    //把所有的cell添加到allCell中
    [self.allCells addObject:cube.subCube1];
    [self.allCells addObject:cube.subCube2];
    [self.allCells addObject:cube.subCube3];
    [self.allCells addObject:cube.subCube4];
    
    [self setCenterForCube:cube];
    return cube;
}

//在多种cube种随机选一个，并显示在预览窗口
- (myCube *)getNextCube:(int)cubeType {
    myCube * cube = [[myCube alloc] init];
    if (cubeType < 0 || cubeType >= CUBE_TYPE_NUMBER) {
        cubeType = arc4random()%CUBE_TYPE_NUMBER;
    }
    switch (cubeType) {
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
        case 4:
            cube = [[CubeE alloc]init];
            break;
        case 5:
            cube = [[CubeF alloc]init];
            break;
        case 6:
            cube = [[CubeG alloc]init];
            break;
        default:
            cube = [[CubeA alloc]init];
            break;
    }
    cube.previewCube.frame = CGRectMake(cube.previewX, cube.previewY, cube.previewCube.frame.size.width, cube.previewCube.frame.size.height);
    //删除原来预览窗口中的图像
    if (self.nextCube != nil) {
        [self.nextCube.previewCube removeFromSuperview];
    }
    [self.gameView addSubview:cube.previewCube];
    return cube;
}

- (void)passCurrentCube {
    [self removeCrashFlagOfCube];
    [self.allCells removeObject:self.currentCube.subCube1];
    [self.allCells removeObject:self.currentCube.subCube2];
    [self.allCells removeObject:self.currentCube.subCube3];
    [self.allCells removeObject:self.currentCube.subCube4];
    [self.currentCube.subCube1 removeFromSuperview];
    [self.currentCube.subCube2 removeFromSuperview];
    [self.currentCube.subCube3 removeFromSuperview];
    [self.currentCube.subCube4 removeFromSuperview];
    
    self.crashed = YES;
    //继续游戏
    //如果存在则销毁定时器
    if (self.cubeDown != nil) {
        [self.cubeDown invalidate];
    }
    self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:self.currentCube.speed target:self selector:@selector(goDown) userInfo:nil repeats:NO];
}

//根据格子的index返回格子中心的X和Y值
- (CGFloat)getCenterXFromCubeIndex:(NSInteger)index {
    return (index%10)*30+15;
}

- (CGFloat)getCenterYFromCubeIndex:(NSInteger)index {
    return (index/10)*30+67+15;
}

//删除cube当前位置在cubeIndex中的记录
- (void)removeCrashFlagOfCube {
    for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
        [self.cubeIndex replaceObjectAtIndex:[self.currentCube.subCubes[i] integerValue] withObject:@NO];
    }
}

//添加cube当前位置到cubeIndex中
- (void)addCrashFlagOfCube {
    for (int i = (int)([self.currentCube.subCubes count]-1); i >= 0; i--) {
        [self.cubeIndex replaceObjectAtIndex:[self.currentCube.subCubes[i] integerValue] withObject:@YES];
    }
}

//根据cubeIndex中的记录刷新页面
- (void)refreshCubeBox {
    for (int i = (int)(self.allCells.count)-1; i >= 0; i--) {
        [(UIImageView *)(self.allCells[i]) removeFromSuperview];
        [self.allCells removeObjectAtIndex:i];
    }
    for (int i = 0; i < 200; i++) {
        if ([self.cubeIndex[i] boolValue] == YES) {
            UIImageView *tempCell = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cubeCell.png"]];
            tempCell.center = CGPointMake([self getCenterXFromCubeIndex:i], [self getCenterYFromCubeIndex:i]);
            [self.gameView addSubview:tempCell];
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

# pragma mark --对cube的操作（平移、旋转、下降）
//平移手势中的回调函数，用于获取手势移动的距离，然后判断是否需要平移cube
- (void)moveCube:(UIPanGestureRecognizer *)sender {
    CGPoint deltaPoint = [sender translationInView:self.gameView];
    if (deltaPoint.x < -15 || deltaPoint.x > 15) {
        [self horizontalMove:(int)(deltaPoint.x)];
        [sender setTranslation:CGPointZero inView:self.gameView];
    }
    if (deltaPoint.y > 50) {
        [self downToBottom];
        [sender setTranslation:CGPointZero inView:self.gameView];
    }
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


# pragma mark --get/set recodeData

- (long)loadGameRecord {
    //1. 从磁盘读取文件，生成NSData实例
    NSData *unarchiverData = [NSData dataWithContentsOfFile:self.recordPath];
    //2. 根据Data实例创建和初始化解归档对象
    NSKeyedUnarchiver *unachiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:unarchiverData];
    return [unachiver decodeInt64ForKey:@"GameScoreRecord"];
}

- (BOOL)saveGameRecord:(long)record {
    NSMutableData *recordArchiverData = [NSMutableData data];
    NSKeyedArchiver *recordArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:recordArchiverData];
    [recordArchiver encodeInt64:record forKey:@"GameScoreRecord"];
    [recordArchiver finishEncoding];
    return [recordArchiverData writeToFile:self.recordPath atomically:YES];
}


# pragma mark --碰撞判定

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


// 以下是挂逼相关的代码
# pragma mark --whosyourdaddy

+ (BOOL)ifDismissBugView {

    if ([DismissFlag isEqualToString:@"执行 召唤神龙"] || [DismissFlag isEqualToString:@"执行 清除计划"] ||
        [DismissFlag isEqualToString:@"Oops"] || [DismissFlag isEqualToString:@"执行 延迟魔法"] ||
        [DismissFlag isEqualToString:@"执行 Xcode"] || [DismissFlag isEqualToString:@"你到底还要不要开挂？！不陪你玩了 =.="] ) {
        
        return YES;
    }else if (![DismissFlag isEqualToString:@"执行"] &&![DismissFlag isEqualToString:@"执行 X"] &&
              ![DismissFlag isEqualToString:@"执行 Xc"] && ![DismissFlag isEqualToString:@"执行 Xco"] &&
              ![DismissFlag isEqualToString:@"执行 Xcod"] && ![DismissFlag isEqualToString:@"不执行"]) {
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
    }
    return NO;
}

+ (NSString *)getCodeString {
    return DismissFlag;
}
- (void)whosyourdaddy{
    //如果菜单开着的话关了它
    [self closeGameMenu];
    //暂停游戏先~
    [self pauseGame];
    
    if (DismissFlag == nil) {
        DismissFlag = [[NSMutableString alloc]init];
    }else  {
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
    }
    
    CHTumblrMenuView *menuView = [[CHTumblrMenuView alloc] init];
    [menuView addMenuItemWithTitle:@"召唤" andIcon:[UIImage imageNamed:@"callDragon.png"] andSelectedBlock:^{
        [DismissFlag appendString:@" 召唤神龙"];
        if ([ViewController ifDismissBugView]) {
            self.nextCube = [self getNextCube:3];
            [self passCurrentCube];
            [self.cubeDown setFireDate:[NSDate date]];
            [self.gameView addGestureRecognizer:self.tap];
            [self.gameView addGestureRecognizer:self.pan];
        }
    }];
    [menuView addMenuItemWithTitle:@"清除" andIcon:[UIImage imageNamed:@"clear.png"] andSelectedBlock:^{
        if ([DismissFlag isEqualToString:@"执行 X"]) {
            [DismissFlag appendString:@"c"];
        }else {
            [DismissFlag appendString:@" 清除计划"];
        }
        if ([ViewController ifDismissBugView]) {
            [self clearCubeBox];
            [self.gameView addGestureRecognizer:self.tap];
            [self.gameView addGestureRecognizer:self.pan];
        }
    }];
    [menuView addMenuItemWithTitle:@"Oops" andIcon:[UIImage imageNamed:@"oops.png"] andSelectedBlock:^{
        if ([DismissFlag isEqualToString:@"执行 Xc"]) {
            [DismissFlag appendString:@"o"];
        }else if ([DismissFlag isEqualToString:@"执行"]) {
            [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
            [DismissFlag appendString:@"Oops"];
        }else {
            [DismissFlag appendString:@" Oops"];
        }
        
        if ([ViewController ifDismissBugView]) {
            //TODO
            [self.cubeDown setFireDate:[NSDate date]];
            [self.gameView addGestureRecognizer:self.tap];
            [self.gameView addGestureRecognizer:self.pan];
        }
    }];
    [menuView addMenuItemWithTitle:@"延迟" andIcon:[UIImage imageNamed:@"delay.png"] andSelectedBlock:^{
        if ([DismissFlag isEqualToString:@"执行 Xco"]) {
            [DismissFlag appendString:@"d"];
        }else {
            [DismissFlag appendString:@" 延迟魔法"];
        }

        if ([ViewController ifDismissBugView]) {
            self.delayCount = 10;
            [self passCurrentCube];
            [self.cubeDown setFireDate:[NSDate date]];
            [self.gameView addGestureRecognizer:self.tap];
            [self.gameView addGestureRecognizer:self.pan];
        }
    }];
    [menuView addMenuItemWithTitle:@"执行" andIcon:[UIImage imageNamed:@"exe.png"] andSelectedBlock:^{
        if ([DismissFlag isEqualToString:@"执行 Xcod"]) {
            [DismissFlag appendString:@"e"];
            //TODO
            return;
        }else if ([DismissFlag isEqualToString:@"执行"]) {
            [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
            [DismissFlag appendString:@"不"];
        }else if ([DismissFlag isEqualToString:@"不执行"]) {
            [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
            [DismissFlag appendString:@"你到底还要不要开挂？！不陪你玩了 =.="];
            [self.cubeDown setFireDate:[NSDate date]];
            [self.gameView addGestureRecognizer:self.tap];
            [self.gameView addGestureRecognizer:self.pan];
            return;
        }else {
            [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        }
        [DismissFlag appendString:@"执行"];
    }];
    [menuView addMenuItemWithTitle:@"未知" andIcon:[UIImage imageNamed:@"xcode.png"] andSelectedBlock:^{
        if ([DismissFlag isEqualToString:@"执行"]) {
            [DismissFlag appendString:@" X"];
        }else {
            [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        }
    }];
    
    [menuView show];
}

- (void)clearCubeBox {
    
    //删除所有cell
    for (int i = (int)(self.allCells.count)-1; i >= 0; i--) {
        [(UIImageView *)(self.allCells[i]) removeFromSuperview];
        [self.allCells removeObjectAtIndex:i];
    }
    //重置cubeIndex
    for (int i = 0; i < 10*20; i++) {
        [self.cubeIndex replaceObjectAtIndex:i withObject:@NO];
    }
    self.currentCube = nil;
    self.nextCube = [self getNextCube:CUBE_TYPE_NUMBER];
    self.crashed = YES;
    //继续游戏
    //如果存在则销毁定时器
    if (self.cubeDown != nil) {
        [self.cubeDown invalidate];
    }
    self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:self.currentCube.speed target:self selector:@selector(goDown) userInfo:nil repeats:NO];
}

@end
