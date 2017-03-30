//
//  DetailViewController.m
//  StudentDirectory
//
//  Created by ardMac on 29/03/2017.
//  Copyright © 2017 ardMac. All rights reserved.
//

#import "DetailViewController.h"
#import "TeacherViewController.h"
#import "Teacher+CoreDataClass.h"
#import "CoreDataManager.h"
@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UISwitch *genderSwitch;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (strong,nonatomic)NSArray *students;
@property (assign,nonatomic) NSUInteger randomAge;
@property (strong,nonatomic) NSArray *randomGender;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSArray *randomImageArray;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[CoreDataManager shared] managedObjectContext];
    [self studentDetail];
    [self generateRandomPicture];
    
    
    
    // Do any additional setup after loading the view.
}

-(void)studentDetail {
    self.nameTextField.text = self.currentStudent.name;
    [self.ageTextField setText: [NSString stringWithFormat:@"%i", self.currentStudent.age]];
   // [self generateGender];
    [self.genderLabel setText: self.currentStudent.gender];
    
    
    
}

-(void)generateAge {
    if (self.currentStudent.age !=0){
        self.ageTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.currentStudent.age];
    }else {
        self.randomAge = arc4random_uniform(99);
        self.ageTextField.text =[NSString stringWithFormat:@"%lu",(unsigned long)self.randomAge];
    }
}

//-(void)generateGender {
//    NSUInteger genderNumber = arc4random_uniform(2);
//    if (genderNumber == 0) {
//        //[sender isOn];
//        self.genderLabel.text = @"Female";
//    }else if (genderNumber ==1){
//        self.genderLabel.text = @"Male";
//    }else {
//        self.genderLabel.text = @"Male";
//    }
//}

-(IBAction)genderToggleSwitch:(id)sender {
    
    self.randomGender = @[@"Male", @"Female"];
    if ([self.genderLabel.text isEqualToString: @"Male"]) {
        self.genderLabel.text = [self.randomGender objectAtIndex:1];
    } else if ([self.genderLabel.text isEqualToString: @"Female"]) {
        self.genderLabel.text = [self.randomGender objectAtIndex:0];
    } else {
        return;
    }
}

- (IBAction)updateButtonTapped:(id)sender {
    self.currentStudent.name = self.nameTextField.text;
    self.currentStudent.age = [self.ageTextField.text integerValue];
    self.currentStudent.gender = self.genderLabel.text;
    
    NSError *saveError = NULL;
    [self.context save:&saveError];
    
    if (saveError) {
        //save failed, show alert
        NSLog(@"ErrorFetching | description: %@ | Reason: %@",saveError.localizedDescription,saveError.localizedFailureReason);
        return;
        
    }
}

-(void)generateRandomPicture {
    
    self.randomImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"lasagna"], [UIImage imageNamed:@"spaghetti"], nil];
    
    int x = arc4random_uniform(2);
    
    [self.imageView setImage:self.randomImageArray[x]];
    
}


    
    




@end
