//
//  PhotoView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoView.h"


@implementation PhotoView

@synthesize image, likesCountLabel, changeStatus;
@synthesize imgDict;

- (id)initWIthImage:(NSDictionary *)imageDict {
    self.imgDict = [NSMutableDictionary dictionaryWithDictionary:imageDict];
//    NSLog(@"%@", self.imgDict);
    
    // HUD
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading";
    HUD.delegate = self;
    [self.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(fetchAndAddPhoto) onTarget:self withObject:nil animated:YES];
    
    self.likesCountLabel.text = [NSString stringWithFormat:@"%@", [self.imgDict objectForKey:@"likes"]];
    if ([[self.imgDict objectForKey:@"active"] intValue] == 0) {
        [self.changeStatus setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    }
    else if ([[self.imgDict objectForKey:@"user_active"] intValue] == 0) {
        [self.changeStatus setImage:[UIImage imageNamed:@"activate.png"] forState:UIControlStateNormal];
    }
    else if ([[self.imgDict objectForKey:@"user_active"] intValue] == 1) {
        [self.changeStatus setImage:[UIImage imageNamed:@"deactivate.png"] forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)fetchAndAddPhoto {
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [self.imgDict objectForKey:@"instagram_id"]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    [ServerConnect downloadPhoto:[imgDict objectForKey:@"url_low"] withName:imageName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSLog(@"cannot find photo");
    }
    
    UIImage *tempImg = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path]];
    self.image.image = tempImg;
    [tempImg release];
}

- (IBAction)imageStatusChange {
    
    self.changeStatus.imageView.image = nil;
    if ([[self.imgDict objectForKey:@"active"] intValue] == 0 || [[self.imgDict objectForKey:@"user_active"] intValue] == 0) 
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"activate" forKey:@"type"];
        [dict setObject:[self.imgDict objectForKey:@"instagram_id"] forKey:@"media_id"];
        [ServerConnect callUrl:MY_PHOTO_URL withData:(NSDictionary *)dict];
        [[[UIApplication sharedApplication] delegate] addAnalytics:@"my_photos/add_tag"];
        
        [self.imgDict setValue:@"1" forKey:@"active"];
        [self.imgDict setValue:@"1" forKey:@"user_active"];
        
        [self.changeStatus setImage:[UIImage imageNamed:@"deactivate.png"] forState:UIControlStateNormal];
    }
    else if ([[self.imgDict objectForKey:@"user_active"] intValue] == 1) 
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"deactivate" forKey:@"type"];
        [dict setObject:[self.imgDict objectForKey:@"instagram_id"] forKey:@"media_id"];
        [ServerConnect callUrl:MY_PHOTO_URL withData:(NSDictionary *)dict];
        
        [self.imgDict setValue:@"0" forKey:@"user_active"];
        [self.changeStatus setImage:[UIImage imageNamed:@"activate.png"] forState:UIControlStateNormal];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:0 forKey:@"counter_my_photos"];
}

/*
UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change status" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"add #instadaily", @"dupa", nil];
[actionSheet showInView:self.view];
[actionSheet release];

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0) {
		NSLog(@"ok");
	}
    else {
        NSLog(@"%d", buttonIndex);
    }
}
*/
- (void)dealloc
{
    [self.image release];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.image = nil;
    self.imgDict = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
