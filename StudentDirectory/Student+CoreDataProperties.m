//
//  Student+CoreDataProperties.m
//  StudentDirectory
//
//  Created by ardMac on 29/03/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Student"];
}

@dynamic age;
@dynamic gender;
@dynamic name;
@dynamic teacher;

@end
