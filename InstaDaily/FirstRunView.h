//
//  FirstRunView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface FirstRunView : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) UIWebView *webView;

- (IBAction) authButton;

@end
