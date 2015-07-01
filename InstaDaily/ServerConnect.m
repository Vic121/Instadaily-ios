//
//  ServerConnect.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerConnect.h"

@implementation ServerConnect

+ (NSDictionary *)fetchJSONByURL:(NSString *)url {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    url = [NSString stringWithFormat:@"%@?user=%@&token=%@", url, [prefs objectForKey:@"user_name"], [prefs objectForKey:@"user_token"]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error) {}
    
    NSDictionary *json = [[request responseString] yajl_JSON];
    
    // NSLog(@"fetching url: %@", url);
    
    [request cancel];
    //	[request release];
    
    return json;
}

+ (void)callUrl:(NSString *)url withData:(NSDictionary *)dataDict {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    url = [NSString stringWithFormat:@"%@?user=%@&token=%@", url, [prefs objectForKey:@"user_name"], [prefs objectForKey:@"user_token"]];
    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
//    [request setRequestMethod:@"POST"];
    for (NSString *key in [dataDict allKeys]) {
        [request addPostValue:[dataDict objectForKey:key] forKey:key];
    }
    [request startAsynchronous];
    
//    NSLog(@"calling url: %@", url);
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    NSString *responseString = [request responseString];
//    NSLog(@"response: %@", responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
//    NSError *error = [request error];
}

+ (NSDictionary *)getSubject {    
    return [ServerConnect fetchJSONByURL:SUBJECT_URL];
}

+ (NSArray *)getRandomPhotos {
    NSDictionary *json = [ServerConnect fetchJSONByURL:PHOTO_URL];
    if ([json objectForKey:@"photos"] == nil) {
        return nil;
    }
    
    id object;
    NSMutableArray *tempPhotos = [NSMutableArray array];
    NSEnumerator *photos_e = [[json objectForKey:@"photos"] objectEnumerator];
    while ((object = [photos_e nextObject])) {
        [tempPhotos addObject:(NSDictionary *) object];
    }
    
    return (NSArray *)tempPhotos;
}

+ (NSDictionary *)getMyPhotos {
    NSDictionary *json = [ServerConnect fetchJSONByURL:MY_PHOTO_URL];
    return [json objectForKey:@"photos"];
}

+ (NSArray *)getUserSubjects {
    NSDictionary *json = [ServerConnect fetchJSONByURL:USER_SUBJECTS_URL];
    return [json objectForKey:@"subjects"];
}

+ (NSArray *)getUserSubjects:(NSString *)username {
    NSString *url = [NSString stringWithFormat:@"%@user/%@/", USER_SUBJECTS_URL, username];
    NSDictionary *json = [ServerConnect fetchJSONByURL:url];
    return [json objectForKey:@"subjects"];
}

+ (NSArray *)getUserSubjectPhotos:(NSString *)subjectId {
    NSString *url = [NSString stringWithFormat:@"%@/%@/", USER_SUBJECT_URL, subjectId];
    NSDictionary *json = [ServerConnect fetchJSONByURL:url];
    return [json objectForKey:@"photos"];
}

+ (NSArray *)getUserSubjectPhotos:(NSString *)subjectId forUser:(NSString *)username {
    NSString *url = [NSString stringWithFormat:@"%@/%@/user/%@/", USER_SUBJECT_URL, subjectId, username];
    NSDictionary *json = [ServerConnect fetchJSONByURL:url];
    return [json objectForKey:@"photos"];
}

+ (NSDictionary *)getLeaderboard {
    NSDictionary *json = [ServerConnect fetchJSONByURL:LEADERBOARD_URL];
    return [json objectForKey:@"leaderboard"];
}

+ (void)downloadPhoto:(NSString *)url withName:(NSString *)name {
	
    NSData *data;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *urlObj = [NSURL URLWithString:url];
        data = [NSData dataWithContentsOfURL:urlObj];
        [data writeToFile:path atomically:YES];
    }
//    NSLog(@"dlded %@ from %@ to %@", name, url, path);
}

+ (UIImage *)downloadAndReturnPhoto:(NSString *)url withName:(NSString *)name {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [ServerConnect downloadPhoto:url withName:name];
    }
    
    return [[[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path]] autorelease];
}

+ (void)downloadPhotos:(NSArray *)photos {
    
    for (NSDictionary *photo in photos) {
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [photo objectForKey:@"instagram_id"]];
    	NSString *urlString = [photo objectForKey:@"url_low"];
        [self downloadPhoto:urlString withName: imageName];
    }
}

+ (void)downloadPhotoThumbs:(NSArray *)photos {
    
    for (NSDictionary *photo in photos) {
        NSString *imageName = [NSString stringWithFormat:@"%@_t.jpg", [photo objectForKey:@"instagram_id"]];
    	NSString *urlString = [photo objectForKey:@"url_thumb"];
        [self downloadPhoto:urlString withName: imageName];
    }
}

@end
