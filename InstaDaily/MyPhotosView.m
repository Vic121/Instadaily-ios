//
//  MyPhotosView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyPhotosView.h"

@implementation MyPhotosView

@synthesize scrollView;
@synthesize activePhotos, inactivePhotos, allPhotos;

- (void)fetchAndAddPhotos {
    // fetch photos
    NSDictionary *myPhotos = [ServerConnect getMyPhotos];
    self.activePhotos = [myPhotos objectForKey:@"active"];
    self.inactivePhotos = [myPhotos objectForKey:@"inactive"];
    
    [ServerConnect downloadPhotoThumbs:self.activePhotos];
    [ServerConnect downloadPhotoThumbs:self.inactivePhotos];
    [[[UIApplication sharedApplication] delegate] addAnalytics:@"my_photos"];
    
    // clean up
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    // add images to view
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.scrollEnabled = YES;
    
    CGFloat curXLoc = 3;
    CGFloat curYLoc = 3;
    if ([self.activePhotos count] == 0 && [self.inactivePhotos count] == 0) {
        // first steps
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.scrollView.bounds.size.width-5, 300)];
        label.text = @"To join the competition you need to post photos using Instagram, before subject’s deadline ends.\nSecond and last requirement is adding #instadaily tag to your photo. Your can do it either as you post it in Instagram app or here.\n\nIf you’re not familiar with tags.\nTag is just a short snippet started with hash (#). In Instagram you can add it to photo’s caption before you post it or as a comment afterwards.";
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 14;
        label.backgroundColor = [UIColor colorWithRed:106 green:74 blue:60 alpha:0];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Courier" size:14.0];
        [self.scrollView addSubview:label];
        [label release];
    }
    else if ([self.activePhotos count] > 0) {
        // #instadaily header
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 22)];
        label.text = @"Active Photos";
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Courier-Bold" size:16.0];
        label.textAlignment = UITextAlignmentCenter;
        [self.scrollView addSubview:label];
        [label release];
        
        curYLoc = 23;
    }
    else {
        // how to activate photos
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.scrollView.bounds.size.width-5, 130)];
        label.text = @"Below is a list of your recent Instagram photos that could be added to the competition. If you think it’s matching current subject, just tap on it and press ‘Add’ button. If you change your mind, you can ‘Deactivate’ it at any time.";
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 8;
        label.backgroundColor = [UIColor colorWithRed:106 green:74 blue:60 alpha:0];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Courier" size:14.0];
        [self.scrollView addSubview:label];
        [label release];
        
        curYLoc = 135;
    }
    
    UITapGestureRecognizer *recognizer;
    NSUInteger i = 1;
    NSUInteger j = 1;
    for (NSDictionary *imgDict in self.activePhotos) {
        NSString *imageName = [NSString stringWithFormat:@"%@_t.jpg", [imgDict objectForKey:@"instagram_id"]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            continue;
        }
        
        UIImage *tempImg = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path]];
        UIImageView *img = [[UIImageView alloc] initWithImage:tempImg];
        [tempImg release];
        
        [img setUserInteractionEnabled:YES];
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapped:)];
        [img addGestureRecognizer:recognizer];
        [recognizer release];
        
		CGRect rect = img.frame;
        rect.size = CGSizeMake(75.0, 75.0);
        rect.origin = CGPointMake(curXLoc, curYLoc);
		img.frame = rect;
		img.tag = i;
		[self.scrollView addSubview:img];
        
        if (j % 4 == 0) {
            curXLoc  = 3;
            curYLoc += 82.0;
        }
        else {
            curXLoc += 80.0;
        }
        
		[img release];
        i++;
        j++;
        
        [self.allPhotos addObject:imgDict];
    }
    
    if ([self.activePhotos count] > 0 && [self.inactivePhotos count] > 0) {
        // photostream header
        if ((j-1) % 4 != 0) {
            curYLoc += 77;
        }
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3, curYLoc, self.scrollView.bounds.size.width, 22)];
        label.text = @"Other Photos";
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Courier-Bold" size:16.0];
        label.textAlignment = UITextAlignmentCenter;
        [self.scrollView addSubview:label];
        [label release];
        
        curYLoc += 23;
    }
    
    curXLoc = 3;
    j = 1;
    for (NSDictionary *imgDict in self.inactivePhotos) {
        NSString *imageName = [NSString stringWithFormat:@"%@_t.jpg", [imgDict objectForKey:@"instagram_id"]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            continue;
        }
        
        UIImage *tempImg = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path]];
        UIImageView *img = [[UIImageView alloc] initWithImage:tempImg];
        [tempImg release];
        
        [img setUserInteractionEnabled:YES];
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapped:)];
        [img addGestureRecognizer:recognizer];
        [recognizer release];
        
		CGRect rect = img.frame;
        rect.size = CGSizeMake(75.0, 75.0);
        rect.origin = CGPointMake(curXLoc, curYLoc);
		img.frame = rect;
		img.tag = i;
		[self.scrollView addSubview:img];
        
        if (j % 4 == 0) {
            curXLoc  = 3;
            curYLoc += 82.0;
        }
        else {
            curXLoc += 80.0;
        }
        
		[img release];
        i++;
        j++;
        
        [self.allPhotos addObject:imgDict];
    }
//    NSLog(@"%@", self.allPhotos);
    
    [self.scrollView setContentSize:CGSizeMake([self.scrollView bounds].size.width, (curYLoc + 85.0))];
}

- (void)imgTapped:(UITapGestureRecognizer *)sender {
    NSDictionary *selectedImg = [self.allPhotos objectAtIndex:sender.view.tag-1];
    
    PhotoView *photoView = [[PhotoView alloc] initWithNibName:nil bundle:nil];
    [photoView initWIthImage:selectedImg];
    
    [self.navigationController pushViewController:photoView animated:YES];
    [photoView release];
}

- (void)refreshList {
    self.allPhotos = [NSMutableArray array];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    HUD.labelText = @"Loading";
    HUD.delegate = self;
    [self.navigationController.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(fetchAndAddPhotos) onTarget:self withObject:nil animated:YES];
}

- (void)dealloc
{
    [self.scrollView release];
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
    
    self.activePhotos = [NSArray array];
    self.inactivePhotos = [NSArray array];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView = nil;
    self.allPhotos = nil;
    self.activePhotos = nil;
    self.inactivePhotos = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (([self.inactivePhotos count] == 0 && [self.activePhotos count] == 0) || [prefs integerForKey:@"counter_my_photos"] == 0) {
        [self refreshList];
        [prefs setInteger:60 forKey:@"counter_my_photos"];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
