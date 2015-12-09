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
//一共有多少中oops的模式
#define OOPS_MODE_NUMBER 3
//迷雾最多要多少回合
#define MAX_MIST_COUNT 30
//迷雾到达最大后会持续多少回合
#define MIST_CONTINUE_COUNT 10
//迷雾最大时的不透明度
#define MAX_MIST_ALPHA 1.0
//开启异形世界后新增的奇怪cube的数量
#define STRANGE_CUBE_NUMBER 0


//游戏难度，用于计算cube下降的时间间隔
@property (nonatomic)int gameLevel;
//游戏得分，用于计算游戏的难度
@property (nonatomic)long gameScore;
//游戏得分记录
@property (nonatomic)long gameScoreRecord;
//游戏进行的次数
@property (nonatomic)long gameCountNum;
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
//第一次游戏时需显示的教程页面
@property (nonatomic,strong)UIView *guideView;
//记录
@property (nonatomic,strong)UIView *recordView;
//成就
@property (nonatomic,strong)UIView *achieveView;
//菜单中tableView的控制类
@property (nonatomic,strong)GameMenuTableViewController *gameMenuTVC;
//oops模式开始前的分数与等级
@property (nonatomic)int beforeOopsLevel;
@property (nonatomic)long beforeOopsScore;
//开启逆世界之后，左右翻转的标志，YES为翻转，NO为正常
@property (nonatomic)BOOL oppositeFlag;
//开启迷雾之后，延迟的次数，初始为10，到0结束
@property (nonatomic)int mistCount;
@property (nonatomic,strong)UIImageView *mistView;
//开启异形之后，getNextCube是否会得到奇怪cube的标志，YES为是，NO为否
@property (nonatomic)BOOL strangeFlag;
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
    self.oppositeFlag = NO;
    self.mistCount = 0;
    self.mistView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 67, 300, 600)];
    self.mistView.image = [UIImage imageNamed:@"mistViewBackground.png"];
    self.strangeFlag = NO;
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
    self.nextCube = [self getNextCube:-1];
    self.theLock = [[NSLock alloc] init];
    
    //启动方块降落的计时器
    self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(goDown) userInfo:nil repeats:NO];
    //平移手势
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCube:)];
    [self.gameView addGestureRecognizer:self.pan];
    //轻拍手势
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotateCube)];
    [self.gameView addGestureRecognizer:self.tap];
    
    self.gameCountNum = [self loadGameCountNum];
    if (self.gameCountNum == 0) {
        [self showGuideView];
    }
    self.gameCountNum++;
    [self saveGameData];

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

- (void)showGuideView {
    [self pauseGame];
    //显示暂停页面
    self.guideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.guideView.backgroundColor = [UIColor blackColor];
    self.guideView.alpha = 0.3;
    [self.view addSubview:self.guideView];
    //添加继续按钮
    UIButton *closeGuideViewButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height-100)/2, 100, 100)];
    [closeGuideViewButton setTitle:@"GUIDE" forState:UIControlStateNormal];
    [closeGuideViewButton addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.guideView addSubview:closeGuideViewButton];
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
        long getScore = (2*lineCount-1)*100*(self.oppositeFlag?2:1);
        getScore = getScore*(self.mistCount>0?1.5:1);
        getScore = getScore*(self.strangeFlag?2:1);
        [self resetGameLevelAndScore:(self.gameScore+getScore)];
        
        [self refreshCubeBox];
        //判断是否需要更新记录
        if (self.gameScore > self.gameScoreRecord) {
            //更新内存中的值
            self.gameScoreRecord = self.gameScore;
            //更新本地的值
            [self saveGameData];
            //更新label中的值
            [self.gameScoreRecordLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScoreRecord]];
        }
    }
}

- (void)died {
    [self showAlertMessage:@"施主 走好 不送 再来否？" ifYes:^{[self restartGame];} ifNO:^{[self quitGame];}];
}

- (void)restartGame {
    self.gameCountNum++;
    [self saveGameData];
    //重置级别和分数
    [self resetGameLevelAndScore:0];
    self.delayCount = 0;
    self.oppositeFlag = NO;
    self.mistCount = 0;
    self.strangeFlag = NO;
    
    [self clearCubeBox];
}

- (void)resetGameLevelAndScore:(long)score {
    if (score < 0) {
        score = 0;
    }
    self.gameScore = score;
    [self.gameScoreLabelValue setText:[NSString stringWithFormat:@"%ld",self.gameScore]];
    self.gameLevel = (int)(self.gameScore/1000+1);
    [self.gameLevelLabelValue setText:[NSString stringWithFormat:@"%d", self.gameLevel]];
}

- (void) quitGame {
    //通过程序异常结束程序
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:10];
    [temp addObject:nil];
}

- (void)pauseGame {
    //暂停游戏
    [self.cubeDown setFireDate:[NSDate distantFuture]];
    [self.gameView removeGestureRecognizer:self.tap];
    [self.gameView removeGestureRecognizer:self.pan];
}

- (void)continueGame {
    //继续游戏
    [self.cubeDown setFireDate:[NSDate date]];
    [self.gameView addGestureRecognizer:self.tap];
    [self.gameView addGestureRecognizer:self.pan];
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
    UIButton *closePauseViewButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height-100)/2, 100, 100)];
    [closePauseViewButton setTitle:@"Continue" forState:UIControlStateNormal];
    [closePauseViewButton addTarget:self action:@selector(closePauseView) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseView addSubview:closePauseViewButton];
}

- (void)showRecordForMenu {
    // TODO
}

- (void)showAchieveForMenu {
    // TODO
}
- (void)exitGameForMenu {
    [self showAlertMessage:@"确认退出程序？" ifYes:^{[self quitGame];} ifNO:^{[self closeGameMenu];}];
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
        //开启迷雾世界
        if (self.mistCount > 0) {
            self.mistCount--;
            [self.mistView removeFromSuperview];
            if (self.mistCount >= ((MAX_MIST_COUNT-MIST_CONTINUE_COUNT)/2+MIST_CONTINUE_COUNT)) {
                //起雾 29~20
                [self.mistView setAlpha:MAX_MIST_ALPHA/(MAX_MIST_COUNT-MIST_CONTINUE_COUNT)*2*(MAX_MIST_COUNT-self.mistCount)];
            } else if (self.mistCount >= (MAX_MIST_COUNT-MIST_CONTINUE_COUNT)/2) {
                //正浓 19~10
                [self.mistView setAlpha:MAX_MIST_ALPHA];
            } else {
                //散了 9~0
                [self.mistView setAlpha:MAX_MIST_ALPHA/(MAX_MIST_COUNT-MIST_CONTINUE_COUNT)*2*self.mistCount];
            }
            [self.gameView addSubview:self.mistView];
            //迷雾结束了
            if (self.mistCount == 0) {
                [self showAlertMessage:[NSString stringWithFormat:@"本次世界收益为：%ld积分，欢迎回归正常世界",(self.gameScore-self.beforeOopsScore)] ifYes:^{[self passCurrentCube];} ifNO:nil];
                return;
            }
        }
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
    //判断 逆转世界 或者 异形世界 满足结束条件（level升级）
    if ((self.oppositeFlag == YES || self.strangeFlag == YES) && self.crashed == YES && self.gameLevel > self.beforeOopsLevel) {
        self.oppositeFlag = NO;
        self.strangeFlag = NO;
        [self showAlertMessage:[NSString stringWithFormat:@"本次世界收益为：%ld积分，欢迎回归正常世界",(self.gameScore-self.beforeOopsScore)] ifYes:^{
            self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:self.currentCube.speed target:self selector:@selector(goDown) userInfo:nil repeats:NO];
        } ifNO:nil];
        return;
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
    self.gameMenuView = [[UIView alloc] initWithFrame:CGRectMake(1, 68, 150, 245)]; // 200=20+45x5 150=30+120
    [self.gameMenuView setBackgroundColor:[UIColor grayColor]];
    //创建菜单view中的tableview
    self.gameMenuTVC.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, 150, 225)];
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

//暂停页面后回调这个函数继续游戏
- (void)closePauseView {
    if (self.pauseView != nil) {
        [self.pauseView removeFromSuperview];
        self.pauseView = nil;
    }
    [self continueGame];
}

- (void)closeGuideView {
    if (self.guideView != nil) {
        [self.guideView removeFromSuperview];
        self.guideView = nil;
    }
    [self continueGame];
}

# pragma mark --为其他方法服务的函数

//初始化其速度和位置
- (myCube *)getCurrentCube {
    myCube * cube = self.nextCube;
    self.nextCube = [self getNextCube:-1];
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
        if (self.oppositeFlag == YES) {
            //判断是否是在逆世界，如果是，则操作相反
            deltaPoint.x = deltaPoint.x * -1;
        }
        [self horizontalMove:(int)(deltaPoint.x)];
        [sender setTranslation:CGPointZero inView:self.gameView];
    }
    if (self.oppositeFlag == YES && deltaPoint.y < -15) {
        //判断是否是在逆世界，如果是，则操作相反
        [self verticalMove];
        [sender setTranslation:CGPointZero inView:self.gameView];
    }
    if (self.oppositeFlag == NO && deltaPoint.y > 15) {
//        [self downToBottom];
        [self verticalMove];
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

- (void)verticalMove {
    [self.theLock lock];
    if ([self isDownCrashed] == NO) {
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

- (BOOL)saveGameData {
    NSMutableData *recordArchiverData = [NSMutableData data];
    NSKeyedArchiver *recordArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:recordArchiverData];
    [recordArchiver encodeInt64:self.gameScoreRecord forKey:@"GameScoreRecord"];
    [recordArchiver encodeInt64:self.gameCountNum forKey:@"GameCountNum"];
    [recordArchiver finishEncoding];
    return [recordArchiverData writeToFile:self.recordPath atomically:YES];
}

- (long)loadGameCountNum {
    //1. 从磁盘读取文件，生成NSData实例
    NSData *unarchiverData = [NSData dataWithContentsOfFile:self.recordPath];
    //2. 根据Data实例创建和初始化解归档对象
    NSKeyedUnarchiver *unachiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:unarchiverData];
    return [unachiver decodeInt64ForKey:@"GameCountNum"];
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
    if ([DismissFlag isEqualToString:@""] || [DismissFlag isEqualToString:@"Oops! Good luck!"]) {
        return YES;
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
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        if (self.gameScore < 500) {
            [DismissFlag appendString:@"您的积分低于500，不足以召唤神龙"];
        } else {
            [self showAlertMessage:@"【召唤神龙】需要500积分，请再次点击以确认召唤" ifYes:^{
                if (self.gameScore >= 500) {
                    self.gameScore -= 500;
                    [self resetGameLevelAndScore:self.gameScore];
                    self.nextCube = [self getNextCube:3];
                    [self passCurrentCube];
                }
                [self continueGame];
            } ifNO:^{[self continueGame];}];
        }
    }];
    [menuView addMenuItemWithTitle:@"清除" andIcon:[UIImage imageNamed:@"clear.png"] andSelectedBlock:^{
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        if (self.gameScore < 2000) {
            [DismissFlag appendString:@"您的积分低于2000，不足以执行清除计划"];
        } else {
            [self showAlertMessage:@"【清除计划】需要2000积分，请再次点击以确认执行" ifYes:^{
                if (self.gameScore >= 2000) {
                    self.gameScore -= 2000;
                    [self resetGameLevelAndScore:self.gameScore];
                    [self clearCubeBox];
                    [self.gameView addGestureRecognizer:self.tap];
                    [self.gameView addGestureRecognizer:self.pan];
                }
            } ifNO:^{[self continueGame];}];
        }
    }];
    [menuView addMenuItemWithTitle:@"Oops" andIcon:[UIImage imageNamed:@"oops.png"] andSelectedBlock:^{
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        [DismissFlag appendString:@"Oops! Good luck!"];
        if (self.oppositeFlag == YES || self.mistCount != 0 || self.strangeFlag == YES) {
            [self showAlertMessage:@"请先完成本世界的任务！" ifYes:^{[self continueGame];} ifNO:nil];
            return;
        }
        [self getRandomMode];
    }];
    [menuView addMenuItemWithTitle:@"延迟" andIcon:[UIImage imageNamed:@"delay.png"] andSelectedBlock:^{
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        if (self.gameScore < 1000) {
            [DismissFlag appendString:@"您的积分低于1000，不足以施放延迟魔法"];
        } else {
            [self showAlertMessage:@"【延迟魔法】需要1000积分，请再次点击以确认施放" ifYes:^{
                if (self.gameScore >= 1000) {
                    self.gameScore -= 1000;
                    [self resetGameLevelAndScore:self.gameScore];
                    self.delayCount = 10;
                    [self passCurrentCube];
                    [self continueGame];
                }
            } ifNO:^{[self continueGame];}];
        }
        
    }];
    [menuView addMenuItemWithTitle:@"返回" andIcon:[UIImage imageNamed:@"exit.png"] andSelectedBlock:^{
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        [self continueGame];
    }];
    [menuView addMenuItemWithTitle:@"未知" andIcon:[UIImage imageNamed:@"xcode.png"] andSelectedBlock:^{
        [DismissFlag deleteCharactersInRange:NSMakeRange(0,[DismissFlag length])];
        //TODO
        [self continueGame];
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
    self.nextCube = [self getNextCube:-1];
    self.crashed = YES;
    //继续游戏
    //如果存在则销毁定时器
    if (self.cubeDown != nil) {
        [self.cubeDown invalidate];
    }
    self.cubeDown = [NSTimer scheduledTimerWithTimeInterval:self.currentCube.speed target:self selector:@selector(goDown) userInfo:nil repeats:NO];
}

- (void)getRandomMode {
    // 随机选择一个模式
    int oopsMode = arc4random()%OOPS_MODE_NUMBER;

    switch (oopsMode) {
        case 0: {
            //逆世界
            [self showAlertMessage:@"世界主题：《逆转未来》\n世界描述：左右上下相反\n世界奖励：所得积分翻倍\n生存目标：Level上升1级\n放弃惩罚：扣除500积分\n失败惩罚：死亡" ifYes:^{
                self.oppositeFlag = YES;
                self.beforeOopsLevel = self.gameLevel;
                self.beforeOopsScore = self.gameScore;
                [self continueGame];
            } ifNO:^{
                self.gameScore = self.gameScore<500?0:self.gameScore-500;
                [self resetGameLevelAndScore:self.gameScore];
                [self continueGame];
            }];
        
            break;
        }
        case 1: {
            //迷雾
            [self showAlertMessage:@"世界主题：《迷雾》\n世界描述：听说高的地方雾大\n世界奖励：所得积分x1.5\n生存目标：坚持30回合\n放弃惩罚：扣除200积分\n失败惩罚：死亡" ifYes:^{
                self.mistCount = MAX_MIST_COUNT;
                self.beforeOopsScore = self.gameScore;
                [self continueGame];
            } ifNO:^{
                self.gameScore = self.gameScore<200?0:self.gameScore-200;
                [self resetGameLevelAndScore:self.gameScore];
                [self continueGame];
            }];

            break;
        }
        case 2: {
            // 异形
            [self showAlertMessage:@"世界主题：《异形》\n世界描述：长得残非我错\n世界奖励：所得积分翻倍\n生存目标：Level上升1级\n放弃惩罚：扣除1000积分\n失败惩罚：死亡" ifYes:^{
                self.strangeFlag = YES;
                self.beforeOopsLevel = self.gameLevel;
                self.beforeOopsScore = self.gameScore;
                [self continueGame];
            } ifNO:^{
                self.gameScore = self.gameScore<1000?0:self.gameScore-1000;
                [self resetGameLevelAndScore:self.gameScore];
                [self continueGame];
            }];
            
            break;
        }
    }
}

- (void)showAlertMessage:(NSString *)msg ifYes:(void(^)(void))doYes ifNO:(void(^)(void))doNo {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    if (doYes != nil) {
        UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确认"
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               doYes();
                                                           }];
        [alertController addAction:actionSure];
    }
    if (doNo != nil) {
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 doNo();
                                                             }];
        [alertController addAction:actionCancel];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
