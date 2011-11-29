//
//  BiometryCloudAppDelegate_iPad.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import "BiometryCloudAppDelegate_iPad.h"

@implementation BiometryCloudAppDelegate_iPad

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //First call the super method to implement the general code
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Create the camera view 
    //BiometryCloudViewController_iPhone *cameraView = [[BiometryCloudViewController_iPhone alloc]init];
    _viewController= [[BiometryCloudViewController_iPad alloc]init];
    [self.window addSubview:_viewController.view];
    [self.window makeKeyAndVisible];
    
    //return when finished
    return YES;
}

@end
