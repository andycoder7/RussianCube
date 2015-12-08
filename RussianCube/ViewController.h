//
//  ViewController.h
//  RussianCube
//
//  Created by andy.yao on 12/3/15.
//  Copyright © 2015 andy.yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 

- (void)pauseGameForMenu;
- (void)restartGameForMenu;
- (void)showRecordForMenu;
- (void)showAchieveForMenu;
- (void)exitGameForMenu;

+ (BOOL)ifDismissBugView;
+ (NSString *)getCodeString;

@end

