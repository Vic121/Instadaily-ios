//
//  ServerConnect.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Prefs.h"

@interface ServerConnect : NSObject {
    
}

+ (NSDictionary *)fetchJSONByURL:(NSString *)url;
+ (void)callUrl:(NSString *)url withData:(NSDictionary *)dataDict;

+ (NSDictionary *)getSubject;
+ (NSArray *)getRandomPhotos;
+ (NSDictionary *)getMyPhotos;
+ (NSArray *)getUserSubjects;
+ (NSArray *)getUserSubjects:(NSString *)username;
+ (NSArray *)getUserSubjectPhotos:(NSString *)subjectId;
+ (NSArray *)getUserSubjectPhotos:(NSString *)subjectId forUser:(NSString *)username;
+ (NSDictionary *)getLeaderboard;

+ (void)downloadPhoto:(NSString *)url withName:(NSString *)name;
+ (UIImage *)downloadAndReturnPhoto:(NSString *)url withName:(NSString *)name;
+ (void)downloadPhotos:(NSArray *)photos;
+ (void)downloadPhotoThumbs:(NSArray *)photos;

@end
