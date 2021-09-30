//
//  EditProfileViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()<GMSAutocompleteViewControllerDelegate>

/* customer side */
@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *txtAddress;
@property (strong, nonatomic) IBOutlet UITextField *txtRePassword;

/* business side */
@property (strong, nonatomic) IBOutlet UITextField *txtBusinessName;
@property (strong, nonatomic) IBOutlet UITextField *txtContactNumber;
@property (strong, nonatomic) IBOutlet UITextField *txtBSEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtBSPassword;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *txtBSAddress;
@property (strong, nonatomic) IBOutlet UITextField *txtBSRePassword;

@property (nonatomic) BOOL isLoad;

@end

NSString *firstName, *lastName, *address, *tmp_restName, *tmp_contact;
PFGeoPoint *location;

@implementation EditProfileViewController
@synthesize me;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isLoad = YES;
    
    me = [PFUser currentUser];
    
    // customer side
    if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
        _txtAddress.placeholder = @"Address";
        _txtFirstName.text = me[PARSE_USER_FIRST_NAME];
        _txtLastName.text = me[PARSE_USER_LAST_NAME];
        _txtEmail.text = me.username;
//        _txtPassword.text = me.password;
//        _txtRePassword.text = me.password;
        _txtPassword.text = [Util getLoginUserPassword];
        _txtRePassword.text = [Util getLoginUserPassword];
        _originFrame = _txtAddress.frame;
        firstName = me[PARSE_USER_FIRST_NAME];
        lastName = me[PARSE_USER_LAST_NAME];
        address = me[PARSE_USER_ADDRESS];
        location = me[PARSE_USER_LOCATION];
    } else if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){ // business side
        _txtBSAddress.placeholder = @"Address";
        _txtBusinessName.text = me[PARSE_BUSINESS_NAME];
        _txtContactNumber.text = me[PARSE_BUSINESS_CONTACT_NUM];
        _txtBSEmail.text = me.username;
//        _txtBSPassword.text = me.password;
//        _txtRePassword.text = me.password;
        _txtBSPassword.text = [Util getLoginUserPassword];
        _txtBSRePassword.text = [Util getLoginUserPassword];
        _originFrame = _txtBSAddress.frame;
        
        tmp_restName = me[PARSE_BUSINESS_NAME];
        tmp_contact = me[PARSE_BUSINESS_CONTACT_NUM];
        address = me[PARSE_USER_ADDRESS];
        location = me[PARSE_USER_LOCATION];
    }
}

- (void) resetData {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    me.username = [Util getLoginUserName];
    me.email = [Util getLoginUserName];
    me.password = [Util getLoginUserPassword];
    if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
        me[PARSE_USER_FIRST_NAME] = firstName;
        me[PARSE_USER_LAST_NAME] = lastName;
        me[PARSE_USER_ADDRESS] = address;
        me[PARSE_USER_LOCATION] = location;
        me[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else {
        me[PARSE_BUSINESS_NAME] = tmp_restName;
        me[PARSE_BUSINESS_CONTACT_NUM] = tmp_contact;
        me[PARSE_USER_ADDRESS] = address;
        me[PARSE_USER_LOCATION] = location;
    }
    [me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            me = (PFUser *) object;
            
            // customer side
            if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
                [Util setLoginUserName:me.username password:me.password];
                _txtAddress.placeholder = @"Address";
                _txtFirstName.text = me[PARSE_USER_FIRST_NAME];
                _txtLastName.text = me[PARSE_USER_LAST_NAME];
                _txtEmail.text = me.username;
                //        _txtPassword.text = me.password;
                //        _txtRePassword.text = me.password;
                _txtPassword.text = [Util getLoginUserPassword];
                _txtRePassword.text = [Util getLoginUserPassword];
                
                _txtAddress.frame = _originFrame;
                _txtAddress.text = me[PARSE_USER_ADDRESS];
                CGFloat fixedWidth = _txtAddress.frame.size.width;
                CGSize newSize = [_txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                CGRect newFrame = _txtAddress.frame;
                newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
                newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 30);
                _txtAddress.frame = newFrame;
            } else if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){ // business side
                [Util setLoginUserName:me.username password:me.password];
                _txtBSAddress.placeholder = @"Address";
                _txtBusinessName.text = me[PARSE_BUSINESS_NAME];
                _txtContactNumber.text = me[PARSE_BUSINESS_CONTACT_NUM];
                _txtBSEmail.text = me.username;
                //        _txtBSPassword.text = me.password;
                //        _txtRePassword.text = me.password;
                _txtBSPassword.text = [Util getLoginUserPassword];
                _txtBSRePassword.text = [Util getLoginUserPassword];
                
                _txtBSAddress.frame = _originFrame;
                _txtBSAddress.text = me[PARSE_USER_ADDRESS];
                CGFloat fixedWidth = _txtBSAddress.frame.size.width;
                CGSize newSize = [_txtBSAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                CGRect newFrame = _txtBSAddress.frame;
                newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
                newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 30);
                _txtBSAddress.frame = newFrame;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidLayoutSubviews {
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        _txtBSAddress.frame = _originFrame;
        _txtBSAddress.text = me[PARSE_USER_ADDRESS];
        CGFloat fixedWidth = _txtBSAddress.frame.size.width;
        CGSize newSize = [_txtBSAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = _txtBSAddress.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 30);
        _txtBSAddress.frame = newFrame;
    } else {
        _txtAddress.frame = _originFrame;
        _txtAddress.text = me[PARSE_USER_ADDRESS];
        CGFloat fixedWidth = _txtAddress.frame.size.width;
        CGSize newSize = [_txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = _txtAddress.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 30);
        _txtAddress.frame = newFrame;
    }
    _isLoad = NO;
}

/* customer side */
- (IBAction)onSaveCustomerProfile:(id)sender {
    NSString *firstName = _txtFirstName.text;
    NSString *lastName = _txtLastName.text;
    NSString *location = _txtAddress.text;
    NSString *password = _txtPassword.text;
    NSString *repassword = _txtRePassword.text;
    NSString *email = _txtEmail.text;
    
    if (firstName.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! You forgot to type your first name." finish:^(void){
            [_txtFirstName becomeFirstResponder];
        }];
        return;
    }
    if (firstName.length>20){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"First Name is too long." finish:^(void){
            [_txtFirstName becomeFirstResponder];
        }];
        return;
    }
    if (lastName.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! You forgot to type your last name." finish:^(void){
            [_txtLastName becomeFirstResponder];
        }];
        return;
    }
    if (lastName.length>20){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Last Name is too long." finish:^(void){
            [_txtLastName becomeFirstResponder];
        }];
        return;
    }
    if (email.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! You forgot to type your email." finish:^(void){
            [_txtEmail becomeFirstResponder];
        }];
        return;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Email address is invalid." finish:^(void){
            [_txtEmail becomeFirstResponder];
        }];
        return;
    }
    if (location.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! Location could not be empty." finish:^(void){
            
        }];
        return;
    }
    if (password.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! You forgot to type your password." finish:^(void){
            [_txtPassword becomeFirstResponder];
        }];
        return;
    }
    if (password.length<6 || password.length>20){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! We detected a few errors. Help me review your answers." finish:^(void){
            [_txtPassword becomeFirstResponder];
        }];
        return;
    }
    if (![password isEqualToString:repassword]){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! Password do not match." finish:^(void){
            [_txtPassword becomeFirstResponder];
        }];
        return;
    }
    
    me[PARSE_USER_FIRST_NAME] = firstName;
    me[PARSE_USER_LAST_NAME] = lastName;
    me[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    me[PARSE_USER_ADDRESS] = location;
    if (self.address)
        me[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLatitude:self.address.coordinate.latitude longitude:self.address.coordinate.longitude];
    me.password = password;
    me.email = email;
    me.username = email;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (succeed && !error){
            [Util setLoginUserName:email password:password];
            [Util showAlertTitle:self title:@"Edit Profile" message:@"Successfully updated" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^{
                [self resetData];
            }];
        }
    }];
}

/* business side */
- (IBAction)onSaveBusinessProfile:(id)sender {
    NSString *businessName = _txtBusinessName.text;
    NSString *contactNum = _txtContactNumber.text;
    NSString *email = _txtBSEmail.text;
    NSString *password = _txtBSPassword.text;
    NSString *rePassword = _txtBSRePassword.text;
    NSString *location = _txtBSAddress.text;
    
    businessName = [Util trim:businessName];
    _txtBusinessName.text = businessName;
    contactNum = [Util trim:contactNum];
    _txtContactNumber.text = contactNum;
    email = [Util trim:email];
    _txtBSEmail.text = email;
    
    if (businessName.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! You forgot to type your restaurant name." finish:^(void){
            [_txtBusinessName becomeFirstResponder];
        }];
        return;
    }
    if (businessName.length > 30){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Restaurant name is too long." finish:^(void){
            [_txtBusinessName becomeFirstResponder];
        }];
        return;
    }
    if (contactNum.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! You forgot to type your contact number." finish:^(void){
            [_txtContactNumber becomeFirstResponder];
        }];
        return;
    }
    if (contactNum.length < 7){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Contact number is too short." finish:^(void){
            [_txtContactNumber becomeFirstResponder];
        }];
        return;
    }
    if (contactNum.length > 20){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Contact number is too long." finish:^(void){
            [_txtContactNumber becomeFirstResponder];
        }];
        return;
    }
    if (location.length < 3){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Address is too short." finish:^(void){
            [_txtAddress becomeFirstResponder];
        }];
        return;
    }
    if (email.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void) {
            [_txtEmail becomeFirstResponder];
        }];
        return;
    } else if (![email isEmail]){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Email address is invalid." finish:^(void) {
            [_txtEmail becomeFirstResponder];
        }];
        return;
    }
    
    if (password.length == 0){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void) {
            [_txtPassword becomeFirstResponder];
        }];
        return;
    } else if (password.length < 6 || password.length>20){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Oops! You forgot to type your Address." finish:^(void){
            [_txtPassword becomeFirstResponder];
        }];
        return;
    }
    
    if (![rePassword isEqualToString:password]){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"Password do not match" finish:^(void){
            [_txtRePassword becomeFirstResponder];
        }];
        return;
    }
    
    me[PARSE_BUSINESS_NAME] = businessName;
    me[PARSE_BUSINESS_CONTACT_NUM] = contactNum;
    me[PARSE_USER_ADDRESS] = location;
    if (self.address)
        me[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLatitude:self.address.coordinate.latitude longitude:self.address.coordinate.longitude];
    me.email = email;
    me.username = email;
    me.password = password;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (succeed && !error){
            [Util setLoginUserName:email password:password];
            [Util showAlertTitle:self title:@"Edit Profile" message:@"Successfully updated" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^{
                [self resetData];
            }];
        }
    }];
}
- (IBAction)onLoaction:(id)sender {
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
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        _txtBSAddress.frame = _originFrame;
        _txtBSAddress.text = placeString;
        me[PARSE_USER_ADDRESS] = placeString;
        CGFloat fixedWidth = _txtBSAddress.frame.size.width;
        CGSize newSize = [_txtBSAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = _txtBSAddress.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 30);
        _txtBSAddress.frame = newFrame;
    } else {
        _txtAddress.frame = _originFrame;
        _txtAddress.text = placeString;
        me[PARSE_USER_ADDRESS] = placeString;
        CGFloat fixedWidth = _txtAddress.frame.size.width;
        CGSize newSize = [_txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = _txtAddress.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 30);
        _txtAddress.frame = newFrame;
    }
    
    
    
    //    CGRect frame = _demarkation.frame;
    //    frame.origin.y = newFrame.size.height - 35 + frame.origin.y;
    //    _demarkation.frame = frame;
    
    self.address = place;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error localizedDescription]);
//    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
//        self.txtBSAddress.text = @"";
//    } else {
//        self.txtAddress.text = @"";
//    }
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
//        self.txtBSAddress.text = @"";
//        self.txtBSAddress.frame = _originFrame;
    } else {
//        self.txtAddress.text = @"";
//        self.txtAddress.frame = _originFrame;
    }
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
