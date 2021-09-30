//
//  AddFoodViewController.m
//  BikerLoops
//
//  Created by developer on 31/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "AddFoodViewController.h"
#import "IQDropDownTextField.h"

@interface AddFoodViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    IBOutlet IQDropDownTextField *category;
    IBOutlet IQDropDownTextField *course;
    int counts;
    PFUser *user;
}
@end

@implementation AddFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [PFUser currentUser];
    counts = 1;
    category.isOptionalDropDown = NO;
    [category setItemList:RESTURANT_CUISINE];
    [category setSelectedItem:[RESTURANT_CUISINE objectAtIndex:0]];
    [course setItemList:FOOD_COURSE];
    [course setSelectedItem:[FOOD_COURSE objectAtIndex:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSave:(id)sender {
    if ([self isValid]){
        for (int i=0;i<counts;i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
            UITextField *txtFoodName = (UITextField *)[cell viewWithTag:1];
            UITextField *txtFoodPrice = (UITextField *)[cell viewWithTag:2];
            if (txtFoodName.text.length == 0 || txtFoodPrice.text.length == 0){
                continue;
            }
            
            NSMutableArray *cuisine = user[PARSE_USER_CUISINE];
            if (!cuisine){
                cuisine = [[NSMutableArray alloc] init];
            }
            if (![cuisine containsObject:[category selectedItem]]){
                [cuisine addObject:[category selectedItem]];
            }
            user[PARSE_USER_CUISINE] = cuisine;
            [user saveInBackgroundWithBlock:^(BOOL succed, NSError *error){
                [user fetchInBackground];
            }];
            
            UIPlaceHolderTextView *txtDescription = (UIPlaceHolderTextView *)[cell viewWithTag:3];
            PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_FOOD];
            obj[PARSE_FOOD_OWNER] = user;
            obj[PARSE_FOOD_CUISINE] = [category selectedItem];
            obj[PARSE_FOOD_COURSE] = [course selectedItem];
            obj[PARSE_FOOD_NAME] = txtFoodName.text;
            obj[PARSE_FOOD_PRICE] = [NSNumber numberWithDouble:[txtFoodPrice.text doubleValue]];
            obj[PARSE_FOOD_DESCRIPTION] = txtDescription.text;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                if (succeed && i==counts-1){
                    [SVProgressHUD dismiss];
                    [self onBack:nil];
                }
                if (!succeed){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                }
            }];
        }
    }
}

- (BOOL) isValid {
    for (int i=0;i<counts;i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
        UITextField *txtFoodName = (UITextField *)[cell viewWithTag:1];
        txtFoodName.text = [Util trim:txtFoodName.text];
        UITextField *txtFoodPrice = (UITextField *)[cell viewWithTag:2];
        UIPlaceHolderTextView *txtDescription = (UIPlaceHolderTextView *)[cell viewWithTag:3];
        NSString *foodname = txtFoodName.text;
        foodname = [Util trim:foodname];
        double foodPrice = [txtFoodPrice.text doubleValue];
        NSString *foodDesc = txtDescription.text;
        foodDesc = [Util trim:foodDesc];
        txtDescription.text = foodDesc;
        [txtFoodName resignFirstResponder];
        [txtDescription resignFirstResponder];
        [txtFoodPrice resignFirstResponder];
        if (foodname.length == 0){
            [Util showAlertTitle:self title:@"Add Food" message:@"Please review entries and try again." finish:^{
                [txtFoodName becomeFirstResponder];
            }];
            return NO;
        }
        if (foodname.length>20){
            [Util showAlertTitle:self title:@"Add Food" message:@"Please review entries and try again." finish:^{
                [txtFoodName becomeFirstResponder];
            }];
            return NO;
        }
        if (foodDesc.length>300){
            [Util showAlertTitle:self title:@"Add Food" message:@"Please review entries and try again." finish:^{
                [txtDescription becomeFirstResponder];
            }];
            return NO;
        }
        if (foodPrice>99999 || foodPrice<0.01){
            [Util showAlertTitle:self title:@"Add Food" message:@"Please review entries and try again." finish:^{
                [txtFoodPrice becomeFirstResponder];
            }];
            return NO;
        }
    }
    return YES;
}

- (IBAction)onAdd:(id)sender {
    if (counts>4){
        return;
    }
    NSInteger count = [tableview numberOfRowsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
    [tableview beginUpdates];
    [tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cellAddFood"];
    UITextField *txtFoodName = (UITextField *)[cell viewWithTag:1];
    UITextField *txtFoodPrice = (UITextField *)[cell viewWithTag:2];
    UIPlaceHolderTextView *txtDescription = (UIPlaceHolderTextView *)[cell viewWithTag:3];
    txtFoodName.text = @"";
    txtFoodPrice.text = @"";
    txtDescription.text = @"";
    txtDescription.placeholder = @"Food Description";
    [Util setCornerView:txtDescription];
    [Util setBorderView:txtDescription color:COLOR_GRAY_LIGHT width:0.5];
    
    counts++;
    [tableview endUpdates];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return counts;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAddFood"];
    UITextField *txtFoodName = (UITextField *)[cell viewWithTag:1];
    UITextField *txtFoodPrice = (UITextField *)[cell viewWithTag:2];
    UIPlaceHolderTextView *txtDescription = (UIPlaceHolderTextView *)[cell viewWithTag:3];
    txtDescription.placeholder = @"Food Description";
    [Util setCornerView:txtDescription];
    [Util setBorderView:txtDescription color:COLOR_GRAY_LIGHT width:0.5];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    return UITableViewCellEditingStyleDelete; //enable when editing mode is on
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [tableview beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        counts--;
        [tableview endUpdates];
    }
}
@end
