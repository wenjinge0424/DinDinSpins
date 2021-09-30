//
//  WriteReviewViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "WriteReviewViewController.h"

@interface WriteReviewViewController ()<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *txtReview;
@property (strong, nonatomic) IBOutlet UILabel *lblRestaurantName;
@property (strong, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (strong, nonatomic) PFObject *preObject;
@property NSString *placeholder;
@property (strong, nonatomic) IBOutlet UILabel *lblTheme;

@property (assign) int reviewCount, marks, sum;
@end

@implementation WriteReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _placeholder = @"Tell people what you think about this Restaurant";
    _txtReview.placeholder = _placeholder;
    _txtReview.delegate = self;
    
    self.lblRestaurantName.text = self.obj[PARSE_BUSINESS_NAME];
    _lblTheme.text = @"Write a review";
    if (self.isChange){
        _lblTheme.text = @"Update your review";
        PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REVIEW];
        [query whereKey:PARSE_REVIEW_POSTER equalTo:[PFUser currentUser]];
        [query whereKey:PARSE_REVIEW_RESTAURANT equalTo:self.obj];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            } else {
                _preObject = obj;
                int marks = [obj[PARSE_REVIEW_MARKS] intValue];
                [_ratingView setValue:marks];
                _txtReview.text = obj[PARSE_REVIEW_REVIEW];
                
                self.marks = marks;
                self.sum = [obj[PARSE_USER_REVIEW_SUM] intValue];
                self.reviewCount = [obj[PARSE_USER_REVIEW_COUNT] intValue];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onDone:(id)sender {
    NSString *review = _txtReview.text;
    review = [Util trim:review];
    if ([review isEqualToString:_placeholder]){
        review = @"";
    }
    if (review.length == 0){
        [Util showAlertTitle:self title:@"Write a review" message:@"Oops! You forgot to write your review." finish:^{
            [_txtReview becomeFirstResponder];
        }];
        return;
    }
    
    if (_isChange){
        [self updateReview];
        return;
    }
    
    PFObject *reviewObj = [PFObject objectWithClassName:PARSE_TABLE_REVIEW];
    reviewObj[PARSE_REVIEW_MARKS] = [NSNumber numberWithFloat:_ratingView.value];
    reviewObj[PARSE_REVIEW_POSTER] = [PFUser currentUser];
    reviewObj[PARSE_REVIEW_REVIEW] = review;
    [self.obj fetchIfNeeded];
    reviewObj[PARSE_REVIEW_RESTAURANT] = (PFUser *)self.obj;
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [reviewObj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (!error){
            [self callCloudFunction];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}

- (void) updateReview {
    _preObject[PARSE_REVIEW_REVIEW] = _txtReview.text;
    _preObject[PARSE_REVIEW_MARKS] = [NSNumber numberWithInt:_ratingView.value];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [_preObject saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            self.reviewCount = [self.obj[PARSE_USER_REVIEW_COUNT] intValue];
            self.sum = [self.obj[PARSE_USER_REVIEW_SUM] intValue];
            int sum = self.sum - self.marks + _ratingView.value;
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.obj.objectId, @"userId",
                                  [NSNumber numberWithInt:sum], @"reviewSum",
                                  [NSNumber numberWithInt:(int)sum/self.reviewCount], @"reviewMarks",
                                  [NSNumber numberWithInt:self.reviewCount], @"reviewCount",
                                  nil];
            [PFCloud callFunctionInBackground:@"setRatingValue" withParameters:data block:^(id object, NSError *err) {
                [SVProgressHUD dismiss];
                if (!err){
                    NSLog(@"%@", err.description);
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [Util showAlertTitle:self title:@"Error" message:[err localizedDescription]];
                }
            }];
        }
    }];
}

- (void) callCloudFunction {
    int reviewCount, marks;
    // review marks
    if (!self.obj[PARSE_USER_REVIEW_COUNT]){
        reviewCount = 1;
    } else {
        reviewCount = [self.obj[PARSE_USER_REVIEW_COUNT] intValue] + 1;
    }
    if (!self.obj[PARSE_USER_REVIEW_SUM]){
        marks = (int) _ratingView.value;
    } else {
        marks = [self.obj[PARSE_USER_REVIEW_SUM] intValue] + (int) _ratingView.value;
    }
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.obj.objectId, @"userId",
                              [NSNumber numberWithInt:marks], @"reviewSum",
                              [NSNumber numberWithInt:(int)marks/reviewCount], @"reviewMarks",
                              [NSNumber numberWithInt:reviewCount], @"reviewCount",
                              nil];
    
    [PFCloud callFunctionInBackground:@"setRatingValue" withParameters:data block:^(id object, NSError *err) {
        if (!err){
            NSLog(@"%@", err.description);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[err localizedDescription]];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}
@end
