//
//  LoitumaView.h
//  requetest
//
//  Created by Albert Montané on 7/7/15.
//  Copyright (c) 2015 Albert Montané. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoitumaView : UIImageView

@property (strong, nonatomic) UIImage* img1;
@property (strong, nonatomic) UIImage* img2;
@property (strong, nonatomic) UIImage* img3;
@property (strong, nonatomic) UIImage* img4;
@property (assign, nonatomic) int current;
@property (strong, nonatomic) NSTimer* timer;

- (void) startRolling;
- (void) stopRolling;

@end
