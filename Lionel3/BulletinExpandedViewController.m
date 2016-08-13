//
//  BulletinExpandedViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 4/4/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "BulletinExpandedViewController.h"

@interface BulletinExpandedViewController ()

@end

@implementation BulletinExpandedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.header;
    self.dateLabel.text = self.date;
    self.authorLabel.text = self.author;
    self.textLabel.text = self.desc;
    self.previewLabel.text = self.preview;
    
	[self.previewLabel sizeToFit];
	self.previewLabelHeightConstraint.constant = [self.previewLabel sizeThatFits:CGSizeMake(self.previewLabel.frame.size.width, CGFLOAT_MAX)].height;

	[self.textLabel sizeToFit];
	//self.textViewHeightConstraint.constant = [self.textLabel sizeThatFits:CGSizeMake(self.textLabel.frame.size.width, CGFLOAT_MAX)].height;
	
	//[self.view setNeedsLayout];
	
    // Do any additional setup after loading the view from its nib.
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
