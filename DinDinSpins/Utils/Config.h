//
//  Config.h
//
//  Created by IOS7 on 12/16/14.
//  Copyright (c) 2014 iOS. All rights reserved.
//

#import "AppStateManager.h"
/* ***************************************************************************/
/* ***************************** Paypal config ********************************/
/* ***************************************************************************/
#define PAYPAL_APP_ID_SANDBOX       @""
#define PAYPAL_APP_ID_LIVE          @""
#define PAYPAL_IS_PRODUCT_MODE      YES
#define PAYPAL_APP_ID               (PAYPAL_IS_PRODUCT_MODE ? PAYPAL_APP_ID_LIVE : PAYPAL_APP_ID_SANDBOX)
#define PAYPAL_ENV                  (PAYPAL_IS_PRODUCT_MODE ? ENV_LIVE : ENV_SANDBOX)


/* ***************************************************************************/
/* ***************************** Stripe config ********************************/
/* ***************************************************************************/

#define STRIPE_KEY                              @""
//#define STRIPE_KEY                              @""
#define STRIPE_URL                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                          @"charges"
#define STRIPE_CUSTOMERS                        @"customers"
#define STRIPE_TOKENS                           @"tokens"
#define STRIPE_ACCOUNTS                         @"accounts"
#define STRIPE_CONNECT_URL                      @"https://dindinspins.brainyapps.tk"


#define APP_NAME                                                @"DinDinSpins"
#define PARSE_FETCH_MAX_COUNT                                   10000
#define APP_THEME                                               [AppStateManager sharedInstance].app_theme
//#define APP_THEME                                                @"business"
#define APP_TEHME_CUSTOMER                                      @"customer"
#define APP_THEME_BUSINESS                                      @"business"

#define WEB_END_POINT_ITEM_SEARCH_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemSearch"
#define WEB_END_POINT_ITEM_LOOKUP_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemLookup/%@"

#define AUTH_TOKEN_KEY                                          @"98c9c3d6-6c1e-4b8a-acd3-9177a1176d90"

/* Friend / SO status values */
#define FRIEND_INVITE_SEND                                      @"Invite"
#define FRIEND_INVITE_ACCEPT                                    @"Accept"
#define FRIEND_INVITE_REJECT                                    @"Reject"

#define SO_INVITE_SEND                                          @"SOInviteSend"
#define SO_INVITE_ACCEPT                                        @"SOInviteAccept"
#define SO_INVITE_REJECT                                        @"SOInviteReject"

/* Pending Type values */
#define PENDING_TYPE_FRIEND_INVITE                              @"Pending_Friend_Invite"
#define PENDING_TYPE_SO_SEND                                    @"Pending_SO_Send"
#define PENDING_TYPE_INTANGIBLE_SEND                            @"Pending_Intangible_Send"

// Push Notification
#define PARSE_CLASS_NOTIFICATION_FIELD_TYPE                     @"type"
#define PARSE_CLASS_NOTIFICATION_FIELD_DATAINFO                 @"dataInfo"
#define PARSE_NOTIFICATION_APP_ACTIVE                           @"app_active"

/* Pagination values  */
#define PAGINATION_DEFAULT_COUNT                                10000
#define PAGINATION_START_INDEX                                  1

/* IWant Type values */
#define IWANT_INTANGIBLE_CATEGORY                                @"Intangible"

/* Notification values */
#define NOTIFICATION_SHOW_PENDING_PAGE                          @"ShowPending"
#define NOTIFICATION_HIDE_PENDING_PAGE                          @"HidePending"

#define NOTIFICATION_SHOW_INPUTSO_PAGE                          @"ShowInputSO"
#define NOTIFICATION_HIDE_INPUTSO_PAGE                          @"HideInputSO"

#define NOTIFICATION_SHOW_INTANGIBLE_PAGE                       @"ShowIntangible"
#define NOTIFICATION_HIDE_INTANGIBLE_PAGE                       @"HideIntangible"

#define NOTIFICATION_SHOW_SOPREVIEW_PAGE                        @"ShowSOPreview"
#define NOTIFICATION_HIDE_SOPREVIEW_PAGE                        @"HideSOPreview"

#define MAIN_COLOR          [UIColor colorWithRed:2/255.f green:114/255.f blue:202/255.f alpha:1.f]
#define MAIN_BORDER_COLOR   [UIColor colorWithRed:186/255.f green:186/255.f blue:186/255.f alpha:1.f]
#define MAIN_BORDER1_COLOR  [UIColor colorWithRed:209/255.f green:209/255.f blue:209/255.f alpha:1.f]
#define MAIN_BORDER2_COLOR  [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:1.f]
#define MAIN_HEADER_COLOR   [UIColor colorWithRed:103/255.f green:103/255.f blue:103/255.f alpha:1.f]
#define MAIN_SWDEL_COLOR    [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
#define MAIN_DESEL_COLOR    [UIColor colorWithRed:206/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_HOLDER_COLOR   [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.f]
#define MAIN_TRANS_COLOR          [UIColor colorWithRed:204/255.f green:227/255.f blue:244/255.f alpha:1.f]

/* Page Notifcation */
#define NOTIFICATION_START_PAGE                                 @"StartMainPage"
#define NOTIFICATION_SIGNIN_PAGE                                @"SignInPage"
#define NOTIFICATION_PASSWDRESET_PAGE                           @"PasswdResetPage"
#define NOTIFICATION_WANTLIST_PAGE                              @"WantListPage"
#define NOTIFICATION_PROFILE_PAGE                               @"ProfilePage"
#define NOTIFICATION_FRIENDS_PAGE                               @"FriendsPage"
#define NOTIFICATION_INVITE_PAGE                                @"InvitePage"
#define NOTIFICATION_INSTRUCTIONS_PAGE                          @"InstructionsPage"
#define NOTIFICATION_NEWITEM_PAGE                               @"NewItemPage"
#define NOTIFICATION_NEWCATEGORY_PAGE                           @"NewCategoryPage"
#define NOTIFICATION_HIDENEW_PAGE                               @"HideNewPage"

/* Refresh Notifcation */
#define NOTIFICATION_REFRESH_FRIENDS                            @"RefreshFriends"
#define NOTIFICATION_REFRESH_MYLIST                             @"RefreshMyList"
#define NOTIFICATION_CHANGED_PAGE                               @"ChangedPage"
#define NOTIFICATION_REFRESH_BADGE                              @"RefreshBadge"

/* Remote Notification Type values */
#define REMOTE_NF_TYPE_NEW_ITEM                                 @"New_Iwant_Item"
#define REMOTE_NF_TYPE_NEW_CATEGORY                             @"New_Category"
#define REMOTE_NF_TYPE_FRIEND_INVITE                            @"Friend_Invite"
#define REMOTE_NF_TYPE_INVITE_ACCEPT                            @"Invite_Result_Accept"
#define REMOTE_NF_TYPE_INVITE_REJECT                            @"Invite_Result_Reject"
#define REMOTE_NF_TYPE_CLICK_EMPTY_CATEGORY                     @"Click_Empty_Category"

/* JCWheelView Notification */
#define NOTIFICATION_SPIN_STOP                                  @"spin_stopped"

/* Spin Notification Data */
#define SPIN_POINT_X                                             @"point_x"
#define SPIN_POINT_Y                                             @"point_y"

enum {
    USER_TYPE_CUSTOMER,
    USER_TYPE_BUSINESS
};

enum {
    FLAG_TERMS_OF_SERVERICE,
    FLAG_PRIVACY_POLICY,
    FLAG_ABOUT_THE_APP
};

/* Parse Table */
#define PARSE_FIELD_OBJECT_ID                                   @"objectId"
#define PARSE_FIELD_USER                                        @"user"
#define PARSE_FIELD_CHANNELS                                    @"channels"
#define PARSE_FIELD_CREATED_AT                                  @"createdAt"
#define PARSE_FIELD_UPDATED_AT                                  @"updatedAt"

/* User Table */
#define PARSE_TABLE_USER                                        @"User"
#define PARSE_USER_FIRST_NAME                                   @"firstName"
#define PARSE_USER_LAST_NAME                                    @"lastName"
#define PARSE_USER_FULL_NAME                                    @"fullname"
#define PARSE_USER_EMAIL                                        @"email"
#define PARSE_USER_GENDER                                       @"gender"
#define PARSE_USER_AGE                                          @"age"
#define PARSE_USER_DESCRIPTION                                  @"description"
#define PARSE_USER_PASSWORD                                     @"password"
#define PARSE_USER_USERNAME                                     @"username"
#define PARSE_USER_LOCATION                                     @"location"
#define PARSE_BUSINESS_NAME                                     @"businessName"
#define PARSE_BUSINESS_CONTACT_NUM                              @"contactNumber"
#define PARSE_USER_TYPE                                         @"type"
#define PARSE_USER_AVATAR                                       @"avatar"
#define PARSE_USER_ADDRESS                                      @"address"
#define PARSE_USER_FACEBOOKID                                   @"facebookid"
#define PARSE_USER_GOOGLEID                                     @"googleid"
#define PARSE_USER_CUISINE                                      @"cuisine"
#define PARSE_USER_REVIEW_SUM                                   @"reviewSum"
#define PARSE_USER_REVIEW_COUNT                                 @"reviewCount"
#define PARSE_USER_REVIEW_MARKS                                 @"reviewMarks"
#define PARSE_USER_BUSINESS_ACCOUNT_ID                          @"accountId"

/* Food Table */
#define PARSE_TABLE_FOOD                                        @"Food"
#define PARSE_FOOD_OWNER                                        @"owner"
#define PARSE_FOOD_COURSE                                       @"course"
#define PARSE_FOOD_CUISINE                                      @"cuisine"
#define PARSE_FOOD_NAME                                         @"name"
#define PARSE_FOOD_PRICE                                        @"price"
#define PARSE_FOOD_DESCRIPTION                                  @"description"

/* Offer Table */
#define PARSE_TABLE_OFFER                                       @"Offer"
#define PARSE_OFFER_OWNER                                       @"owner"
#define PARSE_OFFER_NAME                                        @"name"
#define PARSE_OFFER_TYPE                                        @"type"
#define PARSE_OFFER_AMOUNT                                      @"amount"
#define PARSE_OFFER_DETAILS                                     @"details"
#define PARSE_OFFER_EXPIRE                                      @"expireDate"

/* Review table */
#define PARSE_TABLE_REVIEW                                      @"Review"
#define PARSE_REVIEW_RESTAURANT                                 @"restaurant"
#define PARSE_REVIEW_POSTER                                     @"poster"
#define PARSE_REVIEW_MARKS                                      @"marks"
#define PARSE_REVIEW_REVIEW                                     @"review"

/* Notification table */
#define PARSE_CLASS_NOTIFICATION                @"Notification"
#define PARSE_FIELD_NOTIFICATION_TOUSER         @"toUser"
#define PARSE_FIELD_NOTIFICATION_FROMUSER       @"fromUser"
#define PARSE_FIELD_NOTIFICATION_MESSAGE        @"message"
#define PARSE_FIELD_NOTIFICATION_ADDRESS        @"address"
#define PARSE_FIELD_NOTIFICATION_NOTES          @"notes"
#define PARSE_FIELD_NOTIFICATION_ISREAD         @"isRead"
#define PARSE_FIELD_NOTIFICATION_ORDERS         @"orders"
#define PARSE_FIELD_NOTIFICATION_OFFER          @"offers"
#define PARSE_FIELD_NOTIFICATION_APPROVE        @"transaction_approval"
#define PARSE_FIELD_NOTIFICATION_PAY_TYPE       @"type_payment"
#define PARSE_FIELD_NOTIFICATION_QUANTIES       @"quanties"
#define PARSE_FIELD_NOTIFICATION_AMOUNT         @"amount"

/* Payment History table */
#define PARSE_CLASS_PAYMENTHISTORY              @"PaymentHistory"
#define PARSE_FIELD_PAYMENTHISTORY_AMOUNT       @"amount"
#define PARSE_FIELD_PAYMENTHISTORY_DESCRIPTION  @"description"
#define PARSE_FIELD_PAYMENTHISTORY_OWNER        @"owner"
#define PARSE_FIELD_PAYMENTHISTORY_RESTAURANT   @"restaurant"
#define PARSE_FIELD_PAYMENTHISTORY_ADDRESS      @"address"
#define PARSE_FIELD_PAYMENTHISTORY_NOTES        @"notes"
#define PARSE_FIELD_PAYMENTHISTORY_IS_CAPTURED  @"isCaptured"


#define FOOD_COURSE               [[NSArray alloc] initWithObjects:@"Appetizers", @"Soups", @"Main Course", @"Salad", @"Dessert", nil]
// #define RESTURANT_CUISINE         [[NSArray alloc] initWithObjects:@"Indian", @"Polish", @"Asian", @"Irish", @"Greek", @"Seafood", @"American", @"French", @"Spanish", @"Russian", @"Southern", @"German", @"Middle Eastern", @"Italian", @"Mexican", @"Carribean", nil]
#define RESTURANT_CUISINE         [[NSArray alloc] initWithObjects:@"American", @"Asian", @"Carribean", @"French", @"German", @"Greek", @"Indian", @"Italian", @"Irish", @"Middle Eastern", @"Mexican", @"Polish", @"Seafood", @"Southern", @"Spanish", @"Russian", nil]

