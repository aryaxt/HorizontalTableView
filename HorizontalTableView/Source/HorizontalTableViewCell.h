//
//  HorizontalTableViewCell.h
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface HorizontalTableViewCell : UIView

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) int index;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setHighLighted:(BOOL)highLighted animated:(BOOL)animate;

@end
