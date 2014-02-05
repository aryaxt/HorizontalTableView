//
//  HorizontalTableView.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView()
@property (nonatomic, strong) HorizontalTableViewCell *cellBeingTouched;
@property (nonatomic, strong) NSMutableDictionary *registeredNibsAndClasses;
@property (nonatomic, assign) CGPoint touchStartPoint;
@property (nonatomic, strong) NSMutableArray *reusableCellQueue;
@property (nonatomic, strong) NSMutableArray *rectOfCells;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign) NSUInteger selectedIndex;
@end

@implementation HorizontalTableView

#define ROW_ANIMATION_DURATION .2
#define MAX_ROW_COUNT_IN_QUEUE 10

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
	self.selectedIndex = NSNotFound;
	self.alwaysBounceHorizontal = YES;
	self.rectOfCells = [NSMutableArray array];
	self.reusableCellQueue = [NSMutableArray array];
	self.registeredNibsAndClasses = [NSMutableDictionary dictionary];
	self.allowsSelection = YES;
}

#pragma mark - Overrides -

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// While we are editing content manually we don't want these methods to get called
	if (!self.isEditing)
	{
		[self enqueueInvisibleCells];
		[self populateCellsInVisibleContent];
	}
	
	// Update cell heights if needed
}

#pragma mark - Public Methods -

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
	[self.registeredNibsAndClasses setObject:nib forKey:identifier];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
	[self.registeredNibsAndClasses setObject:cellClass forKey:identifier];
}

- (NSUInteger)indexForSelectedColumn
{
	return self.selectedIndex;
}

- (void)reloadData
{
	self.selectedIndex = NSNotFound;
	
	[self removeVisibleCells];
	
	[self populatexLocationOfCellsAndResizeContentView];
	
	[self populateCellsInVisibleContent];
}

- (void)deleteColumnAtIndex:(NSUInteger)index withColumnAnimation:(HorizontalTableViewColumnAnimation)animation
{
	if (self.rectOfCells.count - 1 != [self numberOfColumns])
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
		
		// Get the last visible cell, and if there is expected to be another after, then dequeue one and animate it in
		HorizontalTableViewCell *lastVisibleCell = [self lastVisibleCell];
		HorizontalTableViewCell *newCellToBeAddedToTheRight = (lastVisibleCell.index+1 < self.numberOfColumns)
			? [self reusableCellAtIndex:lastVisibleCell.index+1]
			: nil;
		
		CGRect rectOfNewCellToBeAddedToTheRight = (newCellToBeAddedToTheRight)
			? [[self.rectOfCells objectAtIndex:newCellToBeAddedToTheRight.index] CGRectValue]
			: CGRectZero;
		
		if (newCellToBeAddedToTheRight)
		{
			rectOfNewCellToBeAddedToTheRight.origin.x = lastVisibleCell.frame.size.width + lastVisibleCell.frame.origin.x;
			newCellToBeAddedToTheRight.frame = rectOfNewCellToBeAddedToTheRight;
			[self insertSubview:newCellToBeAddedToTheRight atIndex:0];
		}
		
		[UIView animateWithDuration:ROW_ANIMATION_DURATION animations:^{
			
			CGRect rect = deletingRow.frame;
			rect.size.width = 0;
			deletingRow.frame = rect;
			
			[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
				if (cell.index >= index && cell != deletingRow)
					cell.frame = [[self.rectOfCells objectAtIndex:cell.index] CGRectValue];
			}];
		} completion:^(BOOL finished) {
			[self removeCellFromViewAndEnqueueIfNeeded:deletingRow];
			self.isEditing = NO;
		}];
	}
}

- (void)insertColumnAtIndex:(NSUInteger)index withColumnAnimation:(HorizontalTableViewColumnAnimation)animation
{
	if (self.rectOfCells.count + 1 != [self numberOfColumns])
		@throw ([NSException exceptionWithName:@"InvalidNumnberOfColumns"
										reason:@"Number of columns in datasource after addition is wrong"
									  userInfo:nil]);
	
	[self populatexLocationOfCellsAndResizeContentView];
	
	CGRect rectForNewCell = [[self.rectOfCells objectAtIndex:index] CGRectValue];

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
			
			newCell.frame = [[self.rectOfCells objectAtIndex:index] CGRectValue];
			
			[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
				if (cell.index > index)
					cell.frame = [[self.rectOfCells objectAtIndex:cell.index] CGRectValue];
			}];
		}completion:^(BOOL finished){
			self.isEditing = NO;
			[self enqueueInvisibleCells];
		}];
	}
}

- (void)reloadColumnAtIndex:(int)index withColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation
{
	HorizontalTableViewCell *cell = [self visibleCellAtIndex:index];
	
	if (cell)
	{
		[self removeCellFromViewAndEnqueueIfNeeded:cell];
		HorizontalTableViewCell *reloadedCell = [self reusableCellAtIndex:index];
		reloadedCell.frame = cell.frame;
		[self insertSubview:reloadedCell atIndex:0];
	}
}

- (void)reloadVisibleCellsWithColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation
{
	[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
		[self reloadColumnAtIndex:cell.index withColumnAnimation:columnAnimation];
	}];
}

- (HorizontalTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
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
	
	id registeredClassOrNib = [self.registeredNibsAndClasses objectForKey:identifier];
	
	if (registeredClassOrNib)
	{
		if ([registeredClassOrNib isKindOfClass:[UINib class]])
		{
			HorizontalTableViewCell *cell = [[registeredClassOrNib instantiateWithOwner:nil options:nil] lastObject];
			
			if (![cell isKindOfClass:[HorizontalTableViewCell class]])
				@throw ([NSException exceptionWithName:@"InvalidSubclassOfCell" reason:@"Invalid cell, Cells must be subclasses of HorizontalTableViewCell" userInfo:nil]);
			
			return cell;
		}
		else
		{
			if (![[registeredClassOrNib class] isSubclassOfClass:[HorizontalTableViewCell class]])
				@throw ([NSException exceptionWithName:@"InvalidSubclassOfCell" reason:@"Invalid cell, Cells must be subclasses of HorizontalTableViewCell" userInfo:nil]);
			
			return [[[registeredClassOrNib class] alloc] initWithFrame:CGRectZero];
		}
	}
	
	return nil;
}

- (void)scrollToColumnAtIndex:(NSUInteger)index animated:(BOOL)animated
{
	CGRect rect = [[self.rectOfCells objectAtIndex:index] CGRectValue];
	[self scrollRectToVisible:rect animated:animated];
}

- (void)selectColumnAtIndex:(NSUInteger)index animated:(BOOL)animated
{
	HorizontalTableViewCell *currentSelectedCell = [self visibleCellAtIndex:self.selectedIndex];
	[currentSelectedCell setSelected:NO animated:NO];
	
	self.selectedIndex = index;
	
	HorizontalTableViewCell *cell = [self visibleCellAtIndex:index];
	[cell setSelected:YES animated:animated];
}

- (void)deselectColumnAtIndex:(NSUInteger)index animated:(BOOL)animated
{
	self.selectedIndex = NSNotFound;
	
	HorizontalTableViewCell *cell = [self visibleCellAtIndex:index];
	[cell setSelected:NO animated:animated];
}

- (NSUInteger)indexForColumnAtPoint:(CGPoint)point
{
	for (int i=0 ; i<self.rectOfCells.count ; i++)
	{
		CGRect rect = [[self.rectOfCells objectAtIndex:i] CGRectValue];
		
		if (CGRectContainsPoint(rect, point))
			return i;
	}
	
	return NSNotFound;
}

#pragma mark - Private Methods -

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

- (void)removeVisibleCells
{
	[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
		[self removeCellFromViewAndEnqueueIfNeeded:cell];
	}];
}

- (void)populatexLocationOfCellsAndResizeContentView
{
	[self.rectOfCells removeAllObjects];
	CGFloat x = 0;
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		CGFloat width = [self.dataSource horizontalTableView:self widthForColumAtIndex:i];
		[self.rectOfCells insertObject:[NSValue valueWithCGRect:CGRectMake(x, 0, width, self.frame.size.height)] atIndex:i];
		
		x+= width;
	}
	
	self.contentSize = CGSizeMake(x, self.frame.size.height);
}

- (NSUInteger)numberOfColumns
{
	return [self.dataSource numberOfColumnsInHorizontalTableView:self];
}

- (HorizontalTableViewCell *)reusableCellAtIndex:(NSUInteger)index
{
	HorizontalTableViewCell *cell = [self visibleCellAtIndex:index];
	
	if (!cell)
		cell = [self.dataSource horizontalTableView:self cellForColumnAtIndex:index];
	
	[cell setSelected:(index == self.selectedIndex) ? YES : NO animated:NO];
	cell.index = index;
	
	return cell;
}

- (HorizontalTableViewCell *)visibleCellAtIndex:(NSUInteger)index
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

- (CGFloat)widthAtIndex:(NSUInteger)index
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
	BOOL startedAddingCells = NO;
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		CGRect rectForView = [[self.rectOfCells objectAtIndex:i] CGRectValue];
		rectForView.size.height = self.frame.size.height;
		
		if (CGRectIntersectsRect(visibleRect, rectForView))
		{
			startedAddingCells = YES;
			HorizontalTableViewCell *cell = [self reusableCellAtIndex:i];
			
			// If cell is already added don't re-add, it causes lag
			if (!cell.superview)
			{
				cell.index = i;
				cell.frame = rectForView;
				[self insertSubview:cell atIndex:0];
			}
		}
		else
		{
			if (startedAddingCells)
				break;
		}
	}
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

- (HorizontalTableViewCell *)visibleCellAtPoint:(CGPoint)point
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]] && CGRectContainsPoint(view.frame, point))
			return (HorizontalTableViewCell *)view;
	}
				
	return nil;
}

- (void)enqueueInvisibleCells
{
	[self enumerateThroughVisibleCells:^(HorizontalTableViewCell *cell) {
		if (!CGRectIntersectsRect(self.visibleRect, cell.frame))
			[self removeCellFromViewAndEnqueueIfNeeded:cell];
	}];
}

- (void)removeCellFromViewAndEnqueueIfNeeded:(HorizontalTableViewCell *)cell
{
	[cell removeFromSuperview];
	
	if (self.reusableCellQueue.count < MAX_ROW_COUNT_IN_QUEUE)
		[self.reusableCellQueue addObject:cell];
}

#pragma mark - Gesture Detection -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.allowsSelection)
		return;
	
	UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	self.touchStartPoint = touchPoint;
	
	self.cellBeingTouched = [self visibleCellAtPoint:touchPoint];
	[self.cellBeingTouched setHighLighted:YES animated:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.allowsSelection)
		return;
	
	UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	HorizontalTableViewCell *cell = [self visibleCellAtPoint:touchPoint];
	
	if (self.cellBeingTouched != cell || !CGPointEqualToPoint(touchPoint, self.touchStartPoint))
	{
		[self.cellBeingTouched setHighLighted:NO animated:NO];
		self.cellBeingTouched = nil;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.allowsSelection)
		return;
	
	UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	HorizontalTableViewCell *cell = [self visibleCellAtPoint:touchPoint];
	
	if (self.cellBeingTouched == cell)
	{
		[self selectColumnAtIndex:cell.index animated:NO];
	
		if (self.selectedIndex != cell.index)
			[self.delegate horizontalTableView:self didSelectColumnAtIndex:cell.index];
		
		self.selectedIndex = cell.index;
		
		self.cellBeingTouched = NO;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.cellBeingTouched setHighLighted:NO animated:NO];
}

@end
