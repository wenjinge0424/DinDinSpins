//
//  AddPictureViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "AddPictureViewController.h"
#import "AppNameViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AddPictureViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;
@property (strong, nonatomic) IBOutlet UILabel *txtLabel;

@end
BOOL isSetImage;
@implementation AddPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isSetImage = NO;
    if ([APP_THEME isEqualToString:@"customer"]){
//        [_txtLabel setText:@"Add Your Profile Picture"];
    } else if ([APP_THEME isEqualToString:@"business"]){
//        [_txtLabel setText:@"Add Your Restaurant Photo"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) gotoMainScreen{
    AppNameViewController *vc = (AppNameViewController *)[Util getNewViewControllerFromStoryBoard:@"AppNameViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onNext:(id)sender {
    if (isSetImage){
        [self saveImage];
        [self gotoMainScreen];
    } else {
        NSString *msg = @"Are you sure you want to proceed without a profile photo?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Yes" actionBlock:^(void) {
            [self gotoMainScreen];
        }];
        [alert addButton:@"Upload photo" actionBlock:^(void) {
            [self onChoosePhoto:nil];
        }];
        [alert showError:@"Profile Picture" subTitle:msg closeButtonTitle:nil duration:0.0f];
    }
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChoosePhoto:(id)sender {
    if (![self checkPhotoPermission]){
        return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)onTakePhoto:(id)sender {
    if (![self checkCameraPermission]){
        return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (![self checkCameraPermission]){
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    [self.imgProfile setImage:image];
    isSetImage = YES;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    isSetImage = NO;
    if (![self checkCameraPermission]){
        return;
    }
    if (![self checkPhotoPermission]){
        return;
    }
}

- (void) saveImage {
    PFUser *user = [PFUser currentUser];
    UIImage *profileImage = [Util getUploadingImageFromImage:self.imgProfile.image];
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
    user[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
    [user saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (!succeed || error){
            NSLog(@"Save Profile Image failed");
        }
    }];
}

- (BOOL)checkCameraPermission{
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
            return NO;
        }
        else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
            return YES;
        }
        return YES;
    }
    else
        return YES;
}

- (BOOL)checkPhotoPermission{
    if ( [ALAssetsLibrary authorizationStatus] !=  ALAuthorizationStatusDenied ) {
        return YES;
    } else {
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        //NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        //NSString *msg = @"You need to enable the permission to use your Photos.";
        //SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
       // alert.customViewColor = MAIN_COLOR;
        //alert.horizontalButtons = YES;
        //[alert addButton:@"Yes" actionBlock:^(void) {
         //   [[UIApplication sharedApplication] openURL:url];
        //}];
        //[alert addButton:@"Not now" actionBlock:^(void) {
         //
       // }];
        //[alert showError:@"Profile Picture" subTitle:msg closeButtonTitle:nil duration:0.0f];
        return NO;
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
