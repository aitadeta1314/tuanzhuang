//
//  MainNavigationViewController.m
//  tuanzhuang
//
//  Created by red on 2017/12/6.
//  Copyright © 2017年 red. All rights reserved.
//

#import "MainNavigationViewController.h"

@interface MainNavigationViewController ()

@end

@implementation MainNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.barTintColor = skyColor;
    [self.navigationBar setShadowImage:[UIImage new]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    UIViewController *topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    viewController.navigationItem.backBarButtonItem = backButtonItem;
    
    [super pushViewController:viewController animated:animated];
    
}

/*
-(BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
