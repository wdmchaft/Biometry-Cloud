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
    BOOL hasFrontalCamera;
    AVCaptureDeviceInput *captureInput;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    IBOutlet UIView *cameraView;
    BOOL needsAutoExposure;
    BOOL needsWhiteBalance;
}

@property (nonatomic, assign, setter = setNeedsAutoExposure:) BOOL _needsAutoExposure;
@property (nonatomic, assign, setter = setNeedsWhiteBalance:) BOOL _needsWhiteBalance;

-(void)initCapture;
-(void)startCapture;
-(void)stopCapture;

@end
