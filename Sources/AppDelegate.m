//
//  AppDelegate.m
//  AXMobile
//
//  Created by Anthony Shoumikhin on 8/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UINavigationBar.appearance setBackgroundImage:[UIImage imageNamed:@"dynamics_logo"] forBarMetrics:UIBarMetricsDefault];
    [TSMessage addCustomDesignFromFileWithName:@"TSMessagesDesign.json"];

    return YES;
}

@end
