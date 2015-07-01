//
//  VoteView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VoteView.h"


@implementation VoteView

@synthesize image, imageCaption, subjectLabel;
@synthesize currentPhoto, currentPhotoIndex, photos, voted;

- (void)fetchData {
    [self getMorePhotos];
    [self switchToNextPhoto];
    
    if (!connectionFailed) 
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if ([prefs boolForKey:@"voting_explained"] != YES) {
            [self showHelp];
            [prefs setBool:YES forKey:@"voting_explained"];
        }
    }
}

- (void)displayCurrentPhoto {
    
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [self.currentPhoto objectForKey:@"instagram_id"]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        HUD_WAIT = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        HUD_WAIT.labelText = @"still downloading";
        HUD_WAIT.delegate = self;
        [self.navigationController.view addSubview:HUD_WAIT];
        [HUD_WAIT showWhileExecuting:@selector(displayCurrentPhotoInBackground) onTarget:self withObject:nil animated:YES];
        [HUD_WAIT release];
        
    }
    else {
        NSData *data = [NSData dataWithContentsOfFile:path];
        
    //    NSLog(@"current photo: %@", self.currentPhoto);
        
        UIImage *img = [[UIImage alloc] initWithData:data];
        self.image.image = img;
        if ([self.currentPhoto objectForKey:@"caption"] != [NSNull null]) {
            self.imageCaption.text = [self.currentPhoto objectForKey:@"caption"];
        }
        else {
            self.imageCaption.text = @"";
        }
        [img release];
    }
}

- (void)displayCurrentPhotoInBackground {
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [self.currentPhoto objectForKey:@"instagram_id"]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    int tries = 0;
    while (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (tries >= 10 && skippedThrough < 3) {
            skippedThrough++;
            [self switchToNextPhoto];
            return;
        }
        else if (skippedThrough >= 3) {            
//            UIAlertView *alert = [[UIAlertView alloc] init];
//            [alert setTitle:@"Internet Connection"];
//            [alert setMessage:@"I could not download more photos, please check you connection."];
//            [alert setDelegate:nil];
//            [alert addButtonWithTitle:@"OK"];
//            [alert show];
//            [alert release];
            
            self.image.image = [UIImage imageNamed:@"no-photo.png"];
            skippedThrough = 1;
            self.photos = nil;
        }
        
        // wait a while
//        NSLog(@"waiting");
        usleep(500000);
        tries++;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *img = [[UIImage alloc] initWithData:data];
    self.image.image = img;
    if ([self.currentPhoto objectForKey:@"caption"] != [NSNull null]) {
        self.imageCaption.text = [self.currentPhoto objectForKey:@"caption"];
    }
    else {
        self.imageCaption.text = @"";
    }
    [img release];
    skippedThrough = 0;
}

- (void)switchToNextPhoto {
    if (connectionFailed && [self.photos count] == 0) {
        [self getMorePhotos];
        if (connectionFailed) {
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert setTitle:@"Internet Connection"];
            [alert setMessage:@"I could not download any photos, please check you connection."];
            [alert setDelegate:nil];
            [alert addButtonWithTitle:@"OK"];
            [alert show];
            [alert release];
            
            self.image.image = [UIImage imageNamed:@"no-photo.png"];
            self.photos = nil;
            return;
        }
    }
    else if ([self.photos count] == 0) {
        return;
    }
    
    self.currentPhotoIndex += 1;
//    NSLog(@"index: %d", self.currentPhotoIndex);
    
    if ([self.photos count] > self.currentPhotoIndex) {
        self.currentPhoto = [self.photos objectAtIndex:self.currentPhotoIndex];
    }
    else {
        self.currentPhoto = nil;
        [self getMorePhotos];
        
        if ([self.photos count] > self.currentPhotoIndex) {
            self.currentPhoto = [self.photos objectAtIndex:self.currentPhotoIndex];
        }
    }
    [self displayCurrentPhoto];
    
    // if 3 to go, get more...
    if (self.currentPhotoIndex % 10 == 7) {
        // in bg?
        [self getMorePhotos];
    }
}

- (void)switchToPrevPhoto {    
    if (self.currentPhotoIndex > 0 && [self.photos count] > 0 && skippedThrough <= 1) {
        self.currentPhotoIndex -= 1;
        if ([self.photos count] > self.currentPhotoIndex) {
            self.currentPhoto = [self.photos objectAtIndex:self.currentPhotoIndex];
            [self displayCurrentPhoto];
        }
    }
}

- (void)thumbsUpPhoto {
    if (self.currentPhoto == nil) return;
    
    [self displayVotingNotification:@"thumbsUp"];
    
    if (![self.voted containsObject:[self.currentPhoto objectForKey:@"instagram_id"]]) 
    {
        // send update
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"like" forKey:@"type"];
        [dict setObject:[self.currentPhoto objectForKey:@"instagram_id"] forKey:@"media_id"];
        [ServerConnect callUrl:PHOTO_URL withData:(NSDictionary *)dict];
        
        [voted addObject:[self.currentPhoto objectForKey:@"instagram_id"]];
        [[[UIApplication sharedApplication] delegate] addAnalytics:@"vote/up"];
    }
}

- (void)thumbsDownPhoto {
    if (self.currentPhoto == nil) return;
    
    [self displayVotingNotification:@"thumbsDown"];
    
    if (![self.voted containsObject:[self.currentPhoto objectForKey:@"instagram_id"]]) 
    {
        // send update
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"unlike" forKey:@"type"];
        [dict setObject:[self.currentPhoto objectForKey:@"instagram_id"] forKey:@"media_id"];
        [ServerConnect callUrl:PHOTO_URL withData:(NSDictionary *)dict];
        
        [voted addObject:[self.currentPhoto objectForKey:@"instagram_id"]];
        [[[UIApplication sharedApplication] delegate] addAnalytics:@"vote/down"];
    }
}

- (void)getMorePhotos {
    NSArray *morePhotos = [ServerConnect getRandomPhotos];
    
    if (morePhotos == nil) {
        connectionFailed = YES;
        return;
    }
    else if ([morePhotos count] == 0) {
        connectionFailed = NO;
        [self showPromoAlert];
        return;
    }
    else if ([self.photos count] == 0) {
        self.photos = [morePhotos copy];
        connectionFailed = NO;
        [[[UIApplication sharedApplication] delegate] addAnalytics:@"vote"];
    }
    else {
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.photos];
        [tempArr addObjectsFromArray:morePhotos];
        self.photos = (NSArray *)tempArr;
        connectionFailed = NO;
        [[[UIApplication sharedApplication] delegate] addAnalytics:@"vote/more"];
    }
    
    dispatch_queue_t aQueue = dispatch_queue_create("pl.w3net.instadaily_queue", NULL);
    dispatch_async(aQueue, ^{
//        NSArray *ps = [self.photos copy];
        [ServerConnect downloadPhotos:[morePhotos copy]];
    });
    dispatch_release(aQueue);
}

- (void)displayVotingNotification:(NSString *)type {
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    if ([type isEqualToString:@"thumbsUp"]) {
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up.png"]] autorelease];
            HUD.labelText = @"Up Voted";
    }
    else if ([type isEqualToString:@"thumbsDown"]) {
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down.png"]] autorelease];
            HUD.labelText = @"Down Voted";
    }
    else {
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
        HUD.labelText = @"Completed";
    }
	
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = self;
    [self.navigationController.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(sleeper) onTarget:self withObject:nil animated:YES];
    [HUD release];
}

- (void)sleeper {
    sleep(1);
    [self switchToNextPhoto];
}

- (IBAction)showHelp {
    UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"How to vote?"];
	[alert setMessage:@"To vote up just swipe on image from bottom to top and to vote down from top to bottom."];
	[alert setDelegate:nil];
	[alert addButtonWithTitle:@"Thanks"];
	[alert show];
	[alert release];
}

- (void)showPromoAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invite friends" message:@"Currently there're no more photos. Would you like to tweet about this app to invite more people?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        VoteInviteView *viv = [[VoteInviteView alloc] initWithNibName:nil bundle:nil];
        [self.navigationController presentModalViewController:viv animated:YES];
        [viv release];
        [[[UIApplication sharedApplication] delegate] addAnalytics:@"vote/tweet"];
    }
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // gestures
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchToPrevPhoto)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchToNextPhoto)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(thumbsUpPhoto)];
    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(thumbsDownPhoto)];
    recognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
    self.voted = [NSMutableSet set];
    skippedThrough = 1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.currentPhoto = nil;
    self.currentPhotoIndex = nil;
    self.photos = nil;
    self.voted = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSLog(@"%@", [[prefs objectForKey:@"subject"] objectForKey:@"name"]);
    self.subjectLabel.text = [[[prefs objectForKey:@"subject"] objectForKey:@"name"] uppercaseString];
    
    if (self.photos == nil) {
        self.currentPhotoIndex = -1;
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        HUD.labelText = @"Loading";
        HUD.delegate = self;
        [self.navigationController.view addSubview:HUD];
        [HUD showWhileExecuting:@selector(fetchData) onTarget:self withObject:nil animated:YES];
        [HUD release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
