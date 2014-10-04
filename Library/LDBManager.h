//
//  LDBManager.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-16.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LAppDelegate.h"
#import "BooksDetailedInfo.h"
#import "CacheSearchResults.h"
#import "BooksImage.h"
#import "BookLists.h"

@interface LDBManager : NSObject

@property (strong, nonatomic) LAppDelegate *appDelegate;

+ (LDBManager *)sharedManager;

- (void)addObject:(id)object toEntity:(NSString *)entityName;

- (NSMutableArray *)takeOutRecordsInEntity:(NSString *)entityName;

@end
