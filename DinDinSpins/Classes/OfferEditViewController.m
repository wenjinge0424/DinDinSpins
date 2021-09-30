//
//  OfferEditViewController.m
//  BikerLoops
//
//  Created by developer on 01/02/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "OfferEditViewController.h"

@interface OfferEditViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *lblRestaurantName;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *dataArray;
//@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UILabel *lblNoResults;
@property (strong, nonatomic) NSMutableArray *selectedIndex;
@end



@implementation OfferEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    PFUser *me = [PFUser currentUser];
    _lblRestaurantName.text = me[PARSE_BUSINESS_NAME];
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.selectedIndex = [[NSMutableArray alloc] init];
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.tintColor = MAIN_COLOR;
//    [self.refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [self.tableview addSubview:self.refreshControl];
//    
//    self.tableview.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    
    _lblNoResults.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshItems {
    _lblNoResults.hidden = YES;
    self.dataArray = [[NSMutableArray alloc] init];
    self.selectedIndex = [[NSMutableArray alloc] init];
    
    PFUser *me = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
    [query whereKey:PARSE_FOOD_OWNER equalTo:me];
//    self.tableview.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
//    [self.refreshControl beginRefreshing];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
//        [self.refreshControl endRefreshing];
        if (!error){
            self.dataArray = (NSMutableArray *)objects;
            [self.tableview reloadData];
            _lblNoResults.hidden = (_dataArray.count == 0)?NO:YES;
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}

- (void) deleteItems {
    if (self.selectedIndex.count == 0){
        [Util showAlertTitle:self title:@"Delete" message:@"No selected items"];
        return;
    }
    NSString *msg = @"Are you sure want to delete these items?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        for (int i=0;i<self.selectedIndex.count;i++){
            int index = [[self.selectedIndex objectAtIndex:i] intValue];
            PFObject *obj = [self.dataArray objectAtIndex:index];
            [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
                if (error){
                    [SVProgressHUD dismiss];
//                    [self refreshItems];
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^{
                        [self onCancel:nil];
                    }];
                } else if (i==self.selectedIndex.count-1) {
                    [SVProgressHUD dismiss];
                    [self refreshItems];
                }
            }];
        }
    }];
    [alert addButton:@"No" actionBlock:^(void) {
        
    }];
    [alert showWarning:@"" subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (IBAction)onDelete:(id)sender {
    [self deleteItems];
}
- (IBAction)onCancel:(id)sender {
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
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellOfferEditItem"];
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    button.selected = [self.selectedIndex containsObject:[NSNumber numberWithInteger:indexPath.row]];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
    UILabel *lblExpireDate = (UILabel *)[cell viewWithTag:4];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:2];
    if (_dataArray.count > 0){
        PFObject *obj = [self.dataArray objectAtIndex:indexPath.row];
        lblName.text = obj[PARSE_OFFER_NAME];
        lblPrice.text = [NSString stringWithFormat:@"$%@", (NSNumber *)obj[PARSE_OFFER_AMOUNT]];
        txtDesc.text = obj[PARSE_OFFER_DETAILS];
        lblExpireDate.text = [Util getExpireDateString:obj[PARSE_OFFER_EXPIRE]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfferEditItem"];
    CGFloat height = 70;
    PFObject *obj = (PFObject *) [self.dataArray objectAtIndex:indexPath.row];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
    NSString *text = obj[PARSE_OFFER_DETAILS];
    txtDesc.text = text;
    CGFloat fixedWidth = txtDesc.frame.size.width;
    CGSize newSize = [txtDesc sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtDesc.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    txtDesc.frame = newFrame;
    return height+newFrame.size.height;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    button.selected = !button.selected;
    
    //    if ([selectedIndex containsObject:[NSNumber numberWithInteger:indexPath.row]]){
    //        [selectedIndex removeObject:[NSNumber numberWithInteger:indexPath.row]];
    //    } else {
    //        [selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
    //    }
    if (button.selected){
        [self.selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
    } else {
        [self.selectedIndex removeObject:[NSNumber numberWithInteger:indexPath.row]];
    }
}
@end
