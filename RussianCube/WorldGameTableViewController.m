//
//  WorldGameTableViewController.m
//  RussianCube
//
//  Created by andy.yao on 12/11/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import "WorldGameTableViewController.h"

@interface WorldGameTableViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSArray *menu;
@property (nonatomic,strong)NSArray *menuImage;
@end

@implementation WorldGameTableViewController

- (NSArray *)menu {
    if (_menu == nil) {
        _menu= @[@[@"重新开始"],
                 @[@"暂停游戏"],
                 @[@"查看记录"],
                 @[@"查看成就"],
                 @[@"回主菜单"]
                 ];
    }
    return _menu;
}
- (NSArray *)menuImage {
    if (_menuImage == nil) {
        _menuImage = @[@[@"menu_restart.png"],
                       @[@"menu_pause.png"],
                       @[@"menu_record.png"],
                       @[@"menu_achieve.png"],
                       @[@"menu_return.png"]
                       ];
    }
    return _menuImage;
}

- (WorldGameTableViewController *)init {
    self = [super init];
    if (self != nil) {
        self.rootViewController = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.menu count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndetifier = @"worldGameMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
    }
    
    //设置每个cell的标题
    cell.textLabel.text = self.menu[indexPath.section][0];
    
    //ios7之后，UITabelView内容使用margin layout，所以设置分割线位置会失败，这里把这个这个设定关了
    [cell setPreservesSuperviewLayoutMargins:NO];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    //设置cell左侧的图片
    //    cell.imageView.image = [UIImage imageNamed:self.menuImage[indexPath.section]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

#pragma mark - Table view Event
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            [self.rootViewController restartGameForMenu];
            break;
        case 1:
            [self.rootViewController pauseGameForMenu];
            break;
        case 2:
            [self.rootViewController showRecordForMenu];
            break;
        case 3:
            [self.rootViewController showAchieveForMenu];
            break;
        case 4:
            [self.rootViewController returnToLaunchViewForMenu];
            break;
        default:
            break;
    }
}


@end
