//
//  OrderSummaryViewController.h
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface OrderSummaryViewController : SuperViewController
@property (strong, nonatomic) NSMutableArray *foodArray;
@property (strong, nonatomic) NSMutableArray *quantyArray;
@property (strong, nonatomic) NSMutableArray *offerArray;
@property (strong, nonatomic) GMSPlace *address;
@property (strong, nonatomic) PFObject *restaurant;
@end
