//
//  CacheSearchResults.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-19.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CacheSearchResults : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) id searchResults;
@property (nonatomic, retain) NSString * searchString;

@end
