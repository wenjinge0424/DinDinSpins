//
//  UseOfferViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "UseOfferViewController.h"
#import "OrderSummaryViewController.h"

@interface UseOfferViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *lblRestaurantName;
    NSMutableArray *offerArray;
    NSMutableArray *selectedIndex;
//    UIRefreshControl *refreshControl;
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *lblNoResults;
}
@end

@implementation UseOfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblRestaurantName.text = self.restaurant[PARSE_BUSINESS_NAME];
//    refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.tintColor = MAIN_COLOR;
//    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [tableView addSubview:refreshControl];
    
    offerArray = [[NSMutableArray alloc] init];
    selectedIndex = [[NSMutableArray alloc] init];
    lblNoResults.hidden = YES;
    
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) refreshItems {
    lblNoResults.hidden = YES;
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
    [query whereKey:PARSE_OFFER_OWNER equalTo:self.restaurant];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//    [refreshControl beginRefreshing];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
//        [refreshControl endRefreshing];
        if (!error){
            offerArray = (NSMutableArray *) objects;
            lblNoResults.hidden = (offerArray.count == 0)?NO:YES;
            [tableView reloadData];
        }
    }];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSkip:(id)sender {
    OrderSummaryViewController *vc = (OrderSummaryViewController *)[Util getUIViewControllerFromStoryBoard:@"OrderSummaryViewController"];
    vc.foodArray = self.dataArray;
    vc.quantyArray = self.quantyArray;
    vc.offerArray = [[NSMutableArray alloc] init];
    vc.restaurant = self.restaurant;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onPayment:(id)sender {
    if (selectedIndex.count == 0){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Try Again" actionBlock:^(void) {
            
        }];
        [alert addButton:@"Skip" actionBlock:^(void) {
            [self onSkip:nil];
        }];
        [alert showError:@"Use Offers" subTitle:@"You did not choose any offer" closeButtonTitle:nil duration:0.0f];
        return;
    }
    OrderSummaryViewController *vc = (OrderSummaryViewController *)[Util getUIViewControllerFromStoryBoard:@"OrderSummaryViewController"];
    vc.foodArray = self.dataArray;
    vc.quantyArray = self.quantyArray;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0;i<selectedIndex.count;i++){
        int index = [[selectedIndex objectAtIndex:i] intValue];
        PFObject *obj = [offerArray objectAtIndex:index];
        [array addObject:obj];
    }
    vc.offerArray = array;
    vc.restaurant = self.restaurant;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return offerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOffer"];
    UIButton *button = (UIButton *)[cell viewWithTag:100];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:2];
    UILabel *lblDate = (UILabel *)[cell viewWithTag:3];
    
    PFObject *obj = [offerArray objectAtIndex:indexPath.row];
    button.selected = [selectedIndex containsObject:[NSNumber numberWithInteger:indexPath.row]];
    lblName.text = obj[PARSE_OFFER_NAME];
    txtDesc.text = obj[PARSE_OFFER_DETAILS];
    lblDate.text = [Util getExpireDateString:obj[PARSE_OFFER_EXPIRE]];
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)[cell viewWithTag:100];
    button.selected = !button.selected;
    
    [self updateOfferTableView:indexPath.row];
    [selectedIndex removeAllObjects];
    [selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
}

- (void) updateOfferTableView:(NSInteger) row {
    NSInteger cellCount = offerArray.count;
    for (int i=0;i<cellCount;i++){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        if (i == row){
            button.selected = true;
        } else {
            button.selected = false;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOffer"];
    CGFloat height = 70;
    PFObject *obj = (PFObject *) [offerArray objectAtIndex:indexPath.row];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:2];
    NSString *text = obj[PARSE_OFFER_DETAILS];
    txtDesc.text = text;
    CGFloat fixedWidth = txtDesc.frame.size.width;
    CGSize newSize = [txtDesc sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtDesc.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    txtDesc.frame = newFrame;
    return height+newFrame.size.height;
}

@end
