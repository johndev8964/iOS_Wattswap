//
//  SurveyMapViewController.m
//  Wattswap
//
//  Created by User on 5/15/15.
//  Copyright (c) 2015 Liming. All rights reserved.
//

#import "SurveyMapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import <UIView+Toast.h>

@interface SurveyMapViewController ()

@end

@implementation SurveyMapViewController
{
    CLLocationManager *locationManager;
}

@synthesize mapView, location;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mapView.showsUserLocation = YES;
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = self.mapView.region;
                         region.center = [(CLCircularRegion *)placemark.region center];
                         region.span.longitudeDelta /= 8.0;
                         region.span.latitudeDelta /= 8.0;
                         
                         CLLocationCoordinate2D centerCoord = { region.center.latitude, region.center.longitude };
                         [self.mapView setCenterCoordinate:centerCoord zoomLevel:12 animated:YES];
                         
//                         [self.mapView setRegion:region animated:YES];
                         [self.mapView addAnnotation:placemark];
                     }
                 }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) getDirection:(id)sender {
 //   [locationManager startUpdatingLocation];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self.view makeToast:@"Failed to Get Your Location"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
//        currentLocation.coordinate.longitude;
//        currentLocation.coordinate.latitude;
//        [locationManager stopUpdatingLocation];
    }
}

@end
