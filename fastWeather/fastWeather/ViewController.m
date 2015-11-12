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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
// http://api.openweathermap.org/data/2.5/weather?lat=37.5137054&lon=127.054362&units=metric&appid=2de143494c0b295cca9337e1e96b00e0

    NSString *url = @"http://api.openweathermap.org/data/2.5/weather?lat=37.5137054&lon=127.054362&units=metric&appid=2de143494c0b295cca9337e1e96b00e0";

    
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.physics.leidenuniv.nl/json/news.php"]];
    
    

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
                NSLog(@"현재 : %f 최고 : %f 최저 : %f 바람 : %f", currentTemp, maxTemp, minTemp, wind);
                
                double feelslike = 13.12 + (0.6215*currentTemp) - 11.37 * pow(wind, 0.16) + 0.3965 *currentTemp*pow(wind, 0.16);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _temp.text = [NSString stringWithFormat:@"체감 %.1fºC", feelslike];
                    _min.text = [NSString stringWithFormat:@"최저 %.1fºC", minTemp];
                    _max.text = [NSString stringWithFormat:@"최고 %.1fºC", maxTemp];
                    _wind.text = [NSString stringWithFormat:@"바람 %.1f km/h", wind];
                });
                
                NSLog(@"%f", feelslike);
                
                // 체감온도 T 기온(섭씨) V 풍속
                // http://cfile10.uf.tistory.com/image/18073B264B024D12029781

            }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
