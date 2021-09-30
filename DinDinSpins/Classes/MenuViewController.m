//
//  MenuViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuEditViewController.h"
#import "AddFoodViewController.h"
#import "HTHorizontalSelectionList.h"

@interface MenuViewController ()<HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblRestrantName;
@property (strong, nonatomic) IBOutlet HTHorizontalSelectionList *topbarList;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIButton *btnAddDel;
@property (strong, nonatomic) IBOutlet UIButton *btnHome;
@property (strong, nonatomic) PFUser *me;
@end
NSMutableArray *dataArray;
//UIRefreshControl *refreshControl;

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataArray = [[NSMutableArray alloc] init];

    self.topbarList.delegate = self;
    self.topbarList.dataSource = self;
    
    self.topbarList.backgroundColor = MAIN_TRANS_COLOR;
    self.topbarList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.topbarList.selectionIndicatorColor = [UIColor clearColor];
    
    [self.topbarList setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.topbarList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.topbarList setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateNormal];
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateSelected];
    [self.topbarList setTitleFont:[UIFont boldSystemFontOfSize:11] forState:UIControlStateHighlighted];
    
//    refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.tintColor = MAIN_COLOR;
//    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [self.tableview addSubview:refreshControl];
//    
//    self.tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    
    self.me = [PFUser currentUser];
    _lblRestrantName.text = self.me[PARSE_BUSINESS_NAME];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshItems];
}

- (void) refreshItems
{
    dataArray = [[NSMutableArray alloc] init];
    
    NSString *categoryItem = [FOOD_COURSE objectAtIndex:[_topbarList selectedButtonIndex]];
    PFUser *me = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOOD];
    [query whereKey:PARSE_FOOD_OWNER equalTo:me];
    [query whereKey:PARSE_FOOD_COURSE equalTo:categoryItem];
//    self.tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
//    [refreshControl beginRefreshing];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
//        [refreshControl endRefreshing];
        if (!error){
            dataArray = (NSMutableArray *)objects;
            [_tableview reloadData];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onEdit:(id)sender {
    MenuEditViewController *vc = (MenuEditViewController *)[Util getUIViewControllerFromStoryBoard:@"MenuEditViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onAddFood:(id)sender {
    AddFoodViewController *vc = (AddFoodViewController *)[Util getUIViewControllerFromStoryBoard:@"AddFoodViewController"];
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

#pragma mark HTHorizontalSelectionListDatasouce Protocal Methods
- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return FOOD_COURSE.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return FOOD_COURSE[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
    [self refreshItems];
}

#pragma mark UITableView
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenuItem"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:2];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
    PFObject *obj = (PFObject *) [dataArray objectAtIndex:indexPath.row];
    lblName.text = obj[PARSE_FOOD_NAME];
    lblPrice.text = [NSString stringWithFormat:@"Price $%@", (NSNumber *)obj[PARSE_FOOD_PRICE]];
    txtDesc.text = obj[PARSE_FOOD_DESCRIPTION];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenuItem"];
    CGFloat height = 36;
    PFObject *obj = (PFObject *) [dataArray objectAtIndex:indexPath.row];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
    NSString *text = obj[PARSE_FOOD_DESCRIPTION];
    txtDesc.text = text;
    CGFloat fixedWidth = txtDesc.frame.size.width;
    CGSize newSize = [txtDesc sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtDesc.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    txtDesc.frame = newFrame;
    return height+newFrame.size.height;
}
@end
