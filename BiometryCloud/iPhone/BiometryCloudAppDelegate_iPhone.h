//
//  BiometryCloudAppDelegate_iPhone.h
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import "BiometryCloudAppDelegate.h"

@class CameraViewController_iPhone;
@interface BiometryCloudAppDelegate_iPhone : BiometryCloudAppDelegate
{
}

@property (nonatomic, retain) IBOutlet CameraViewController_iPhone *viewController;

@end
