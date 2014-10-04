//
//  LDBManager.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-16.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LDBManager.h"

@implementation LDBManager

- (id)init {
    self = [super init];
    if (self) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

+ (LDBManager *)sharedManager {
    static LDBManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[LDBManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)addObject:(id)object toEntity:(NSString *)entityName {
    // Fetch the entity.
    NSMutableArray *fetchResults = [self takeOutRecordsInEntity:entityName];
    
    if ([entityName isEqualToString:NSStringFromClass([BooksDetailedInfo class])]) {
        
        NSDictionary *dataSource = (NSDictionary *)object;
        BooksDetailedInfo *detailedInfo;
        for (NSInteger i = 0; i < [fetchResults count]; i++) {
            BooksDetailedInfo *tempDetailedInfo = fetchResults[i];
            if ([tempDetailedInfo.bookID isEqualToString:dataSource[@"bookID"]]) {
                detailedInfo = tempDetailedInfo;
                break;
            }
        }
        if (!detailedInfo) {
            detailedInfo = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                         inManagedObjectContext:self.appDelegate.managedObjectContext];
        }
        
        NSArray *details = dataSource[@"detailedInfo"];
        for (NSInteger i = 0; i < [details count]; i++) {
            if ([details[i][0] isEqualToString:@"题名"]) {
                NSString *contents = details[i][1];
                for (NSInteger j = 2; j < [details[i] count]; j++) {
                    contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n%@", details[i][j]]];
                }
                [detailedInfo setName:contents];
            }
            if ([details[i][0] isEqualToString:@"索书号"]) {
                NSString *contents = details[i][1];
                for (NSInteger j = 2; j < [details[i] count]; j++) {
                    contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n%@", details[i][j]]];
                }
                [detailedInfo setBorrowingID:contents];
            }
        }
        [detailedInfo setBookID:dataSource[@"bookID"]];
        [detailedInfo setDetailedInfo:dataSource[@"detailedInfo"]];
        [detailedInfo setCreationDate:[NSDate date]];
        
        NSError *saveError = nil;
        if (![self.appDelegate.managedObjectContext save:&saveError]) {
            NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
        }
        
    } else if ([entityName isEqualToString:NSStringFromClass([CacheSearchResults class])]) {
        
        NSDictionary *dataSource = (NSDictionary *)object;
        CacheSearchResults *cacheSearchResults;
        for (NSInteger i = 0; i < [fetchResults count]; i++) {
            CacheSearchResults *tempCacheSearchResults = fetchResults[i];
            if ([tempCacheSearchResults.searchString isEqualToString:dataSource[@"searchString"]]) {
                cacheSearchResults = tempCacheSearchResults;
                break;
            }
        }
        if (!cacheSearchResults) {
            cacheSearchResults = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                               inManagedObjectContext:self.appDelegate.managedObjectContext];
        }
        
        [cacheSearchResults setSearchString:dataSource[@"searchString"]];
        [cacheSearchResults setSearchResults:dataSource[@"booksBriefInfo"]];
        [cacheSearchResults setCreationDate:[NSDate date]];
        
        NSError *saveError = nil;
        if (![self.appDelegate.managedObjectContext save:&saveError]) {
            NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
        }
        
    } else if ([entityName isEqualToString:NSStringFromClass([BooksImage class])]) {
        
        NSDictionary *dataSource = (NSDictionary *)object;
        BooksImage *booksImage;
        for (NSInteger i = 0; i < [fetchResults count]; i++) {
            BooksImage *tempBooksImage = fetchResults[i];
            if ([tempBooksImage.bookID isEqualToString:dataSource[@"bookID"]]) {
                booksImage = tempBooksImage;
                break;
            }
        }
        if (!booksImage) {
            booksImage = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                       inManagedObjectContext:self.appDelegate.managedObjectContext];
        }
        
        [booksImage setBookID:dataSource[@"bookID"]];
        [booksImage setImageData:dataSource[@"imageData"]];
        [booksImage setCreationDate:[NSDate date]];
        
        NSError *saveError = nil;
        if (![self.appDelegate.managedObjectContext save:&saveError]) {
            NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
        }
    } else if ([entityName isEqualToString:NSStringFromClass([BookLists class])]) {
        
        NSDictionary *dataSource = (NSDictionary *)object;
        NSString *dataSourceName = dataSource[@"name"];
        NSString *bookID = dataSource[@"bookID"];
        if (!bookID) {
            // It means creating a bookList
            BookLists *bookLists = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                 inManagedObjectContext:self.appDelegate.managedObjectContext];
            [bookLists setName:dataSourceName];
//            [bookLists setBookList:[NSMutableArray array]];
            NSError *saveError = nil;
            if (![self.appDelegate.managedObjectContext save:&saveError]) {
                NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
            }
            
        } else {
            // It means add a record to a known bookList
            for (NSInteger i = 0; i < [fetchResults count]; i++) {
                BookLists *tempBookLists = fetchResults[i];
                if ([tempBookLists.name isEqualToString:dataSourceName]) {
                    NSMutableArray *mutArr = tempBookLists.bookList;
                    if (!mutArr || [mutArr count] == 0) {
                        mutArr = [NSMutableArray arrayWithObject:bookID];
                        [tempBookLists setBookList:mutArr];
                        NSError *saveError = nil;
                        if (![self.appDelegate.managedObjectContext save:&saveError]) {
                            NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
                        }
                        break;
                    }
                    BOOL exist = NO;
                    for (NSInteger j = 0; j < [mutArr count]; j++) {
                        if ([mutArr[j] isEqualToString:bookID]) {
                            exist = YES;
                            break;
                        }
                    }
                    if (!exist) {
                        NSMutableArray *newMutArr = [NSMutableArray arrayWithArray:mutArr];
                        [newMutArr addObject:bookID];
                        [tempBookLists setBookList:newMutArr];
                        NSError *saveError = nil;
                        if (![self.appDelegate.managedObjectContext save:&saveError]) {
                            NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
                        }
                    }
                    break;
                }
            }
            for (NSInteger i = 0; i < [fetchResults count]; i++) {
                BookLists *tempBookLists = fetchResults[i];
                if ([tempBookLists.name isEqualToString:@"allInOneBookList"]) {
                    NSMutableArray *mutArr = tempBookLists.bookList;
                    if (!mutArr || [mutArr count] == 0) {
                        mutArr = [NSMutableArray arrayWithObject:bookID];
                        [tempBookLists setBookList:mutArr];
                        NSError *saveError = nil;
                        if (![self.appDelegate.managedObjectContext save:&saveError]) {
                            NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
                        }
                        break;
                    }
                    BOOL exist = NO;
                    for (NSInteger j = 0; j < [mutArr count]; j++) {
                        if ([mutArr[j] isEqualToString:bookID]) {
                            exist = YES;
                            break;
                        }
                    }
                    if (!exist) {
                        NSMutableArray *newMutArr = [NSMutableArray arrayWithArray:mutArr];
                        [newMutArr addObject:bookID];
                        [tempBookLists setBookList:newMutArr];
                        NSError *saveError = nil;
                        if (![self.appDelegate.managedObjectContext save:&saveError]) {
                            NSLog(@"Error(%@) : %@, %@", entityName, saveError, [saveError userInfo]);
                        }
                    }
                    break;
                }
            }
        }
    }
}

- (NSMutableArray *)takeOutRecordsInEntity:(NSString *)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self.appDelegate.managedObjectContext];
    [request setEntity:entity];
    NSError *requestForEntityError = nil;
    NSMutableArray *fetchResults = [[self.appDelegate.managedObjectContext executeFetchRequest:request
                                                                                         error:&requestForEntityError]
                                    mutableCopy];
    if (!fetchResults) {
        NSLog(@"Error(%@) : %@, %@", entityName, requestForEntityError, [requestForEntityError userInfo]);
        return nil;
    }
    return fetchResults;
}

@end
