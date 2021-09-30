//
//  InformViewController.m
//  DinDinSpins
//
//  Created by developer on 27/02/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "InformViewController.h"
#import "Util.h"

@interface InformViewController ()
{
    IBOutlet UILabel *lblTitle;
}
@end

@implementation InformViewController
@synthesize flag;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView.delegate = self;
    
    NSString *docName = @"";
    if (flag == FLAG_TERMS_OF_SERVERICE){
        docName = @"termsofservice";
        lblTitle.text = @"Terms & Conditions";
    } else if (flag == FLAG_PRIVACY_POLICY){
        docName = @"privacypolicy";
        lblTitle.text = @"Privacy Policy";
    } else if (flag == FLAG_ABOUT_THE_APP){
        docName = @"aboutapp";
        lblTitle.text = @"About the App";
    }
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:docName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSStringEncodingConversionAllowLossy  error:nil];
    [_webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];

//    webView.scrollView.scrollEnabled = YES;
    _webView.scrollView.bounces = NO;
//    _webView.userInteractionEnabled = YES;
}
- (void) viewDidLayoutSubviews {
    _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
// UIWebView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    return YES;
}

- (void) webViewDidFinished:(UIWebView *)webview
{
    //    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    //    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
}

@end
