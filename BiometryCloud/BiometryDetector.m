//
//  ByometryDetector.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/11/11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import "BiometryDetector.h"
#import "BiometryCloudConfiguration.h"

@implementation BiometryDetector

@synthesize delegate;
@synthesize detectionROI, validROI, viewSize;

#pragma mark - Object Lifecycle

- (id) init {

    if (self == [super init]) {
        
        nRects = 3;
        lastRects = [[NSMutableArray alloc] init];
        imageHandler = [[ImageHandler alloc] init];
        threadQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void) dealloc {

    [threadQueue release];
    [lastRects release];
    [imageHandler release];
    
    [super dealloc];
}

#pragma mark - Rects Methods

- (void) addRectToList:(CGRect) rect {
    
    if ([lastRects count] < nRects) {
        [lastRects addObject:[NSValue valueWithCGRect:rect]];
    }
    else {
        
        [lastRects removeObjectAtIndex:0];
        [lastRects addObject:[NSValue valueWithCGRect:rect]];
    }
}

- (BOOL) compareRect:(CGRect)firstRect withRect:(CGRect)secondRect {
    
    return CGRectContainsPoint(CGRectMake(firstRect.origin.x-3, firstRect.origin.y-3, 6, 6), secondRect.origin) && CGRectContainsPoint(CGRectMake(firstRect.origin.x-3 + firstRect.size.width, firstRect.origin.y-3 + firstRect.size.height, 6, 6), CGPointMake(secondRect.origin.x + secondRect.size.width, secondRect.origin.y + secondRect.size.height));
}

- (BOOL) areRectsAligned {
    
    if ([lastRects count] < nRects) {
        return FALSE;
    }
    
    BOOL ret = TRUE;
    
    for (int i = 0; i<[lastRects count]-1; i++) {
        
        ret = ret && [self compareRect:[[lastRects objectAtIndex:i] CGRectValue] withRect:[[lastRects lastObject] CGRectValue]];
        
        if (!ret) {
            break;
        }
    }
    
    return ret;
}

#pragma mark - Detection Methods

- (void) startFaceDetection {

    detecting = TRUE;
    
    NSInvocationOperation *faceDetection = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doFaceDetection) object:nil];
    [threadQueue addOperation:faceDetection];
    
    [faceDetection release];
}

- (void) stopFaceDetection {

    detecting = FALSE;
}

- (void) doFaceDetection
{
    
	if (imageHandler.opencvRunningFace) {
        
		return;
	}
	else if (detecting)
	{
        
        UIImage	*frameImage = [delegate getCurrentFrame];
		
        if (frameImage.CGImage) {
            
            //Crop the image to ROI
            UIImage *img = [imageHandler imageByCropping:frameImage toRect:[imageHandler convertRect:CGRectMake(detectionROI.origin.x - 20, detectionROI.origin.y - 20, detectionROI.size.width + 40, detectionROI.size.height + 40) fromContextSize:viewSize toContextSize:frameImage.size]];
            
            int scale = 3;
            
            UIImage *scaledImg = [imageHandler imageWithImage:img scaledToSize:CGSizeMake(img.size.width/scale, img.size.height/scale)];
            
            CGRect faceRect = [imageHandler opencvFaceDetect:scaledImg];
            
            if (!CGRectIsEmpty(faceRect)) 
            {	
                
                CGRect auxRect = CGRectMake(faceRect.origin.x, faceRect.origin.y, faceRect.size.width, faceRect.size.height);
                
                //don't go to sleep
                //personRecognized=TRUE;
                [self addRectToList:faceRect];
                //[self addFrameToList:img];
                
                faceRect.origin.x = scale * faceRect.origin.x;
                
                faceRect.origin.y = scale * faceRect.origin.y;
                
                faceRect.size.width = scale * faceRect.size.width;
                
                faceRect.size.height = scale * faceRect.size.height;
                
                
                //Convert the rect to the view´s coordinates
                CGRect rect = [imageHandler convertRect:CGRectMake(faceRect.origin.x - 20, faceRect.origin.y - 20, faceRect.size.width + 40, faceRect.size.height + 40) fromContextSize:img.size toContextSize:viewSize];
                
                
                //Mirror
                CGRect mirroredRect = CGRectMake(viewSize.width - rect.origin.x - rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
                
                
                
                //Check faceRect position with validROI
                BOOL positionOK;
                BOOL centered = CGRectContainsRect(validROI, mirroredRect);
                
                BOOL close;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {   // iPhone or iPod
                    close = mirroredRect.size.height > viewSize.height/3;//2.25
                }
                else{   // iPad
                    close = mirroredRect.size.height > viewSize.height/2.5;
                }
                
                positionOK = centered && close;
                
                
                //set drawing parameters for colouring --> CAMERA VIEW
                /*
                drawingView.distanceOK = close;
                drawingView.positionOK = contains;
                
                if (!close) {
                    
                    [self performSelectorOnMainThread:@selector(showFeedback:) withObject:@"getCloser" waitUntilDone:NO];
                }
                else if (!contains) {
                    
                    [self performSelectorOnMainThread:@selector(showFeedback:) withObject:@"centerFace" waitUntilDone:NO];
                }
                
                
                if (positionOK) {
                    
                    hideFeedback = TRUE;
                    [self performSelectorOnMainThread:@selector(hideFeedback) withObject:nil waitUntilDone:NO];
                }
                */
                
                BOOL rectsAligned = [self areRectsAligned];
                
                
                if (positionOK && rectsAligned) 
                {	
                    
                    double hist_mean = [imageHandler opencvGetHistMean:scaledImg inFace:auxRect];
                    
                    if (hist_mean > histThreshold) {
                        
                        detecting = FALSE;
                        
                        //Don´t use rect --> convert in CAMERA VIEW
                        //CGRect face_rect = [imageHandler convertRect:detectionROI fromContextSize:viewSize toContextSize:frameImage.size];
                        
                        /*
                        NSArray *params = [[NSArray alloc] initWithObjects:[[NSArray alloc] initWithArray:currentFrames], [NSValue valueWithCGRect:face_rect], nil];
                        
                        [self performSelectorOnMainThread:@selector(faceDetectedWithParams:) withObject:params waitUntilDone:NO];
                         */
                        
                        [delegate successfullFaceDetection:img];
                        
                        //Erase rects
                        faceRect = CGRectZero;
                        [lastRects removeAllObjects];
                    }
                    else {
                        
                        //Draw mirrored rect --> CAMERA VIEW
                        [delegate faceDetectedInRect:mirroredRect centered:centered close:close light:FALSE aligned:rectsAligned];
                    }
                }
                else {
                    
                    //Draw mirrored rect --> CAMERA VIEW
                    [delegate faceDetectedInRect:mirroredRect centered:centered close:close light:FALSE aligned:rectsAligned]; 
                }
                
            }
            else 
            {
                [lastRects removeAllObjects];
                
                [delegate noFaceDetected];
                
                /* --> CAMERA VIEW
                drawingView.distanceOK = FALSE;
                drawingView.positionOK = FALSE;
                
                //hide feedback
                [self hideFeedbackWithDelay];
                 */
            }
		}
        
        [frameImage release];
	}
	
	if (detecting) {
		
		NSInvocationOperation *faceDetection = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doFaceDetection) object:nil];
		[threadQueue addOperation:faceDetection];
		
		[faceDetection release];
	}
}


@end
