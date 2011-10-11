//
//  ByometryDetector.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageHandler.h"

@protocol BiometryDelegate

- (UIImage *) getCurrentFrame;
- (void) faceDetectedInRect: (CGRect) rect centered: (BOOL) centered close: (BOOL) close light: (BOOL) light aligned: (BOOL) aligned;
- (void) noFaceDetected;

@end

@interface BiometryDetector : NSObject {
    
    id<BiometryDelegate> delegate;
    
    ImageHandler *imageHandler;
    
    //Queue for detection
    NSOperationQueue *threadQueue;
    
    //Parameters for correct image size handling
    CGRect detectionROI;
    CGRect validROI;
    CGSize viewSize;
    
    //Array to store last rects and see if they are aligned
    NSMutableArray *lastRects;
    int nRects;
    
    //Flag to continue or stop detection
    BOOL detecting;
    
    //Histogram threshold to avoid dark faces
    int histThreshold;
}

@property (nonatomic, retain) id<BiometryDelegate> delegate;

@end
