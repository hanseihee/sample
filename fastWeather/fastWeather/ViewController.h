//
//  ViewController.h
//  fastWeather
//
//  Created by seiheehan on 2015. 11. 12..
//  Copyright © 2015년 greenmonster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

