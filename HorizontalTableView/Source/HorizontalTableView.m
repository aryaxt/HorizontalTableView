//
//  HorizontalTableView.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView()
@property (nonatomic, strong) NSMutableArray *reusableCellQueue;
@property (nonatomic, strong) NSMutableArray *xLocationOfCells;
@property (nonatomic, assign) BOOL isEditing;
@end

@implementation HorizontalTableView

#define ROW_ANIMATION_DURATION .2

#pragma mark - Initialization -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self initialize];
		[self reloadData];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self initialize];
		[self reloadData];
	}
	
	return self;
}

- (void)initialize
{
	self.alwaysBounceHorizontal = YES;
	self.xLocationOfCells = [NSMutableArray array];
	self.reusableCellQueue = [NSMutableArray array];
}

#pragma mark - Overrides -

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.isEditing)
	{
		[self enqueueInvisibleCells];
		[self populateCellsInVisibleContent];
	}
	
	// Update cell heights if needed
}

#pragma mark - Public Methods -

- (void)reloadData
{
	[self removeVisibleCells];
	
	[self populatexLocationOfCellsAndResizeContentView];
	
	[self populateCellsInVisibleContent];
}

- (void)deleteColumnAtIndex:(int)index withColumnAnimation:(HorizontalTableViewColumnAnimation)animation
{
	if (self.xLocationOfCells.count - 1 != [self numberOfColumns])
		@throw ([NSException exceptionWithName:@"InvalidNumnberOfColumns"
										reason:@"Number of columns in datasource after addition is wrong"
									  userInfo:nil]);
	
	[self populatexLocationOfCellsAndResizeContentView];
	
	HorizontalTableViewCell *deletingRow = [self visibleCellAtIndex:index];
	
	// If deleting row is visible
	if (deletingRow)
	{
		self.isEditing = YES;
		
		[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
			if (cell.index > index && cell != deletingRow)
				cell.index--;
		}];
		
		[UIView animateWithDuration:ROW_ANIMATION_DURATION animations:^{
			
			CGRect rect = deletingRow.frame;
			rect.size.width = 0;
			deletingRow.frame = rect;
			
			[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
				if (cell.index >= index && cell != deletingRow)
					cell.frame = [[self.xLocationOfCells objectAtIndex:cell.index] CGRectValue];
			}];
		} completion:^(BOOL finished) {
			[deletingRow removeFromSuperview];
			self.isEditing = NO;
		}];
	}
}

- (void)insertColumnAtIndex:(int)index withColumnAnimation:(HorizontalTableViewColumnAnimation)animation
{
	if (self.xLocationOfCells.count + 1 != [self numberOfColumns])
		@throw ([NSException exceptionWithName:@"InvalidNumnberOfColumns"
										reason:@"Number of columns in datasource after addition is wrong"
									  userInfo:nil]);
	
	[self populatexLocationOfCellsAndResizeContentView];
	
	CGRect rectForNewCell = [[self.xLocationOfCells objectAtIndex:index] CGRectValue];

	if (CGRectIntersectsRect(self.visibleRect, rectForNewCell))
	{
		self.isEditing = YES;
		
		[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
			if (cell.index >= index)
				cell.index++;
		}];
		
		HorizontalTableViewCell *newCell = [self reusableCellAtIndex:index];
		rectForNewCell.size.width = 0;
		newCell.frame = rectForNewCell;
		[self insertSubview:newCell atIndex:0];
		
		[UIView animateWithDuration:ROW_ANIMATION_DURATION animations:^{
			
			newCell.frame = [[self.xLocationOfCells objectAtIndex:index] CGRectValue];
			
			[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
				if (cell.index > index)
					cell.frame = [[self.xLocationOfCells objectAtIndex:cell.index] CGRectValue];
			}];
		}completion:^(BOOL finished){
			self.isEditing = NO;
			[self enqueueInvisibleCells];
		}];
	}
}

- (void)enumerateThroughVisibleCells:(void (^)(HorizontalTableViewCell *cell))block
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]])
		{
			block((HorizontalTableViewCell *)view);
		}
	}
}

- (HorizontalTableViewCell *)dequeueReusableViewWithIdentifier:(NSString *)identifier
{
	for (int i=0 ; i<self.reusableCellQueue.count ; i++)
	{
		HorizontalTableViewCell *cell = [self.reusableCellQueue objectAtIndex:i];
		
		if ([cell.identifier isEqual:identifier])
		{
			[self.reusableCellQueue removeObject:cell];
			return cell;
		}
	}
	
	return nil;
}

#pragma mark - Private Methods -

- (void)removeVisibleCells
{
	[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
		[cell removeFromSuperview];
	}];
}

- (void)populatexLocationOfCellsAndResizeContentView
{
	[self.xLocationOfCells removeAllObjects];
	CGFloat x = 0;
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		CGFloat width = [self.dataSource horizontalTableView:self widthForColumAtIndex:i];
		[self.xLocationOfCells insertObject:[NSValue valueWithCGRect:CGRectMake(x, 0, width, self.frame.size.height)] atIndex:i];
		
		x+= width;
	}
	
	self.contentSize = CGSizeMake(x, self.frame.size.height);
	
}

- (NSInteger)numberOfColumns
{
	return [self.dataSource numberOfColumnsInHorizontalTableView:self];
}

- (HorizontalTableViewCell *)reusableCellAtIndex:(int)index
{
	HorizontalTableViewCell *cell = [self visibleCellAtIndex:index];
	
	if (cell)
		return cell;
	
	cell = [self.dataSource horizontalTableView:self cellForColumnAtIndex:index];
	cell.index = index;
	return cell;
}

- (HorizontalTableViewCell *)visibleCellAtIndex:(int)index
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]])
		{
			HorizontalTableViewCell *cell = (HorizontalTableViewCell *) view;
			
			if (cell.index == index)
				return cell;
		}
	}
	
	return nil;
}

- (CGFloat)widthAtIndex:(int)index
{
	return [self.dataSource horizontalTableView:self widthForColumAtIndex:index];
}

- (CGRect)visibleRect
{
	return CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height);
}

- (void)populateCellsInVisibleContent
{
	CGRect visibleRect = [self visibleRect];
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		CGRect rectForView = [[self.xLocationOfCells objectAtIndex:i] CGRectValue];
		rectForView.size.height = self.frame.size.height;
		
		if (CGRectIntersectsRect(visibleRect, rectForView))
		{
			HorizontalTableViewCell *cell = [self reusableCellAtIndex:i];
			
			// If cell is already added don't re-add, it causes lag
			if (!cell.superview)
			{
				cell.index = i;
				cell.frame = rectForView;
				[self insertSubview:cell atIndex:0];
			}
		}
		
		// Improve performance get out of this loop
	}
}

- (void)reloadColumnAtIndex:(int)index withColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation
{
	
}

- (HorizontalTableViewCell *)firstVisibleCell
{
	__block HorizontalTableViewCell *firstCell;
	
	[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
		if (!firstCell || cell.index < firstCell.index)
			firstCell = cell;
	}];
	
	return firstCell;
}

- (HorizontalTableViewCell *)lastVisibleCell
{
	__block HorizontalTableViewCell *lastCell;
	
	[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
		if (!lastCell || cell.index > lastCell.index)
			lastCell = cell;
	}];
	
	return lastCell;
}

- (void)enqueueInvisibleCells
{
	[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
		if (!CGRectIntersectsRect(self.visibleRect, cell.frame))
		{
			[cell removeFromSuperview];
			
			// There is no need to store more than 2 cells in the queue one for left side, one for right side
			if (self.reusableCellQueue.count <= 2)
				[self.reusableCellQueue addObject:cell];
		}
	}];
}

@end
