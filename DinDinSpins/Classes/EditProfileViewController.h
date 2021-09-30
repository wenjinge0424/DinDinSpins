//
//  EditProfileViewController.h
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface EditProfileViewController : SuperViewController
@property (strong, nonatomic) PFUser *me;
@property (strong, nonatomic) GMSPlace *address;
@property (nonatomic) CGRect originFrame;
@end
