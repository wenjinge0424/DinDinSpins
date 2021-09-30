//
//  SignUpViewController.h
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface SignUpViewController : SuperViewController

// customer side
@property (strong, nonatomic) IBOutlet UITextField *txtFirstname;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;

// business side
@property (strong, nonatomic) IBOutlet UITextField *txtBusinessName;
@property (strong, nonatomic) IBOutlet UITextField *txtContactNumber;


// all side
@property (strong, nonatomic) PFUser *preUser;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtRePassword;
@property (strong, nonatomic) GMSPlace *address;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *txtAddress;
@property (strong, nonatomic) IBOutlet UITextField *demarkation;

@end
