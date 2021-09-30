//
//  UseOfferViewController.h
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface UseOfferViewController : SuperViewController
@property (strong, nonatomic) NSMutableArray *dataArray; // food Array
@property (strong, nonatomic) NSMutableArray *quantyArray; // quanty Array
@property (strong, nonatomic) PFObject *restaurant;
@end
