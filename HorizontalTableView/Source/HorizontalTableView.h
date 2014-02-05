//
//  HorizontalTableView.h
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalTableViewCell.h"

typedef enum ColumnAnimation {
	HorizontalTableViewColumnAnimationNone
}HorizontalTableViewColumnAnimation;

@class HorizontalTableView;
@protocol HorizontalTableViewDelegate <UIScrollViewDelegate>
- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(NSUInteger)index;
@end

@protocol HorizontalTableViewDataSource <NSObject>
- (NSUInteger)numberOfColumnsInHorizontalTableView:(HorizontalTableView *)horizontalTableView;
- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(NSUInteger)index;
- (HorizontalTableViewCell *)horizontalTableView:(HorizontalTableView *)horizontalTableView cellForColumnAtIndex:(NSUInteger)index;
@end

@interface HorizontalTableView : UIScrollView

@property (nonatomic, weak) IBOutlet id <HorizontalTableViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id <HorizontalTableViewDataSource> dataSource;

- (HorizontalTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)deleteColumnAtIndex:(NSUInteger)index withColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation;
- (void)insertColumnAtIndex:(NSUInteger)index withColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation;
- (void)reloadVisibleCellsWithColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation;
- (void)scrollToRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)selectRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)deselectRowAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)reloadData;
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (NSUInteger)indexForSelectedRow;
- (NSUInteger)indexForColumnAtPoint:(CGPoint)point;

@end
