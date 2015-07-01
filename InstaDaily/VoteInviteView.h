//
//  VoteInviteView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface VoteInviteView : UIViewController <MBProgressHUDDelegate, UIWebViewDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)closeWindow;

@end
