//
//  BiometryCloudViewController.h
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "BiometryCloudDelegate.h"

//Classes
@class DrawingView;
@class BiometryDetector;
@class RequestHandler;
@class InputView;
@class CheckView;
@class AudioHandler;

//Protocols
@protocol InputViewDelegate;
@protocol RequestHandlerDelegate;
@protocol CheckViewDelegate;
@protocol BiometryDetectorDelegate;


@interface BiometryCloudViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, BiometryDetectorDelegate, RequestHandlerDelegate, InputViewDelegate, CheckViewDelegate>

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
    
    //Sound
    AudioHandler *audioHandler;
    
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
    BOOL _requestAnswerRequired;
    
    //Flag to set if input is required
    BOOL _inputRequired;
    
    //Last found face to store it while entering input
    UIImage *detectedFaceImage;
    
    //SubView
    IBOutlet InputView *_inputView;
    IBOutlet DrawingView *_drawingView;
    IBOutlet CheckView *_checkView;
    
    IBOutlet UIButton *switchCameraButton;

}

//The delegate
@property (nonatomic, assign) id<BiometryCloudDelegate> libraryDelegate;

//Parameters
@property (nonatomic, assign) int consequentPhotos;
@property (nonatomic, assign) BOOL inputRequired;
@property (nonatomic, assign) BOOL requestAnswerRequired;

@property (nonatomic, assign) BOOL needsAutoExposure;
@property (nonatomic, assign) BOOL needsWhiteBalance;
@property (nonatomic, assign) BOOL canSwitchCamera;
@property (nonatomic, assign) CGPoint pointOfExposure;
@property (nonatomic, assign) float scale;

/*
-(void)initCapture;
-(void)startCapture;
-(void)stopCapture;
-(void)setPreviewLayer;
-(IBAction)switchCamera;
 */

@end
