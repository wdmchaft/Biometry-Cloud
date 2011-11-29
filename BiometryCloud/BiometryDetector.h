//
//  ByometryDetector.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/11/11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageHandler.h"

@protocol BiometryDetectorDelegate

- (UIImage *) getCurrentFrame;
- (CGSize) getViewSize;
- (CGRect) getValidROI;
- (CGRect) getDetectionROI;

- (void) faceDetectedInRect: (CGRect) rect centered: (BOOL) centered close: (BOOL) close light: (BOOL) light aligned: (BOOL) aligned;
- (void) successfullFaceDetection:(UIImage*) face;
- (void) noFaceDetected;

@end

@interface BiometryDetector : NSObject {
    
    id<BiometryDetectorDelegate> delegate;
    
    ImageHandler *imageHandler;
    
    //Queue for detection
    NSOperationQueue *threadQueue;
    
    //Array to store last rects and see if they are aligned
    NSMutableArray *lastRects;
    int nRects;
    
    //Flag to continue or stop detection
    BOOL detecting;
    
    //Histogram threshold to avoid dark faces
    int histThreshold;
}

@property (nonatomic, assign) id<BiometryDetectorDelegate> delegate;

- (void) startFaceDetection;
- (void) stopFaceDetection;

@end
