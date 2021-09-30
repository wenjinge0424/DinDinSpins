//
//  FilterViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "FilterViewController.h"
#import "GPUImage.h"

@interface FilterViewController ()
{
    IBOutlet UISegmentedControl *segmentPrices;
    IBOutlet UISegmentedControl *segmentRating;
    IBOutlet UISegmentedControl *segmentDistance;
    AppStateManager *instance;
}
@end

@implementation FilterViewController
@synthesize imgBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.bgImage){
        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        
        blurFilter.blurRadiusInPixels = 15.0;
        imgBackground.image = [blurFilter imageByFilteringImage:self.bgImage];
    }
    
    instance = [AppStateManager sharedInstance];
    
    double price = instance.price_top;
    if (price == 9.9){
        [segmentPrices setSelectedSegmentIndex:0];
    } else if (price == 99.9){
        [segmentPrices setSelectedSegmentIndex:1];
    } else if (price == 999.99){
        [segmentPrices setSelectedSegmentIndex:2];
    } else if (price == 1000000){
        [segmentPrices setSelectedSegmentIndex:3];
    } else {
        
    }
    
    switch (instance.rate_top) {
        case 1:
            [segmentRating setSelectedSegmentIndex:0];
            break;
        case 2:
            [segmentRating setSelectedSegmentIndex:1];
            break;
        case 3:
            [segmentRating setSelectedSegmentIndex:2];
            break;
        case 4:
            [segmentRating setSelectedSegmentIndex:3];
            break;
        case 5:
            [segmentRating setSelectedSegmentIndex:4];
            break;
        default:
            break;
    }
    
    if (instance.distance_top == 0.1){
        [segmentDistance setSelectedSegmentIndex:0];
    }
    if (instance.distance_top == -1){
        [segmentDistance setSelectedSegmentIndex:-1];
    }
    switch ((int)instance.distance_top) {
        case 1:
            [segmentDistance setSelectedSegmentIndex:1];
            break;
        case 2:
            [segmentDistance setSelectedSegmentIndex:2];
            break;
        case 5:
            [segmentDistance setSelectedSegmentIndex:3];
            break;
        case 7:
            [segmentDistance setSelectedSegmentIndex:4];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onReset:(id)sender {
    //    segmentPrices.selectedSegmentIndexes = [NSIndexSet indexSetWithIndex:0];
    segmentPrices.selectedSegmentIndex = -1;
    segmentDistance.selectedSegmentIndex = -1;
    segmentRating.selectedSegmentIndex = -1;
    
    instance.price_top = -1;
    instance.price_bottom = -1;
    instance.rate_top = -1;
    instance.rate_bottom = -1;
    instance.distance_top = -1;
    instance.distance_bottom = -1;
    instance.is_filter = NO;
}
- (IBAction)onApply:(id)sender {
    if (![self validate]){
        [Util showAlertTitle:self title:@"Filter" message:@"Please review entries." finish:^{
            [AppStateManager sharedInstance].is_filter = NO;
        }];
        return;
    }
    [Util showAlertTitle:self title:@"Filter" message:@"Your filters are applied" finish:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [AppStateManager sharedInstance].is_filter = YES;
}

- (BOOL) validate {
    //    NSIndexSet *prices = segmentPrices.selectedSegmentIndexes;
    NSInteger prices = segmentPrices.selectedSegmentIndex;
    NSInteger ratings = segmentRating.selectedSegmentIndex;
    NSInteger distance = segmentDistance.selectedSegmentIndex;
    if (prices<0 ||ratings<0 || ratings>4 || distance<0 || distance>4){
        return NO;
    }
    // Prices
    switch (prices) {
        case 0:
            instance.price_bottom = 0.0;
            instance.price_top = 9.9;
            break;
        case 1:
            instance.price_bottom = 10;
            instance.price_top = 99.9;
            break;
        case 2:
            instance.price_bottom = 100;
            instance.price_top = 999.99;
            break;
        case 3:
            instance.price_bottom = 1000;
            instance.price_top = 1000000;
            break;
        default:
            break;
    }
    //    switch (prices.lastIndex) {
    //        case 1:
    //            instance.price_top = 25000;
    //            break;
    //        case 2:
    //            instance.price_top = 25000 * 2;
    //            break;
    //        case 3:
    //            instance.price_top = 25000 * 3;
    //            break;
    //        case 4:
    //           instance.price_top = 25000 * 4;
    //            break;
    //        default:
    //            break;
    //    }
    // Ratings
    switch (ratings) {
        case 0:
            instance.rate_bottom = 1;
            instance.rate_top = 1;
            break;
        case 1:
            instance.rate_bottom = 2;
            instance.rate_top = 2;
            break;
        case 2:
            instance.rate_bottom = 3;
            instance.rate_top = 3;
            break;
        case 3:
            instance.rate_bottom = 4;
            instance.rate_top = 4;
            break;
        default:
            break;
    }
    //    switch (ratings.lastIndex) {
    //        case 1:
    //            instance.rate_top = 2;
    //            break;
    //       case 2:
    //            instance.rate_top = 3;
    //            break;
    //        case 3:
    //            instance.rate_top = 4;
    //            break;
    //        case 4:
    //            instance.rate_top = 5;
    //           break;
    //        default:
    //            break;
    //    }
    // distance
    //    switch (distances.firstIndex) {
    //        case 0:
    //            instance.distance_bottom = 0.1;
    //            break;
    //        case 1:
    //            instance.distance_bottom = 1;
    //            break;
    //        case 2:
    //            instance.distance_bottom = 2;
    //            break;
    //        case 3:
    //            instance.distance_bottom = 5;
    //            break;
    //        default:
    //            break;
    //    }
    switch (distance) {
        case 0:
            instance.distance_top = 0.1;
            break;
        case 1:
            instance.distance_top = 1;
            break;
        case 2:
            instance.distance_top = 2;
            break;
        case 3:
            instance.distance_top = 5;
            break;
        case 4:
            instance.distance_top = 7;
        default:
            break;
    }
    return YES;
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
