//
//  TodayViewController.m
//  InformationWidget
//
//  Created by Lart Ace Ignacio on 12/5/14.
//  Copyright (c) 2014 Ace Ignacio. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, retain) IBOutlet UILabel *messageLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad
{
    
    [self geoCallBack];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)geoCallBack
{
    NSURL *url = [NSURL URLWithString:@"http://www.telize.com/geoip?callback="];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSLog(@"json : %@", json);
    
    NSString *areaCode = [json valueForKey:@"area_code"];
    NSString *asn = [json valueForKey:@"asn"];
    NSString *city = [json valueForKey:@"city"];
    NSString *continentCode = [json valueForKey:@"continent_code"];
    NSString *country = [json valueForKey:@"country"];
    NSString *countryCode = [json valueForKey:@"country_code3"];
    NSString *dmaCode = [json valueForKey:@"dma_code"];
    NSString *ip = [json valueForKey:@"ip"];
    NSString *isp = [json valueForKey:@"isp"];
    NSString *latitude = [json valueForKey:@"latitude"];
    NSString *longitude = [json valueForKey:@"longitude"];
    NSString *offSet = [json valueForKey:@"offset"];
    NSString *region = [json valueForKey:@"region"];
    NSString *regionCode = [json valueForKey:@"region_code"];
    NSString *timeZone = [json valueForKey:@"timezone"];
    
    self.messageLabel.text = [NSString stringWithFormat:@"Latitude : %@ , Longitude : %@", latitude, longitude];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
