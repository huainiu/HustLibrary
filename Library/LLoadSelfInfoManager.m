//
//  LLoadSelfInfoManager.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LLoadSelfInfoManager.h"
#import "HTMLParser.h"

@implementation LLoadSelfInfoManager

+ (LLoadSelfInfoManager *)sharedManager {
    static LLoadSelfInfoManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"https://ftp.lib.hust.edu.cn"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        [config setHTTPAdditionalHeaders:@{}];
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10*1024*1024
                                                          diskCapacity:50*1024*1024
                                                              diskPath:nil];
        [config setURLCache:cache];
        
        _sharedManager = [[LLoadSelfInfoManager alloc] initWithBaseURL:baseURL
                                                  sessionConfiguration:config];
        _sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return _sharedManager;
}

- (id)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _userName = [userDefaults objectForKey:@"User_Name"];
    _userCode = [userDefaults objectForKey:@"User_Code"];
    _userID = [userDefaults objectForKey:@"User_ID"];
    return self;
}

- (NSURLSessionDataTask *)loadBorrowingBooksInfoWithName:(NSString *)name Code:(NSString *)code Completion:(void (^)(NSArray *info, NSError *error, BOOL finished))completion {
    _userName = name;
    _userCode = code;
    
    NSURLSessionDataTask *task = [self POST:@"/patroninfo*chx"
                                 parameters:@{@"name":_userName, @"code":_userCode}
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        NSString *urlStr = task.response.URL.absoluteString;
                                        NSRange itemsRange = [urlStr rangeOfString:@"/items"];
                                        // Check if the name and code are right
                                        if (itemsRange.location != NSNotFound) {
                                            // Save the name, code and ID into userDefaults
                                            NSRange IDRange = [[urlStr substringWithRange:NSMakeRange(0, urlStr.length-6)] rangeOfString:@"/" options:NSBackwardsSearch];
                                            _userID = [urlStr substringWithRange:NSMakeRange(IDRange.location+1, itemsRange.location-IDRange.location-1)];
                                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                            [userDefaults setObject:_userName forKey:@"User_Name"];
                                            [userDefaults setObject:_userCode forKey:@"User_Code"];
                                            [userDefaults setObject:_userID forKey:@"User_ID"];
                                            [userDefaults synchronize];
                                            
                                            NSData *data = [NSMutableData dataWithData:responseObject];
                                            while ([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] == nil) {
                                                for (NSInteger i = 0; i < [data length]; i+=3) {
                                                    NSData *tempData = [data subdataWithRange:NSMakeRange(i, 3)];
                                                    if ([[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding] == nil) {
                                                        if (i == 0) {
                                                            data = [data subdataWithRange:NSMakeRange(2, data.length-3)];
                                                        } else if (i == (NSInteger)([data length]/3)) {
                                                            data = [data subdataWithRange:NSMakeRange(0, ((NSInteger)([data length]/3))*3)];
                                                        } else {
                                                            NSData *formmerData = [data subdataWithRange:NSMakeRange(0, i-1)];
                                                            NSData *latterData = [data subdataWithRange:NSMakeRange(i+3, [data length]-i-3)];
                                                            NSMutableData *mutData = [[NSMutableData alloc] initWithData:formmerData];
                                                            [mutData appendData:latterData];
                                                            data = [mutData copy];
                                                        }
                                                        break;
                                                    }
                                                }
                                            }
                                            NSArray *borrowingInfo = [self parseBorrowingData:data];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(borrowingInfo, nil, YES);
                                            });
                                        } else {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(nil, nil, NO);
                                            });
                                        }
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            _userName = nil;
                                            _userCode = nil;
                                            completion(nil, error, YES);
                                        });
                                    }];
    return task;
}

- (NSArray *)parseBorrowingData:(NSData *)data {
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:nil];
    HTMLNode *bodyNode = [parser body];
    NSArray *patFuncEntryNodes = [bodyNode findChildrenOfClass:@"patFuncEntry"];
    NSMutableArray *borrowingBooks = [NSMutableArray array];
    for (HTMLNode *patFuncEntryNode in patFuncEntryNodes) {
        // Book name
//        HTMLNode *patFuncTitleMainNode = [patFuncEntryNode findChildOfClass:@"patFuncTitleMain"];
//        NSString *bookName = [[patFuncTitleMainNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // ID
        HTMLNode *aNode = [patFuncEntryNode findChildTag:@"a"];
        NSString *ID = [aNode getAttributeNamed:@"href"];
        ID = [ID substringFromIndex:[ID rangeOfString:@"="].location+1];
        ID = [ID substringToIndex:[ID rangeOfString:@"*"].location];
        // Book ID
//        HTMLNode *patFuncCallNoNode = [patFuncEntryNode findChildOfClass:@"patFuncCallNo"];
//        NSString *bookID = [[patFuncCallNoNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // Book returning date
        HTMLNode *patFuncStatusNode = [patFuncEntryNode findChildOfClass:@"patFuncStatus"];
        NSString *returningDate = [[patFuncStatusNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // Add the book into the mutable array
        [borrowingBooks addObject:@{@"ID": ID,
                                  @"date": returningDate}];
    }
    return [borrowingBooks copy];
}

- (NSURLSessionDataTask *)loadBorrowedBooksInfoWithCompletion:(void (^)(NSArray *info, NSError *error))completion {
    NSURLSessionDataTask *task = [self POST:[[self.baseURL absoluteString] stringByAppendingString:[NSString stringWithFormat:@"/%@/readinghistory", _userID]]
                                 parameters:@{@"name":_userName, @"code":_userCode}
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        NSData *data = [NSMutableData dataWithData:responseObject];
                                        while ([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] == nil) {
                                            for (NSInteger i = 0; i < [data length]; i+=3) {
                                                NSData *tempData = [data subdataWithRange:NSMakeRange(i, 3)];
                                                if ([[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding] == nil) {
                                                    if (i == 0) {
                                                        data = [data subdataWithRange:NSMakeRange(2, data.length-3)];
                                                    } else if (i == (NSInteger)([data length]/3)) {
                                                        data = [data subdataWithRange:NSMakeRange(0, ((NSInteger)([data length]/3))*3)];
                                                    } else {
                                                        NSData *formmerData = [data subdataWithRange:NSMakeRange(0, i-1)];
                                                        NSData *latterData = [data subdataWithRange:NSMakeRange(i+3, [data length]-i-3)];
                                                        NSMutableData *mutData = [[NSMutableData alloc] initWithData:formmerData];
                                                        [mutData appendData:latterData];
                                                        data = [mutData copy];
                                                    }
                                                    break;
                                                }
                                            }
                                        }
                                        NSArray *borrowedInfo = [self parseBorrowedData:data];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(borrowedInfo, nil);
                                        });
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(nil, error);
                                        });
                                    }];
    return task;
}

- (NSArray *)parseBorrowedData:(NSData *)data {
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:nil];
    HTMLNode *bodyNode = [parser body];
    NSArray *patFuncEntryNodes = [bodyNode findChildrenOfClass:@"patFuncEntry"];
    NSMutableArray *borrowedBooks = [NSMutableArray array];
    for (HTMLNode *patFuncEntryNode in patFuncEntryNodes) {
        // Book URL
        HTMLNode *aNode = [patFuncEntryNode findChildTag:@"a"];
        // Book name
        HTMLNode *patFuncTitleMainNode = [patFuncEntryNode findChildOfClass:@"patFuncTitleMain"];
        // Book author
        HTMLNode *patFuncAuthorNode = [patFuncEntryNode findChildOfClass:@"patFuncAuthor"];
        // Book date
        HTMLNode *patFuncDateNode = [patFuncEntryNode findChildOfClass:@"patFuncDate"];
        // Add the book into the mutable array
        [borrowedBooks addObject:@{@"URL": [[aNode getAttributeNamed:@"href"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                  @"name": [[patFuncTitleMainNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                @"author": [[patFuncAuthorNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                  @"date": [[patFuncDateNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]}];
    }
    return [borrowedBooks copy];
}

@end
