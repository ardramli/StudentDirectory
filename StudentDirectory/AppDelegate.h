//
//  AppDelegate.h
//  StudentDirectory
//
//  Created by ardMac on 28/03/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

