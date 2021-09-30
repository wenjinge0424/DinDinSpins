//
//  MyPaymentViewController.m
//  DinDinSpins
//
//  Created by developer on 10/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MyPaymentViewController.h"
#import "SRMonthPicker.h"
#import "StripeRest.h"
#import "AIDatePickerController.h"

@interface MyPaymentViewController ()<UITextFieldDelegate, SRMonthPickerDelegate>
{
    IBOutlet UITextView *descriptionView;
    IBOutletCollection(UIView) NSArray *cornerCollection;
    IBOutlet UITextField *numberField;
    IBOutlet UITextField *amountField;
    IBOutlet UITextField *cvcField;
    IBOutlet UITextField *expiryField;
    IBOutlet UILabel *lblTitle;
    
    NSDate *defaultExp;
    
    NSString *mainId;
    NSString *feeId;
    
    AIDatePickerController *datePickerViewController;
}
@end

@implementation MyPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerCollection:cornerCollection];
    [Util setBorderView:descriptionView color:MAIN_BORDER_COLOR width:1.f];
    
    defaultExp = [NSDate date];
    expiryField.text = [Util convertDate2StringWithFormat:defaultExp dateFormat:@"yyyy/MM"];
    
    amountField.text = [NSString stringWithFormat:@"$%.2f", self.total]; // amount
    lblTitle.text = [NSString stringWithFormat:@"Payment for %@", self.restaurant[PARSE_BUSINESS_NAME]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onCharge:(id)sender {
    /* Get expiryDate of charge */
    PFUser *me = [PFUser currentUser];
    NSArray *paths = [expiryField.text pathComponents];
    NSString *description = [NSString stringWithFormat:@"MAIN - '%@' paid to '%@'", [NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FIRST_NAME], me[PARSE_USER_LAST_NAME]], self.restaurant[PARSE_BUSINESS_NAME]];
    NSString *amount = [NSString stringWithFormat:@"%d", (int)self.total * 100];
    NSString *accountId = self.restaurant[PARSE_USER_BUSINESS_ACCOUNT_ID];
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     @"iOS", @"DeviceType",
                                     nil];
    NSMutableDictionary *chargeDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       amount, @"amount",
                                       @"usd", @"currency",
                                       @"false", @"capture",
                                       accountId, @"destination",
                                       description, @"description",
                                       metadata, @"metadata",
                                       nil];
    NSMutableDictionary *tokenDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       numberField.text, @"number",
                                       paths[0], @"exp_year",
                                       paths[1], @"exp_month",
                                       cvcField.text, @"cvc",
                                       @"usd", @"currency",
                                       nil],
                                      @"card",
                                      nil];
    
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [StripeRest setCharges:chargeDict tokenDict:tokenDict completionBlock:^(id response, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            [Util showAlertTitle:self title:@"" message:@"Unable to process payment. Please check your details and try again."];
        } else {
            NSDictionary *dict = response;
            mainId = dict[@"id"];
            
                    //                    NSString *message = [NSString stringWithFormat:@"%@ accepted your bid and sent $%.2f(accessible upon delivery confirmation)", me[PARSE_FIELD_USER_FULLNAME], [self.selectedBid[PARSE_FIELD_BIDS_PRICE] doubleValue]];
                    NSString *message = [NSString stringWithFormat:@"%@ ordered your food. Funds accessible upon delivery confirmation", [NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FIRST_NAME], me[PARSE_USER_LAST_NAME]]];
            NSString *email = [NSString stringWithFormat:@"You paid $%.2f", self.total];
            
                        /* save history */
                        PFObject *history = [PFObject objectWithClassName:PARSE_CLASS_PAYMENTHISTORY];
                        history[PARSE_FIELD_PAYMENTHISTORY_OWNER] = me;
                        history[PARSE_FIELD_PAYMENTHISTORY_RESTAURANT] = self.restaurant;
                        history[PARSE_FIELD_PAYMENTHISTORY_AMOUNT] = [NSNumber numberWithDouble:self.total];
                        history[PARSE_FIELD_PAYMENTHISTORY_DESCRIPTION] = descriptionView.text;
                        history[PARSE_FIELD_PAYMENTHISTORY_IS_CAPTURED] = [NSNumber numberWithBool:NO];
                        history[PARSE_FIELD_PAYMENTHISTORY_ADDRESS] = self.address;
                        history[PARSE_FIELD_PAYMENTHISTORY_NOTES] = self.notes;
                        [history save];
                        
                        /* save notification */
//                        [Util saveNotification:(PFUser *)self.restaurant type:-1 message:message address:self.address notes:self.notes];
                        [Util saveNotification:(PFUser *)self.restaurant foods:self.orders offers:self.offers quanties:self.quanties message:message address:self.address notes:self.notes amout:self.total transaction:mainId];
            
                        /* send email */
                        [Util sendEmail:me.username subject:APP_NAME message:email];
                        [Util showAlertTitle:self title:@"" message:@"Payment Success." finish:^{
                /* goto main */
                [self gotoMain];
            }];
            
      }
    }];
}
- (IBAction)onExpireDate:(id)sender {
//    CGFloat width = [[UIScreen mainScreen] bounds].size.width * 0.8;
//    CGFloat height = [[UIScreen mainScreen] bounds].size.height * 0.5;
//    
//    SRMonthPicker *datePicker = [[SRMonthPicker alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
//    datePicker.monthPickerDelegate = self;
//    datePicker.maximumYear = [components year] + 10;
//    datePicker.minimumYear = [components year];
//    datePicker.yearFirst = YES;
//    datePicker.enableColourRow = NO;
//    datePicker.date = defaultExp;
//    
//    NSMutableArray *buttonList = [[NSMutableArray alloc] initWithObjects:@"Cancel", @"Okay", nil];
//    [Util showCustomAlertView:self.view view:datePicker buttonTitleList:buttonList completionBlock:^(int buttonIndex) {
//        if (buttonIndex == 1) {
//            // Ok
//            NSDate *date = datePicker.date;
//            NSString *dateStr = [Util convertDate2StringWithFormat:date dateFormat:@"yyyy/MM"];
//            expiryField.text = dateStr;
//        }
//    }];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM"];
    NSDate *date = [dateFormatter dateFromString:@"2017/03"];
    
    // Create an instance of the picker
    datePickerViewController = [AIDatePickerController pickerWithDate:defaultExp selectedBlock:^(NSDate *selectedDate) {
        expiryField.text = [dateFormatter stringFromDate:selectedDate];
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
        defaultExp = selectedDate;
    } cancelBlock:^{
        [datePickerViewController dismissViewControllerAnimated:YES completion:nil];
        defaultExp = nil;
    }];
    
    // Present it
    [self presentViewController:datePickerViewController animated:YES completion:nil];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - TextField Delegate
- (IBAction)textFieldDidTextChanged:(id)sender {
    UITextField *tf = (UITextField *)sender;
    if (tf.text.length > 0) {
        if (tf == cvcField) {
            if (cvcField.text.length >= 3)
                [cvcField resignFirstResponder];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (textField == cvcField)
        return newLength <= 3;
    
    return YES;
}

#pragma mark - SRMonthPicker Delegate
- (void)monthPickerWillChangeDate:(SRMonthPicker *)monthPicker {
}

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker {
}
@end
