//
//  CameraViewController.h
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "BiometryCloudDelegate.h"

#import "DrawingView.h"
#import "BiometryDetector.h"
#import "RequestHandler.h"
#import "InputView.h"
#import "CheckView.h"

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, BiometryDetectorDelegate, RequestHandlerDelegate, InputViewDelegate, CheckViewDelegate>

{
    //Library's delegate
    id<BiometryCloudDelegate> libraryDelegate;
    
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
    BOOL _canSwitchCamera;
    BOOL frontalCamera;
    CGPoint _pointOfExposure;
    
    //Number of consequent photos (0 for infinite)
    int _consequentPhotos;
    int _takenPhotos;
    
    //Flag to set if answer from webservice is required
    BOOL requestAnswerRequired;
    
    //Flag to set if input is required
    BOOL inputRequired;
    
    //Last found face to store it while entering input
    UIImage *detectedFaceImage;
    
    //SubView
    IBOutlet InputView *_inputView;
    IBOutlet DrawingView *_drawingView;
    IBOutlet CheckView *_checkView;
    
    IBOutlet UIButton *switchCameraButton;

}

@property (nonatomic, assign) id<BiometryCloudDelegate> libraryDelegate;

@property (nonatomic, assign, setter = setNeedsAutoExposure:) BOOL needsAutoExposure;
@property (nonatomic, assign, setter = setNeedsWhiteBalance:) BOOL needsWhiteBalance;
@property (nonatomic, assign, setter = setCanSwitchCamera:) BOOL canSwitchCamera;
@property (nonatomic, assign, setter = setPointOfExposure:) CGPoint pointOfExposure;
@property (nonatomic, assign, setter = setScale:) float scale;
//@property (nonatomic, retain) IBOutlet DrawingView *drawingView;

@property (nonatomic, assign, setter = setConsequentPhotos:) int consequentPhotos;

/*
-(void)initCapture;
-(void)startCapture;
-(void)stopCapture;
-(void)setPreviewLayer;
-(IBAction)switchCamera;
 */

@end
