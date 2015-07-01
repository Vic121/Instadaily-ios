//
//  MyPhotosView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerConnect.h"
#import "MBProgressHUD.h"
#import "PhotoView.h"

@interface MyPhotosView : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSMutableArray *allPhotos;
@property (nonatomic, retain) NSArray *activePhotos;
@property (nonatomic, retain) NSArray *inactivePhotos;

- (void)fetchAndAddPhotos;
- (void)imgTapped:(UITapGestureRecognizer *)sender;
- (IBAction)refreshList;

@end
