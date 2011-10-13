//
//  CameraViewController.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 06-10-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController

//create the setters and getters for the parameters of the cammera

@synthesize needsAutoExposure=_needsAutoExposure, needsWhiteBalance=_needsWhiteBalance, pointOfExposure=_pointOfExposure, scale=_scale;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        biometryDetector = [[BiometryDetector alloc] init];
        biometryDetector.delegate = self;
        
        //start with initial params
        
        [self setPointOfExposure:CGPointMake(0.8f, 0.5f)];
        [self setNeedsWhiteBalance:YES];
        [self setNeedsAutoExposure:NO];
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
    [self initCapture];
    
    //Biometry detector parameters
    biometryDetector.viewSize = self.view.frame.size;
    biometryDetector.validROI = self.view.frame; //MASK
    biometryDetector.detectionROI = CGRectMake(-previewLayer.frame.origin.x/_scale, -previewLayer.frame.origin.y/_scale, previewLayer.bounds.size.width/_scale, previewLayer.bounds.size.height/_scale);
    
    [biometryDetector startFaceDetection];
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
        //it also needs a param of a point of exposure, for now, we won't use params
   
        if ([captureInput.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]&&_needsAutoExposure) {
            captureInput.device.exposurePointOfInterest = _pointOfExposure;
            [captureInput.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        //also needed param (bool)enableWhiteBalance
        
        if ([captureInput.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]&&_needsWhiteBalance) {
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
        
        hasFrontalCamera=TRUE;
        
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
    
    [self performSelectorOnMainThread:@selector(setPreviewLayer) withObject:nil waitUntilDone:YES];    
	/*We start the capture*/
	[self startCapture];
	[cameraView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

//method for extracting the image

- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{ 
	//We create an autorelease pool because as we are not in the main_queue our code is
    //not executed in the main thread. So we have to create an autorelease pool for the thread we are in

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    
    //Lock the image buffer
    
    CVPixelBufferLockBaseAddress(imageBuffer,0); 
	
    //Get information about the image
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer);  
    
    //Create a CGImageRef from the CVImageBufferRef
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
	
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, 
													kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	
	CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
    
	//The next lines will be in the openCV class
	
    if (!copyingFrame) 
    {
        CGImageRef aux = currentShownFrame;
        currentShownFrame = newImage;
        CGImageRelease(aux);
	}
	else 
    {
        CGImageRelease(newImage);
	}
	
    //We release some components
    
    CGContextRelease(newContext); 
    CGColorSpaceRelease(colorSpace);
    
	//We unlock the  image buffer
	
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	[pool drain];
} 


#pragma mark - Parameters setting

//setting of params for the cammera.

-(void) setNeedsAutoExposure:(BOOL)needsAutoExposure 
{
    _needsAutoExposure=needsAutoExposure;
    
    if ([captureSession isRunning]) 
    {
        [self setupCamera];
    }
    
}

-(void) setNeedsWhiteBalance:(BOOL)needsWhiteBalance 
{
    _needsWhiteBalance=needsWhiteBalance;
    if ([captureSession isRunning]) 
    {
        [self setupCamera];
    }
}

-(void) setPointOfExposure:(CGPoint)pointOfExposure
{
    _pointOfExposure=pointOfExposure;
    if ([captureSession isRunning]) 
    {
        [self setupCamera];
    }
}
-(void) setPreviewLayer
{
    previewLayer.transform = CATransform3DMakeScale(_scale, _scale, 0);
    
    previewLayer.contentsGravity = kCAGravityResizeAspectFill;
    
    [cameraView.layer addSublayer:previewLayer];
}

#pragma mark - Biometry Delegate methods

- (UIImage *) getCurrentFrame 
{
    //set the bool copying frame to true to "lock" the CGImage

    copyingFrame=TRUE;
    
    UIImage	*frameImage = [[UIImage alloc] initWithCGImage:(CGImageRef)currentShownFrame scale:1.0f orientation:UIImageOrientationRight];
    
    copyingFrame=FALSE;
    
    //after "unlocking" the CGImage, return 
    
    return frameImage;
}

- (void) faceDetectedInRect: (CGRect) rect centered: (BOOL) centered close: (BOOL) close light: (BOOL) light aligned: (BOOL) aligned{

    NSLog(@"Face detected!");
}

- (void) noFaceDetected{
    
    NSLog(@"No face detected!");
}

@end
