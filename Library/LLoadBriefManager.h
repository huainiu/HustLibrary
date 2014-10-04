//
//  LLoadBriefManager.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface LLoadBriefManager : AFHTTPSessionManager

+ (LLoadBriefManager *)sharedManager;

- (NSURLSessionDataTask *)loadingBriefForTerm:(NSString *)term Completion:(void (^)(NSDictionary *briefInfo, NSError *error, BOOL finished))completion;

@end
