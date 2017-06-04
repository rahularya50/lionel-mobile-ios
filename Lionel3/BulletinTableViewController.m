//
//  BulletinTableViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 28/3/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "BulletinTableViewController.h"
#import "BulletinViewCell.h"
#import "BulletinExpandedViewController.h"
#import "TFHpple.h"
#import "LoginViewController.h"
#import "Sync.h"
#import "KeychainWrapper.h"

@interface BulletinTableViewController (){
    NSMutableArray *titles;
    NSMutableArray *authors;
    NSMutableArray *dates;
    NSMutableArray *previews;
    NSMutableArray *texts;
    int item;
}
@end

@implementation BulletinTableViewController

- (void)viewDidLoad {
    item = 0;
    
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.leftBarButtonItem = logOut;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self parseBulletin];
    [super viewDidLoad];
    
    [self.tableView reloadData];
}

-(IBAction)logOut:(id)sender{
	UIAlertController* alert = [UIAlertController
								alertControllerWithTitle:@"Are you sure you want to log out?"
								message:@"Your saved credentials will be erased."
								preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* defaultAction = [UIAlertAction
									actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * action) {	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
			 [keychainItem resetKeychainItem];
			 
			 LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
			 [self presentViewController:lvc animated:YES completion:nil];}];
	
	UIAlertAction* cancelAction = [UIAlertAction
								   actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction * action) {}];
	
	[alert addAction:defaultAction];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) parseBulletin{
    NSLog(@"Parsing bulletin.");
    titles = [[NSMutableArray alloc] init];
    dates = [[NSMutableArray alloc] init];
    texts = [[NSMutableArray alloc] init];
    authors = [[NSMutableArray alloc] init];
    previews = [[NSMutableArray alloc] init];
    
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"bulletin.txt"];
    
    NSLog(@"%@", filepath);
    
    NSString *bulletinString = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    NSData *bulletinData = [bulletinString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",bulletinString);
    //Parsing bulletin
    
    TFHpple *bulletin = [[TFHpple alloc] initWithHTMLData:bulletinData];
    NSArray *span9Titles = [bulletin searchWithXPathQuery:@"//div[@class=' span9']/h4[@class='itemheading']"];
    NSArray *span9Authors = [bulletin searchWithXPathQuery:@"//div[@class=' span9']/div[@class=' itemmeta']/span[@class='itemauthor']"];
    NSArray *span9Previews = [bulletin searchWithXPathQuery:@"//div[@class=' span9']/div[@class=' itemhook']"];
    NSArray *span9Descs = [bulletin searchWithXPathQuery:@"//div[@class=' span9']/div[@class=' itemtext']"];
    NSArray *span9Times = [bulletin searchWithXPathQuery:@"//div[@class=' span9']/div[@class=' itemmeta']/span[@class='itemtimes']"];
    //NSLog(@"%@",span9);
    for(TFHppleElement *itm in span9Titles){
        [titles addObject:[itm content]];
    }
    for(TFHppleElement *itm in span9Authors){
        [authors addObject:[itm content]];
    }
    for(TFHppleElement *itm in span9Previews){
        [previews addObject:[itm content]];
    }
    for(TFHppleElement *itm in span9Times){
        [dates addObject:[itm content]];
    }
    for(TFHppleElement *itm in span9Descs){
        NSMutableString *tempDescription = [[itm raw]mutableCopy];
        
        //tempDescription = [[tempDescription stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"] mutableCopy];
        
        //NSLog(@"Received HTML: %@",tempDescription);
        NSArray *splitString = [[tempDescription componentsSeparatedByString:@"<br/>"]mutableCopy];
        tempDescription = [[splitString componentsJoinedByString:@"\n"]mutableCopy];
        NSArray *ss2 = [tempDescription componentsSeparatedByString:@"<p>"];
        tempDescription = [[ss2 componentsJoinedByString:@"\n\n"]mutableCopy];
        NSArray *ss3 = [tempDescription componentsSeparatedByString:@"</p>"];
        tempDescription = [[ss3 componentsJoinedByString:@""]mutableCopy];
        NSArray *ss4 = [tempDescription componentsSeparatedByString:@"<br>"];
        tempDescription = [[ss4 componentsJoinedByString:@"\n"]mutableCopy];
        //NSLog(@"%@",tempDescription);
        [tempDescription setString:[tempDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        //NSLog(@"Old: %@",tempDescription);
        NSData *tempData = [tempDescription dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *temp = [[TFHpple alloc] initWithHTMLData:tempData];
        [texts addObject:[[[temp searchWithXPathQuery:@"//*"]objectAtIndex:0]content]];
        
    }
    /*
    NSMutableArray *bData = [[NSMutableArray alloc] init];
    [bData addObject:titles];
    [bData addObject:authors];
    [bData addObject:previews];
    [bData addObject:dates];
    [bData addObject:texts];
    for(NSArray *tempArray in bData){
        NSLog(@"%d",tempArray.count);
    }*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //item++;
	
	int index = (int)indexPath.row;
	
	NSLog(@"Creating row %d",item);
    BulletinViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BulletinViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    //NSLog(@"%@",classNames);
    
    //NSLog(@"%@",[texts objectAtIndex:item-1]);
    //cell.textsLabel.numberOfLines = 1;
	
    cell.titleLabel.text = [titles objectAtIndex:index];
    cell.authorLabel.text = [authors objectAtIndex:index];
    cell.datesLabel.text = [dates objectAtIndex:index];
    cell.previewLabel.text = [previews objectAtIndex:index];
    NSString *tempDesc = [[texts objectAtIndex:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [cell.textsLabel setText:tempDesc];
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;

// texts objectAtIndex:item-1]];
    
    //cell.textsLabel.numberOfLines = 0;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
    BulletinExpandedViewController *bevc = [[BulletinExpandedViewController alloc] initWithNibName:@"BulletinExpandedViewController" bundle:nil];
    
    //NSLog(@"Class Name: %@",[classNames objectAtIndex:index]);
    bevc.header = [titles objectAtIndex:indexPath.row];
    bevc.date = [dates objectAtIndex:indexPath.row];
    bevc.author = [authors objectAtIndex:indexPath.row];
    bevc.preview = [previews objectAtIndex:indexPath.row];
	bevc.desc = [[texts objectAtIndex:indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
    //NSLog(@"Pushing %@",hevc.className);

    
    
    [self.navigationController pushViewController:bevc animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}

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

- (IBAction)refresh:(UIRefreshControl *)sender {
	NSLog(@"Reloading");
	
	Sync *syncer = [[Sync alloc] init];
	
	dispatch_queue_t queue = dispatch_queue_create("com.noemptypromises.Lionel3", NULL);
	dispatch_async(queue, ^{
		
        NSString *username;
        NSString *password;
        
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
        
        username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
        password = [[NSString alloc] initWithData:[keychainItem objectForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
		
        @try{
            NSLog(@"%@", username);
            NSLog(@"%@", password);
            if (![syncer login:username andPassword: password])
            {
                [sender endRefreshing];
                return;
            }
        }
		@catch(NSException *e){
			NSLog(@"Wrong pw!");
			NSLog(@"%@",e);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
                                                            message:@"An unexpected error occurred. Please try logging out and reentering your LIONeL credentials. If this error persists, please contact Lilian Luong at 16luongl1@kgv.hk."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
 		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			
			[sender endRefreshing];
			[self parseBulletin];
			[self.tableView reloadData];
		});
	});
}
@end
