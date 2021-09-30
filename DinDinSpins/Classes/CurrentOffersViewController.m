
//
//  CurrentOffersViewController.m
//  BikerLoops
//
//  Created by developer on 01/02/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "CurrentOffersViewController.h"
#import "OfferEditViewController.h"
#import "AddOfferViewController.h"
#import "OfferDetailViewController.h"
#import "OfferViewController.h"

@interface CurrentOffersViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    IBOutlet UIButton *btnEdit;
    IBOutlet UIButton *btnHome;
    IBOutlet UIButton *btnDelete;
    
    NSMutableArray *dataArray;
    IBOutlet UILabel *lblRestaurantName;
    PFUser *me;
//    UIRefreshControl *refreshControl;

    IBOutlet UILabel *lblNoResult;
}
@end

@implementation CurrentOffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    lblRestaurantName.text = me[PARSE_BUSINESS_NAME];
    
//    refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.tintColor = MAIN_COLOR;
//    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [tableview addSubview:refreshControl];
    
//    tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    lblNoResult.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshItems {
    lblNoResult.hidden = YES;
    dataArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_OFFER];
    [query whereKey:PARSE_OFFER_OWNER equalTo:me];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//    tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
//    [refreshControl beginRefreshing];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
//        [refreshControl endRefreshing];
        if (!error){
            dataArray = (NSMutableArray *)objects;
            lblNoResult.hidden = (dataArray.count == 0)?NO:YES;
            [tableview reloadData];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}

- (IBAction)onHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onEdit:(id)sender {
    OfferEditViewController *vc = (OfferEditViewController *)[Util getUIViewControllerFromStoryBoard:@"OfferEditViewController"];
    [self.navigationController pushViewController:vc animated:YES];
//    editable = !editable;
//    if (editable){
//        [btnHome setTitle:@"Cancel" forState:UIControlStateNormal];
//        btnEdit.hidden = YES;
//        [btnDelete setTitle:@"Delete" forState:UIControlStateNormal];
//    } else {
//        btnEdit.hidden = NO;
//        [btnHome setTitle:@"Home" forState:UIControlStateNormal];
//        [btnDelete setTitle:@"Add Offer" forState:UIControlStateNormal];
//        
//        // clear borders and selected index
//        for (int i=0;i<selectedIndex.count;i++){
//            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:(NSInteger)[selectedIndex objectAtIndex:i]];
//            UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
//            cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
//        }
//        [selectedIndex removeAllObjects];
//    }
}
- (IBAction)onAdd:(id)sender {
        AddOfferViewController *vc = (AddOfferViewController *)[Util getUIViewControllerFromStoryBoard:@"AddOfferViewController"];
        [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfferItem"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:2];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
    UILabel *expireDate = (UILabel *)[cell viewWithTag:4];
    PFObject *obj = (PFObject *) [dataArray objectAtIndex:indexPath.row];
    lblName.text = obj[PARSE_OFFER_NAME];
    lblPrice.text = [NSString stringWithFormat:@"$%@", (NSNumber *)obj[PARSE_OFFER_AMOUNT]];
    txtDesc.text = obj[PARSE_OFFER_DETAILS];
    expireDate.text = [NSString stringWithFormat:@"Expiration date %@", [Util getExpireDateString:obj[PARSE_OFFER_EXPIRE]]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfferItem"];
    CGFloat height = 50;
    PFObject *obj = (PFObject *) [dataArray objectAtIndex:indexPath.row];
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
    OfferDetailViewController *vc = (OfferDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"OfferDetailViewController"];
    vc.object = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
