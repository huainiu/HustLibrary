//
//  LLoadDetailsManager.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface LLoadDetailsManager : AFHTTPSessionManager

+ (LLoadDetailsManager *)sharedManager;

- (NSURLSessionDataTask *)loadingDetailsForTerm:(NSString *)term Completion:(void (^)(NSDictionary *detailsInfo, NSError *error))completion;

@end
