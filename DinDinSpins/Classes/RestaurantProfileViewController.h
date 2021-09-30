//
//  RestaurantProfileViewController.h
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"

@interface RestaurantProfileViewController : SuperViewController
@property NSInteger currentTag;
@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) NSMutableArray *dataReviewArray, *dataMenuArray, *dataOfferArray;
@property (strong, nonatomic) NSMutableArray *quantityArray;
@property (strong, nonatomic) NSMutableArray *selectedIndexOffer;

@property (strong, nonatomic) NSMutableArray *foodArray_appet, *foodArray_soups, *foodArray_main, *foodArray_salad, *foodArray_desert, *quantyArray_appet, *quantyArray_soups, *quantyArray_main, *quantyArray_salad, *quantyArray_desert, *select_appet, *select_soups, *select_main, *select_salad, *select_desert;
@end
