//
//  LAppDelegate.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-16.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
