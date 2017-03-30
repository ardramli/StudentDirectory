//
//  ViewController.m
//  StudentDirectory
//
//  Created by ardMac on 28/03/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

#import "ViewController.h"
#import "Student+CoreDataClass.h"
#import "CoreDataManager.h"
#import "DetailViewController.h"



@interface ViewController () <UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *students;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultController;
//@property (strong,nonatomic) NSManagedObjectContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupDataWithGenderFilter:@"None"];
    self.searchBar.delegate = self;
 //   [self fetchData];
 //   [self.tableView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated {
//    [self fetchData];
    
    //[self.tableView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup
-(void)setupUI{
    [self.buttonAdd addTarget:self action:@selector (buttonAddTapped: ) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
}
-(void)setupDataWithGenderFilter:(NSString*)filter {
    self.students = [NSMutableArray array];
    
    [self.segmentControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    NSFetchRequest *studentFetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Student"];
    NSManagedObjectContext *context = [[CoreDataManager shared]managedObjectContext];
    
    //set predicate
    if ([filter isEqualToString:@"Male"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(teacher.name == %@) AND (gender == %@)", self.currentTeacher.name, @"Male"];
        [studentFetchRequest setPredicate:predicate];
    } else if ([filter isEqualToString:@"Female"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(teacher.name == %@) AND (gender == %@)", self.currentTeacher.name, @"Female"];
        [studentFetchRequest setPredicate:predicate];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacher.name == %@", self.currentTeacher.name];
        [studentFetchRequest setPredicate:predicate];
    }
    
    //sort
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [studentFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.fetchedResultController = [[NSFetchedResultsController alloc]initWithFetchRequest:studentFetchRequest managedObjectContext:context sectionNameKeyPath:NULL cacheName:NULL];
    
    self.fetchedResultController.delegate =self;
    
    NSError *fetchControllerError = NULL;
    [self.fetchedResultController performFetch:&fetchControllerError];
    
    if (fetchControllerError){
        NSLog(@"FetchController Error : %@",fetchControllerError);
    }
    [self.tableView reloadData];
}

//-(void)configureManagedObjectContext:(NSManagedObjectContext *)context{
//    self.context = context;
//}

#pragma mark - Actions
-(void)buttonAddTapped: (UIButton *)sender {
    [self createNewStudent];
//    [self fetchData];
    [self.tableView reloadData];
}

-(void)createNewStudent {
    NSManagedObjectContext *context = [[CoreDataManager shared] managedObjectContext];
    
    //create object
    Student *newStudent = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:context];
    NSArray *randomGenderArray = @[@"Male", @"Female"];
    
    int r = arc4random_uniform(2);
    
    newStudent.teacher = self.currentTeacher;
    
    newStudent.name =self.textField.text;
    newStudent.age = arc4random_uniform(99);
    newStudent.gender = randomGenderArray[r];
    
    
    //save to coredata
    NSError *saveError = NULL;
    [context save:&saveError];
    
    if (saveError) {
        NSLog(@"Error saving to CoreData : %@, because: %@", saveError.localizedDescription, saveError.localizedFailureReason);
        return;
    }else {
        
    }
    
}

-(void)fetchData {
    
    NSFetchRequest *studentFetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Student"];
    NSManagedObjectContext *context = [[CoreDataManager shared]managedObjectContext];
    
    //set predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacher.name == %@",self.currentTeacher.name];
    [studentFetchRequest setPredicate:predicate];
    
    //sort
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [studentFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    
    NSError *fetchError = NULL;
    self.students =[[context executeFetchRequest:studentFetchRequest error:&fetchError]mutableCopy];
    if (fetchError) {
        //fetching failed show alert
        return;
    }
    
    [self.tableView reloadData];
}

-(void)removeStudent:(Student *)student {
    NSManagedObjectContext *context = [[CoreDataManager shared]managedObjectContext];
    [context deleteObject:student];
    
    NSError *saveError = NULL;
    [context save:&saveError];
    if (saveError) {
        return;
    }
//    [self fetchData];
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.students.count;
    return self.fetchedResultController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StudentCell" forIndexPath:indexPath];
    
//    Student *student = self.students[indexPath.row];
    Student *student = [self.fetchedResultController objectAtIndexPath:indexPath];
    cell.textLabel.text = student.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Gender:%@" " " @"Age:%hd",student.gender,student.age];
    
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Student *selectedStudent = [self.fetchedResultController objectAtIndexPath:indexPath];
    
    DetailViewController *controller = (DetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DetailViewController class])];
    
    controller.currentStudent = selectedStudent;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - NSFetchedResultContoller Delegate

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    [self.tableView beginUpdates];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
    }
    [self.tableView endUpdates];
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *deleteAlertController = [UIAlertController alertControllerWithTitle:@"Warning:" message:@"Are you sure you want to delete item?" preferredStyle:UIAlertControllerStyleAlert];
        
        //ADD DELETE ACTION
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            [self removeStudent:[self.fetchedResultController objectAtIndexPath:indexPath]];
            //[self removeTeachers:self.teachers[indexPath.row]
            
        }];
        
        [deleteAlertController addAction:deleteAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [deleteAlertController addAction:cancelAction];
        
        [self presentViewController:deleteAlertController animated:YES completion:nil];
    }
}
#pragma mark - Sorting Gender

-(void)segmentedControlAction:(UISegmentedControl *)segment {
    
    if (segment.selectedSegmentIndex == 0){
        //display all
          [self setupDataWithGenderFilter:@"None"];
    }else if (segment.selectedSegmentIndex ==1){
        //display males only
        [self setupDataWithGenderFilter:@"Male"];
    }else if (segment.selectedSegmentIndex ==2){
        //display female only
        [self setupDataWithGenderFilter:@"Female"];
    }
    
}

#pragma mark - Search Bar
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [self setupDataWithGenderFilter:text];
}


@end
