//
//  NotificationViewController.m
//  DinDinSpins
//
//  Created by developer on 04/03/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "NotificationViewController.h"
#import "HTHorizontalSelectionList.h"
#import "NotificationDetailViewController.h"

@interface NotificationViewController ()<UITableViewDelegate,UITableViewDataSource, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>
{
    IBOutlet HTHorizontalSelectionList *topbarList;
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
//    UIRefreshControl *refreshControl;
    PFUser *me;
    IBOutlet UILabel *lblNoResults;
}
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableview.delegate = self;
    tableview.dataSource = self;
    
    topbarList.delegate = self;
    topbarList.dataSource = self;
    topbarList.backgroundColor = [UIColor clearColor];
    
    topbarList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    topbarList.selectionIndicatorColor = MAIN_COLOR;
    
    [topbarList setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [topbarList setTitleColor:COLOR_GRAY_DARK forState:UIControlStateNormal];
    [topbarList setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:15] forState:UIControlStateNormal];
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:15] forState:UIControlStateSelected];
    [topbarList setTitleFont:[UIFont boldSystemFontOfSize:15] forState:UIControlStateHighlighted];
    
//    refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.tintColor = MAIN_COLOR;
//    [refreshControl addTarget:self action:@selector(refreshItems) forControlEvents:UIControlEventValueChanged];
//    [tableview addSubview:refreshControl];
    
    dataArray = [[NSMutableArray alloc] init];
    
    me = [PFUser currentUser];
}

- (void) viewDidAppear:(BOOL)animated
{
    [me fetchInBackground];
    [super viewDidAppear:animated];
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshItems {
//    tableview.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
//    [refreshControl beginRefreshing];
    lblNoResults.hidden = YES;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    dataArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_NOTIFICATION];
    if (topbarList.selectedButtonIndex == 0){
        [query whereKey:PARSE_FIELD_NOTIFICATION_ISREAD equalTo:@NO];
    } else {
        [query whereKey:PARSE_FIELD_NOTIFICATION_ISREAD equalTo:@YES];
    }
    [query whereKey:PARSE_FIELD_NOTIFICATION_TOUSER equalTo:me];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error){
            [SVProgressHUD dismiss];
//            [refreshControl endRefreshing];
            dataArray = (NSMutableArray *)objects;
            [tableview reloadData];
            lblNoResults.hidden = (dataArray.count == 0)?NO:YES;
        } else {
            [Util showAlertTitle:self title:@"Notifications" message:[error localizedDescription]];
        }
    }];
}

- (IBAction)onSaveChanges:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onEdit:(id)sender {
}

/* tableview delegate */
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellNotification"];
    if (dataArray.count>0){
        PFObject *obj = [dataArray objectAtIndex:indexPath.row];
        UILabel *lblDate = (UILabel *)[cell viewWithTag:1];
        lblDate.text = [Util getParseDate:obj.createdAt];
    }
    
    return cell;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Yes" actionBlock:^(void) {
            PFObject *obj = [dataArray objectAtIndex:indexPath.row];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [obj deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                [SVProgressHUD dismiss];
                if (succeed && !error){
                    [self refreshItems];
                } else {
                    [Util showAlertTitle:self title:@"Error" message:@"Failed to delete notification."];
                }
            }];
        }];
        [alert addButton:@"No" actionBlock:^(void) {
            
        }];
        [alert showWarning:@"Notifications" subTitle:@"Are you sure want to delete this notification?" closeButtonTitle:nil duration:0.0f];
    }];
    //    deleteAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ic_trash.png"]];
    deleteAction.backgroundColor = [UIColor redColor];
    UITableViewRowAction *unreadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Unread" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Yes" actionBlock:^(void) {
            PFObject *obj = [dataArray objectAtIndex:indexPath.row];
            obj[PARSE_FIELD_NOTIFICATION_ISREAD] = @NO;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                [SVProgressHUD dismiss];
                if (succeed && !error){
                    [self refreshItems];
                } else {
                    [Util showAlertTitle:self title:@"Error" message:@"Failed to mark notification as unread."];
                }
            }];
        }];
        [alert addButton:@"No" actionBlock:^(void) {
            
        }];
        [alert showWarning:@"Notifications" subTitle:@"Are you sure want to mark this notification as unread?" closeButtonTitle:nil duration:0.0f];
    }];
    unreadAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, unreadAction];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (topbarList.selectedButtonIndex == 1) // disble swipe for unread notification
    {
        return UITableViewCellEditingStyleDelete; //enable when editing mode is on
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationDetailViewController *vc = (NotificationDetailViewController *) [Util getUIViewControllerFromStoryBoard:@"NotificationDetailViewController"];
    vc.object = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

/* horizontal delegate */
- (void) selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index
{
    [self refreshItems];
}
- (NSInteger) numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList
{
    return 2;
}
- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    if (index == 0){
        return @"Unread Notifications";
    } else {
        return @"Read Notifications";
    }
}

@end
