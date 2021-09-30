//
//  OrderSummaryViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "OrderSummaryViewController.h"
#import "MyPaymentViewController.h"
#import "StripeRest.h"

@interface OrderSummaryViewController ()<UITableViewDelegate, UITableViewDataSource, GMSAutocompleteViewControllerDelegate>
{
    IBOutlet UIPlaceHolderTextView *txtNotes;
    IBOutlet UILabel *lblOfferPrice;
    IBOutlet UILabel *lblTotalPrice;
    IBOutlet UITableView *tableview;
    double food_sum, sum;
    IBOutlet UIPlaceHolderTextView *txtAddress;
}
@end

@implementation OrderSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    txtNotes.placeholder = @"Enter notes here";
    txtAddress.placeholder = @"Address";
    [Util setBorderView:txtNotes color:[UIColor lightGrayColor] width:0.5];
    
    sum = 0;
    for (int i=0;i<self.offerArray.count;i++){
        PFObject *offer = [self.offerArray objectAtIndex:i];
        double price = [offer[PARSE_OFFER_AMOUNT] doubleValue];
        sum = sum + price;
    }
    lblOfferPrice.text = [NSString stringWithFormat:@"$ %.2f", sum];
    food_sum = 0;
    for (int i=0;i<self.foodArray.count;i++){
        PFObject *food = [self.foodArray objectAtIndex:i];
        double price = [food[PARSE_FOOD_PRICE] doubleValue];
        int count = [[self.quantyArray objectAtIndex:i] intValue];
        food_sum = food_sum + price * count;
    }
    lblTotalPrice.text = [NSString stringWithFormat:@"$ %.2f", food_sum-sum];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onPay:(id)sender {
        
    if (txtAddress.text.length == 0){
        [Util showAlertTitle:self title:@"Order" message:@"Oops! You forgot to type your address."];
        return;
    }
    if (txtNotes.text.length > 300){
        [Util showAlertTitle:self title:@"Order" message:@"Oops! Note is too long." finish:^{
            [txtNotes becomeFirstResponder];
        }];
        return;
    }
    if (food_sum-sum<0){
        [Util showAlertTitle:self title:@"Order" message:@"Oops! Invalid Values." finish:^{
            [txtNotes becomeFirstResponder];
        }];
        return;
    }
    
    // check stripe account
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [self.restaurant fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Failed to submit." finish:^(void) {
            }];
        } else {
            // check stripe account
            [StripeRest getAccount:self.restaurant[PARSE_USER_BUSINESS_ACCOUNT_ID] completionBlock:^(id data, NSError *error) {
                [SVProgressHUD dismiss];
                if (error) {
                    NSString *confirmStr = @"This restaurant requires a connected ‘Stripe’ account";
                    [Util showAlertTitle:self title:@"Order" message:confirmStr finish:^(void){
                        [self onBack:nil];
                    }];
                } else {
                    MyPaymentViewController *vc = (MyPaymentViewController *)[Util getUIViewControllerFromStoryBoard:@"MyPaymentViewController"];
                    vc.total = food_sum-sum;
                    vc.restaurant = self.restaurant;
                    vc.address = txtAddress.text;
                    vc.notes = txtNotes.text;
                    vc.offers = self.offerArray;
                    vc.orders = self.foodArray;
                    vc.quanties = self.quantyArray;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
    }];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onLocation:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foodArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellDelivery"];
    PFObject *obj = [self.foodArray objectAtIndex:indexPath.row];
    int quanty = [[self.quantyArray objectAtIndex:indexPath.row] intValue];
    UILabel *lblFood = (UILabel *)[cell viewWithTag:1];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:2];
    UILabel *lblQuanty = (UILabel *)[cell viewWithTag:3];
    lblQuanty.text = [NSString stringWithFormat:@"* %d", quanty];
    lblFood.text = [NSString stringWithFormat:@"%@", obj[PARSE_FOOD_NAME]];
    double price = [obj[PARSE_FOOD_PRICE] doubleValue];
    
    lblPrice.text = [NSString stringWithFormat:@"$%.1f", price * quanty];
    return cell;
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    NSString *placeString = place.formattedAddress;
//    if (placeString.length > 30){
//        [Util showAlertTitle:self title:@"Address" message:@"Address is too long."];
//    } else {
        self.address = place;
    
    txtAddress.text = placeString;
    CGFloat fixedWidth = txtAddress.frame.size.width;
    CGSize newSize = [txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtAddress.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 35);
    txtAddress.frame = newFrame;
//    }
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
    txtAddress.text = @"";
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    txtAddress.text = @"";
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
