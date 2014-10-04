//
//  LLoadDetailsManager.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LLoadDetailsManager.h"
#import "HTMLParser.h"
#import "LDBManager.h"

@implementation LLoadDetailsManager

+ (LLoadDetailsManager *)sharedManager {
    static LLoadDetailsManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://ftp.lib.hust.edu.cn"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //        [config setHTTPAdditionalHeaders:@{}];
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10*1024*1024
                                                          diskCapacity:50*1024*1024
                                                              diskPath:nil];
        [config setURLCache:cache];
        
        _sharedManager = [[LLoadDetailsManager alloc] initWithBaseURL:baseURL
                                               sessionConfiguration:config];
        _sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return _sharedManager;
}

- (NSURLSessionDataTask *)loadingDetailsForTerm:(NSString *)term Completion:(void (^)(NSDictionary *detailsInfo, NSError *error))completion {
    NSMutableArray *fetchResults = [[LDBManager sharedManager] takeOutRecordsInEntity:@"BooksDetailedInfo"];
    for (NSInteger i = 0; i < [fetchResults count]; i++) {
        BooksDetailedInfo *tempBooksDetailedInfo = fetchResults[i];
        if ([tempBooksDetailedInfo.bookID isEqualToString:term]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@{@"detailedInfo" :tempBooksDetailedInfo.detailedInfo,
                                    @"bookID": term}, nil);
            });
        }
    }
    
    NSURLSessionDataTask *task = [self GET:[NSString stringWithFormat:@"/record=%@*chx", term]
                                parameters:nil
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSDictionary *detailsInfo = [self parseData:responseObject forTerm:term];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(detailsInfo, nil);
                                       });
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(nil, error);
                                       });
                                   }];
    return task;
}

- (NSDictionary *)parseData:(NSData *)data forTerm:(NSString *)term {
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:nil];
    HTMLNode *bodyNode = [parser body];
    NSArray *bibDetailNodes = [bodyNode findChildrenOfClass:@"bibDetail"];
    NSMutableArray *detailsMutArr = [NSMutableArray array];
    for (HTMLNode *bibDetailNode in bibDetailNodes) {
        NSMutableArray *tdNodes = [NSMutableArray arrayWithArray:[bibDetailNode findChildTags:@"td"]];
        [tdNodes removeObjectAtIndex:0];
        for (HTMLNode *tdNode in tdNodes) {
            NSMutableString *rawContents = [NSMutableString stringWithString:[tdNode rawContents]];
            NSRange lineFeedRange = [rawContents rangeOfString:@"\n"];
            while (lineFeedRange.location != NSNotFound) {
                [rawContents deleteCharactersInRange:lineFeedRange];
                lineFeedRange = [rawContents rangeOfString:@"\n"];
            }
            NSRegularExpression *deleteTagRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"<[ A-Za-z=\"0-9%!-/~*?.+,]*>" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
            NSRange tagRange = [deleteTagRegularExpression rangeOfFirstMatchInString:rawContents options:NSMatchingReportCompletion range:NSMakeRange(0, rawContents.length)];
            while (tagRange.location != NSNotFound) {
                [rawContents deleteCharactersInRange:tagRange];
                tagRange = [deleteTagRegularExpression rangeOfFirstMatchInString:rawContents options:NSMatchingReportCompletion range:NSMakeRange(0, rawContents.length)];
            }
            if ([[tdNode getAttributeNamed:@"class"] isEqual:@"bibInfoLabel"]) {
                NSMutableArray *detailMutArr = [NSMutableArray array];
                [detailMutArr addObject:rawContents];
                [detailsMutArr addObject:detailMutArr];
            } else if ([[tdNode getAttributeNamed:@"class"] isEqual:@"bibInfoData"]) {
                NSMutableArray *detailMutArr = [detailsMutArr lastObject];
                if ([detailMutArr[0] isEqualToString:@"题名"]) {
                    NSRange cnEqualRange = [rawContents rangeOfString:@"＝" options:NSBackwardsSearch];
                    if (cnEqualRange.location != NSNotFound) {
                        [rawContents deleteCharactersInRange:NSMakeRange(cnEqualRange.location, rawContents.length-cnEqualRange.location)];
                    }
                    NSRange enEqualRange = [rawContents rangeOfString:@"=" options:NSBackwardsSearch];
                    if (enEqualRange.location != NSNotFound) {
                        [rawContents deleteCharactersInRange:NSMakeRange(enEqualRange.location, rawContents.length-enEqualRange.location)];
                    }
                    NSRange slashRange = [rawContents rangeOfString:@"/" options:NSBackwardsSearch];
                    if (slashRange.location != NSNotFound) {
                        [rawContents deleteCharactersInRange:NSMakeRange(slashRange.location, rawContents.length-slashRange.location)];
                    }
                }
                [detailMutArr addObject:[rawContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
        }
    }
    
    NSDictionary *collectionDic = nil;
    NSMutableArray *collectionInfoMutArr = [NSMutableArray array];
    NSArray *bibOrderEntryNodes = [bodyNode findChildrenOfClass:@"bibOrderEntry"];
    if ([bibOrderEntryNodes count] != 0) {
        NSNumber *collectionType = [NSNumber numberWithInteger:0];
        for (HTMLNode *bibOrderEntryNode in bibOrderEntryNodes) {
            NSArray *tdNodes = [bibOrderEntryNode findChildTags:@"td"];
            for (HTMLNode *tdNode in tdNodes) {
                NSMutableString *collectionInfo = [NSMutableString stringWithString:[tdNode contents]];
                NSRange lineFeedRange = [collectionInfo rangeOfString:@"\n"];
                while (lineFeedRange.location != NSNotFound) {
                    [collectionInfo deleteCharactersInRange:lineFeedRange];
                    lineFeedRange = [collectionInfo rangeOfString:@"\n"];
                }
                [collectionInfoMutArr addObject:collectionInfo];
            }
        }
        collectionDic = @{@"type": collectionType,
                    @"collection": collectionInfoMutArr};
    } else {
        NSNumber *collectionType = [NSNumber numberWithInteger:1];
        NSArray *bibItemsEntryNodes = [bodyNode findChildrenOfClass:@"bibItemsEntry"];
        for (HTMLNode *bibItemsEntryNode in bibItemsEntryNodes) {
            NSMutableArray *partCollectionInfoMutArr = [NSMutableArray array];
            NSArray *tdNodes = [bibItemsEntryNode findChildTags:@"td"];
            for (HTMLNode *tdNode in tdNodes) {
                NSMutableString *collectionInfo = [NSMutableString stringWithString:[tdNode rawContents]];
                NSRange lineFeedRange = [collectionInfo rangeOfString:@"\n"];
                while (lineFeedRange.location != NSNotFound) {
                    [collectionInfo deleteCharactersInRange:lineFeedRange];
                    lineFeedRange = [collectionInfo rangeOfString:@"\n"];
                }
                NSRegularExpression *deleteTagsRegEx = [[NSRegularExpression alloc] initWithPattern:@"<[ A-Za-z=\"0-9%!-/~*?.+,]*>" options:NSRegularExpressionCaseInsensitive error:nil];
                NSRange tagRange = [deleteTagsRegEx rangeOfFirstMatchInString:collectionInfo options:NSMatchingReportCompletion range:NSMakeRange(0, collectionInfo.length)];
                while (tagRange.location != NSNotFound) {
                    [collectionInfo deleteCharactersInRange:tagRange];
                    tagRange = [deleteTagsRegEx rangeOfFirstMatchInString:collectionInfo options:NSMatchingReportCompletion range:NSMakeRange(0, collectionInfo.length)];
                }
                [partCollectionInfoMutArr addObject:collectionInfo];
            }
            [collectionInfoMutArr addObject:partCollectionInfoMutArr];
        }
        collectionDic = @{@"type": collectionType,
                    @"collection": collectionInfoMutArr};
    }
    
    NSDictionary *detailsInfo = @{@"bookID": term,
                                  @"detailedInfo":detailsMutArr,
                                  @"collectionInfo":collectionDic};
    [[LDBManager sharedManager] addObject:detailsInfo toEntity:@"BooksDetailedInfo"];
    return detailsInfo;
}

@end
