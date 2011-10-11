//
//  CameraViewController.h
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import <CoreGraphics/CoreGraphics.h>
//#import <CoreVideo/CoreVideo.h>
//#import <CoreMedia/CoreMedia.h>
//#import <QuartzCore/QuartzCore.h>
//#import <AudioToolbox/AudioToolbox.h>


@interface CameraViewController : UIViewController

{
    BOOL frontalCamera;
    AVCaptureDeviceInput *captureInput;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    IBOutlet UIView *cameraView;
}

-(void)initCapture;
-(void)startCapture;
-(void)stopCapture;

@end
