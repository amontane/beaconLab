//
//  BubbleView.h
//  requetest
//
//  Created by Albert Montané on 7/7/15.
//  Copyright (c) 2015 Albert Montané. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BubbleView : UIImageView

@property (strong, nonatomic) NSArray* textList;
@property (strong, nonatomic) UILabel* textView;
@property (assign, nonatomic) int current;
@property (strong, nonatomic) NSTimer* timer;

- (void) startRolling;
- (void) stopRolling;

@end
