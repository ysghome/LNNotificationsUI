//
//  LNNotificationCenter.m
//  LNNotificationsUI
//
//  Created by Leo Natan on 9/4/14.
//  Copyright (c) 2014 Leo Natan. All rights reserved.
//

#import "LNNotificationCenter.h"
#import "LNNotification.h"
#import "LNNotificationAppSettings_Private.h"
#import "LNNotificationBannerWindow.h"

#import <AVFoundation/AVFoundation.h>

@interface LNNotification ()

@property (nonatomic, copy) NSString* appIdentifier;

@end

static LNNotificationCenter* __ln_defaultNotificationCenter;

@interface LNNotificationCenter () <AVAudioPlayerDelegate> @end

@implementation LNNotificationCenter
{
	NSMutableDictionary* _applicationMapping;
	LNNotificationBannerWindow* _notificationWindow;
	NSMutableArray* _pendingNotifications;
	
	LNNotificationBannerStyle _bannerStyle;
	BOOL _wantsBannerStyleChange;
	
	BOOL _currentlyAnimating;
	
	AVAudioPlayer* _currentAudioPlayer;
	
	id _orientationHandler;
}

+ (instancetype)defaultCenter
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__ln_defaultNotificationCenter = [LNNotificationCenter new];
	});
	
	return __ln_defaultNotificationCenter;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
		_applicationMapping = [NSMutableDictionary new];
		_pendingNotifications = [NSMutableArray new];
		
		_orientationHandler = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
			
			UIInterfaceOrientation newOrientation = [note.userInfo[UIApplicationStatusBarOrientationUserInfoKey] unsignedIntegerValue];
			
			if([UIDevice currentDevice].orientation == (UIDeviceOrientation)newOrientation)
			{
				return;
			}
		
			//Fix Apple bug of rotations.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(__bridge id)((void*)[note.userInfo[UIApplicationStatusBarOrientationUserInfoKey] unsignedIntegerValue])];
#pragma clang diagnostic pop
		}];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:_orientationHandler];
	_orientationHandler = nil;
}

- (LNNotificationBannerStyle)notificationsBannerStyle
{
	return _bannerStyle;
}

- (void)setNotificationsBannerStyle:(LNNotificationBannerStyle)bannerStyle
{
	_bannerStyle = bannerStyle;
	
	//Signal future handling of banner style change.
	_wantsBannerStyleChange = YES;
	
	if(_currentlyAnimating == NO)
	{
		//Handle banner change.
		[self _handleBannerCanChange];
	}
}

- (void)_handleBannerCanChange
{
	if(_wantsBannerStyleChange)
	{
		_notificationWindow.hidden = YES;
		_notificationWindow = nil;
		
		_wantsBannerStyleChange = NO;
	}
}

- (void)clearPendingNotificationsForApplicationIdentifier:(NSString*)appIdentifier;
{
	[_pendingNotifications filterUsingPredicate:[NSPredicate predicateWithFormat:@"appIdentifier != %@", appIdentifier]];
}

- (void)clearAllPendingNotifications;
{
	[_pendingNotifications removeAllObjects];
}

- (void)presentNotification:(LNNotification*)notification forApplicationIdentifier:(NSString*)appIdentifier
{
    LNNotification* pendingNotification = [notification copy];
    
    pendingNotification.title = notification.title ? notification.title : _applicationMapping[appIdentifier][LNAppNameKey];
    pendingNotification.icon = notification.icon ? notification.icon : _applicationMapping[appIdentifier][LNAppIconNameKey];
    pendingNotification.appIdentifier = appIdentifier;
    pendingNotification.customView = notification.customView;
    
    [_pendingNotifications addObject:pendingNotification];
    
    [self _handlePendingNotifications];
}

- (void)_handlePendingNotifications
{
	if(_notificationWindow == nil)
	{
		_notificationWindow = [[LNNotificationBannerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds style:_bannerStyle];
		
		[_notificationWindow setHidden:NO];
	}
	
	if(_currentlyAnimating)
	{
		return;
	}
	
	_currentlyAnimating = YES;
	
	void(^block)() = ^ {
		_currentlyAnimating = NO;
		
		[self _handleBannerCanChange];
		
		[self _handlePendingNotifications];
	};
	
	if(_pendingNotifications.count == 0)
	{
		if(![_notificationWindow isNotificationViewShown])
		{
			_currentlyAnimating = NO;
			
			//Clean up notification window.
			_notificationWindow.hidden = YES;
			_notificationWindow = nil;
			
			[self _handleBannerCanChange];
			
			return;
		}
		
		[_notificationWindow dismissNotificationViewWithCompletionBlock:block];
	}
	else
	{
		LNNotification* notification = _pendingNotifications.firstObject;
		[_pendingNotifications removeObjectAtIndex:0];
		
		[_notificationWindow presentNotification:notification completionBlock:block];
		
		[self _handleSoundForAppId:notification.appIdentifier fileName:notification.soundName];
	}
}

- (void)_handleSoundForAppId:(NSString*)appId fileName:(NSString*)fileName
{
	if(fileName == nil)
	{
		return;
	}
	
	NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
	NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
	
	[_currentAudioPlayer stop];
	
	_currentAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
	_currentAudioPlayer.delegate = self;
	[_currentAudioPlayer play];
}

- (NSDictionary*)_applicationsMapping
{
	return _applicationMapping;
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[_currentAudioPlayer stop];
	_currentAudioPlayer = nil;
	[[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

//获取LNBundle 的图片资源
NSString *getLNImageBundlePath(NSString *filename) {
    
    NSBundle *libBundle = [NSBundle bundleWithPath:[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Frameworks"]stringByAppendingPathComponent:@"LNNotificationsUI.bundle"]];
    
    
    if (libBundle && filename) {
        CGFloat screenScale = [UIScreen mainScreen].scale;
        NSString *filePath = [[libBundle resourcePath] stringByAppendingPathComponent:filename];
        NSString *path = [filePath stringByAppendingString:[NSString stringWithFormat:@"@%fx.png", screenScale]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {//判断当前分辨率是否存在
            path = [filePath stringByAppendingString:@"@3x.png"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                path = [filePath stringByAppendingString:@"@2x.png"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    path = [filePath stringByAppendingString:@".png"];
                }
            }
        }
        return path;
    }
    
    return nil;
}

@end
