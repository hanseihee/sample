//
//  ViewController.m
//  fastWeather
//
//  Created by seiheehan on 2015. 11. 12..
//  Copyright © 2015년 greenmonster. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 
@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *min;
@property (weak, nonatomic) IBOutlet UILabel *max;
@property (weak, nonatomic) IBOutlet UILabel *wind;
@property (weak, nonatomic) IBOutlet UILabel *weather;
@property (weak, nonatomic) IBOutlet UILabel *loading;

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (weak, nonatomic) IBOutlet UIImageView *img;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [_img setClipsToBounds:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSigninUpNotification:)
                                                 name:@"receiveSigninUpNotification"
                                               object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)receiveSigninUpNotification:(NSNotification *) notification{
    [self.locationManager startUpdatingLocation];
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        [self setTemp:currentLocation.coordinate.latitude lon:currentLocation.coordinate.longitude];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTemp :(double)let lon:(double)lon{
    [_loading setHidden:YES];
    [self.locationManager stopUpdatingLocation];

    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric&appid=2de143494c0b295cca9337e1e96b00e0", let, lon];
    
    __block NSDictionary *json;
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // handle response
                json = [NSJSONSerialization JSONObjectWithData:data
                                                       options:0
                                                         error:nil];
                NSLog(@"Async JSON: %@", json);
                
                double currentTemp = [[[json objectForKey:@"main"] objectForKey:@"temp"]floatValue];
                double maxTemp = [[[json objectForKey:@"main"] objectForKey:@"temp_max"]floatValue];
                double minTemp = [[[json objectForKey:@"main"] objectForKey:@"temp_min"]floatValue];
                double wind = [[[json objectForKey:@"wind"] objectForKey:@"speed"]floatValue];
                NSString *location = [json objectForKey:@"name"];
                NSString *weather =[NSString stringWithFormat:@"%@(%@)",[[[json objectForKey:@"weather"] objectAtIndex:0]objectForKey:@"main"] ,
                                                                          [[[json objectForKey:@"weather"] objectAtIndex:0]objectForKey:@"description"] ];
                
                NSLog(@"현재 : %f 최고 : %f 최저 : %f 바람 : %f", currentTemp, maxTemp, minTemp, wind);
                
                double feelslike = 13.12 + (0.6215*currentTemp) - 11.37 * pow(wind, 0.16) + 0.3965 *currentTemp*pow(wind, 0.16);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _temp.text = [NSString stringWithFormat:@"체감 %.1fºC", feelslike];
                    _min.text = [NSString stringWithFormat:@"최저 %.1fºC", minTemp];
                    _max.text = [NSString stringWithFormat:@"최고 %.1fºC", maxTemp];
                    _wind.text = [NSString stringWithFormat:@"바람 %.1f km/h", wind];
                    _weather.text = weather;
                });
                
                NSLog(@"%f", feelslike);
                
                // 체감온도 T 기온(섭씨) V 풍속
                // http://cfile10.uf.tistory.com/image/18073B264B024D12029781
            }] resume];
}
@end
