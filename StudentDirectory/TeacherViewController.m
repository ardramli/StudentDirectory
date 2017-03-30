//
//  TeacherViewController.m
//  StudentDirectory
//
//  Created by ardMac on 29/03/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

#import "TeacherViewController.h"
#import "Teacher+CoreDataClass.h"
#import "CoreDataManager.h"
#import "ViewController.h"
#import "Student+CoreDataClass.h"
//typedef NS_ENUM(NSUInteger, DataState) {
//    DataStateFetched,
//    DataStateInitialized
//};

@interface TeacherViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *teachers;
@property (strong,nonatomic) NSManagedObjectContext *context;

//@property (assign,nonatomic) DataState dataState;

@end

@implementation TeacherViewController

- (void)viewDidLoad {
    
  //  self.dataState = DataStateInitialized;
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
        [self fetchTeachers];
        [self.tableView reloadData];
    
    
}

#pragma mark - Setup 

-(void)setupUI {
    
    [self.buttonAdd addTarget:self action:@selector(buttonAddTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.context = [[CoreDataManager shared ]managedObjectContext];
}

#pragma mark - Actions
-(void)buttonAddTapped:(UIButton *)sender{
    //save to database
    
    Teacher *newTeacher = (Teacher *) [NSEntityDescription insertNewObjectForEntityForName:@"Teacher" inManagedObjectContext:self.context];
    
    newTeacher.name = self.textField.text;
    NSError *saveError = NULL;
    [self.context save:&saveError];
    if (saveError){
        NSLog(@"ErrorSaving %@ | description: %@ | Reason: %@", self.textField.text,saveError.localizedDescription,saveError.localizedFailureReason);
        return;
    }
    [self fetchTeachers];
    [self.tableView reloadData];
}

-(void)fetchTeachers {
    //fetch all the teacher
    
    NSFetchRequest *teacherFetchRequest = [Teacher fetchRequest];
    
    NSError *fetchError = NULL;
    NSArray *fetchObjects = [self.context executeFetchRequest:teacherFetchRequest error:&fetchError];
    
    if (fetchError){
        NSLog(@"ErrorFetching | description: %@ | Reason: %@",fetchError.localizedDescription,fetchError.localizedFailureReason);
        return;
    }
    
   // self.dataState = DataStateFetched;
    self.teachers = fetchObjects;
    
}
-(void)removeTeachers:(Teacher *)teacher {
    NSManagedObjectContext *context = [[CoreDataManager shared]managedObjectContext];
    [context deleteObject:teacher];
    
    NSManagedObjectContext *contextStudents = [[CoreDataManager shared]managedObjectContext];
    for (Student *studentToDelete in teacher.student) {
        [contextStudents deleteObject:studentToDelete];
    }
    
    NSError *saveError = NULL;
    [context save:&saveError];
    if (saveError) {
        return;
    }
    [self fetchTeachers];
    [self.tableView reloadData];
}



#pragma mark - UITableView DataSource 

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.teachers.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teacherCell" forIndexPath:indexPath];
    
    Teacher *teacher = self.teachers[indexPath.row];
    cell.textLabel.text = teacher.name;
    
    NSMutableString *allStudentsName = [@"" mutableCopy];
    for (Student *student in teacher.student ) {
        [allStudentsName appendFormat:@"%@ ",student.name];
    }
    
    
    cell.detailTextLabel.text= allStudentsName;
    
    
    return cell;
}


#pragma mark - UITableView Delegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Teacher *selectedTeacher = self.teachers[indexPath.row];
    
    ViewController *controller = (ViewController*)[self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ViewController class])];
    
    controller.currentTeacher = selectedTeacher;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:@"Warning:" message:@"Are you sure you want to delete item?" preferredStyle:UIAlertControllerStyleAlert];
        
        //ADD DELETE ACTION
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            [self removeTeachers:self.teachers[indexPath.row]];
            //[self removeTeachers:self.teachers[indexPath.row]
            
        }];
        
        [deleteAlertController addAction:deleteAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [deleteAlertController addAction:cancelAction];
        
        [self presentViewController:deleteAlertController animated:YES completion:nil];
    }
}









@end
