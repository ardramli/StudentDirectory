//
//  DetailViewController.h
//  StudentDirectory
//
//  Created by ardMac on 29/03/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student+CoreDataClass.h"

@interface DetailViewController : UIViewController
@property (nonatomic,strong) Student *currentStudent;
@end
