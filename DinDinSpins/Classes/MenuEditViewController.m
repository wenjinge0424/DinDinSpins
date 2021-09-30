//
//  MenuEditViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MenuEditViewController.h"
#import "HTHorizontalSelectionList.h"

@interface MenuEditViewController ()<UITableViewDelegate, UITableViewDataSource, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>

@property (strong, nonatomic) IBOutlet HTHorizontalSelectionList *topbarList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
//@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UILabel *lblRestaurantName;
@property (strong, nonatomic) PFUser *me;
@end

NSMutableArray *selectedIndex;

@implementation MenuEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [[NSMutableArray alloc] init];
    selectedIndex = [[NSMutableArray alloc] init];

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
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.tintColor = MAIN_COLOR;
//    [self.refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:self.refreshControl];
//    
//    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    
    self.me = [PFUser currentUser];
    self.lblRestaurantName.text = self.me[PARSE_BUSINESS_NAME];
    
    [self.topbarList setSelectedButtonIndex:0];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDelete:(id)sender {
    [self deleteItems];
}

- (void) refreshItems
{
    self.dataArray = [[NSMutableArray alloc] init];
    selectedIndex = [[NSMutableArray alloc] init];
    
    NSString *categoryItem = [FOOD_COURSE objectAtIndex:[_topbarList selectedButtonIndex]];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_FOOD];
    [query whereKey:PARSE_FOOD_OWNER equalTo:self.me];
    [query whereKey:PARSE_FOOD_COURSE equalTo:categoryItem];
//    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
//    [self.refreshControl beginRefreshing];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
//        [self.refreshControl endRefreshing];
        if (!error){
            self.dataArray = (NSMutableArray *)objects;
            [self.tableView reloadData];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}

- (void) deleteItems {
    if (selectedIndex.count == 0){
        [Util showAlertTitle:self title:@"Delete" message:@"No selected items"];
        return;
    }
    NSString *msg = @"Are you sure want to delete these items?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        for (int i=0;i<selectedIndex.count;i++){
            int index = [[selectedIndex objectAtIndex:i] intValue];
            PFObject *obj = [self.dataArray objectAtIndex:index];
            [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error){
                if (!succeeded){
                    [SVProgressHUD dismiss];
                    [self refreshItems];
                } else if (i==selectedIndex.count-1) {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellMenuEditItem"];
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    button.selected = [selectedIndex containsObject:[NSNumber numberWithInteger:indexPath.row]];
    UILabel *lblRestName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:2];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
    if (_dataArray.count > 0){
        PFObject *obj = [_dataArray objectAtIndex:indexPath.row];
        lblRestName.text = obj[PARSE_FOOD_NAME];
        lblPrice.text = [NSString stringWithFormat:@"Price $%@", (NSNumber *)obj[PARSE_FOOD_PRICE]];
        txtDesc.text = obj[PARSE_FOOD_DESCRIPTION];
    }
    return cell;
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
        [selectedIndex addObject:[NSNumber numberWithInteger:indexPath.row]];
    } else {
        [selectedIndex removeObject:[NSNumber numberWithInteger:indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMenuEditItem"];
    CGFloat height = 31;
    PFObject *obj = (PFObject *) [self.dataArray objectAtIndex:indexPath.row];
    UITextView *txtDesc = (UITextView *)[cell viewWithTag:3];
    NSString *text = obj[PARSE_FOOD_DESCRIPTION];
    txtDesc.text = text;
    CGFloat fixedWidth = txtDesc.frame.size.width;
    CGSize newSize = [txtDesc sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtDesc.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    txtDesc.frame = newFrame;
    return height+newFrame.size.height+5;
}

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
