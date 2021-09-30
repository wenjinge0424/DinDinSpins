//
//  WriteReviewViewController.h
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "SuperViewController.h"
#import "HCSStarRatingView.h"

@interface WriteReviewViewController : SuperViewController
@property (strong, nonatomic)PFObject *obj;
@property (assign) BOOL isChange;
@end
