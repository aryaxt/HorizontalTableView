//
//  ViewController.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.arrayOfStrings = [NSMutableArray array];
	
	self.horizontalTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.horizontalTableView.layer.borderWidth = .6;
	
	self.horizontalTableView.delegate = self;
	self.horizontalTableView.dataSource = self;
	[self.horizontalTableView reloadData];
	
	[self printCellStats];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self printCellStats];
}

#pragma mark - HorizontalTableViewDelegate & HorizontalTableViewDataSource -

- (NSUInteger)numberOfColumnsInHorizontalTableView:(HorizontalTableView *)horizontalTableView
{
	return self.arrayOfStrings.count;
}

- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(NSUInteger)index
{
	return 80;
	return (index%2 == 0) ? 80 : 120;
}

- (HorizontalTableViewCell *)horizontalTableView:(HorizontalTableView *)horizontalTableView cellForColumnAtIndex:(NSUInteger)index
{
	MyCell *cell = (MyCell *) [self.horizontalTableView dequeueReusableViewWithIdentifier:@"MyCell"];
	
	if (!cell)
	{
		cell = [[MyCell alloc] init];
		self.numberOfTimesInitializingCell++;
	}
	else
	{
		self.numberOfTimesDequeueingCells++;
	}
	
	cell.lblTitle.text = [self.arrayOfStrings objectAtIndex:index];
	cell.lblTitle.backgroundColor = (index%2 == 0) ? [UIColor greenColor] : [UIColor redColor];
	
	return cell;
}

- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(NSUInteger)index
{
	NSLog(@"selected: %lu", (unsigned long)index);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self printCellStats];
}

#pragma mark - IBActions -

- (IBAction)addRowAndReloadTable:(id)sender
{
	for (int i=0 ; i<10 ; i++)
	{
		[self.arrayOfStrings insertObject:[NSString stringWithFormat:@"Reload %d", self.insertCounter] atIndex:0];
		self.insertCounter++;
	}
	
	[self.horizontalTableView reloadData];
	[self printCellStats];
}

- (IBAction)insertRowInTable:(id)sender
{
	[self.arrayOfStrings insertObject:[NSString stringWithFormat:@"Insert %d", self.insertCounter] atIndex:0];
	[self.horizontalTableView insertColumnAtIndex:0 withColumnAnimation:HorizontalTableViewColumnAnimationNone];
	[self printCellStats];
	self.insertCounter++;
}

- (IBAction)deleteRowInTable:(id)sender
{
	if (self.arrayOfStrings.count == 0)
		return;
	
	[self.arrayOfStrings removeObjectAtIndex:0];
	[self.horizontalTableView deleteColumnAtIndex:0 withColumnAnimation:HorizontalTableViewColumnAnimationNone];
	[self printCellStats];
}

- (IBAction)clearDataAndStats:(id)sender
{
	[self.arrayOfStrings removeAllObjects];
	
	[self.horizontalTableView reloadData];
	self.numberOfTimesInitializingCell = 0;
	self.numberOfTimesDequeueingCells = 0;
	self.insertCounter = 0;
	
	[[self.horizontalTableView valueForKey:@"reusableCellQueue"] removeAllObjects];
	[self printCellStats];
}

- (IBAction)reloadVisibleCells:(id)sender
{
	[self.horizontalTableView reloadVisibleCellsWithColumnAnimation:HorizontalTableViewColumnAnimationNone];
}

- (IBAction)scrollToRandomCell:(id)sender
{
	int randomIndex = arc4random() % self.arrayOfStrings.count-1;
	[self.horizontalTableView scrollToRowAtIndex:randomIndex animated:YES];
}

#pragma mark - Private Methods -

- (void)printCellStats
{
	int cellsInViewCount = 0;
	for (UIView *view in self.horizontalTableView.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]])
			cellsInViewCount++;
	}
	
	self.lblCellQueueStats.text = [NSString stringWithFormat:@"Cells in queue: %lu \nCells in view: %d \nNumber of columns: %lu \nNumber of cells initialized: %d \nNumber of cells dequeued: %d",
								   (unsigned long)[[self.horizontalTableView valueForKey:@"reusableCellQueue"] count],
								   cellsInViewCount,
								   (unsigned long)self.arrayOfStrings.count,
								   self.numberOfTimesInitializingCell,
								   self.numberOfTimesDequeueingCells];
}

@end
