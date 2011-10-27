//
//  ImageHandler.h
//  ControlApplication
//
//  Created by Pablo Mandiola on 10-01-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <opencv2/imgproc/imgproc_c.h> 
#import <opencv2/objdetect/objdetect.hpp>

/*!
 @class
 @abstract
 @discussion
 */
@interface ImageHandler : NSObject {

	CvHaarClassifierCascade* faceCascade;
    CvHaarClassifierCascade* profileCascade;
    CvHaarClassifierCascade* eyeCascade;
    CvHaarClassifierCascade* mouthCascade;
	
	BOOL opencvRunningFace;
    BOOL opencvRunningEyes;
    BOOL opencvRunningMouth;
    
    BOOL mirror;
}

@property (nonatomic, assign) BOOL opencvRunningFace;
@property (nonatomic, assign) BOOL opencvRunningEyes;
@property (nonatomic, assign) BOOL opencvRunningMouth;
@property (nonatomic, assign) BOOL mirror;

/*!
 @method
 @abstract
 @discussion
 */
- (CGImageRef ) drawRect: (CGRect ) face_rect inImage: (CGImageRef ) imageRef;
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
- (UIImage*)imageWithImage:(UIImage*)image 
			  scaledToSize:(CGSize)newSize;
- (CGRect) convertRectToCGImage:(CGRect) rect fromUIImageSize:(CGSize) uiSize;

- (CGRect ) opencvFaceDetect:(UIImage *)imageToProcess;
- (CGRect) opencvEyeDetect:(UIImage *)imageToProcess inFaceRect:(CGRect ) face_rect;
- (CGRect) opencvMouthDetect:(UIImage *)imageToProcess inFaceRect:(CGRect ) face_rect;
- (CGRect) opencvProfileDetect:(UIImage *)imageToProcess inFaceRect: (CGRect) faceRect;
- (UIImage *) opencvDetectEdges: (UIImage *) image;

- (double) opencvGetHistMean: (UIImage *) image inFace: (CGRect) rect;
- (double) opencvCompareHalfs: (UIImage *) image inFace: (CGRect) rect;
- (double) opencvCompareBorders: (UIImage *) image inFace: (CGRect) rect;

- (CGRect) convertRect:(CGRect) rect fromContextSize:(CGSize) fromSize toContextSize:(CGSize)toSize;

@end
