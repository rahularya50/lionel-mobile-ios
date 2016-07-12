//
//  HomeworkExpandedViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 26/3/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "HomeworkExpandedViewController.h"

@interface HomeworkExpandedViewController (){
    
}

@end

@implementation HomeworkExpandedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.classLabel.text = self.className;
	
	self.classLabel.textAlignment = NSTextAlignmentCenter;
	
    self.dueLabel.text = self.dueDate;
    self.teacherLabel.text = self.teacher;
    self.timeLabel.text = self.time;
    self.codeLabel.text = self.classCode;
    self.homeworkLabel.text = self.desc;
    
    [self.homeworkLabel sizeToFit];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	//[self.homeworkLabel sizeToFit];
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
