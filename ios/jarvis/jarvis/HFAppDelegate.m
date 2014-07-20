//
//  HFAppDelegate.m
//  jarvis
//
//  Created by Nikhil Srinivasan on 7/20/14.
//  Copyright (c) 2014 greylock hackfest. All rights reserved.
//

#import "HFAppDelegate.h"
#import "HFViewController.h"

@implementation HFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[HFViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end