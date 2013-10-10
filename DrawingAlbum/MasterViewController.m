//
//  MasterViewController.m
//  DrawingAlbum
//
//  Created by Takeshi Bingo on 2013/08/28.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [[self tableView] setRowHeight:57.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    NSInteger fileIdx = [indexPath row];
    NSString *dataFilePath = [_detailViewController makeDataPathWithIndex:fileIdx];
    NSString *title = @"no data";
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath]){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:dataFilePath];
        title = [dic valueForKey:@"title"];
        if ((title == nil)|| ([title length]==0)) {
            title = @"no title";
        }
    }
    [[cell textLabel] setText:title];
    NSString *iconFilePath = [_detailViewController makeIconPathWithIndex:fileIdx];
    UIImage *iconImage = [UIImage imageNamed:@"no_image.png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:iconFilePath]) {
        iconImage = [UIImage imageWithContentsOfFile:iconFilePath];
    }
    [[cell imageView] setImage:iconImage];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger fileIdx = [indexPath row];
    [self.detailViewController setDetailItem:[NSNumber numberWithInteger:fileIdx]];
    //選択したfileIdxをUserDefaultsに保存しておく（再起動時に読み込むため）
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:fileIdx forKey:@"fileIdx"];
    [ud synchronize];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //最後の選択にする
    NSInteger fileIdx = [[NSUserDefaults standardUserDefaults] integerForKey:@"fileIdx"];
    UITableView *tableView = (UITableView *)[self view];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:fileIdx inSection:0];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

@end
