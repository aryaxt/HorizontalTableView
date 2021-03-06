//
//  ViewController.h
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <stdlib.h>
#import "HorizontalTableView.h"
#import "MyCell.h"

@interface ViewController : UIViewController <HorizontalTableViewDelegate, HorizontalTableViewDataSource>

@property (nonatomic, strong) IBOutlet HorizontalTableView *horizontalTableView;
@property (nonatomic, strong) IBOutlet UILabel *lblCellQueueStats;
@property (nonatomic, strong) NSMutableArray *arrayOfStrings;
@property (nonatomic, assign) int insertCounter;
@property (nonatomic, assign) int numberOfTimesInitializingCell;
@property (nonatomic, assign) int numberOfTimesDequeueingCells;

- (IBAction)addRowAndReloadTable:(id)sender;
- (IBAction)insertRowInTable:(id)sender;
- (IBAction)deleteRowInTable:(id)sender;
- (IBAction)clearDataAndStats:(id)sender;
- (IBAction)reloadVisibleCells:(id)sender;
- (IBAction)scrollToRandomCell:(id)sender;
- (IBAction)selectRandomCell:(id)sender;
- (IBAction)deselectCell:(id)sender;

@end
