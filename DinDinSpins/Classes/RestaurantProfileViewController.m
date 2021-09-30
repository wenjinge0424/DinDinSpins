//
//  RestaurantProfileViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "RestaurantProfileViewController.h"
#import "WriteReviewViewController.h"
#import "UseOfferViewController.h"
#import "OfferViewController.h"
#import "AppNameViewController.h"
#import "HTHorizontalSelectionList.h"
#import "OfferDetailViewController.h"
#import "HCSStarRatingView.h"
#import "CircleImageView.h"

@interface RestaurantProfileViewController ()<UITableViewDelegate, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableViewReviews;
@property (strong, nonatomic) IBOutlet UITableView *tableViewMenus;
@property (strong, nonatomic) IBOutlet UITableView *tableViewOffers;

@property (strong, nonatomic) IBOutlet UIView *viewReviews;
@property (strong, nonatomic) IBOutlet UIView *viewMenu;
@property (strong, nonatomic) IBOutlet UIView *viewOffers;

@property (strong, nonatomic) IBOutlet UIButton *btnWriteReview;
@property (strong, nonatomic) IBOutlet UIButton *btnMenuNext;
@property (strong, nonatomic) IBOutlet UIButton *btnUseOffer;

@property (strong, nonatomic) IBOutlet HTHorizontalSelectionList *topbarList;
@property (strong, nonatomic) IBOutlet HTHorizontalSelectionList *topbarItemList;

@property (strong, nonatomic) IBOutlet UILabel *lblRestaurant;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblContactNumber;
//@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *menuItems;
@property (strong, nonatomic) IBOutlet HCSStarRatingView *ratingBar;
@property (strong, nonatomic) IBOutlet UIImageView *bgRestaurant;

@property (nonatomic) CGRect originFrame;
@property (strong, nonatomic) IBOutlet UITextView *txtAddress;

@property (strong, nonatomic) IBOutlet UILabel *lblNoresults;
@end

@implementation RestaurantProfileViewController
@synthesize currentTag, dataMenuArray, dataOfferArray, dataReviewArray, selectedIndexOffer, quantityArray, foodArray_appet, foodArray_soups, foodArray_main, foodArray_salad, foodArray_desert, quantyArray_appet, quantyArray_soups, quantyArray_main, quantyArray_salad, quantyArray_desert, select_appet, select_soups, select_main, select_salad, select_desert;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _btnWriteReview.hidden = [APP_THEME isEqualToString:@"business"];
    _btnMenuNext.hidden = [APP_THEME isEqualToString:@"business"];
    _btnUseOffer.hidden = [APP_THEME isEqualToString:@"business"];
    currentTag = 0;
    selectedIndexOffer = [[NSMutableArray alloc] init];
    quantityArray = [[NSMutableArray alloc] init];

    dataMenuArray = [[NSMutableArray alloc] init];
    dataReviewArray = [[NSMutableArray alloc] init];
    dataOfferArray = [[NSMutableArray alloc] init];
    
    _menuItems = [[NSMutableArray alloc] initWithObjects:@"REVIEWS", @"MENU", @"OFFERS", nil];
    
    self.topbarList.delegate = self;
    self.topbarList.dataSource = self;
    
    self.topbarList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.topbarList.selectionIndicatorColor = [UIColor clearColor];
    self.topbarList.backgroundColor = MAIN_TRANS_COLOR;
    
    [self.topbarList setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.topbarList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.topbarList setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateNormal];
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateSelected];
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateHighlighted];
    
    self.lblRestaurant.text = self.object[PARSE_BUSINESS_NAME];
    
//    self.txtAddress.backgroundColor = [UIColor clearColor];
    
    self.lblContactNumber.text = self.object[PARSE_BUSINESS_CONTACT_NUM];
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.tintColor = MAIN_COLOR;
//    [self.refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [self.tableViewMenus addSubview:self.refreshControl];
//    [self.tableViewOffers addSubview:self.refreshControl];
//    [self.tableViewReviews addSubview:self.refreshControl];
    
//    self.tableViewMenus.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
//    self.tableViewReviews.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
//    self.tableViewOffers.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    
    // configure Review, mene, Offer topbar list
    [self configureItems];
    
    [Util setImage:self.bgRestaurant imgFile:(PFFile *)self.object[PARSE_USER_AVATAR]];
}

- (void) viewDidLayoutSubviews {
    _txtAddress.text = self.object[PARSE_USER_ADDRESS];
    CGFloat fixedWidth = _txtAddress.frame.size.width;
    CGSize newSize = [_txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _txtAddress.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    newFrame.origin.y = newFrame.origin.y - (newFrame.size.height - 30);
    [_txtAddress setFrame:newFrame];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self.object fetchInBackgroundWithBlock:^(PFObject *obj, NSError *error){
        [SVProgressHUD dismiss];
        dataReviewArray = [[NSMutableArray alloc] init];
        [self.ratingBar setValue:[self.object[PARSE_USER_REVIEW_MARKS] intValue]];
        [self refreshItems];
    }];
}
- (void) configureItems {
    self.topbarItemList.delegate = self;
    self.topbarItemList.dataSource = self;
    
    self.topbarItemList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.topbarItemList.selectionIndicatorColor = MAIN_COLOR;
    self.topbarItemList.backgroundColor = [UIColor whiteColor];
    
    [self.topbarItemList setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.topbarItemList setTitleColor:COLOR_GRAY_LIGHT forState:UIControlStateNormal];
    [self.topbarItemList setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [self.topbarItemList setTitleFont:[UIFont boldSystemFontOfSize:15] forState:UIControlStateNormal];
    [self.topbarItemList setTitleFont:[UIFont boldSystemFontOfSize:15] forState:UIControlStateSelected];
    [self.topbarItemList setTitleFont:[UIFont boldSystemFontOfSize:15] forState:UIControlStateHighlighted];
}

- (void) refreshItems {
    self.lblNoresults.hidden = YES;
    NSInteger count = 0;
    if (currentTag == 0){
       [self refreshReviews];
    } else if (currentTag == 1){
        count = [_tableViewMenus numberOfRowsInSection:0];
//        if (count == 0){
            [self refreshMenus];
//        }
    } else if (currentTag == 2){
        count = [_tableViewOffers numberOfRowsInSection:0];
        if (count == 0)
            [self refreshOffers];
    }
}

- (void) refreshReviews {
    dataReviewArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REVIEW];
    [query whereKey:PARSE_REVIEW_RESTAURANT equalTo:(PFUser *)self.object];
    [query includeKey:PARSE_REVIEW_POSTER];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
//    self.tableViewReviews.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
//    [self.refreshControl beginRefreshing];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
//        [self.refreshControl endRefreshing];
        if (!error){
            dataReviewArray = (NSMutableArray *)objects;
            _lblNoresults.hidden = (objects.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available reviews";
            [self.tableViewReviews reloadData];
        } else {
            NSLog(@"failed getting data");
        }
    }];
}

- (void) refreshMenus {
    dataMenuArray = [[NSMutableArray alloc] init];
    quantityArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOOD];
    [query setLimit:PARSE_FETCH_MAX_COUNT];
    [query whereKey:PARSE_FOOD_OWNER equalTo:self.object];
//    [query whereKey:PARSE_FOOD_COURSE equalTo:[FOOD_COURSE objectAtIndex:[_topbarList selectedButtonIndex]]];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
//    self.tableViewMenus.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
//    [self.refreshControl beginRefreshing];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){  // get All Course Food
        [SVProgressHUD dismiss];
//        [self.refreshControl endRefreshing];
        if (!error){
            dataMenuArray = (NSMutableArray *)objects;
            _lblNoresults.hidden = (objects.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available foods";
            [self initFoodArray:dataMenuArray];
            for (int i=0;i<dataMenuArray.count;i++){
                [quantityArray addObject:[NSNumber numberWithInt:0]];
            }
            [self.tableViewMenus reloadData];
        } else {
            NSLog(@"failed getting data");
        }
    }];
}

// @"Appetizers", @"Soups", @"Main Course", @"Salad", @"Dessert"
- (void) initFoodArray:(NSMutableArray *) allFood {
    foodArray_appet = [[NSMutableArray alloc] init];
    foodArray_soups = [[NSMutableArray alloc] init];
    foodArray_main = [[NSMutableArray alloc] init];
    foodArray_salad = [[NSMutableArray alloc] init];
    foodArray_desert = [[NSMutableArray alloc] init];
    
    select_appet = [[NSMutableArray alloc] init];
    select_soups = [[NSMutableArray alloc] init];
    select_main = [[NSMutableArray alloc] init];
    select_salad = [[NSMutableArray alloc] init];
    select_desert = [[NSMutableArray alloc] init];
    
    for (int i=0;i<allFood.count;i++){
        PFObject *obj = [allFood objectAtIndex:i];
        if ([obj[PARSE_FOOD_COURSE] isEqualToString:[FOOD_COURSE objectAtIndex:0]]){ // Appetizers
            [foodArray_appet addObject:obj];
        } else if ([obj[PARSE_FOOD_COURSE] isEqualToString:[FOOD_COURSE objectAtIndex:1]]) { // Soups
            [foodArray_soups addObject:obj];
        } else if ([obj[PARSE_FOOD_COURSE] isEqualToString:[FOOD_COURSE objectAtIndex:2]]) { // Main Course
            [foodArray_main addObject:obj];
        } else if ([obj[PARSE_FOOD_COURSE] isEqualToString:[FOOD_COURSE objectAtIndex:3]]) { // Salad
            [foodArray_salad addObject:obj];
        } else if ([obj[PARSE_FOOD_COURSE] isEqualToString:[FOOD_COURSE objectAtIndex:4]]) { // Dessert
            [foodArray_desert addObject:obj];
        }
    }
    
    quantyArray_appet = [[NSMutableArray alloc] init];
    quantyArray_soups = [[NSMutableArray alloc] init];
    quantyArray_main = [[NSMutableArray alloc] init];
    quantyArray_salad = [[NSMutableArray alloc] init];
    quantyArray_desert = [[NSMutableArray alloc] init];
    for (int i=0;i<foodArray_appet.count;i++){
        [quantyArray_appet addObject:[NSNumber numberWithInt:0]];
    }
    for (int i=0;i<foodArray_soups.count;i++){
        [quantyArray_soups addObject:[NSNumber numberWithInt:0]];
    }
    for (int i=0;i<foodArray_main.count;i++){
        [quantyArray_main addObject:[NSNumber numberWithInt:0]];
    }
    for (int i=0;i<foodArray_salad.count;i++){
        [quantyArray_salad addObject:[NSNumber numberWithInt:0]];
    }
    for (int i=0;i<foodArray_desert.count;i++){
        [quantyArray_desert addObject:[NSNumber numberWithInt:0]];
    }
}

- (void) refreshOffers {
    dataOfferArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
    [query whereKey:PARSE_OFFER_OWNER equalTo:self.object];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
//    self.tableViewOffers.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
//    [self.refreshControl beginRefreshing];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
//        [self.refreshControl endRefreshing];
        if (!error){
            dataOfferArray = (NSMutableArray *)objects;
            _lblNoresults.hidden = (objects.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available offers";
            [self.tableViewOffers reloadData];
        } else {
            NSLog(@"failed getting data");
        }
    }];
}

- (IBAction)onHome:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onReviews:(id)sender {
    currentTag = 0;
    _viewReviews.hidden = NO;
    _viewMenu.hidden = YES;
    _viewOffers.hidden = YES;
    [self refreshItems];
}

- (IBAction)onMenu:(id)sender {
    currentTag = 1;
    _viewReviews.hidden = YES;
    _viewMenu.hidden = NO;
    _viewOffers.hidden = YES;
    [self refreshItems];
}

- (IBAction)onOffers:(id)sender {
    currentTag = 2;
    _viewReviews.hidden = YES;
    _viewMenu.hidden = YES;
    _viewOffers.hidden = NO;
    [self refreshItems];
}

- (IBAction)onWriteReview:(id)sender {
    if (![PFUser currentUser]){
        [self gotoLogin];
        return;
    }
    // check exist my review for this restaurant
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_REVIEW];
    [query whereKey:PARSE_REVIEW_POSTER equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_REVIEW_RESTAURANT equalTo:self.object];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (objects.count>0){
            NSString *msg = @"You already wrote your review for this restaurant. Do you want to update your review?";
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:@"Yes" actionBlock:^(void) {
                WriteReviewViewController *vc = (WriteReviewViewController *)[Util getUIViewControllerFromStoryBoard:@"WriteReviewViewController"];
                vc.isChange = YES;
                vc.obj = self.object;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            [alert addButton:@"No" actionBlock:^(void) {
                
            }];
            [alert showQuestion:@"Write a Review" subTitle:msg closeButtonTitle:nil duration:0.0f];
        } else {
            WriteReviewViewController *vc = (WriteReviewViewController *)[Util getUIViewControllerFromStoryBoard:@"WriteReviewViewController"];
            vc.obj = self.object;
            vc.isChange = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (IBAction)onMenuNext:(id)sender {
    if (![PFUser currentUser]){
        [self gotoLogin];
        return;
    }
    unsigned long quanty = select_appet.count + select_soups.count + select_main.count + select_salad.count + select_desert.count;
    if (quanty == 0){
        [Util showAlertTitle:self title:@"Order" message:@"You need to choose at least 1 food to proceed."];
        return;
    }
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *quanties = [[NSMutableArray alloc] init];
    for (int i=0;i<select_appet.count;i++){
        int index = [[select_appet objectAtIndex:i] intValue];
        int quanty =  [[quantyArray_appet objectAtIndex:index] intValue];
        if (quanty >0 && quanty<=10){
            [data addObject:[foodArray_appet objectAtIndex:index]];
            [quanties addObject:[NSNumber numberWithInt:quanty]];
        } else if (quanty == 0) {
            [Util showAlertTitle:self title:@"Menu" message:@"Oops! You forgot to input quantity." finish:^{
                [_topbarList setSelectedButtonIndex:0];
                [_tableViewMenus reloadData];
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                UITableViewCell *cell = [_tableViewMenus cellForRowAtIndexPath:path];
                
                UITextField *av = (UITextField *)[cell viewWithTag:4];
//                [av becomeFirstResponder];
            }];
            return;
        }
    }
    for (int i=0;i<select_soups.count;i++){
        int index = [[select_soups objectAtIndex:i] intValue];
        int quanty =  [[quantyArray_soups objectAtIndex:index] intValue];
        if (quanty >0 && quanty<=10){
            [data addObject:[foodArray_soups objectAtIndex:index]];
            [quanties addObject:[NSNumber numberWithInt:quanty]];
        } else if (quanty == 0) {
            [Util showAlertTitle:self title:@"Menu" message:@"Oops! You forgot to input quantity." finish:^{
                [_topbarList setSelectedButtonIndex:1];
                [_tableViewMenus reloadData];
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                UITableViewCell *cell = [_tableViewMenus cellForRowAtIndexPath:path];
                
                UITextField *av = (UITextField *)[cell viewWithTag:4];
                //                [av becomeFirstResponder];
            }];
            return;
        }
    }
    for (int i=0;i<select_main.count;i++){
        int index = [[select_main objectAtIndex:i] intValue];
        int quanty =  [[quantyArray_main objectAtIndex:index] intValue];
        if (quanty >0 && quanty<=10){
            [data addObject:[foodArray_main objectAtIndex:index]];
            [quanties addObject:[NSNumber numberWithInt:quanty]];
        } else if (quanty == 0) {
            [Util showAlertTitle:self title:@"Menu" message:@"Oops! You forgot to input quantity." finish:^{
                [_topbarList setSelectedButtonIndex:2];
                [_tableViewMenus reloadData];
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                UITableViewCell *cell = [_tableViewMenus cellForRowAtIndexPath:path];
                
                UITextField *av = (UITextField *)[cell viewWithTag:4];
                //                [av becomeFirstResponder];
            }];
            return;
        }
    }
    for (int i=0;i<select_salad.count;i++){
        int index = [[select_salad objectAtIndex:i] intValue];
        int quanty =  [[quantyArray_salad objectAtIndex:index] intValue];
        if (quanty >0 && quanty<=10){
            [data addObject:[foodArray_salad objectAtIndex:index]];
            [quanties addObject:[NSNumber numberWithInt:quanty]];
        } else if (quanty == 0) {
            [Util showAlertTitle:self title:@"Menu" message:@"Oops! You forgot to input quantity." finish:^{
                [_topbarList setSelectedButtonIndex:3];
                [_tableViewMenus reloadData];
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                UITableViewCell *cell = [_tableViewMenus cellForRowAtIndexPath:path];
                
                UITextField *av = (UITextField *)[cell viewWithTag:4];
                //                [av becomeFirstResponder];
            }];
            return;
        }
    }
    for (int i=0;i<select_desert.count;i++){
        int index = [[select_desert objectAtIndex:i] intValue];
        int quanty =  [[quantyArray_desert objectAtIndex:index] intValue];
        if (quanty >0 && quanty<=10){
            [data addObject:[foodArray_desert objectAtIndex:index]];
            [quanties addObject:[NSNumber numberWithInt:quanty]];
        } else if (quanty == 0) {
            [Util showAlertTitle:self title:@"Menu" message:@"Oops! You forgot to input quantity." finish:^{
                [_topbarList setSelectedButtonIndex:4];
                [_tableViewMenus reloadData];
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                UITableViewCell *cell = [_tableViewMenus cellForRowAtIndexPath:path];
                
                UITextField *av = (UITextField *)[cell viewWithTag:4];
                //                [av becomeFirstResponder];
            }];
            return;
        }
    }
    UseOfferViewController *vc = (UseOfferViewController *)[Util getUIViewControllerFromStoryBoard:@"UseOfferViewController"];
    if (data.count == 0){
        [Util showAlertTitle:self title:@"Order" message:@"Oops! Invalid Values"];
        return;
    }
    vc.dataArray = data;
    vc.quantyArray = quanties;
    vc.restaurant = self.object;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onUseOffer:(id)sender {
    if (![PFUser currentUser]){
        [self gotoLogin];
        return;
    }
    OfferDetailViewController *vc = (OfferDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"OfferDetailViewController"];
    if (selectedIndexOffer.count == 0){
        [Util showAlertTitle:self title:@"Use Offer" message:@"you need to choose at least 1 offer to proceed."];
        return;
    }
    int index = [[selectedIndexOffer objectAtIndex:0] intValue];
    vc.object = [dataOfferArray objectAtIndex:index];
    [self.navigationController pushViewController:vc animated:YES];
}

/* table view delegate */

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([tableView.restorationIdentifier isEqualToString:@"tableviewReview"]){
        PFObject *obj = [dataReviewArray objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellReview"];
        UILabel *lblusername = (UILabel *)[cell viewWithTag:1];
        UILabel *lblDate = (UILabel *)[cell viewWithTag:2];
//        UIImageView *imgMarks = (UIImageView *)[cell viewWithTag:3];
        UITextView *txtReview = (UITextView *)[cell viewWithTag:4];
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        CircleImageView *imgAvatar = (CircleImageView *)[cell viewWithTag:10];
        HCSStarRatingView *rate = (HCSStarRatingView *)[cell viewWithTag:9];
        PFUser *poster = (PFUser *)obj[PARSE_REVIEW_POSTER];
        if (poster[PARSE_USER_AVATAR]){
            [Util setImage:imgAvatar imgFile:(PFFile *)poster[PARSE_USER_AVATAR]];
        }
        lblusername.text = [NSString stringWithFormat:@"%@ %@", poster[PARSE_USER_FIRST_NAME], poster[PARSE_USER_LAST_NAME]];
        lblDate.text = [Util getExpireDateString:[obj createdAt]];
        txtReview.text = obj[PARSE_REVIEW_REVIEW];
        [rate setValue:[obj[PARSE_REVIEW_MARKS] intValue]];

        button.hidden = [APP_THEME isEqualToString:APP_THEME_BUSINESS];
    } else if ([tableView.restorationIdentifier isEqualToString:@"tableviewMenu"]){
        PFObject *obj = [dataMenuArray objectAtIndex:indexPath.row];
        
        if (_topbarList.selectedButtonIndex == 0){
            obj = [foodArray_appet objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 1){
            obj = [foodArray_soups objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 2){
            obj = [foodArray_main objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 3){
            obj = [foodArray_salad objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 4){
            obj = [foodArray_desert objectAtIndex:indexPath.row];
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenu"];
        if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenuRest"];
        }
        UILabel *lblName = (UILabel *)[cell viewWithTag:1];
        UILabel *lblPrice = (UILabel *)[cell viewWithTag:2];
        UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
        UILabel *lblDesc = (UILabel *)[cell viewWithTag:5];
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        UITextField *value = (UITextField *)[cell viewWithTag:4];
        
        if (_topbarList.selectedButtonIndex == 0){
            value.text = [[quantyArray_appet objectAtIndex:indexPath.row] stringValue];
            button.selected = [select_appet containsObject:[NSNumber numberWithInteger:indexPath.row]];
        } else if (_topbarList.selectedButtonIndex == 1){
            value.text = [[quantyArray_soups objectAtIndex:indexPath.row] stringValue];
            button.selected = [select_soups containsObject:[NSNumber numberWithInteger:indexPath.row]];
        } else if (_topbarList.selectedButtonIndex == 2){
            value.text = [[quantyArray_main objectAtIndex:indexPath.row] stringValue];
            button.selected = [select_main containsObject:[NSNumber numberWithInteger:indexPath.row]];
        } else if (_topbarList.selectedButtonIndex == 3){
            value.text = [[quantyArray_salad objectAtIndex:indexPath.row] stringValue];
            button.selected = [select_salad containsObject:[NSNumber numberWithInteger:indexPath.row]];
        } else if (_topbarList.selectedButtonIndex == 4){
            value.text = [[quantyArray_desert objectAtIndex:indexPath.row] stringValue];
            button.selected = [select_desert containsObject:[NSNumber numberWithInteger:indexPath.row]];
        }
        
        value.delegate = self;
        
        lblName.text = obj[PARSE_FOOD_NAME];
        lblPrice.text = [NSString stringWithFormat:@"Price: $%@", [obj[PARSE_FOOD_PRICE] stringValue]];
        
        txtDesc.text = obj[PARSE_FOOD_DESCRIPTION];
        button.hidden = [APP_THEME isEqualToString:APP_THEME_BUSINESS];
        lblDesc.hidden = [APP_THEME isEqualToString:APP_THEME_BUSINESS];
        value.hidden = [APP_THEME isEqualToString:APP_THEME_BUSINESS];
    } else if ([tableView.restorationIdentifier isEqualToString:@"tableviewOffer"]){
        PFObject *obj = [dataOfferArray objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellOffer"];
        UILabel *lblname = (UILabel *)[cell viewWithTag:1];
        UITextView *txtDesc = (UITextView *)[cell viewWithTag:2];
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        UILabel *lblDate = (UILabel *)[cell viewWithTag:8];
        button.selected = [selectedIndexOffer containsObject:[NSNumber numberWithInteger:indexPath.row]];
        lblname.text = obj[PARSE_OFFER_NAME];
        txtDesc.text = obj[PARSE_OFFER_DETAILS];
        lblDate.text = [NSString stringWithFormat:@"Expiration date %@", [Util getExpireDateString:obj[PARSE_OFFER_EXPIRE]]];
        button.hidden = [APP_THEME isEqualToString:APP_THEME_BUSINESS];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 70;
    UITableViewCell *cell;
    UITextView *txtDesc;
    
    if ([tableView.restorationIdentifier isEqualToString:@"tableviewReview"]){
        PFObject *obj = (PFObject *) [dataReviewArray objectAtIndex:indexPath.row];
        height = 80;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellReview"];
        txtDesc = (UITextView *)[cell viewWithTag:4];
        txtDesc.text = obj[PARSE_REVIEW_REVIEW];
    } else if ([tableView.restorationIdentifier isEqualToString:@"tableviewMenu"]){
        PFObject *obj = (PFObject *) [self.dataMenuArray objectAtIndex:indexPath.row];
        
        if (_topbarList.selectedButtonIndex == 0){
            obj = [foodArray_appet objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 1){
            obj = [foodArray_soups objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 2){
            obj = [foodArray_main objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 3){
            obj = [foodArray_salad objectAtIndex:indexPath.row];
        } else if (_topbarList.selectedButtonIndex == 4){
            obj = [foodArray_desert objectAtIndex:indexPath.row];
        }
        
        height = 85;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenu"];
        txtDesc = (UITextView *)[cell viewWithTag:3];
        txtDesc.text = obj[PARSE_FOOD_DESCRIPTION];
        if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
            height = 50;
        }
    } else if ([tableView.restorationIdentifier isEqualToString:@"tableviewOffer"]){
        PFObject *obj = (PFObject *) [self.dataOfferArray objectAtIndex:indexPath.row];
        height = 65;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellOffer"];
        txtDesc = (UITextView *)[cell viewWithTag:2];
        txtDesc.text = obj[PARSE_OFFER_DETAILS];
    }
    
    CGFloat fixedWidth = txtDesc.frame.size.width;
    CGSize newSize = [txtDesc sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtDesc.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    txtDesc.frame = newFrame;
    return height+newFrame.size.height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.restorationIdentifier isEqualToString:@"tableviewMenu"]){
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        button.selected = !button.selected;
        UITextField *value = (UITextField *)[cell viewWithTag:4];
        
        if (_topbarList.selectedButtonIndex == 0){
            if (button.isSelected)
                [select_appet addObject:[NSNumber numberWithInteger:indexPath.row]];
            else{
                [select_appet removeObject:[NSNumber numberWithInteger:indexPath.row]];
                value.text = [NSString stringWithFormat:@"%d", 0];
            }
        } else if (_topbarList.selectedButtonIndex == 1){
            if (button.isSelected)
                [select_soups addObject:[NSNumber numberWithInteger:indexPath.row]];
            else {
                [select_soups removeObject:[NSNumber numberWithInteger:indexPath.row]];
                value.text = [NSString stringWithFormat:@"%d", 0];
            }
                
        } else if (_topbarList.selectedButtonIndex == 2){
            if (button.isSelected)
                [select_main addObject:[NSNumber numberWithInteger:indexPath.row]];
            else {
                [select_main removeObject:[NSNumber numberWithInteger:indexPath.row]];
                value.text = [NSString stringWithFormat:@"%d", 0];
            }
        } else if (_topbarList.selectedButtonIndex == 3){
            if (button.isSelected)
                [select_salad addObject:[NSNumber numberWithInteger:indexPath.row]];
            else {
                [select_salad removeObject:[NSNumber numberWithInteger:indexPath.row]];
                value.text = [NSString stringWithFormat:@"%d", 0];
            }
        } else if (_topbarList.selectedButtonIndex == 4){
            if (button.isSelected)
                [select_desert addObject:[NSNumber numberWithInteger:indexPath.row]];
            else {
                [select_desert removeObject:[NSNumber numberWithInteger:indexPath.row]];
                value.text = [NSString stringWithFormat:@"%d", 0];
            }
        }
        
    } else if ([tableView.restorationIdentifier isEqualToString:@"tableviewOffer"]){
        [self updateOfferTableView:indexPath.row];
        [selectedIndexOffer removeAllObjects];
        [selectedIndexOffer addObject:[NSNumber numberWithInteger:indexPath.row]];
    }
}

- (void) updateOfferTableView:(NSInteger) row {
    NSInteger cellCount = dataOfferArray.count;
    for (int i=0;i<cellCount;i++){
        UITableViewCell *cell = [_tableViewOffers cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        if (i == row){
            button.selected = true;
        } else {
            button.selected = false;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView.restorationIdentifier isEqualToString:@"tableviewMenu"]){
        if (_topbarList.selectedButtonIndex == 0){
            return foodArray_appet.count;
        } else if (_topbarList.selectedButtonIndex == 1){
            return foodArray_soups.count;
        } else if (_topbarList.selectedButtonIndex == 2){
            return foodArray_main.count;
        } else if (_topbarList.selectedButtonIndex == 3){
            return foodArray_salad.count;
        } else if (_topbarList.selectedButtonIndex == 4){
            return foodArray_desert.count;
        } else {
            return dataMenuArray.count;
        }
    } else if ([tableView.restorationIdentifier isEqualToString:@"tableviewOffer"]){
        return dataOfferArray.count;
    } else {
        return dataReviewArray.count;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index
{
    if (selectionList == self.topbarList){
//        [self refreshItems];
        if (index == 0){
            _lblNoresults.hidden = (foodArray_appet.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available foods";
        } else if (index == 1){
            _lblNoresults.hidden = (foodArray_soups.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available foods";
        } else if (index == 2){
            _lblNoresults.hidden = (foodArray_main.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available foods";
        } else if (index == 3){
            _lblNoresults.hidden = (foodArray_salad.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available foods";
        } else if (index == 4){
            _lblNoresults.hidden = (foodArray_desert.count == 0)?NO:YES;
            _lblNoresults.text = @"Oops! There is no available foods";
        }
        
        [_tableViewMenus reloadData];
    }
    else {
        if (index == 0){ // reviews
            [self onReviews:nil];
        } else if (index == 1){ // menu
            [self onMenu:nil];
        } else if (index == 2){ // offers
            [self onOffers:nil];
        }
    }
}
- (NSInteger) numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList
{
    if (selectionList == self.topbarList)
        return FOOD_COURSE.count;
    else
        return self.menuItems.count;
}
- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    if (selectionList == self.topbarList)
        return FOOD_COURSE[index];
    else {
        return self.menuItems[index];
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 4){
        UITableViewCell *cell = (UITableViewCell *) textField.superview;
        int index = [_tableViewMenus indexPathForCell:cell].row;
    }
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 4){
        // check 10
        if ([textField.text intValue] == 1 && [string intValue] == 0){
            return YES;
        }
        
        textField.text = string;
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 1 || returnKey;
    }
    return YES;
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 4){
        UITableViewCell *cell = (UITableViewCell *) textField.superview.superview;
        NSInteger index = [_tableViewMenus indexPathForCell:cell].row;
        [quantityArray removeObjectAtIndex:index];
        [quantityArray insertObject:[NSNumber numberWithInt:[textField.text intValue]] atIndex:index];
        
        if (_topbarList.selectedButtonIndex == 0){
            [quantyArray_appet removeObjectAtIndex:index];
            [quantyArray_appet insertObject:[NSNumber numberWithInt:[textField.text intValue]] atIndex:index];
        } else if (_topbarList.selectedButtonIndex == 1){
            [quantyArray_soups removeObjectAtIndex:index];
            [quantyArray_soups insertObject:[NSNumber numberWithInt:[textField.text intValue]] atIndex:index];
        } else if (_topbarList.selectedButtonIndex == 2){
            [quantyArray_main removeObjectAtIndex:index];
            [quantyArray_main insertObject:[NSNumber numberWithInt:[textField.text intValue]] atIndex:index];
        } else if (_topbarList.selectedButtonIndex == 3){
            [quantyArray_salad removeObjectAtIndex:index];
            [quantyArray_salad insertObject:[NSNumber numberWithInt:[textField.text intValue]] atIndex:index];
        } else if (_topbarList.selectedButtonIndex == 4){
            [quantyArray_desert removeObjectAtIndex:index];
            [quantyArray_desert insertObject:[NSNumber numberWithInt:[textField.text intValue]] atIndex:index];
        }
    }
    [textField resignFirstResponder];
}
@end
