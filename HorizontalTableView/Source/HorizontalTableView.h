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
- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(int)index;
@end

@protocol HorizontalTableViewDataSource <NSObject>
- (NSInteger)numberOfColumnsInHorizontalTableView:(HorizontalTableView *)horizontalTableView;
- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(int)index;
- (HorizontalTableViewCell *)horizontalTableView:(HorizontalTableView *)horizontalTableView cellForColumnAtIndex:(int)index;
@end

@interface HorizontalTableView : UIScrollView

@property (nonatomic, weak) IBOutlet id <HorizontalTableViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id <HorizontalTableViewDataSource> dataSource;

- (HorizontalTableViewCell *)dequeueReusableViewWithIdentifier:(NSString *)identifier;
- (void)deleteColumnAtIndex:(int)index withColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation;
- (void)insertColumnAtIndex:(int)index withColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation;
- (void)reloadVisibleCellsWithColumnAnimation:(HorizontalTableViewColumnAnimation)columnAnimation;
- (void)scrollToRowAtIndex:(int)index animated:(BOOL)animated;
- (void)selectRowAtIndex:(int)index animated:(BOOL)animated;
- (void)reloadData;

@end
