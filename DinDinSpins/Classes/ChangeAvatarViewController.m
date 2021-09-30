//
//  ChangeAvatarViewController.m
//  DinDinSpins
//
//  Created by developer on 27/02/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "ChangeAvatarViewController.h"
#import "CircleImageView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ChangeAvatarViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet CircleImageView *imgProfile;
    PFUser *user;
}
@end

@implementation ChangeAvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    imgProfile.delegate = self;
    user = [PFUser currentUser];
    [Util setImage:imgProfile imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onChooseProfile:(id)sender {
    if (![self checkPhotoPermission]){
        return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
- (IBAction)onTakePickture:(id)sender {
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
    [imgProfile setImage:image];
}
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([self checkCameraPermission]){
    }
    if ([self checkPhotoPermission]){
    }
}

- (IBAction)onSave:(id)sender {
    UIImage *profileImage = [Util getUploadingImageFromImage:imgProfile.image];
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
    user[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
    [SVProgressHUD show];
    [user saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (succeed){
            [self onCancel:nil];
        } else {
            NSLog(@"update profile image failed");
        }
    }];
}
- (IBAction)onCancel:(id)sender {
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
- (void) tapCircleImageView {
    
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
        return NO;
    }
}


@end
