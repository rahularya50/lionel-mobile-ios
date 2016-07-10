//
//  TimetableExpandedViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 24/4/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "TimetableExpandedViewController.h"

@interface TimetableExpandedViewController ()

@end

@implementation TimetableExpandedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.teacherLabel.text = self.teacher;
    self.classroomLabel.text = self.classroom;
    self.classCodeLabel.text = self.classCode;
    self.classLabel.text = self.className;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
