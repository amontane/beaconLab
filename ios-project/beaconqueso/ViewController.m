//
//  ViewController.m
//  beaconqueso
//
//  Created by Albert on 03/07/15.
//  Copyright (c) 2015 UserZoom. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LogView.h"
#import "LoitumaView.h"
#import "BubbleView.h"

#define POST_URL @"http://192.168.1.110:8006/post.cgi"
#define GET_URL @"http://192.168.1.110:8006/get.cgi"
#define WEB_URL @"http://192.168.1.110:8005/main.html"

#define LOG_WIDTH 270
#define LOG_HEIGHT 400

#define BUT_WIDTH 50
#define BUT_HEIGHT 50

#define MODE_SCAN 1
#define MODE_SCAN_SEND 2
#define MODE_RECON 3
#define MODE_WB 4

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLBeaconRegion* coffeeRegion;
@property (strong, nonatomic) NSMutableDictionary* mutableDict;
@property (strong, nonatomic) NSOperationQueue* operationQueue;

// Views
@property (strong, nonatomic) UIButton* passPop;
@property (strong, nonatomic) LogView* logView;
@property (strong, nonatomic) UIWebView* webView;
@property (strong, nonatomic) LoitumaView* loitumaView;
@property (strong, nonatomic) BubbleView* bubbleView;

// HTTP dataz
@property (strong, nonatomic) NSMutableDictionary* faceDict;
@property (strong, nonatomic) NSMutableDictionary* urlDict;

// State
@property (assign, nonatomic) int mode;
@property (assign, nonatomic) BOOL bubbleRolling;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mode = 0;
    self.bubbleRolling = NO;
    // Do any additional setup after loading the view, typically from a nib.
    [self initCrapBeacon];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layThisCrapOut];
    if (self.mode == 0) {
        self.mode = MODE_SCAN;
        [self changeMode];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initCrapBeacon {
    self.faceDict = [[NSMutableDictionary alloc] init];
    
    self.mutableDict = [[NSMutableDictionary alloc] init];
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:@"c0ffee12-3456-7890-c0ff-ee1234567890"];
    self.coffeeRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"iBKS"];
    
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization]; // ios 8 only, crashes on 7!
    [self.locationManager startMonitoringForRegion:self.coffeeRegion];
    
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    BOOL shouldBubbleRoll = NO;
    for (CLBeacon* beacon in beacons) {
        int major = [beacon.major intValue];
        int minor = [beacon.minor intValue];
        NSString* beaconId = [NSString stringWithFormat:@"%i-%i", major, minor];
        float distance = beacon.accuracy;
        if (distance > 0) {
            if ([self shouldSendDataToCGI]) {
                NSURLRequest* urlReq = [self.mutableDict objectForKey:beaconId];
                if (!urlReq) {
                    NSString* url = [NSString stringWithFormat:@"%@?id=%@&dist=%.3f",
                                     POST_URL,
                                     beaconId,
                                     distance];
                    urlReq = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
                    [self.mutableDict setObject:urlReq forKey:beaconId];
                    NSLog(@"%@ starting with dist %.3f...", beaconId, distance);
                    [self.logView logBeaconRequest:beaconId];
                    [NSURLConnection sendAsynchronousRequest:urlReq
                                                       queue:self.operationQueue
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                               NSLog(@"%@ ok!", beaconId);
                                               [self.logView logBeaconResponse:beaconId];
                                               [self.mutableDict removeObjectForKey:beaconId];
                                               
                                           }];
                }
            }
            if ([self shouldListenForBubbles]) {
                if (distance < 0.12) {
                    shouldBubbleRoll = YES;
                }
            }
            
            if ([self shouldRecognizeFaces] && self.urlDict) {
                UIImageView* imgV = [self.faceDict objectForKey:beaconId];
                if (!imgV) {
                    NSURL *imageURL = [NSURL URLWithString:[self.urlDict objectForKey:beaconId]];
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    UIImage *image = [UIImage imageWithData:imageData];
                    imgV = [[UIImageView alloc] initWithImage:image];
                    imgV.frame = CGRectMake(0, 0, 150, 150);
                    [self.faceDict setObject:imgV forKey:beaconId];
                    [self.view addSubview:imgV];
                }
                
                if (distance < 0.5) {
                    imgV.alpha = 1 - (distance / 0.5);
                } else {
                    imgV.alpha = 0;
                }
            }
        }
    }
    if (!shouldBubbleRoll && self.bubbleRolling) {
        self.bubbleRolling = NO;
        [self stopBubbleRoll];
    } else if (shouldBubbleRoll && !self.bubbleRolling) {
        self.bubbleRolling = YES;
        [self doBubbleRoll];
    }
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.coffeeRegion];
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    
}

- (void) locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
}

#pragma mark layout

- (void) layThisCrapOut {
    if (!self.loitumaView) {
        self.loitumaView = [[LoitumaView alloc] initWithFrame:self.view.bounds];
        self.loitumaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.loitumaView];
        [self.loitumaView startRolling];
    }
    
    if (!self.bubbleView) {
        self.bubbleView = [[BubbleView alloc] initWithFrame:CGRectMake(self.view.frame.size.height * 0.65, self.view.frame.size.width * 0.15, 225,225)];
    }
    
    if (!self.webView) {
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:WEB_URL]]];
        self.webView.hidden = YES;
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.webView];
    }
    
    if (!self.logView) {
        self.logView = [[LogView alloc] initWithFrame:CGRectMake(0, 0, LOG_WIDTH, LOG_HEIGHT)];
        self.logView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        self.logView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.view addSubview:self.logView];
    }
    
    if (!self.passPop) {
        self.passPop = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUT_WIDTH, BUT_HEIGHT)];
        [self.passPop addTarget:self action:@selector(popPopPop:) forControlEvents:UIControlEventTouchUpInside];
        self.passPop.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        [self.passPop setTitleColor:[UIColor colorWithWhite:0 alpha:1] forState:UIControlStateNormal];
        [self.passPop setTitle:@"Eh!" forState:UIControlStateNormal];
        self.passPop.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:self.passPop];
    }
    
    self.logView.frame = CGRectMake(self.view.frame.size.width - LOG_WIDTH, self.view.frame.size.height - LOG_HEIGHT, LOG_WIDTH, LOG_HEIGHT);
    self.passPop.frame = CGRectMake(0, self.view.frame.size.height - BUT_HEIGHT, BUT_WIDTH, BUT_HEIGHT);
    self.webView.frame = self.view.bounds;
}

#pragma mark - UIAlertView

- (void) popPopPop:(NSObject*)sender {
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"QUE COÑO PASA?!" message:nil delegate:self cancelButtonTitle:@":S" otherButtonTitles:nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *emailTextField = [alertView textFieldAtIndex:0];
    NSString* fieldValue = [emailTextField.text lowercaseString];
    if ([fieldValue isEqualToString:@"ojete"]) {
        self.mode = MODE_SCAN;
        [self changeMode];
    } else if ([fieldValue isEqualToString:@"cucumber"]) {
        self.mode = MODE_SCAN_SEND;
        [self changeMode];
    } else if ([fieldValue isEqualToString:@"marhuenda"]) {
        self.mode = MODE_RECON;
        [self changeMode];
    } else if ([fieldValue isEqualToString:@"macaulay"]) {
        self.mode = MODE_WB;
        [self changeMode];
    }
}

#pragma mark - GET data

- (void) getBeaconData {
    if (self.urlDict) {
        return;
    }
    self.urlDict = [[NSMutableDictionary alloc] init];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GET_URL]];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               id jsonobject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                               if (jsonobject) {
                                   NSArray* arr = [jsonobject objectForKey:@"beacons"];
                                   for (NSDictionary* group in arr) {
                                       NSString* ident = [group objectForKey:@"id"];
                                       NSString* url = [group objectForKey:@"url"];
                                       if (ident && url) {
                                           [self.urlDict setObject:url forKey:ident];
                                       }
                                   }
                               }
                           }];
}

#pragma mark - mode logic

- (BOOL) shouldSendDataToCGI {
    return self.mode != MODE_SCAN;
}

- (BOOL) shouldListenForBubbles {
    return self.mode == MODE_SCAN || self.mode == MODE_SCAN_SEND;
}

- (BOOL) shouldRecognizeFaces {
    return self.mode == MODE_RECON;
}

- (void) changeMode {
    if (self.mode == MODE_SCAN) {
        self.webView.hidden = YES;
        self.logView.hidden = YES;
        self.bubbleView.hidden = NO;
    } else if (self.mode == MODE_SCAN_SEND) {
        self.webView.hidden = YES;
        self.logView.hidden = NO;
        self.bubbleView.hidden = NO;
    } else if (self.mode == MODE_RECON) {
        self.webView.hidden = YES;
        self.logView.hidden = NO;
        self.bubbleView.hidden = YES;
        [self getBeaconData];
    } else if (self.mode == MODE_WB) {
        self.webView.hidden = NO;
        self.logView.hidden = NO;
        self.bubbleView.hidden = YES;
    }
}

- (void) doBubbleRoll {
    [self.view addSubview:self.bubbleView];
    self.bubbleView.hidden = NO;
    [self.bubbleView startRolling];
}

- (void) stopBubbleRoll {
    [self.bubbleView removeFromSuperview];
    [self.bubbleView stopRolling];
}

@end
