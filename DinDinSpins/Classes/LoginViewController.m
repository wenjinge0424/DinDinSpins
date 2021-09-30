//
//  LoginViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "ResetPasswordViewController.h"
#import "AppNameViewController.h"
#import "SignUpOptionViewController.h"

@interface LoginViewController ()<GIDSignInUIDelegate, GIDSignInDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtUserEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([Util getLoginUserName].length > 0){
        _txtUserEmail.text = [Util getLoginUserName];
        _txtPassword.text = [Util getLoginUserPassword];
        
        [self onLogin:nil];
    }
    
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onForgotPassword:(id)sender {
    ResetPasswordViewController *vc = (ResetPasswordViewController *)[Util getUIViewControllerFromStoryBoard:@"ResetPasswordViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) gotoMainScreen
{
    [SVProgressHUD dismiss];
    AppNameViewController *vc = (AppNameViewController *)[Util getNewViewControllerFromStoryBoard:@"AppNameViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onLogin:(id)sender {
    
#ifdef DEBUG
#endif
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    
    NSString *email = _txtUserEmail.text;
    NSString *password = _txtPassword.text;
    if (email.length == 0){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Please input email." finish:^(void) {
            [_txtUserEmail becomeFirstResponder];
        }];
        return;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Please input valid email address." finish:^(void) {
            [_txtUserEmail becomeFirstResponder];
        }];
        return;
        
    }
    if (password.length == 0) {
        [Util showAlertTitle:self title:@"Login" message:@"Please input password" finish:^(void) {
            [_txtPassword becomeFirstResponder];
        }];
        return;
    }
    [SVProgressHUD setForegroundColor:MAIN_COLOR];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:_txtUserEmail.text];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:_txtPassword.text block:^(PFUser *user, NSError *error) {
                if (user) {
                    [Util setLoginUserName:user.email password:password];
                    if ([user[PARSE_USER_TYPE] intValue] == USER_TYPE_CUSTOMER){
                        [AppStateManager sharedInstance].app_theme = APP_TEHME_CUSTOMER;
                    } else {
                        [AppStateManager sharedInstance].app_theme = APP_THEME_BUSINESS;
                    }
                    [self gotoMainScreen];
                } else {
                    [SVProgressHUD dismiss];
                    NSString *errorString = @"Password entered is incorrect";
                    [Util showAlertTitle:self title:@"Login Failed" message:errorString info:NO];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [Util setLoginUserName:@"" password:@""];
            
            NSString *msg = @"Email entered is not registered. Create an account now?";
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:@"Not Now" actionBlock:^(void) {
            }];
            [alert addButton:@"Sign Up" actionBlock:^(void) {
                [self onSignUp:self];
            }];
            [alert showError:@"SignUp" subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
}
- (IBAction)onSignUp:(id)sender {
    SignUpOptionViewController *vc = (SignUpOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOptionViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onGoogleLogin:(id)sender {
    [[GIDSignIn sharedInstance] signIn];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)onFacebookLogin:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil) {
             if (user[@"facebookid"] == nil) {
                 PFUser *puser = [PFUser user];
                 puser = user;
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self requestFacebook:puser];
             } else {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self userLoggedIn:user];
             }
         } else {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"" message:@"This email has already been used. Please try logging in."];
         }
     }];
}

- (void)requestFacebook:(PFUser *)user
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,first_name,last_name,birthday,email" forKey:@"fields"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil)
        {
            NSDictionary *userData = (NSDictionary *)result;
            [self processFacebook:user UserData:userData];
        }
        else
        {
            [Util setLoginUserName:@"" password:@""];
            [PFUser logOut];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile."];
        }
    }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
{
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             user.username = userData[@"name"];
             user.password = [Util randomStringWithLength:20];
             user[PARSE_USER_FIRST_NAME] = userData[@"first_name"];
             user[PARSE_USER_LAST_NAME] = userData[@"last_name"];
             user[PARSE_USER_FACEBOOKID] = userData[@"id"];
             if (userData[@"email"]) {
                 user.email = userData[@"email"];
                 user.username = user.email;
             } else {
                 NSString *name = [[userData[@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 user.email = [NSString stringWithFormat:@"%@@facebook.com",name];
                 user.username = user.email;
             }
             
             UIImage *profileImage = [Util getUploadingImageFromImage:responseObject];
             NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
             NSString *filename = [NSString stringWithFormat:@"avatar.png"];
             PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
             user[PARSE_USER_AVATAR] = imageFile;
             
//             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//              {
//                  [MBProgressHUD hideHUDForView:self.view animated:YES];
//                  [Util setLoginUserName:user.email password:user.password type:0];
//                  [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
//                      self.emailField.text = user.email;
//                      self.passwdField.text = user.password;
//                      [self onLogin:nil];
//                  }];
//              }];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             SignUpOptionViewController *vc = (SignUpOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOptionViewController"];
             vc.user = user;
             [self.navigationController pushViewController:vc animated:YES];
         
         } else {
             [Util setLoginUserName:@"" password:@""];
             [PFUser logOut];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [Util setLoginUserName:@"" password:@""];
         [PFUser logOut];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)userLoggedIn:(PFUser *)user {
    /* login */
    user.password = [Util randomStringWithLength:20];
    [Util setLoginUserName:user.email password:user.password];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [user saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            _txtUserEmail.text = user.email;
            _txtPassword.text = user.password;
            [self onLogin:nil];
        }];
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

//  "Sign in with Google" delegate
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (error) {
        [Util showAlertTitle:self title:@"Oops!" message:@"Failed to login Google."];
    } else {
        NSString *passwd = [Util randomStringWithLength:20];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              user.profile.email, @"username",
                              user.userID, @"googleid",
                              passwd, @"password",
                              nil];
        
        [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
        [PFCloud callFunctionInBackground:@"resetGooglePasswd" withParameters:data block:^(id object, NSError *err) {
            if (err) { // this user is not registered on parse server
                PFUser *puser = [PFUser user];
                puser.password = passwd;
                puser[PARSE_USER_FIRST_NAME] = user.profile.givenName;
                puser[PARSE_USER_LAST_NAME] = user.profile.familyName;
                puser[PARSE_USER_FULL_NAME] = [NSString stringWithFormat:@"%@ %@", user.profile.givenName, user.profile.familyName];
                puser[PARSE_USER_GOOGLEID] = user.userID;
                puser.email = user.profile.email;
                puser.username = puser.email;
                
                if (user.profile.hasImage) {
                    NSURL *imageURL = [user.profile imageURLWithDimension:50*50];
                    UIImage *im = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                    UIImage *profileImage = [Util getUploadingImageFromImage:im];
                    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                    NSString *filename = [NSString stringWithFormat:@"avatar.png"];
                    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
                    puser[PARSE_USER_AVATAR] = imageFile;
                }
                
//                [puser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    [SVProgressHUD dismiss];
//                    if (!error) {
//                        _txtUserEmail.text = user.profile.email;
//                        _txtPassword.text = passwd;
//                        [self onLogin:nil];
//                    } else {
//                        [Util showAlertTitle:self title:@"" message:@"This email has already been used. Please try logging in."];
//                    }
//                }];
                [SVProgressHUD dismiss];
                SignUpOptionViewController *vc = (SignUpOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOptionViewController"];
                vc.user = puser;
                [self.navigationController pushViewController:vc animated:YES];
            } else { // this server is registerd on parse server
                [SVProgressHUD dismiss];
                _txtUserEmail.text = user.profile.email;
                _txtPassword.text = passwd;
                [self onLogin:nil];
            }
        }];
        
    }
}

@end
