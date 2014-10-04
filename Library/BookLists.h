//
//  BookLists.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-21.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BookLists : NSManagedObject

@property (nonatomic, retain) id bookList;
@property (nonatomic, retain) NSString * name;

@end
