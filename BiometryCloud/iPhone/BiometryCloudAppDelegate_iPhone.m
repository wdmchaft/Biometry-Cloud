//
//  BiometryCloudAppDelegate_iPhone.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BiometryCloudAppDelegate_iPhone.h"
#import "CameraViewController_iPhone.h"

@implementation BiometryCloudAppDelegate_iPhone
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//First call the super method to implement the general code
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
//Create the camera view 
    CameraViewController_iPhone *cameraView = [[CameraViewController_iPhone alloc]init];
    
//Add the cameraView to the window and make the window visible
    [self.window addSubview:cameraView.view];
    [self.window makeKeyAndVisible];

//return when finished
    return YES;
}

@end
