//
//  PhotoView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ServerConnect.h"
#import "Prefs.h"

@interface PhotoView : UIViewController <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *likesCountLabel;
@property (nonatomic, retain) IBOutlet UIButton *changeStatus;

@property (nonatomic, retain) NSMutableDictionary *imgDict;

- (id)initWIthImage:(NSDictionary *)imgDict;
- (void)fetchAndAddPhoto;
- (IBAction)imageStatusChange;

@end
