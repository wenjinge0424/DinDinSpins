//
//  AppNameViewController.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "AppNameViewController.h"
#import "FilterViewController.h"
#import "UIImage+Convenience.h"
#import "SettingViewController.h"
#import "RestaurantProfileViewController.h"
#import "MenuViewController.h"
#import "CurrentOffersViewController.h"
#import "JCWheelView.h"
#import "JCWheelItem.h"
#import "JCRotateGestureRecognizer.h"
#import "IQDropDownTextField.h"
#import "CircleImageView.h"
#import "NotificationViewController.h"
#import "StripeRest.h"
#import "StripeConnectionViewController.h"

@interface AppNameViewController ()<JCWheelViewDelegate, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, IQDropDownTextFieldDelegate>
@property (strong, nonatomic) PFUser *me;
@property (strong, nonatomic) IBOutlet UIButton *btnSpin;
@property (strong, nonatomic) IBOutlet UIButton *btnMap;
@property (strong, nonatomic) IBOutlet UIView *viewSpin;
@property (strong, nonatomic) IBOutlet UIView *viewMap;
@property (strong, nonatomic) IBOutlet UIView *viewBlur;
@property (strong, nonatomic) IBOutlet UITextField *txtSearchField;
@property (strong, nonatomic) IBOutlet UIButton *btnSearch;
@property (strong, nonatomic) IBOutlet UIView *viewRestaurantDetail;
@property (strong, nonatomic) IBOutlet UILabel *lblRestaurantname;
@property (strong, nonatomic) IBOutlet UILabel *lblRestaurantArea;
@property (strong, nonatomic) IBOutlet UIImageView *imgRestaurantAvatar;
@property (strong, nonatomic) IBOutlet UITextView *txtRestaurantAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblRestaurantAddress;
@property (strong, nonatomic) IBOutlet UIView *viewWheel;
@property (strong, nonatomic) IBOutlet UITextView *txtRestaurantAddressDetail;
@property (strong, nonatomic) IBOutlet JCWheelView *menu;
//@property (strong, nonatomic) JCWheelView *menu;
@property (strong, nonatomic) IBOutlet UIView *viewSpinned;
@property (strong, nonatomic) IBOutlet UITableView *spinstableview;
@property (strong, nonatomic) IBOutlet GMSMapView *map;
@property (strong, nonatomic) IBOutlet UIButton *btnCategory;
@property (strong, nonatomic) IBOutlet UIButton *btnResutl;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *categoryField;
@property (strong, nonatomic) IBOutlet UIButton *btnStartSpin;

@property (strong, nonatomic) NSMutableArray *spinnedArray;
@property (strong, nonatomic) GMSCameraPosition *camera;
@property (strong, nonatomic) NSMutableArray *_markers;
@property (strong, nonatomic) NSMutableArray *_restaurants;

@property (nonatomic) BOOL isFirst;
@property (strong, nonatomic) IBOutlet UILabel *lblBadgeNumber;
@property (strong, nonatomic) IBOutlet CircleImageView *imgAvatar;
@property (strong, nonatomic) IBOutlet UILabel *restaurantEmail;
@property (strong, nonatomic) IBOutlet UILabel *lblRestaurantContactNumber;

@property (strong, nonatomic) PFUser *targetRestaurant;
@property (nonatomic) NSInteger currentIndex;

@property (nonatomic) CGRect originFrame, menuFrame;
@property (nonatomic) CGRect frameDetailAddress;
@end

BOOL isFrameSet;
@implementation AppNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _me = [PFUser currentUser];
    if (!_me){ // skip to this screen
        
    }
    
    isFrameSet = NO;
    
    _currentIndex = 0;
    
    _categoryField.delegate = self;
    _categoryField.itemList = RESTURANT_CUISINE;
    _categoryField.textColor = [UIColor clearColor];
    
    _viewSpinned.hidden = YES;
    _isFirst = YES;
    
    // customer side
    if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
        [self configWheelView];
        [Util setCornerView:_imgRestaurantAvatar];
        [Util setBorderView:_imgRestaurantAvatar color:MAIN_COLOR width:0.5];
        
        _txtSearchField.delegate = self;
        _frameDetailAddress = _txtRestaurantAddressDetail.frame;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(SpinStopped:) name:@"spinstopped" object:nil];
        
        if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER]){
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationIsActive:)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationEnteredForeground:)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationEnteredBackground:)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
    } else {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refreshView:) name:@"refresh" object:nil];
        _originFrame = _txtRestaurantAddress.frame;
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appDidBecome:) name:PARSE_NOTIFICATION_APP_ACTIVE object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    _spinnedArray = [[NSMutableArray alloc] init];
}

- (void) viewDidLayoutSubviews {
    // business side
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS] && !isFrameSet){
        [self configureBusiness];
        _originFrame = _txtRestaurantAddress.frame;
    } else {
        _menuFrame = self.menu.frame;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self onSpin:nil];
}

- (void)applicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        NSInteger badgeNums = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badgeNums == 0){
            _lblBadgeNumber.hidden = YES;
        } else {
            _lblBadgeNumber.hidden = NO;
            _lblBadgeNumber.text = [NSString stringWithFormat:@"%ld", (long)badgeNums];
        }
    } else {
        
    }
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    
}

- (void)applicationEnteredBackground:(NSNotification *)notification {
    NSLog(@"Application Entered Background");

}

- (void) refreshView:(NSNotification *) notif {
    if (![APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        return;
    }
    NSInteger badgeNums = [UIApplication sharedApplication].applicationIconBadgeNumber;
    if (badgeNums == 0){
        _lblBadgeNumber.hidden = YES;
    } else {
        _lblBadgeNumber.hidden = NO;
        _lblBadgeNumber.text = [NSString stringWithFormat:@"%ld", (long)badgeNums];
    }
    _me = [_me fetchIfNeeded];
    [self configureBusiness];
}

- (void) appDidBecome:(NSNotification *)notif{
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        NSInteger badgeNums = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badgeNums == 0){
            _lblBadgeNumber.hidden = YES;
        } else {
            _lblBadgeNumber.hidden = NO;
            _lblBadgeNumber.text = [NSString stringWithFormat:@"%ld", (long)badgeNums];
        }
    } else {

    }
}

- (void) configureBusiness {

//    _txtRestaurantAddress.frame = _originFrame;
    
    isFrameSet = YES;
    
    // business side
    [Util setCircleView:_lblBadgeNumber];
    NSInteger badgeNums = [UIApplication sharedApplication].applicationIconBadgeNumber;
    if (badgeNums == 0){
        _lblBadgeNumber.hidden = YES;
    } else {
        _lblBadgeNumber.text = [NSString stringWithFormat:@"%ld", (long)badgeNums];
    }
    
    if (_me[PARSE_USER_AVATAR]){
        [Util setImage:_imgAvatar imgFile:(PFFile *)_me[PARSE_USER_AVATAR]];
    }
    _lblRestaurantname.text = _me[PARSE_BUSINESS_NAME];
    _restaurantEmail.text = _me.username;
    _lblRestaurantAddress.text = _me[PARSE_USER_ADDRESS];
    _lblRestaurantContactNumber.text = _me[PARSE_BUSINESS_CONTACT_NUM];
    [Util setImage:_imgRestaurantAvatar imgFile:(PFFile *)_me[PARSE_USER_AVATAR]];
    
    _txtRestaurantAddress.text = _me[PARSE_USER_ADDRESS];
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if (![PFUser currentUser]){
        [self gotoLogin];
        return;
    }
    _spinnedArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:USER_TYPE_BUSINESS]];
    [query whereKey:PARSE_USER_CUISINE containsString:RESTURANT_CUISINE[_menu.seletedIndex]];
    [query includeKey:PARSE_USER_ADDRESS];
    [query includeKey:PARSE_USER_LOCATION];
    [query includeKey:PARSE_USER_AVATAR];
    [query includeKey:PARSE_BUSINESS_NAME];
    [query includeKey:PARSE_BUSINESS_CONTACT_NUM];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    
    AppStateManager* instance = [AppStateManager sharedInstance];
    
    // add filter when Customer
    if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER] && [AppStateManager sharedInstance].is_filter){
        // rating
//        [query whereKey:PARSE_USER_REVIEW_MARKS greaterThanOrEqualTo:[NSNumber numberWithInt:instance.rate_bottom]];
//        [query whereKey:PARSE_USER_REVIEW_MARKS lessThanOrEqualTo:[NSNumber numberWithInt:instance.rate_top]];
//        PFGeoPoint *meLocation = [PFGeoPoint geoPointWithLocation:[Util appDelegate].currentLocation];
        [query whereKey:PARSE_USER_REVIEW_MARKS equalTo:[NSNumber numberWithInt:instance.rate_top]];
        PFGeoPoint *meLocation = (PFGeoPoint *)_me[PARSE_USER_LOCATION];
        [query whereKey:PARSE_USER_LOCATION nearGeoPoint:meLocation withinMiles:instance.distance_top];
        
        PFQuery *queryFood = [PFQuery queryWithClassName:PARSE_TABLE_FOOD];
        [queryFood whereKey:PARSE_FOOD_PRICE lessThanOrEqualTo:[NSNumber numberWithDouble:instance.price_top]];
        [queryFood whereKey:PARSE_FOOD_PRICE greaterThanOrEqualTo:[NSNumber numberWithDouble:instance.price_bottom]];
        [queryFood includeKey:PARSE_FOOD_OWNER];
        [queryFood whereKey:PARSE_FOOD_OWNER matchesQuery:query];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [queryFood findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [SVProgressHUD dismiss];
            if (!error){
                for (int i=0;i<objects.count;i++){
                    PFObject *obj = [objects objectAtIndex:i];
                    PFUser *restaurant = (PFUser *)obj[PARSE_FOOD_OWNER];
                    if (![self isContainsRestaurant:_spinnedArray restaurant:restaurant]){
                        [_spinnedArray addObject:restaurant];
                    }
                }
                if (_spinnedArray.count > 0){
                    _menu.userInteractionEnabled = NO;
                    _btnStartSpin.enabled = NO;
                    _viewSpinned.hidden = NO;
                    [_spinstableview reloadData];
                }
            } else {
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            }
        }];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [SVProgressHUD dismiss];
            if (!error && objects.count>0){
                _menu.userInteractionEnabled = NO;
                _btnStartSpin.enabled = NO;
                _viewSpinned.hidden = NO;
                _spinnedArray = (NSMutableArray *) objects;
                [_spinstableview reloadData];
            } else if (error){
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            }
        }];
    }
}

- (BOOL) isContainsRestaurant:(NSMutableArray *)array restaurant:(PFUser *)rest {
    if (array.count == 0){
        return NO;
    }
    for (int i=0;i<array.count;i++){
        PFUser *obj = [array objectAtIndex:i];
        if ([obj.objectId isEqualToString:rest.objectId]){
            return YES;
        }
    }
    return NO;
}

 - (void) configWheelView {
    _menu.delegate = self;
    _menu.seletedIndex = 0;
    _menu.marrItemColors = @[@"f8e82b", @"22ad6f", @"4799f1", @"407ae1", @"f776b2", @"f25a5a", @"fffeff", @"f98048", @"fae92b", @"22ad6f", @"4799f1", @"407ae1", @"f776b2", @"f25a5a", @"131313", @"f98048", @"e3b64e"];
    self.menu.marrItemData = RESTURANT_CUISINE;
    _menu.isSubItem = false;
    
//    [self.viewWheel addSubview:_menu];
}

- (void)setFontSizeBigger:(NSInteger)selectedIndex{
    for (JCWheelItem *wheelItem in self.menu.subviews) {
        if (wheelItem.tag == selectedIndex){
            _currentIndex = selectedIndex;
            wheelItem.mlblTitile.font = [UIFont systemFontOfSize:GET_RESIZED_FONT(self.view.frame.size.width, 14.5f)];
            
            wheelItem.mlblTitile.layer.shadowColor = [UIColor colorWithRed:255.0f/255.0f green:246.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor;
            wheelItem.mlblTitile.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            wheelItem.mlblTitile.layer.shadowRadius = 5.0;
            wheelItem.mlblTitile.layer.shadowOpacity =0.9f;
            wheelItem.mlblTitile.layer.masksToBounds = NO;
        }
        else{
            wheelItem.mlblTitile.font = [UIFont systemFontOfSize:GET_RESIZED_FONT(self.view.frame.size.width, 12.0f)];
            
            wheelItem.mlblTitile.layer.shadowColor = [UIColor colorWithRed:255.0f/255.0f green:246.0f/255.0f blue:0.0f/255.0f alpha:0.0f].CGColor;
            wheelItem.mlblTitile.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            wheelItem.mlblTitile.layer.shadowRadius = 5.0;
            wheelItem.mlblTitile.layer.shadowOpacity =0.9f;
            wheelItem.mlblTitile.layer.masksToBounds = NO;
        }
    }
    
    // refresh items
//    if (!_isFirst && _viewSpinned.hidden){
//        [self refreshItems];
//    }
//    if (_isFirst){
//        _isFirst = !_isFirst;
//    }
    // DEBUG TEST
    [self refreshItems];
}

- (void) setFontSizeBiggerOnly:(NSInteger) selectedIndex {
    for (JCWheelItem *wheelItem in self.menu.subviews) {
        if (wheelItem.tag == selectedIndex){
            _currentIndex = selectedIndex;
            wheelItem.mlblTitile.font = [UIFont systemFontOfSize:GET_RESIZED_FONT(self.view.frame.size.width, 14.5f)];
            
            wheelItem.mlblTitile.layer.shadowColor = [UIColor colorWithRed:255.0f/255.0f green:246.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor;
            wheelItem.mlblTitile.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            wheelItem.mlblTitile.layer.shadowRadius = 5.0;
            wheelItem.mlblTitile.layer.shadowOpacity =0.9f;
            wheelItem.mlblTitile.layer.masksToBounds = NO;
        }
        else{
            wheelItem.mlblTitile.font = [UIFont systemFontOfSize:GET_RESIZED_FONT(self.view.frame.size.width, 12.0f)];
            
            wheelItem.mlblTitile.layer.shadowColor = [UIColor colorWithRed:255.0f/255.0f green:246.0f/255.0f blue:0.0f/255.0f alpha:0.0f].CGColor;
            wheelItem.mlblTitile.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            wheelItem.mlblTitile.layer.shadowRadius = 5.0;
            wheelItem.mlblTitile.layer.shadowOpacity =0.9f;
            wheelItem.mlblTitile.layer.masksToBounds = NO;
        }
    }
}

- (void)setFontSizeNormal {
    for (JCWheelItem *wheelItem in self.menu.subviews) {
            wheelItem.mlblTitile.font = [UIFont systemFontOfSize:GET_RESIZED_FONT(self.view.frame.size.width, 13.0f)];
            
            wheelItem.mlblTitile.layer.shadowColor = [UIColor colorWithRed:255.0f/255.0f green:246.0f/255.0f blue:0.0f/255.0f alpha:0.0f].CGColor;
            wheelItem.mlblTitile.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            wheelItem.mlblTitile.layer.shadowRadius = 5.0;
            wheelItem.mlblTitile.layer.shadowOpacity =0.9f;
            wheelItem.mlblTitile.layer.masksToBounds = NO;
    }
}

- (IBAction)onStripe:(id)sender {
    // check stripe account
    PFUser *me = [PFUser currentUser];
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^(void) {
            }];
        } else {
            // check stripe account
            [StripeRest getAccount:me[PARSE_USER_BUSINESS_ACCOUNT_ID] completionBlock:^(id data, NSError *error) {
                [SVProgressHUD dismiss];
                if (error) {
                    NSString *confirmStr = @"This app requires a connected ‘Stripe’ account in order that the user may be paid for services rendered – please either signup and/or connect your ‘Stripe’ account to our app.";
                    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                    alert.customViewColor = MAIN_COLOR;
                    [alert setHorizontalButtons:YES];
                    [alert addButton:@"Next" actionBlock:^(void) {
                        StripeConnectionViewController *vc = (StripeConnectionViewController *)[Util getUIViewControllerFromStoryBoard:@"StripeConnectionViewController"];
                        vc.isFromHome = YES;
                        [self.navigationController pushViewController:vc animated:YES];
                    }];
                    [alert addButton:@"Cancel" actionBlock:^(void) {
                    }];
                    [alert showSuccess:@"Confirm" subTitle:confirmStr closeButtonTitle:nil duration:0.0f];
                } else {
                    StripeConnectionViewController *vc = (StripeConnectionViewController *)[Util getUIViewControllerFromStoryBoard:@"StripeConnectionViewController"];
                    vc.isFromHome = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
    }];
}

/* business side */
- (IBAction)onMenu:(id)sender {
    MenuViewController *vc = (MenuViewController *)[Util getUIViewControllerFromStoryBoard:@"MenuViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onOffers:(id)sender {
    CurrentOffersViewController *vc = (CurrentOffersViewController *)[Util getUIViewControllerFromStoryBoard:@"CurrentOffersViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onViewProfile:(id)sender {
    RestaurantProfileViewController *vc = (RestaurantProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"RestaurantProfileViewController"];
    vc.object = [PFUser currentUser];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onSettingBS:(id)sender {
    SettingViewController *vc = (SettingViewController *)[Util getUIViewControllerFromStoryBoard:@"SettingViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onNotifications:(id)sender {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NotificationViewController *vc = (NotificationViewController *)[Util getUIViewControllerFromStoryBoard:@"NotificationViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}


/* customer side */
- (IBAction)onSpin:(id)sender {
    if (_viewSpin.hidden){
        _viewMap.hidden = YES;
        _viewSpin.hidden = NO;
        _viewRestaurantDetail.hidden = YES;
        [self.map clear];
        
        [_btnSpin setImage:[UIImage imageNamed:@"ic_spin_wheel"] forState:UIControlStateNormal];
        [_btnMap setImage:[UIImage imageNamed:@"ic_view_map_gray"] forState:UIControlStateNormal];
    }
}

- (IBAction)onSpinAgain:(id)sender {
    _viewSpinned.hidden = YES;
    _menu.userInteractionEnabled = YES;
    _btnStartSpin.enabled = YES;
}

- (IBAction)onMap:(id)sender {
    if (![PFUser currentUser]){
        [self gotoLogin];
        return;
    }
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *current, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:@"Unable to use GPS. Please check your permission in Settings > Privacy > Location Service"];
            return;
        } else {
            if (_viewMap.hidden){
                _viewMap.hidden = NO;
                _viewSpin.hidden = YES;
                _viewRestaurantDetail.hidden = YES;
                [self.map clear];
                
                _txtSearchField.enabled = NO;
                _txtSearchField.text = @"";
                _txtSearchField.placeholder = @"Select Category";
                _categoryField.hidden = NO;
                [_btnSearch setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
                [_btnResutl setImage:[UIImage imageNamed:@"ic_anti_triangle"] forState:UIControlStateNormal];
                _btnCategory.hidden = NO;
                _viewRestaurantDetail.hidden = YES;
                
                [_btnSpin setImage:[UIImage imageNamed:@"ic_spin_wheel_gray"] forState:UIControlStateNormal];
                [_btnMap setImage:[UIImage imageNamed:@"ic_view_map"] forState:UIControlStateNormal];
                
                self.map.myLocationEnabled = YES;
                self.map.camera = [GMSCameraPosition cameraWithLatitude:current.latitude longitude:current.longitude zoom:15];
                self.map.delegate = self;
                self.map.myLocationEnabled = true;
                
                // Creates a marker in the center of the map.
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(current.latitude, current.longitude);
                marker.map = self.map;
            }
        }
    }];
}

- (IBAction)onSettingCS:(id)sender {
    if (![PFUser currentUser]){
        [self gotoLogin];
        return;
    }
    SettingViewController *vc = (SettingViewController *)[Util getUIViewControllerFromStoryBoard:@"SettingViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onFilter:(id)sender {
    if (![PFUser currentUser]){
        [self gotoLogin];
        return;
    }
    FilterViewController *vc = (FilterViewController *)[Util getUIViewControllerFromStoryBoard:@"FilterViewController"];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    vc.bgImage = [UIImage imageWithView:_viewBlur];
    [self presentViewController:vc animated:YES completion:^{
        [SVProgressHUD dismiss];
    }];
}
- (IBAction)onSearch:(id)sender {
    if (!_txtSearchField.isEnabled){ // search restaurant - curretn - select category
        _txtSearchField.enabled = YES;
        _txtSearchField.text = @"";
        _txtSearchField.placeholder = @"Search Restaurants";
        _categoryField.hidden = YES;
        [_btnSearch setImage:[UIImage imageNamed:@"ic_category"] forState:UIControlStateNormal];
        [_btnResutl setImage:[UIImage imageNamed:@"ic_forward"] forState:UIControlStateNormal];
        _btnCategory.hidden = YES;
        _viewRestaurantDetail.hidden = YES;
    } else { // select category
        _txtSearchField.placeholder = @"Select Category";
        _txtSearchField.text = @"";
        _categoryField.hidden = NO;
        _txtSearchField.enabled = NO;
        [_btnSearch setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
        [_btnResutl setImage:[UIImage imageNamed:@"ic_anti_triangle"] forState:UIControlStateNormal];
        _btnCategory.hidden = NO;
        _viewRestaurantDetail.hidden = YES;
    }
}
- (IBAction)onSelectCategory:(id)sender { // go to result
    if (!_txtSearchField.isEnabled){
        _viewRestaurantDetail.hidden = YES;
        // show category list and select
    } else {
        [_txtSearchField resignFirstResponder];
        _viewRestaurantDetail.hidden = YES;
        // search restaurant on map
        _txtSearchField.text = [Util trim:_txtSearchField.text];
        NSString *resName = _txtSearchField.text;
        if (resName.length == 0){
            [Util showAlertTitle:self title:@"Search Restaurant" message:@"Please type in the restaurant name you're looking for." finish:^(void){
                [_txtSearchField becomeFirstResponder];
            }];
            return;
        } else if (resName.length > 30){
            [Util showAlertTitle:self title:@"Search Restaurant" message:@"The restaurant name is too long." finish:^(void){
                [_txtSearchField becomeFirstResponder];
            }];
            return;
        }
        [self findRestaurantwithName:resName];
        // get result from server and show detail frame
//        _viewRestaurantDetail.hidden = NO;
    }
}

- (void) findRestaurantwithName:(NSString *)name{
    [self.map clear];
    _viewRestaurantDetail.hidden = YES;
    AppStateManager *instance = [AppStateManager sharedInstance];
    PFQuery *query = [PFUser query];
//    [query whereKey:PARSE_BUSINESS_NAME equalTo:name];
    [query whereKey:PARSE_BUSINESS_NAME matchesRegex:name modifiers:@"i"];
    [query includeKey:PARSE_USER_LOCATION];
    if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER] && [AppStateManager sharedInstance].is_filter){
        // rating
        [query whereKey:PARSE_USER_REVIEW_MARKS greaterThanOrEqualTo:[NSNumber numberWithInt:instance.rate_bottom]];
        [query whereKey:PARSE_USER_REVIEW_MARKS lessThanOrEqualTo:[NSNumber numberWithInt:instance.rate_top]];
        // distance
        PFGeoPoint *meLocation = (PFGeoPoint *)_me[PARSE_USER_LOCATION];
        [query whereKey:PARSE_USER_LOCATION nearGeoPoint:meLocation withinMiles:instance.distance_top];
        
        PFQuery *queryFood = [PFQuery queryWithClassName:PARSE_TABLE_FOOD];
        [queryFood whereKey:PARSE_FOOD_PRICE lessThanOrEqualTo:[NSNumber numberWithDouble:instance.price_top]];
        [queryFood whereKey:PARSE_FOOD_PRICE greaterThanOrEqualTo:[NSNumber numberWithDouble:instance.price_bottom]];
        [queryFood includeKey:PARSE_FOOD_OWNER];
        [queryFood whereKey:PARSE_FOOD_OWNER matchesQuery:query];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [queryFood findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [SVProgressHUD dismiss];
            if (!error){
                for (int i=0;i<objects.count;i++){
                    PFObject *obj = [objects objectAtIndex:i];
                    [results addObject:(PFUser *)obj[PARSE_FOOD_OWNER]];
                }
                if (results>0){
                    [self loadRestuarants:(NSArray *)results];
                }
            } else {
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            }
        }];
    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [SVProgressHUD dismiss];
            if (!error && objects.count>0){
                [self loadRestuarants:objects];
            } else if (error) {
                [Util showAlertTitle:self title:@"Search Result" message:[error localizedDescription] finish:nil];
            }
        }];
    }
}

- (void) findRestaurantswithCategory:(NSString *)category{
    if (category.length == 0){
        return;
    }
    [self.map clear];
    _viewRestaurantDetail.hidden = YES;
    PFQuery *query = [PFUser query];
    AppStateManager *instance = [AppStateManager sharedInstance];
    [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:USER_TYPE_BUSINESS]];
    [query whereKey:PARSE_USER_CUISINE containsString:category];
    // category
    // user filter condition
    if ([APP_THEME isEqualToString:APP_TEHME_CUSTOMER] && [AppStateManager sharedInstance].is_filter){
        // rating
        [query whereKey:PARSE_USER_REVIEW_MARKS greaterThanOrEqualTo:[NSNumber numberWithInt:instance.rate_bottom]];
        [query whereKey:PARSE_USER_REVIEW_MARKS lessThanOrEqualTo:[NSNumber numberWithInt:instance.rate_top]];
        // distance
        PFGeoPoint *meLocation = (PFGeoPoint *)_me[PARSE_USER_LOCATION];
        [query whereKey:PARSE_USER_LOCATION nearGeoPoint:meLocation withinMiles:instance.distance_top];
        
        // price
        PFQuery *queryFood = [PFQuery queryWithClassName:PARSE_TABLE_FOOD];
        [queryFood whereKey:PARSE_FOOD_PRICE lessThanOrEqualTo:[NSNumber numberWithDouble:instance.price_top]];
        [queryFood whereKey:PARSE_FOOD_PRICE greaterThanOrEqualTo:[NSNumber numberWithDouble:instance.price_bottom]];
        [queryFood includeKey:PARSE_FOOD_OWNER];
        [queryFood whereKey:PARSE_FOOD_OWNER matchesQuery:query];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        NSMutableArray *results = [[NSMutableArray alloc] init];
        [queryFood findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [SVProgressHUD dismiss];
            if (!error){
                for (int i=0;i<objects.count;i++){
                    PFObject *obj = [objects objectAtIndex:i];
                    [results addObject:(PFUser *)obj[PARSE_FOOD_OWNER]];
                }
                if (results.count>0)
                    [self loadRestuarants:(NSArray *)results];
            } else {
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            }
        }];

    } else {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [SVProgressHUD dismiss];
            if (!error && objects.count>0){
                [self loadRestuarants:objects];
            } else if (error) {
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:nil];
            }
        }];
    }
}

- (void) loadRestuarants:(NSArray *)restaurants {
    self._markers = [[NSMutableArray alloc] init];
    self._restaurants = [[NSMutableArray alloc] init];
    for (PFUser *restaurant in restaurants){
        PFGeoPoint *location = restaurant[PARSE_USER_LOCATION];
        
        // Creates a marker in the center of the map.
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        marker.title = restaurant[PARSE_BUSINESS_NAME];
        marker.icon = [UIImage imageNamed:@"mark_restaurant"];
        marker.map = self.map;
        
        [self._restaurants addObject:restaurant];
        [self._markers addObject:marker];
    }
    [self fitBounds];
}

- (void)fitBounds {
    if ([self._markers count] == 0)
        return;
    
    CLLocationCoordinate2D firstPos = ((GMSMarker *)self._markers.firstObject).position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstPos coordinate:firstPos];
    for (GMSMarker *marker in self._markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
    [self.map moveCamera:update];
}

- (IBAction)onCategories:(id)sender { // show category list and select
    
}

- (IBAction)onViewDetails:(id)sender {
    RestaurantProfileViewController *vc = (RestaurantProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"RestaurantProfileViewController"];
    vc.object = self.targetRestaurant;
    [self.navigationController pushViewController:vc animated:YES];
}

/* JCWheelView delegate */
- (NSInteger)numberOfItemsInWheelView:(JCWheelView *)wheelView
{
    return [_menu.marrItemData count];
}

- (void)wheelView:(JCWheelView *)wheelView didSelectItemAtIndex:(NSInteger)index
{
    if (index != _currentIndex)
        [self setFontSizeBigger:index];
    else
        [self setFontSizeBiggerOnly:index];
}
- (IBAction)tapOut:(id)sender {
    [self onStopSpin:self];
}

- (IBAction)onStopSpin:(id)sender {
    [self.menu stopSpin];
    
//    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    rotation.fromValue = [NSNumber numberWithFloat:0];
//    rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
//    rotation.duration = 1.0;// Speed
//    rotation.repeatCount = 1;// Repeat forever.
//    [self.menu.layer addAnimation:rotation forKey:@"Spin"];
//    
    
}

- (void) SpinStopped:(NSNotification *) notif {
    // get selected item
    for (JCWheelItem *wheelItem in self.menu.subviews) {
        
        CGPoint itemViewCenterPoint = CGPointMake(CGRectGetMidX(wheelItem.bounds), CGRectGetMidY(wheelItem.bounds));
        
        CGPoint itemCenterPointInWindow = [wheelItem convertPoint:itemViewCenterPoint toView:nil];
        CGRect baseWheelItemRectInWindow = [self.menu.baseWheelItem.superview convertRect:self.menu.baseWheelItem.frame toView:nil];
        
        if (CGRectContainsPoint(baseWheelItemRectInWindow, itemCenterPointInWindow)) {
            CGPoint itemCenterPointInBaseWheelItem = [wheelItem convertPoint:itemViewCenterPoint toView:self.menu.baseWheelItem];
            if ([self.menu.rotateGR point:itemCenterPointInBaseWheelItem at:wheelItem]){
                self.menu.seletedIndex = wheelItem.tag;
                //                [UIView animateWithDuration:0.3 animations:^{
                //                    self.menu.transform = CGAffineTransformRotate(self.menu.transform, self.menu.rotateGR.degrees);
                //                } completion:^(BOOL finished) {
                [self wheelView:self.menu didSelectItemAtIndex:self.menu.seletedIndex];
                //                }];
                break;
            }
        }
    }
}

- (IBAction)onStartSpin:(id)sender {
    [self setFontSizeNormal];
    [self.menu startSpin];
}

/*
    #pragma mark - UITableView Delegate
*/
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _spinnedArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellRestaurant"];
    UIImageView *imgAvatar = (UIImageView *)[cell viewWithTag:10];
    [Util setCornerView:imgAvatar];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblArea = (UILabel *)[cell viewWithTag:2];
    UILabel *lblAddress = (UILabel *)[cell viewWithTag:3];
    UIButton *btnDetails = (UIButton *)[cell viewWithTag:4];
    UITextView *txtAddress = (UITextView *)[cell viewWithTag:6];
    PFUser *obj = (PFUser *)[_spinnedArray objectAtIndex:indexPath.row];
    if (obj[PARSE_USER_AVATAR])
        [Util setImage:imgAvatar imgFile:(PFFile *)obj[PARSE_USER_AVATAR]];
//    lblArea.text = @"Sample Area";
    lblAddress.text = obj[PARSE_USER_ADDRESS];
    txtAddress.text = obj[PARSE_USER_ADDRESS];
    lblName.text=obj[PARSE_BUSINESS_NAME];
    [btnDetails addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 60;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellRestaurant"];;
    UITextView *txtAddress = (UITextView *)[cell viewWithTag:6];
    PFUser *obj = (PFUser *)[_spinnedArray objectAtIndex:indexPath.row];
    txtAddress.text = obj[PARSE_USER_ADDRESS];
    CGFloat fixedWidth = txtAddress.frame.size.width;
    CGSize newSize = [txtAddress sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = txtAddress.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    txtAddress.frame = newFrame;

    
//    if (height + newSize.height > 100){
//        return height + newSize.height;
//    } else {
        return 120;
//    }
}

- (void)checkButtonTapped:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_spinstableview];
    NSIndexPath *indexPath = [_spinstableview indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        PFObject *obj = [_spinnedArray objectAtIndex:indexPath.row];
        RestaurantProfileViewController *vc = (RestaurantProfileViewController *)[Util getUIViewControllerFromStoryBoard:@"RestaurantProfileViewController"];
        vc.object = obj;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/* google map delegate */
- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSInteger index = [self._markers indexOfObject:marker];
    if (self._markers.count == 0 || index == NSNotFound){
        return NO;
    }
    marker.icon = [UIImage imageNamed:@"mark_restaurant_result"];
    PFUser *restauant = [self._restaurants objectAtIndex:index];
    self.viewRestaurantDetail.hidden = NO;
    if (restauant[PARSE_USER_AVATAR])
        [Util setImage:_imgRestaurantAvatar imgFile:(PFFile *)restauant[PARSE_USER_AVATAR]];
    _lblRestaurantname.text = restauant[PARSE_BUSINESS_NAME];
//    _lblRestaurantArea.text = @"Area";
    _lblRestaurantAddress.text = restauant[PARSE_USER_ADDRESS];
    
    _txtRestaurantAddressDetail.frame = _frameDetailAddress;
    _txtRestaurantAddressDetail.text = restauant[PARSE_USER_ADDRESS];
    CGFloat fixedWidth = _txtRestaurantAddressDetail.frame.size.width;
    CGSize newSize = [_txtRestaurantAddressDetail sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _txtRestaurantAddressDetail.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    _txtRestaurantAddressDetail.frame = newFrame;
    
    self.targetRestaurant = restauant;
    return YES;
}

/* IQDropDownTextField */
- (void) textField:(IQDropDownTextField *)textField didSelectItem:(NSString *)item
{
    if ([item isEqualToString:@"Select"]){
        return;
    }
    _txtSearchField.text = item;
}

/* UITextField */
- (void) textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    if (_txtSearchField.isEnabled){ // search
        NSString *resName = _txtSearchField.text;
        resName = [Util trim:resName];
        _txtSearchField.text = resName;
        if (resName.length == 0){
            [Util showAlertTitle:self title:@"Search Restaurant" message:@"Please type in the restaurant name you're looking for." finish:^(void){
            }];
            return;
        } else if (resName.length > 30){
            [Util showAlertTitle:self title:@"Search Restaurant" message:@"The restaurant name is too long." finish:^(void){
            }];
            return;
        }
        [self findRestaurantwithName:_txtSearchField.text];
    } else { // category
        [self findRestaurantswithCategory:_txtSearchField.text];
    }
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
