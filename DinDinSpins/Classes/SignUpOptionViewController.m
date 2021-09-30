//
//  SignUpOptionViewController.m
//  DinDinSpins
//
//  Created by developer on 02/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SignUpOptionViewController.h"
#import "SignUpViewController.h"

@interface SignUpOptionViewController ()

@end

@implementation SignUpOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [AppStateManager sharedInstance].app_theme = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onUserSignUp:(id)sender {
    [AppStateManager sharedInstance].app_theme = APP_TEHME_CUSTOMER;
    [self gotoSignUp];
}

- (IBAction)onRestaurantSignUp:(id)sender {
    [AppStateManager sharedInstance].app_theme = APP_THEME_BUSINESS;
    [self gotoSignUp];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) gotoSignUp {
    SignUpViewController *vc = (SignUpViewController *)[Util getNewViewControllerFromStoryBoard:@"SignUpViewController"];
    if (self.user){
        vc.preUser = self.user;
    }
    [self.navigationController pushViewController:vc animated:YES];
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
