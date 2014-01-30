//
//  HorizontalTableView.h
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalTableViewCell.h"

@class HorizontalTableView;
@protocol HorizontalTableViewDelegate <UIScrollViewDelegate>
- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(NSInteger)index;
@end

@protocol HorizontalTableViewDataSource <NSObject>
- (NSInteger)numberOfColumnsInHorizontalTableView:(HorizontalTableView *)horizontalTableView;
- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(NSInteger)index;
- (HorizontalTableViewCell *)horizontalTableView:(HorizontalTableView *)horizontalTableView cellForColumnAtIndex:(NSInteger)index;
@end

@interface HorizontalTableView : UIScrollView

@property (nonatomic, weak) IBOutlet id <HorizontalTableViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id <HorizontalTableViewDataSource> dataSource;

- (HorizontalTableViewCell *)dequeueReusableViewWithIdentifier:(NSString *)identifier;
- (void)beginUpdates;
- (void)endUpdates;
- (void)reloadData;

@end
