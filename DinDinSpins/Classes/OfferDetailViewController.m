//
//  OfferDetailViewController.m
//  DinDinSpins
//
//  Created by developer on 27/02/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "OfferDetailViewController.h"

@interface OfferDetailViewController ()
{
    IBOutlet UILabel *lblOfferName;
    IBOutlet UILabel *lblOfferDetailName;
    IBOutlet UITextView *txtDetails;
    IBOutlet UILabel *lblExpire;
}
@end

@implementation OfferDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblOfferName.text = self.object[PARSE_OFFER_NAME];
    lblOfferDetailName.text = self.object[PARSE_OFFER_NAME];
    txtDetails.text = self.object[PARSE_OFFER_DETAILS];
    lblExpire.text = [NSString stringWithFormat:@"Expiration date %@", [Util getExpireDateString:self.object[PARSE_OFFER_EXPIRE]]];
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
