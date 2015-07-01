//
//  VoteView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ServerConnect.h"
#import "VoteInviteView.h"

@interface VoteView : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    MBProgressHUD *HUD_WAIT;
    NSUInteger skippedThrough;
    BOOL connectionFailed;
}

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *imageCaption;
@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, copy) NSDictionary *currentPhoto;
@property (nonatomic, assign) NSInteger currentPhotoIndex;
@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, retain) NSMutableSet *voted;

- (void)fetchData;
- (void)displayCurrentPhoto;
- (void)displayCurrentPhotoInBackground;
- (IBAction)switchToNextPhoto;
- (IBAction)switchToPrevPhoto;
- (IBAction)thumbsUpPhoto;
- (IBAction)thumbsDownPhoto;
- (IBAction)showHelp;
- (void)getMorePhotos;
- (void)displayVotingNotification:(NSString *)type;
- (void)sleeper;
- (void)showPromoAlert;

@end
