//
//  CameraViewController.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)hasFrontalCamera
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
     
     for (AVCaptureDevice *device in videoDevices)
     {
     if (device.position == AVCaptureDevicePositionFront)
     {
     return TRUE;
     }
     }
	return FALSE;
}

- (void) setupCamera
{
    //lock the device for configuration
    if ([captureInput.device lockForConfiguration:nil]) 
    {
        //this method needs a bool that comes as a param from the server: (bool)enableAutoExposure
        //it also needs a param of a point of exposure, for now, we won't use params
        if ([captureInput.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            captureInput.device.exposurePointOfInterest = CGPointMake(0.8f, 0.5f);
            [captureInput.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        //also needed param (bool)enableWhiteBalance
        if ([captureInput.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureInput.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        } 
        //Unlock the device once the configuration is finished
        [captureInput.device unlockForConfiguration];
    }
     

}

-(void)startCapture 
{
    [captureSession startRunning];
}
-(void)stopCapture 
{
    [captureSession stopRunning];
}

- (void)initCapture 
{
    AVCaptureDevice *captureDevice = nil;
    
    //Ask if the device has frontal camera
    if ([self hasFrontalCamera]) 
    {
        
        frontalCamera=TRUE;
        
        //Set the capture device to be the frontal camera
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
		
		for (AVCaptureDevice *device in videoDevices)
		{
			if (device.position == AVCaptureDevicePositionFront)
			{
				captureDevice = device;
				break;
			}
		}
    }
    
    //Set the capture device to be the default camera (the one on the back)
    else 
	{
		captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	}
    
    //now we have to setup the capture input: it needs to be like this so we can change the input device or it's configuration
    captureInput = [[[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:nil] autorelease];
    
    //We need to setup the camera
    [self setupCamera];

    //Now we need to setup the output
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    //While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: 
	//delegate methods no other frames are added in the queue.
	//If you don't want this behaviour set the property to NO
	captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    //We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
    //in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
	//In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
	//we are not able to process more than 10 frames per second.
	captureOutput.minFrameDuration = CMTimeMake(1, 10);
    
    //We create a serial queue to handle the processing of our frames
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
    
    // Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 	
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
    [captureOutput setVideoSettings:videoSettings]; 

    //Now is time to create the captureSession
    captureSession = [[AVCaptureSession alloc]init];
    
    //This preset should be parametrizable
    captureSession.sessionPreset= AVCaptureSessionPreset640x480;
    
    //Now is time to add the input and output to the session:
    [captureSession addInput:captureInput];
    [captureSession addOutput:captureOutput];
    
    //set the frame for the session
    [captureSession setAccessibilityFrame:cameraView.frame];
    
    //The preview layer doesn't process frames so it is faster, we will use it to show the images
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.frame=cameraView.bounds;
    
}


@end
