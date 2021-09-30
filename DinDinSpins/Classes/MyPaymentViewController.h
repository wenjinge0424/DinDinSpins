//
//  MyPaymentViewController.h
//  DinDinSpins
//
//  Created by developer on 10/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface MyPaymentViewController : SuperViewController

@property (strong, nonatomic) PFObject *selectedBid;
@property (strong, nonatomic) PFObject *selectedRequest;

@property (nonatomic) double total;
@property (strong, nonatomic) PFObject *restaurant;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, strong) NSArray *offers;
@property (nonatomic, strong) NSArray *quanties;
@end
