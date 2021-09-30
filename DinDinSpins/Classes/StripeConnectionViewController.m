//
//  StripeConnectionViewController.m
//  BidDrivers
//
//  Created by Vitaly on 2/13/17.
//  Copyright © 2017 iOS. All rights reserved.
//

#import "StripeConnectionViewController.h"
#import "AddPictureViewController.h"
#import "Util.h"

@interface StripeConnectionViewController ()<UIWebViewDelegate>
{
    __weak IBOutlet UIView *htmlView;
    
    UIWebView *newWebView;
    BOOL inited;
    NSURLRequest *stripeRequest;
    IBOutlet UIButton *btnNext;
    IBOutlet UILabel *lblTitle;
}

@end

@implementation StripeConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *stripeURL = [NSString stringWithFormat:@"%@?email=%@&password=%@", STRIPE_CONNECT_URL, [Util getLoginUserName], [Util getLoginUserPassword]];
    NSURL *url = [NSURL URLWithString:stripeURL];
    stripeRequest =[NSURLRequest requestWithURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    btnNext.hidden = _isFromHome;
    if (_isFromHome) {
        lblTitle.text = @"History";
    } else {
        lblTitle.text = @"Create Account";
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (inited)
        return;
    
    newWebView = [[UIWebView alloc] initWithFrame:htmlView.frame];
    [self.view addSubview:newWebView];
    inited = YES;
    newWebView.delegate = self;
    [newWebView loadRequest:stripeRequest];
    newWebView.backgroundColor = [UIColor clearColor];
    [newWebView setOpaque:NO];
}
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onNext:(id)sender {
    AddPictureViewController *vc = (AddPictureViewController *)[Util getUIViewControllerFromStoryBoard:@"AddPictureViewController"];
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
- (void) webViewDidStartLoad:(UIWebView *)webView{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView{
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
