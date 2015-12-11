//
//  LaunchViewController.m
//  RussianCube
//
//  Created by andy.yao on 12/10/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "LaunchViewController.h"
#import "NormalGameViewController.h"
#import "WorldGameViewController.h"

#define BUTTON_HEIGHT   50
#define TITLE_HEIGHT    40
#define GAME_BOX_WIDTH  (self.view.frame.size.width*4.0/5)
#define GAME_BOX_HEIGHT (self.view.frame.size.height*600.0/667)
#define GAME_BOX_SMALLER_TIMES 40
#define NOTIFICATION_BAR_HEIGHT 20

@interface LaunchViewController ()

@property (nonatomic,strong)UIView *launchView;
@property (nonatomic,strong)UIImageView *launchAnimationView;

@property (nonatomic,strong)NSTimer *translateProcessTimer;
@property (nonatomic,strong)NSTimer *resumeProcessTimer;
@property (nonatomic)float widthChangeInterval;
@property (nonatomic)float heightChangeInterval;
@property (nonatomic,strong)NormalGameViewController *  normalGameVC;
@property (nonatomic,strong)WorldGameViewController *   worldGameVC;
@property (nonatomic)int startTag;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startTag = 0;
    
    //创建一个和屏幕一样大的启动View
    self.launchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.launchView];
    
    //启动页面的背景动画
    self.launchAnimationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beginAnimation0.png"]];
    self.launchAnimationView.contentMode = UIViewContentModeScaleToFill;
    self.launchAnimationView.frame = CGRectMake(0, NOTIFICATION_BAR_HEIGHT, self.launchView.frame.size.width, self.launchView.frame.size.height-NOTIFICATION_BAR_HEIGHT);
    [self.launchView addSubview:self.launchAnimationView];
    [self playLaunchAnimation];
    
    //游戏标题，位于页面上1/4偏上的位置（因为没有扣除通知栏的高度）
    UILabel *gameTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, self.launchView.frame.size.height/4, self.launchView.frame.size.width, TITLE_HEIGHT)];
    [gameTitle setText:@"PRIVATE CUBE"];
    [gameTitle setFont:[UIFont boldSystemFontOfSize:40]];
    [gameTitle setTextAlignment:NSTextAlignmentCenter];
    [self.launchView addSubview:gameTitle];
    
    //游戏主目录：经典模式，世界模式，退出游戏
    UIButton *startNormalModeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.launchView.frame.size.width/3, self.launchView.frame.size.height/4*3, self.launchView.frame.size.width/3, BUTTON_HEIGHT)];
    [startNormalModeButton setTitle:@"经典模式" forState:UIControlStateNormal];
    startNormalModeButton.tag = 1;
    [startNormalModeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [startNormalModeButton addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.launchView addSubview:startNormalModeButton];
    
    UIButton *startWorldModeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.launchView.frame.size.width/3, self.launchView.frame.size.height/4*3+BUTTON_HEIGHT, self.launchView.frame.size.width/3, BUTTON_HEIGHT)];
    [startWorldModeButton setTitle:@"世界模式" forState:UIControlStateNormal];
    startWorldModeButton.tag = 2;
    [startWorldModeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [startWorldModeButton addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.launchView addSubview:startWorldModeButton];
    
    UIButton *exitGameButton = [[UIButton alloc]initWithFrame:CGRectMake(self.launchView.frame.size.width/3, self.launchView.frame.size.height/4*3+BUTTON_HEIGHT*2, self.launchView.frame.size.width/3, BUTTON_HEIGHT)];
    [exitGameButton setTitle:@"退出游戏" forState:UIControlStateNormal];
    [exitGameButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [exitGameButton addTarget:self action:@selector(exitGame) forControlEvents:UIControlEventTouchUpInside];
    [self.launchView addSubview:exitGameButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(resumeLaunchView)
               name:@"resumeLaunchView"
             object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startGame:(UIButton *)btn {
    if (self.translateProcessTimer != nil) {
        return;
    }
    self.startTag = (int)btn.tag;
    //停止背景动画
    [self.launchAnimationView stopAnimating];
    //释放图片资源
    [self.launchAnimationView setAnimationImages:nil];
    //把game box移动到最前面
    [self.launchView bringSubviewToFront:self.launchAnimationView];
    self.launchView.backgroundColor = [UIColor blackColor];
    //计算宽度和长度每次的改变值
    self.widthChangeInterval = (self.launchAnimationView.frame.size.width - GAME_BOX_WIDTH)/GAME_BOX_SMALLER_TIMES;
    self.heightChangeInterval = (self.launchAnimationView.frame.size.height - GAME_BOX_HEIGHT)/GAME_BOX_SMALLER_TIMES;
    //启动过度动画（定时器实现）
    self.translateProcessTimer = [NSTimer scheduledTimerWithTimeInterval:0.0075 target:self selector:@selector(translateProcess) userInfo:nil repeats:YES];
}


- (void)exitGame {
    [self showAlertMessage:@"确认退出程序？" ifYes:^{[self quitGame];} ifNO:^{}];
}
- (void)quitGame {
    //通过程序异常结束程序
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:10];
    [temp addObject:nil];
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

- (void)translateProcess {
    self.launchAnimationView.frame = CGRectMake(0, self.launchAnimationView.frame.origin.y+self.heightChangeInterval, self.launchAnimationView.frame.size.width-self.widthChangeInterval, self.launchAnimationView.frame.size.height-self.heightChangeInterval);
    
    //结束动画的条件
    if (self.launchAnimationView.frame.size.width <= GAME_BOX_WIDTH) {
        self.launchAnimationView.frame = CGRectMake(0, self.view.frame.size.height-GAME_BOX_HEIGHT, GAME_BOX_WIDTH, GAME_BOX_HEIGHT);
        [self.translateProcessTimer setFireDate:[NSDate distantFuture]];
        [self.translateProcessTimer invalidate];
        self.translateProcessTimer = nil;
        if (self.startTag == 1) {
            self.normalGameVC = [[NormalGameViewController alloc]init];
            [self presentViewController:self.normalGameVC animated:NO completion:nil];
        } else if (self.startTag == 2) {
            self.worldGameVC = [[WorldGameViewController alloc]init];
            [self presentViewController:self.worldGameVC animated:NO completion:nil];
        }
    }
}

- (void)resumeProcess {
    self.launchAnimationView.frame = CGRectMake(0, self.launchAnimationView.frame.origin.y-self.heightChangeInterval, self.launchAnimationView.frame.size.width+self.widthChangeInterval, self.launchAnimationView.frame.size.height+self.heightChangeInterval);
    
    //结束动画的条件
    if (self.launchAnimationView.frame.size.width >= self.launchView.frame.size.width) {
        self.launchAnimationView.frame = CGRectMake(0, NOTIFICATION_BAR_HEIGHT, self.launchView.frame.size.width, self.launchView.frame.size.height-NOTIFICATION_BAR_HEIGHT);
        [self.resumeProcessTimer setFireDate:[NSDate distantFuture]];
        [self.resumeProcessTimer invalidate];
        self.resumeProcessTimer = nil;
        self.normalGameVC = nil;
        self.worldGameVC = nil;
        [self.launchView sendSubviewToBack:self.launchAnimationView];
        self.launchView.backgroundColor = [UIColor clearColor];
        [self playLaunchAnimation];
    }
}

- (void)resumeLaunchView {
    if (self.resumeProcessTimer != nil) {
        return;
    }
    self.startTag = 0;
    self.resumeProcessTimer = [NSTimer scheduledTimerWithTimeInterval:0.0075 target:self selector:@selector(resumeProcess) userInfo:nil repeats:YES];
}

- (void)playLaunchAnimation {
    NSMutableArray  *arrayM=[NSMutableArray array];
    for (int i=0; i<6; i++) {
        [arrayM addObject:[UIImage imageNamed:[NSString stringWithFormat:@"beginAnimation%d.png",i]]];
    }
    //设置动画数组
    [self.launchAnimationView setAnimationImages:arrayM];
    //设置动画播放次数
    [self.launchAnimationView setAnimationRepeatCount:0];
    //设置动画播放时间
    [self.launchAnimationView setAnimationDuration:6*0.1];
    //开始动画
    [self.launchAnimationView startAnimating];
}

@end
