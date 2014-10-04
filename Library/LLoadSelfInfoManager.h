//
//  LLoadSelfInfoManager.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface LLoadSelfInfoManager : AFHTTPSessionManager {
@private
    NSString *_userName;
    NSString *_userCode;
    NSString *_userID;
}

+ (LLoadSelfInfoManager *)sharedManager;

- (NSURLSessionDataTask *)loadBorrowingBooksInfoWithName:(NSString *)name Code:(NSString *)code Completion:(void (^)(NSArray *info, NSError *error, BOOL finished))completion;

- (NSURLSessionDataTask *)loadBorrowedBooksInfoWithCompletion:(void (^)(NSArray *info, NSError *error))completion;

@end
