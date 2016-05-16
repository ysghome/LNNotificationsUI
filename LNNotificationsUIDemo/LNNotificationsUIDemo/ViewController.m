//
//  ViewController.m
//  LNNotificationsUIDemo
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "ViewController.h"

@import LNNotificationsUI;

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)queueMoreButtonTapped:(id)sender {
	LNNotification* notification = [LNNotification notificationWithMessage:@"Looks just like the native iOS 8 and iOS 9 banner notifications!"];
	notification.title = @"First Notification";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24];
	notification.soundName = @"demo.aiff";
	notification.defaultAction = [LNNotificationAction actionWithTitle:@"View" handler:^(LNNotificationAction *action) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:notification.title message:@"Notification was tapped!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}];
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
	
	notification = [LNNotification notificationWithMessage:@"You can customize most parts of the notification messages."];
	notification.title = @"Another Notification";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24 * 30];
	notification.soundName = @"demo.aiff";
	notification.defaultAction = nil;
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"456"];
	
	notification = [LNNotification notificationWithMessage:@"You can swipe notifications up to dismiss them."];
	notification.title = @"And Another";
	notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24 * 30];
	notification.soundName = @"demo.aiff";
	notification.defaultAction = [LNNotificationAction actionWithTitle:@"View" handler:^(LNNotificationAction *action) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:notification.title message:@"Notification was tapped!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}];
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"789"];
	
	notification = [LNNotification notificationWithMessage:@"Pretty cool, isn't it?"];
	notification.title = @"Last One";
	notification.soundName = @"demo.aiff";
	notification.defaultAction = nil;
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
    
    [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Notifications Demo App 1" icon:[UIImage imageNamed:@"DemoApp1Icon"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
}

- (IBAction)changeStyleButtonTapped:(id)sender {
	[LNNotificationCenter defaultCenter].notificationsBannerStyle = ![LNNotificationCenter defaultCenter].notificationsBannerStyle;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Notifications Demo App 1" icon:[UIImage imageNamed:@"DemoApp1Icon"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
//	[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"456" name:@"Notifications Demo App 2" icon:[UIImage imageNamed:@"DemoApp2Icon"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
//	[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"789" name:@"Notifications Demo App 3" icon:[UIImage imageNamed:@"DemoApp3Icon"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
	
	LNNotification* notification = [LNNotification notificationWithMessage:@"Welcome to LNNotificationsUI!"];
	notification.title = @"Hello World!";
//	notification.soundName = @"demo.aiff";
	notification.defaultAction = [LNNotificationAction actionWithTitle:@"View" handler:^(LNNotificationAction *action) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:notification.title message:@"Notification was tapped!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}];
	
	[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
}

@end
