//
//  BubbleView.m
//  requetest
//
//  Created by Albert Montané on 7/7/15.
//  Copyright (c) 2015 Albert Montané. All rights reserved.
//

#import "BubbleView.h"

#define INTERVAL 1.5

@implementation BubbleView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textList = @[
                          @"Somos balleneros",
                          @"Llevamos arpones",
                          @"Y como en la luna no hay ballenas",
                          @"Cantamos canciones",
                          ];
        self.current = 0;
        self.textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 60)];
        self.textView.numberOfLines = 0;
        self.textView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textView];
        self.textView.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2) - 30);
        
        self.image = [UIImage imageNamed:@"bubble"];
    }
    return self;
}

- (void) roll {
    self.textView.text = self.textList[self.current];
    self.current++;
    if (self.current == self.textList.count) {
        self.current = 0;
    }
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
