//
//  BooksDetailedInfo.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-19.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BooksDetailedInfo : NSManagedObject

@property (nonatomic, retain) NSString * bookID;
@property (nonatomic, retain) NSString * borrowingID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id detailedInfo;
@property (nonatomic, retain) NSDate * creationDate;

@end
