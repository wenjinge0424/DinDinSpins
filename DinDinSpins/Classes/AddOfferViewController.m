//
//  AddOfferViewController.m
//  BikerLoops
//
//  Created by developer on 01/02/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "AddOfferViewController.h"
#import "AIDatePickerController.h"

@interface AddOfferViewController ()
@property (strong, nonatomic) IBOutlet UITextField *txtOfferName;
@property (strong, nonatomic) IBOutlet UITextField *txtOfferType;
@property (strong, nonatomic) IBOutlet UITextField *txtOfferAmount;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *txtOfferDetails;
@property (strong, nonatomic) IBOutlet UITextField *txtExpireDate;
@property (strong, nonatomic) AIDatePickerController *datePickerViewController;
@property (strong, nonatomic) NSDate *expire;
@end

@implementation AddOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:_txtOfferDetails];
    [Util setBorderView:_txtOfferDetails color:COLOR_GRAY_LIGHT width:0.5];
    _txtOfferDetails.placeholder = @"Offer details";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSave:(id)sender {
    if (![self isValid]){
        return;
    }
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_OFFER];
    object[PARSE_OFFER_OWNER] = [PFUser currentUser];
    object[PARSE_OFFER_NAME] = _txtOfferName.text;
    object[PARSE_OFFER_DETAILS] = _txtOfferDetails.text;
    object[PARSE_OFFER_AMOUNT] = [NSNumber numberWithDouble:[_txtOfferAmount.text doubleValue]];
    object[PARSE_OFFER_EXPIRE] = _expire;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (!error){
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
    
}

- (BOOL) isValid {
    _txtOfferName.text = [Util trim:_txtOfferName.text];
    _txtOfferDetails.text = [Util trim:_txtOfferDetails.text];
    NSString *name = _txtOfferName.text;
    NSString *details = _txtOfferDetails.text;
    double price = [_txtOfferAmount.text doubleValue];
    NSString *date = _txtExpireDate.text;
    
    if (name.length<1||name.length>20){
        [Util showAlertTitle:self title:@"Add Offer" message:@"Please review entries and try again." finish:^{
            [_txtOfferName becomeFirstResponder];
        }];
        return NO;
    }
    if (details.length<1||details.length>300){
        [Util showAlertTitle:self title:@"Add Offer" message:@"Please review entries and try again." finish:^{
            [_txtOfferDetails becomeFirstResponder];
        }];
        return NO;
    }
    if (price<0.01 || price>99999){
        [Util showAlertTitle:self title:@"Add Offer" message:@"Please review entries and try again." finish:^{
            [_txtOfferAmount becomeFirstResponder];
        }];
        return NO;
    }
    if (date.length == 0){
        [Util showAlertTitle:self title:@"Add Offer" message:@"Please review entries and try again." finish:^{
            [_txtOfferName becomeFirstResponder];
        }];
        return NO;
    }
    return YES;
}
- (IBAction)onDatePicker:(id)sender {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate date];
    
    // Create an instance of the picker
    _datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        if ([selectedDate timeIntervalSinceNow] < 0.0){
            [_datePickerViewController dismissViewControllerAnimated:YES completion:nil];
            [Util showAlertTitle:self title:@"Expire Date" message:@"Oops! You cannot select past date."];
            return;
        }
        _txtExpireDate.text = [dateFormatter stringFromDate:selectedDate];
        _expire = selectedDate;
        [_datePickerViewController dismissViewControllerAnimated:YES completion:nil];
    } cancelBlock:^{
        [_datePickerViewController dismissViewControllerAnimated:YES completion:nil];
        _expire = nil;
    }];
    
    // Present it
    [self presentViewController:_datePickerViewController animated:YES completion:nil];
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
