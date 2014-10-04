//
//  LLoadImagesManager.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-14.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface LLoadImagesManager : AFHTTPSessionManager

+ (LLoadImagesManager *)sharedManager;

- (NSURLSessionDataTask *)loadingImagesForTerm:(NSString *)term Completion:(void (^)(UIImage *image, NSError *error))completion;

@end
