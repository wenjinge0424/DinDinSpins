//
//  AppDelegate.m
//  BikerLoops
//
//  Created by developer on 30/01/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate ()<CLLocationManagerDelegate>
{
    CLLocationManager *manager;
    NSTimer *locationtimer;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [GMSServices provideAPIKey:@""];
    [GMSPlacesClient provideAPIKey:@""];
    // Google SignIn
    [GIDSignIn sharedInstance].clientID = @"";
    
    // Parse init
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"56955cc6-ef63-4fc9-b512-e34ee34dbe76";
        configuration.clientKey = @"444076b5-fce3-4925-ab6d-333b8b687b09";
        configuration.server = @"https://parse.brainyapps.com:20004/parse";
    }]];
    [PFUser enableRevocableSessionInBackground];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    PFInstallation *currentInstall = [PFInstallation currentInstallation];
    if (currentInstall) {
        currentInstall.badge = 0;
        [currentInstall saveInBackground];
    }
    //
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // Push Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
    [self CurrentLocationIdentifier];
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                          options:options];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber++;
    [NSNotificationCenter.defaultCenter postNotificationName:PARSE_NOTIFICATION_APP_ACTIVE object:nil];
}

-(void)CurrentLocationIdentifier
{
    manager = [CLLocationManager new];
    manager.delegate = self;
    manager.distanceFilter = kCLDistanceFilterNone;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [manager requestAlwaysAuthorization];
    [manager startUpdatingLocation];
    
    locationtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updatelocation:) userInfo:nil repeats:YES];
}

- (void)updatelocation:(id)sender
{
    static CLLocation *old;
    if ([APP_THEME isEqualToString:APP_THEME_BUSINESS]){
        return;
    }

    CLLocation *current = self.currentLocation;
    PFUser *me = [PFUser currentUser];
    if (me) {
        if (old == nil || [current distanceFromLocation:old] >= 50.0) {
            old = current;
            me[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLocation:current];
            if (self.address.length > 0)
                me[PARSE_USER_ADDRESS] = self.address;
#ifdef DEBUG
            me[PARSE_USER_LOCATION] = [PFGeoPoint geoPointWithLatitude:23.01174456183538 longitude:72.52326541787828]; // QA location
#endif
            [me saveInBackground];
        } else {
            PFGeoPoint *meLocation = me[PARSE_USER_LOCATION];
            old = [[CLLocation alloc] initWithLatitude:meLocation.latitude longitude:meLocation.longitude];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    //#ifdef DEBUG
    //    self.currentLocation = [[CLLocation alloc] initWithLatitude:29.8830527 longitude:-97.941793];
    //#endif
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             self.currentLocationPlacemark = [placemarks objectAtIndex:0];
             NSString *strAdd = nil;
             
             if ([self.currentLocationPlacemark.subThoroughfare length] != 0)
                 strAdd = self.currentLocationPlacemark.subThoroughfare;
             
             if ([self.currentLocationPlacemark.thoroughfare length] != 0)
             {
                 // strAdd -> store value of current location
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark thoroughfare]];
                 else
                 {
                     // strAdd -> store only this value,which is not null
                     strAdd = self.currentLocationPlacemark.thoroughfare;
                 }
             }
             
             if ([self.currentLocationPlacemark.postalCode length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark postalCode]];
                 else
                     strAdd = self.currentLocationPlacemark.postalCode;
             }
             
             if ([self.currentLocationPlacemark.locality length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark locality]];
                 else
                     strAdd = self.currentLocationPlacemark.locality;
             }
             
             if ([self.currentLocationPlacemark.administrativeArea length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark administrativeArea]];
                 else
                     strAdd = self.currentLocationPlacemark.administrativeArea;
             }
             
             if ([self.currentLocationPlacemark.country length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark country]];
                 else
                     strAdd = self.currentLocationPlacemark.country;
             }
             self.address = strAdd;
         }
     }];
}

- (BOOL)handleActionURL:(NSURL *)url {
    //    if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
    //        NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
    //        if (photoObjectId && photoObjectId.length > 0) {
    //            return YES;
    //        }
    //    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
