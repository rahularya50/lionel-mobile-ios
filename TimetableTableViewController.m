//
//  TimetableTableViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 18/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import "TimetableTableViewController.h"
#import "TimetableViewCell.h"
#import "TimetableExpandedViewController.h"

@interface TimetableTableViewController (){
    NSInteger item;
}

@end

@implementation TimetableTableViewController
@synthesize table;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    if(table.contentSize.height < table.frame.size.height){
        table.scrollEnabled = NO;
    }else{
        table.scrollEnabled = YES;
    }
    
    NSLog(@"%d", _pageIndex);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self view] setFrame:[[UIScreen mainScreen] bounds]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int item = indexPath.row;
    
    tableView.rowHeight = 100;
    TimetableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimetableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.periodLabel.text = [@"Period " stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)item+1]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.classLabel.text = [[_classes objectAtIndex:item]objectAtIndex:2];
    cell.classLabel.numberOfLines = 0;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = indexPath.row;
    
    TimetableExpandedViewController *tevc = [[TimetableExpandedViewController alloc] initWithNibName:@"TimetableExpandedViewController" bundle:nil];
    
    //NSLog(@"Class Name: %@",[classNames objectAtIndex:index]);
    
    tevc.className = [[_classes objectAtIndex:index]objectAtIndex:2];
    tevc.classroom = [[_classes objectAtIndex:index]objectAtIndex:1];
    tevc.classCode = [[_classes objectAtIndex:index]objectAtIndex:0];
    tevc.teacher = [[_classes objectAtIndex:index]objectAtIndex:3];
    
    [self.navigationController pushViewController:tevc animated:YES];
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",indexPath);
    NSLog(@"%d",item);
    if([[[_classes objectAtIndex:indexPath.row-1]objectAtIndex:2] isEqualToString:@"Liberal and Personal Studies"]){
    //if(true){
        return 120;
    }else{
        return 100;
    }
}*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
