//
//  LoitumaView.m
//  requetest
//
//  Created by Albert Montané on 7/7/15.
//  Copyright (c) 2015 Albert Montané. All rights reserved.
//

#import "LoitumaView.h"

#define FRAME1 @"frame_000.gif"
#define FRAME2 @"frame_001.gif"
#define FRAME3 @"frame_002.gif"
#define FRAME4 @"frame_003.gif"

#define INTERVAL 0.1

@implementation LoitumaView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.img1 = [UIImage imageNamed:FRAME1];
        self.img2 = [UIImage imageNamed:FRAME2];
        self.img3 = [UIImage imageNamed:FRAME3];
        self.img4 = [UIImage imageNamed:FRAME4];
    }
    return self;
}

- (void) roll {
    if (self.current == 0) {
        self.image = self.img2;
    } else if (self.current == 1) {
        self.image = self.img3;
    } else if (self.current == 2) {
        self.image = self.img4;
    } else {
        self.image = self.img1;
        self.current = -1;
    }
    self.current++;
    [self startRolling];
}

- (void) startRolling {
    [self stopRolling];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:INTERVAL target:self selector:@selector(roll) userInfo:nil repeats:NO];
}

- (void) stopRolling {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
