//
//  MasterViewController.h
//  DrawingAlbum
//
//  Created by Takeshi Bingo on 2013/08/28.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
