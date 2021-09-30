//
//  OfferViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "OfferViewController.h"

@interface OfferViewController ()
{
    
    IBOutlet UILabel *lblOfferdetailTitle;
    IBOutlet UILabel *lblOffername;
    IBOutlet UITextView *txtOfferDetails;
}
@end

@implementation OfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    lblOffername.text = self.object[PARSE_OFFER_NAME];
    lblOfferdetailTitle.text = self.object[PARSE_OFFER_NAME];
    txtOfferDetails.text = self.object[PARSE_OFFER_DETAILS];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
