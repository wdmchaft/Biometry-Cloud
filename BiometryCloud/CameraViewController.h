//
//  CameraViewController.h
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "BiometryDetector.h"
#import "RequestHandler.h"

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, BiometryDelegate, RequestHandlerDelegate>

{
    BOOL hasFrontalCamera;
    AVCaptureDeviceInput *captureInput;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    IBOutlet UIView *cameraView;
    
    //Handles the detection process
    BiometryDetector *biometryDetector;
    
    //Handles everything related to sending requests
    RequestHandler *requestHandler;
    
    CGImageRef currentShownFrame;
    BOOL copyingFrame;
    float _scale;
    BOOL _needsAutoExposure;
    BOOL _needsWhiteBalance;
    CGPoint _pointOfExposure;
}

@property (nonatomic, assign, setter = setNeedsAutoExposure:) BOOL needsAutoExposure;
@property (nonatomic, assign, setter = setNeedsWhiteBalance:) BOOL needsWhiteBalance;
@property (nonatomic, assign, setter = setPointOfExposure:) CGPoint pointOfExposure;
@property (nonatomic, assign, setter = setScale:) float scale;

-(void)initCapture;
-(void)startCapture;
-(void)stopCapture;
-(void)setPreviewLayer;

@end
