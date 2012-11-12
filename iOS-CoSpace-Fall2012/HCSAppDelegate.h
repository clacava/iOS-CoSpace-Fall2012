//
//  HCSAppDelegate.h
//  iOS-CoSpace-Fall2012
//
//  Created by Carl Brown on 10/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSViewController;

@interface HCSAppDelegate : UIResponder <UIApplicationDelegate>

- (void)saveContext;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) HCSViewController *viewController;

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
