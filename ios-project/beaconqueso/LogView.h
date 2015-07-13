//
//  LogView.h
//  beaconqueso
//
//  Created by Albert on 07/07/15.
//  Copyright (c) 2015 UserZoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogView : UIView

- (void) logBeaconRequest:(NSString*)beaconId;

- (void) logBeaconResponse:(NSString*)beaconId;

@end
