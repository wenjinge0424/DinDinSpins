//
//  InformViewController.h
//  DinDinSpins
//
//  Created by developer on 27/02/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

@interface InformViewController : UIViewController<UIWebViewDelegate>
@property(nonatomic, assign) int flag;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
