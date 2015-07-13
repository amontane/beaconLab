//
//  LogView.m
//  beaconqueso
//
//  Created by Albert on 07/07/15.
//  Copyright (c) 2015 UserZoom. All rights reserved.
//

#import "LogView.h"

#define LABEL_HEIGHT 30.0

@interface LogView()

@property (strong, nonatomic) NSMutableDictionary* lastEntries;
@property (strong, nonatomic) NSMutableArray* entries;

@end

@implementation LogView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lastEntries = [[NSMutableDictionary alloc] init];
        self.entries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) logBeaconRequest:(NSString*)beaconId {
    UILabel* lastEntry = [self.lastEntries objectForKey:beaconId];
    if (!lastEntry) {
        lastEntry = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - LABEL_HEIGHT, self.frame.size.width, LABEL_HEIGHT)];
        lastEntry.backgroundColor = [UIColor clearColor];
        lastEntry.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        lastEntry.text = [NSString stringWithFormat:@"%@ Sent!", [self translateBeaconId:beaconId ]];
        
        [self reorderViews];
        
        [self.entries addObject:lastEntry];
        [self.lastEntries setObject:lastEntry forKey:beaconId];
        [self addSubview:lastEntry];
    }
}

- (void) logBeaconResponse:(NSString*)beaconId {
    UILabel* lastEntry = [self.lastEntries objectForKey:beaconId];
    if (lastEntry) {
        lastEntry.text  = [lastEntry.text stringByAppendingString:@" Recvd!"];
        lastEntry.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        [self.lastEntries removeObjectForKey:beaconId];
    }
}

- (NSString*) translateBeaconId:(NSString*)beaconId {
    if ([beaconId isEqualToString:@"4097-4182"]) {
        return @"CAYETANA";
    }
    if ([beaconId isEqualToString:@"51914-61642"]) {
        return @"MARGARET";
    }
    if ([beaconId isEqualToString:@"2100-17714"]) {
        return @"WHITNEY";
    }
    return beaconId;
}

- (void) reorderViews {
    UILabel* kickOutView = nil;
    for (UILabel* label in self.entries) {
        if (label.frame.origin.y > 30) {
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y - 30, label.frame.size.width, label.frame.size.height);
            
        } else {
            [label removeFromSuperview];
            kickOutView = label;
        }
    }
    [self.entries removeObject:kickOutView];
}

@end
