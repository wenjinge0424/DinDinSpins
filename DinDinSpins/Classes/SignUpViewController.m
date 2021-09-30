//
//  SignUpViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SignUpViewController.h"
#import "AddPictureViewController.h"
#import "AppNameViewController.h"
#import "CreatAccountViewController.h"
#import "StripeConnectionViewController.h"

@interface SignUpViewController ()<GMSAutocompleteViewControllerDelegate>
{
    CGRect orginFrame;
}
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.preUser){
        _txtEmail.text = _preUser.email;
        _txtPassword.text = _preUser.password;
        _txtRePassword.text = _preUser.password;
        _txtFirstname.text = _preUser[PARSE_USER_FIRST_NAME];
        _txtLastName.text = _preUser[PARSE_USER_LAST_NAME];
        
        _txtEmail.enabled = NO;
    }
    _txtAddress.placeholder = @"Location";
    
    orginFrame = _txtAddress.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender { // customer
    if (![self onSignUpValidate]){
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    PFUser *user = [PFUser user];
    if (self.preUser){
        user = self.preUser;
    }
    user.username =  _txtEmail.text;
    user.password = _txtPassword.text;
    user.email = _txtEmail.text;
    user[PARSE_USER_FIRST_NAME] = _txtFirstname.text;
    user[PARSE_USER_LAST_NAME] = _txtLastName.text;
    user[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@ %@", _txtFirstname.text, _txtLastName.text];
    user[PARSE_USER_TYPE] = [NSNumber numberWithInt:USER_TYPE_CUSTOMER];
    user[PARSE_USER_ADDRESS] = _txtAddress.text;
    user[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLatitude:self.address.coordinate.latitude longitude:self.address.coordinate.longitude];
    
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    if (user[PARSE_USER_FACEBOOKID]){
        [user saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [Util setLoginUserName:_txtEmail.text password:_txtPassword.text];
            [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSString *message = @"Congratulation! Your account was created successfully.";
                [Util showAlertTitle:self title:@"Sign Up" message:message finish:^(void) {
                    [self login:nil];
                }];
            }];
        }];
    } else {
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                    [Util setLoginUserName:_txtEmail.text password:_txtPassword.text];
                    NSString *message = @"Congratulation! Your account was created successfully.";
                
                    [Util showAlertTitle:self title:@"Sign Up" message:message finish:^(void) {
                        if (!user[PARSE_USER_AVATAR]){
                            AddPictureViewController *vc = (AddPictureViewController *)[Util getUIViewControllerFromStoryBoard:@"AddPictureViewController"];
                            [self.navigationController pushViewController:vc animated:YES];
                        } else {
                            AppNameViewController *vc = (AppNameViewController *)[Util getNewViewControllerFromStoryBoard:@"AppNameViewController"];
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                    }];
        } else {
            NSString *message = [error localizedDescription];
            [Util showAlertTitle:self title:@"Sign Up" message:message];
        }
    }];
    }
}

- (IBAction)onSkip:(id)sender {
    AppNameViewController *vc = (AppNameViewController *)[Util getNewViewControllerFromStoryBoard:@"AppNameViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onNextBS:(id)sender { // business
    _txtBusinessName.text = [Util trim:_txtBusinessName.text];
    _txtEmail.text = [Util trim:_txtEmail.text];
    _txtPassword.text = [Util trim:_txtPassword.text];
    if (![self onSignUpValidate]){
        return;
    }
    PFUser *user = [PFUser user];
    if (self.preUser){
        user = self.preUser;
    }
    user.username =  _txtEmail.text;
    user.password = _txtPassword.text;
    user.email = _txtEmail.text;
    user[PARSE_BUSINESS_NAME] = _txtBusinessName.text;
    user[PARSE_BUSINESS_CONTACT_NUM] = _txtContactNumber.text;
    user[PARSE_USER_TYPE] = [NSNumber numberWithInt:USER_TYPE_BUSINESS];
    user[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLatitude:self.address.coordinate.latitude longitude:self.address.coordinate.longitude];
    user[PARSE_USER_ADDRESS] = _txtAddress.text;
    
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    if (user[PARSE_USER_FACEBOOKID]){
        [user saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [Util setLoginUserName:_txtEmail.text password:_txtPassword.text];
            [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSString *message = @"Congratulation! Your account was created successfully.";
                [Util showAlertTitle:self title:@"Sign Up" message:message finish:^(void) {
                    [self login:nil];
                }];
            }];
        }];
    } else
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            if (!error) {
                
                [Util setLoginUserName:_txtEmail.text password:_txtPassword.text];
                NSString *message = @"Congratulation! Your account was created successfully.";
                [Util showAlertTitle:self title:@"Sign Up" message:message finish:^(void) {
                    StripeConnectionViewController *vc = (StripeConnectionViewController *)[Util getUIViewControllerFromStoryBoard:@"StripeConnectionViewController"];
                    vc.isFromHome = NO;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
            }
        } else {
            NSString *message = [error localizedDescription];
            [Util showAlertTitle:self title:@"Sign Up" message:message];
        }
    }];
}

- (BOOL) onSignUpValidate
{
    NSString *email = _txtEmail.text;
    NSString *password = _txtPassword.text;
    NSString *rePassword = _txtRePassword.text;
    NSString *location = _txtAddress.text;
    
#ifdef DEBUG
    location = @"Texas, USA";
#endif
    
    if (location.length == 0){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Oops! You forgot to input your address." finish:^(void) {
            
        }];
        return false;
    }
    
    if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
        NSString *firstName = _txtFirstname.text;
        NSString *lastName = _txtLastName.text;
        firstName = [Util trim:firstName];
        lastName = [Util trim:lastName];
        _txtFirstname.text = firstName;
        _txtLastName.text = lastName;
        if (firstName.length == 0){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Oops! You forgot to type your first name." finish:^(void){
                [_txtFirstname becomeFirstResponder];
            }];
            return false;
        }
        if (firstName.length>20){
            [Util showAlertTitle:self title:@"Sign Up" message:@"First Name is too long." finish:^(void){
                [_txtFirstname becomeFirstResponder];
            }];
            return false;
        }
        if (lastName.length == 0){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Oops! You forgot to type your last name." finish:^(void){
                [_txtLastName becomeFirstResponder];
            }];
            return false;
        }
        if (lastName.length>20){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Last Name is too long." finish:^(void){
                [_txtLastName becomeFirstResponder];
            }];
            return false;
        }
    } else if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]) {
        NSString *businessName = _txtBusinessName.text;
        NSString *contactNumber = _txtContactNumber.text;
        
        if (businessName.length == 0){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Oops! You forgot to type your restaurant name." finish:^(void){
                [_txtBusinessName becomeFirstResponder];
            }];
            return false;
        }
        if (businessName.length > 30){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Restaurant name is too long." finish:^(void){
                [_txtBusinessName becomeFirstResponder];
            }];
            return false;
        }
        if (contactNumber.length == 0){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Oops! You forgot to type your contact number." finish:^(void){
                [_txtContactNumber becomeFirstResponder];
            }];
            return false;
        }
        if (contactNumber.length < 7){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Contact number is too short." finish:^(void){
                [_txtContactNumber becomeFirstResponder];
            }];
            return false;
        }
        if (contactNumber.length > 20){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Contact number is too long." finish:^(void){
                [_txtContactNumber becomeFirstResponder];
            }];
            return false;
        }
        if (location.length < 3){
            [Util showAlertTitle:self title:@"Sign Up" message:@"Address is too short." finish:^(void){
                [_txtAddress becomeFirstResponder];
            }];
            return false;
        }
    }

    if (email.length == 0){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Oops! You forgot to type your email address." finish:^(void) {
            [_txtEmail becomeFirstResponder];
        }];
        return false;
    } else if (![email isEmail]){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Email address is invalid." finish:^(void) {
            [_txtEmail becomeFirstResponder];
        }];
        return false;
    }
    
    if (password.length == 0){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Oops! You forgot to type your password." finish:^(void) {
            [_txtPassword becomeFirstResponder];
        }];
        return false;
    } else if (password.length < 6){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Password is too short." finish:^(void){
            [_txtPassword becomeFirstResponder];
        }];
        return false;
    } else if (password.length>20) {
        [Util showAlertTitle:self title:@"Sign Up" message:@"Password is too long." finish:^(void){
            [_txtPassword becomeFirstResponder];
        }];
        return false;
    }
    
    if (![rePassword isEqualToString:password]){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Passwords do not match" finish:^(void){
            [_txtRePassword becomeFirstResponder];
        }];
        return false;
    }
    
    return true;
}
- (IBAction)onGetLocation:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    NSString *placeString = place.formattedAddress;
//    if (placeString.length > 30){
//        [Util showAlertTitle:self title:@"Address" message:@"Address is too long."];
//    } else {
//    _txtLocation.font = [_txtLocation.font fontWithSize:[self fontSizeAddress:_txtLocation :placeString]];
        self.address = place;
//    }
    _txtAddress.frame = orginFrame;
    _txtAddress.text = placeString;
    CGFloat fixedWidth = _txtAddress.frame.size.width;
    CGSize newSize = [_txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _txtAddress.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 35);
    _txtAddress.frame = newFrame;
    
//    CGRect frame = _demarkation.frame;
//    frame.origin.y = newFrame.size.height - 35 + frame.origin.y;
//    _demarkation.frame = frame;
}

- (CGFloat) fontSizeAddress:(UITextField *)textField :(NSString *)string {
    const CGRect  textBounds = [textField textRectForBounds: textField.frame];
    const CGFloat maxWidth   = textBounds.size.width;
    
    CGFloat _originalFontSize = textField.font.pointSize;
    
    UIFont* font     = textField.font;
    CGFloat fontSize = _originalFontSize;
    
    BOOL found = NO;
    do
    {
        if( font.pointSize != fontSize )
        {
            font = [font fontWithSize: fontSize];
        }
        
        CGSize size = [string sizeWithFont: font];
        if( size.width <= maxWidth )
        {
            found = YES;
            break;
        }
        
        fontSize -= 1.0;
        if( fontSize < textField.minimumFontSize )
        {
            fontSize = textField.minimumFontSize;
            break;
        }
        
    } while( TRUE );
    
    return( fontSize );
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
//    self.txtAddress.text = @"";
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
//    self.txtAddress.text = @"";
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) login:(PFUser *)user{
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:_txtEmail.text];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:_txtPassword.text block:^(PFUser *user, NSError *error) {
                if (user) {
                    [SVProgressHUD dismiss];
                    [Util setLoginUserName:user.email password:_txtPassword.text];
                    if ([user[PARSE_USER_TYPE] intValue] == USER_TYPE_CUSTOMER){
                        [AppStateManager sharedInstance].app_theme = APP_TEHME_CUSTOMER;
                    } else {
                        [AppStateManager sharedInstance].app_theme = APP_THEME_BUSINESS;
                    }
                    if (!user[PARSE_USER_AVATAR]){
                        AddPictureViewController *vc = (AddPictureViewController *)[Util getUIViewControllerFromStoryBoard:@"AddPictureViewController"];
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        AppNameViewController *vc = (AppNameViewController *)[Util getNewViewControllerFromStoryBoard:@"AppNameViewController"];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                } else {
                    [SVProgressHUD dismiss];
                    NSString *errorString = @"Password entered is incorrect";
                    [Util showAlertTitle:self title:@"Login Failed" message:errorString info:NO];
                }
            }];
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
