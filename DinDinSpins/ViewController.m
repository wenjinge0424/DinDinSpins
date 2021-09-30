//
//  ViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self gotoNextScreen];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) gotoNextScreen{
    LoginViewController *vc = (LoginViewController *)[Util getUIViewControllerFromStoryBoard:@"LoginViewController_cs"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
