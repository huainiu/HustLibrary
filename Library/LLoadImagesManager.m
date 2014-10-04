//
//  LLoadImagesManager.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-14.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LLoadImagesManager.h"
#import "LDBManager.h"

@implementation LLoadImagesManager

+ (LLoadImagesManager *)sharedManager {
    static LLoadImagesManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://ftp.lib.hust.edu.cn"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //        [config setHTTPAdditionalHeaders:@{}];
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10*1024*1024
                                                          diskCapacity:50*1024*1024
                                                              diskPath:nil];
        [config setURLCache:cache];
        
        _sharedManager = [[LLoadImagesManager alloc] initWithBaseURL:baseURL
                                                 sessionConfiguration:config];
        _sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return _sharedManager;
}

- (NSURLSessionDataTask *)loadingImagesForTerm:(NSString *)term Completion:(void (^)(UIImage *, NSError *))completion {
    NSMutableArray *fetchResults = [[LDBManager sharedManager] takeOutRecordsInEntity:@"BooksImage"];
    for (NSInteger i = 0; i < [fetchResults count]; i++) {
        BooksImage *tempBooksImage = fetchResults[i];
        if ([tempBooksImage.bookID isEqualToString:term]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([UIImage imageWithData:tempBooksImage.imageData], nil);
            });
            return nil;
        }
    }
    
    NSURLSessionDataTask *task = [self GET:[NSString stringWithFormat:@"/bookjacket?recid=%@&size=0", term]
                                parameters:nil
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       [[LDBManager sharedManager] addObject:@{@"bookID": term,
                                                                            @"imageData": responseObject}
                                                                    toEntity:@"BooksImage"];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion([UIImage imageWithData:responseObject], nil);
                                       });
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(nil, error);
                                       });
                                   }];
    return task;
}

@end
