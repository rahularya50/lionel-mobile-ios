//
//  TimetableViewController2.h
//  Lionel3
//
//  Created by Rahul Arya on 11/7/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimetableViewController2 : UIViewController <UIPageViewControllerDataSource>
    @property (strong, nonatomic) UIPageViewController *pageViewController;
    @property (strong, nonatomic) UINavigationItem *navItem;
@end
