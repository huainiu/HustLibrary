//
//  LLoadBriefManager.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LLoadBriefManager.h"
#import "HTMLParser.h"
#import "LDBManager.h"

@implementation LLoadBriefManager

+ (LLoadBriefManager *)sharedManager {
    static LLoadBriefManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://ftp.lib.hust.edu.cn"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _sharedManager = [[LLoadBriefManager alloc] initWithBaseURL:baseURL
                                                  sessionConfiguration:config];
        
        _sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return _sharedManager;
}

- (NSURLSessionDataTask *)loadingBriefForTerm:(NSString *)term Completion:(void (^)(NSDictionary *briefInfo, NSError *error, BOOL finished))completion {
    // Fetch all the records
    NSMutableArray *fetchResults = [[LDBManager sharedManager] takeOutRecordsInEntity:@"CacheSearchResults"];
    BOOL exist = NO;
    for (NSInteger i = 0; i < [fetchResults count]; i++) {
        CacheSearchResults *tempCacheSearchResults = fetchResults[i];
        if ([tempCacheSearchResults.searchString isEqualToString:term]) {
            exist = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@{@"booksBriefInfo": tempCacheSearchResults.searchResults,
                             @"searchString": tempCacheSearchResults.searchString}, nil, YES);
            });
            break;
        }
    }

    NSURLSessionDataTask *task = [self GET:term
                                parameters:nil
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSDictionary *booksBriefInfo = [self parseData:responseObject forTerm:term];
                                       if (!exist) {
                                           if ([booksBriefInfo[@"booksBriefInfo"] count] == 0) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(nil, nil, NO);
                                               });
                                           } else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(booksBriefInfo, nil, YES);
                                               });
                                           }
                                       }
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(nil, error, YES);
                                       });
                                   }];
    return task;
}

- (NSDictionary *)parseData:(NSData *)data forTerm:(NSString *)term {
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:nil];
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *booksBriefInfo = [NSMutableArray array];
    NSArray *briefCitRowNodes = [bodyNode findChildrenOfClass:@"briefCitRow"];
    for (HTMLNode *briefCitRowNode in briefCitRowNodes) {
        // ID
        NSString *rawbriefCitRow = [briefCitRowNode rawContents];
        rawbriefCitRow = [rawbriefCitRow substringFromIndex:[rawbriefCitRow rangeOfString:@"save"].location+5];
        NSString *bookID = [rawbriefCitRow substringToIndex:[rawbriefCitRow rangeOfString:@"#"].location];
        // Book name
        HTMLNode *briefcitTitleNode = [briefCitRowNode findChildOfClass:@"briefcitTitle"];
        NSString *title = [[briefcitTitleNode findChildTag:@"a"] contents];
        NSRange cnEqualRange = [title rangeOfString:@"＝" options:NSBackwardsSearch];
        if (cnEqualRange.location != NSNotFound) {
            title = [title substringToIndex:cnEqualRange.location];
        }
        NSRange enEqualRange = [title rangeOfString:@"=" options:NSBackwardsSearch];
        if (enEqualRange.location != NSNotFound) {
            title = [title substringToIndex:enEqualRange.location];
        }
        NSRange slashRange = [title rangeOfString:@"/" options:NSBackwardsSearch];
        if (slashRange.location != NSNotFound) {
            title = [title substringToIndex:slashRange.location];
        }
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // Book details
        NSArray *briefcitDetailNodes = [briefCitRowNode findChildrenOfClass:@"briefcitDetail"];
        NSMutableArray *bookDetailsInfo = [NSMutableArray array];
        for (HTMLNode *briefcitDetailNode in briefcitDetailNodes) {
            [bookDetailsInfo addObject:[[briefcitDetailNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
        // Add the book to the mutable array
        if (!bookID || bookID.length == 0) {
            continue;
        }
        if (!title || title.length == 0) {
            title = @"无书名";
        }
        [booksBriefInfo addObject:@{@"bookID": bookID,
                                    @"name": title,
                                    @"briefInfo": bookDetailsInfo}];
    }
    NSDictionary *briefInfo = @{@"searchString": term,
                                @"booksBriefInfo": [booksBriefInfo copy]};
    if ([booksBriefInfo count] > 0) {
        [[LDBManager sharedManager] addObject:briefInfo toEntity:@"CacheSearchResults"];
    }
    return briefInfo;
}

//- (NSString *)transformToURLString:(NSString *)str {
//    NSString *checkStr = @"检索";
//    NSString *encodedCheckStr = [checkStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *encodedSearchStr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    encodedSearchStr = [encodedSearchStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//    encodedSearchStr = [encodedSearchStr stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
//    NSString *urlStr = [NSString stringWithFormat:@"/search~S0*chx/?searchtype=X&searcharg=%@&sortdropdown=-&SORT=D&extended=0&SUBMIT=%@", encodedSearchStr, encodedCheckStr];
//    return urlStr;
//}

@end
