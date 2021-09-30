//
//  SettingViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SettingViewController.h"
#import "EditProfileViewController.h"
#import "CircleImageView.h"
#import "LoginViewController.h"
#import <MessageUI/MessageUI.h>
#import "ChangeAvatarViewController.h"
#import "InformViewController.h"

@interface SettingViewController ()<MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet CircleImageView *imgProfile;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) PFUser *me;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _me = [PFUser currentUser];
    [Util setImage:_imgProfile imgFile:(PFFile *)_me[PARSE_USER_AVATAR]];
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        _lblName.text = _me[PARSE_BUSINESS_NAME];
    } else if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
        _lblName.text = [NSString stringWithFormat:@"%@ %@", _me[PARSE_USER_FIRST_NAME], _me[PARSE_USER_LAST_NAME]];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [_me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [SVProgressHUD dismiss];
        [Util setImage:_imgProfile imgFile:(PFFile *)_me[PARSE_USER_AVATAR]];
        if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
            _lblName.text = _me[PARSE_BUSINESS_NAME];
        } else if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
            _lblName.text = [NSString stringWithFormat:@"%@ %@", _me[PARSE_USER_FIRST_NAME], _me[PARSE_USER_LAST_NAME]];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        [NSNotificationCenter.defaultCenter postNotificationName:@"refresh" object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onEditProfile:(id)sender {
    EditProfileViewController *vc = (EditProfileViewController *)[Util getNewViewControllerFromStoryBoard:@"EditProfileViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onAboutAPp:(id)sender {
    [self openInformationScreen:FLAG_ABOUT_THE_APP];
}
- (IBAction)onTOS:(id)sender {
    [self openInformationScreen:FLAG_TERMS_OF_SERVERICE];
}
- (IBAction)onPrivacy:(id)sender {
    [self openInformationScreen:FLAG_PRIVACY_POLICY];
}
- (void) openInformationScreen:(int) tag {
    InformViewController *vc = (InformViewController *)[Util getUIViewControllerFromStoryBoard:@"InformViewController"];
    vc.flag = tag;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onReport:(id)sender {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    if([MFMailComposeViewController canSendMail])
    {
        NSArray *toRecipients = [NSArray arrayWithObjects:@"Amark7@optimum.net",nil];
        [controller setToRecipients:toRecipients];
        controller.mailComposeDelegate = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self presentViewController:controller animated:YES completion:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else {
        [Util showAlertTitle:self title:@"Report a Problem" message:@"You cannot send mail from this device"];
    }
}
- (IBAction)onLogOut:(id)sender {
    [SVProgressHUD showWithStatus:@"Logging Out..." maskType:SVProgressHUDMaskTypeGradient];
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Log Out" message:[error localizedDescription]];
        } else {
            [Util setLoginUserName:@"" password:@""];
            for (UIViewController *vc in self.navigationController.viewControllers){
                if ([vc isKindOfClass:[LoginViewController class]]){
                    [self.navigationController popToViewController:vc animated:YES];
                    break;
                }
            }
        }
    }];
}

- (IBAction)onEditAvatar:(id)sender {
    ChangeAvatarViewController *vc = (ChangeAvatarViewController *)[Util getUIViewControllerFromStoryBoard:@"ChangeAvatarViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CircleImageView delegate
- (void) tapCircleImageView{
    
}

#pragma mark - MFMainComposeViewController delegate
#pragma mark - MFMailCompose Viewcontroller Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            NSLog(@"mail sent");
            [Util showAlertTitle:self title:@"" message:@"Message Sent!"];
        } else if (result == MFMailComposeResultFailed){
            [Util showAlertTitle:self title:@"" message:@"Message failed!"];
            NSLog(@"mail failed");
        } else if (result == MFMailComposeResultSaved){
            [Util showAlertTitle:self title:@"" message:@"Message saved!"];
            NSLog(@"mail saved");
        } else if (result == MFMailComposeResultCancelled){
            [Util showAlertTitle:self title:@"" message:@"Message cancelled!"];
            NSLog(@"mail cancelled");
        }
    }];
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
