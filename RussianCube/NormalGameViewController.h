//
//  NormalGameViewController.h
//  RussianCube
//
//  Created by andy.yao on 12/11/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NormalGameViewController : UIViewController

- (void)pauseGameForMenu;
- (void)restartGameForMenu;
- (void)showRecordForMenu;
- (void)showAchieveForMenu;
- (void)returnToLaunchViewForMenu;

@end
