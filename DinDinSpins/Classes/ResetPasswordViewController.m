//
//  ResetPasswordViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ResetPasswordViewController.h"

@interface ResetPasswordViewController ()
{
    
    IBOutlet UITextField *txtEmail;
}
@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onReset:(id)sender {
    NSString *email = txtEmail.text;
    if (email.length == 0){
        [txtEmail resignFirstResponder];
        [Util showAlertTitle:self title:@"Reset password" message:@"Please input Email" finish:^(void) {
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    if ([email isEmail]){
        [txtEmail resignFirstResponder];
        [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                [Util showAlertTitle:self
                               title:@"Success"
                             message: [NSString stringWithFormat: @"We've sent a password reset link to your email"]
                              finish:^(void) {
                                  [self onBack:nil];
                              }];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                [Util showAlertTitle:self
                               title:@"Reset password"
                             message:errorString
                              finish:^(void) {
                              }];
            }
        }];
    } else {
        [Util showAlertTitle:self title:@"Reset password" message:@"Oops! Email address is invalid" finish:^(void) {
            [txtEmail becomeFirstResponder];
        }];
    }
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
