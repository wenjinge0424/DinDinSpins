//
//  CreatAccountViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "CreatAccountViewController.h"
#import "AddPictureViewController.h"

@interface CreatAccountViewController ()
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

@end

@implementation CreatAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNext:(id)sender {
    AddPictureViewController *vc = (AddPictureViewController *)[Util getUIViewControllerFromStoryBoard:@"AddPictureViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
