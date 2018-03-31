//
//  CopyRightViewController.m
//  tuanzhuang
//
//  Created by Fenly on 2017/12/21.
//  Copyright © 2017年 red. All rights reserved.
//

#import "CopyRightViewController.h"

@interface CopyRightViewController ()

@end

@implementation CopyRightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_W, SCREEN_H - 64)];
    [self.view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"版权信息.png"];
    
}

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
