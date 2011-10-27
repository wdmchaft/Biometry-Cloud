//
//  ImageHandler.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10-01-11.
//  Copyright 2011 Biometry Cloud. All rights reserved.
//

#import "ImageHandler.h"
#import "BiometryCloudConfiguration.h"

@implementation ImageHandler;

@synthesize opencvRunningEyes, opencvRunningFace, opencvRunningMouth, mirror;

- (id)init {
	
    if ((self = [super init])) {
        
        // Load XMLs
        // Face template
        NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        // Eye Pairs template
		//NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_mcs_eyepair_small" ofType:@"xml"];
		faceCascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
        
        //path = [[NSBundle mainBundle] pathForResource:@"haarcascade_eyes_pair" ofType:@"xml"];
        //eyeCascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
        
        //path = [[NSBundle mainBundle] pathForResource:@"haarcascade_mouth" ofType:@"xml"];
        //mouthCascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
        
        //path = [[NSBundle mainBundle] pathForResource:@"haarcascade_profileface" ofType:@"xml"];
        //profileCascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
		
    }    
    return self;
	
}

- (void) dealloc {
    cvReleaseHaarClassifierCascade(&faceCascade);
    cvReleaseHaarClassifierCascade(&eyeCascade);
    cvReleaseHaarClassifierCascade(&mouthCascade);
    [super dealloc];
}

#pragma mark -
#pragma mark OpenCV Support Methods

// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
	CGImageRef imageRef = image.CGImage;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
	
	return ret;
}

- (IplImage *)CreateIplImageFromImageRef:(CGImageRef )imageRef {
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
	
	return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
- (UIImage *)UIImageFromIplImage:(IplImage *)image {
	debugLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s", image->width, image->height, image->depth, image->nChannels, image->widthStep, image->channelSeq);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationRight];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], [self convertRectToCGImage:rect fromUIImageSize:imageToCrop.size]);
    
	UIImage *cropped = [[[UIImage alloc] initWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationRight] autorelease];
	CGImageRelease(imageRef);
	
	
	return cropped;
}

- (CGRect ) opencvFaceDetect:(UIImage *)imageToProcess  {
    
    if (opencvRunningFace) {
        return CGRectZero;
    }
    
	opencvRunningFace = YES;
	
	cvSetErrMode(CV_ErrModeParent);
	
	IplImage *image = [self CreateIplImageFromUIImage:imageToProcess];
    
    int scale;
    
    CvMemStorage* storage = cvCreateMemStorage(0);
    
    CvSeq* faces;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
    
        // Scaling down
        IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
        cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
        scale = 2;
        
        // Detect faces
        faces = cvHaarDetectObjects(small_image, faceCascade, storage, 1.1f, 3, CV_HAAR_DO_CANNY_PRUNING, cvSize(25, 25), cvSize(100, 100));
        cvReleaseImage(&small_image);
    }
    else {
    
        // Detect faces
        faces = cvHaarDetectObjects(image, faceCascade, storage, 1.1f, 3, CV_HAAR_DO_CANNY_PRUNING, cvSize(10, 10), cvSize(100, 100));
        scale = 1;
    }
    

	cvReleaseImage(&image);
    

	
	// Create canvas to show the results
	//CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	//CGContextRef contextRef = CGBitmapContextCreate(NULL, imageToProcess.size.width, imageToProcess.size.height,8, imageToProcess.size.width * 4,colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	
	CGRect face_rect;
	
	// Draw results on the image
	if(faces->total) {
		
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		// Calc the rect of faces
		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, 0);
		face_rect = CGRectMake(cvrect.x * scale, cvrect.y * scale,cvrect.width * scale, cvrect.height * scale);
		//debugLog(@"Face detected!");
        
        
        //Change OpenCV's face_rect dimensions to our needs.
        
        face_rect.origin.y -= face_rect.size.height/10;
        face_rect.size.height += 2*face_rect.size.height/15;
        
        face_rect.origin.x += face_rect.size.width/15;
        face_rect.size.width -= 2*face_rect.size.width/15;
        
        /*
         face_rect.origin.y += face_rect.size.width/8;
         face_rect.size.height -= 2*face_rect.size.width/8;
         
         face_rect.origin.x += face_rect.size.width/5;
         face_rect.size.width -= 2*face_rect.size.width/5;
         */
		[pool release];
	}
	else {
		//debugLog(@"No face detected!");
		
		face_rect = CGRectZero;
	}
    
    
	//CGContextRelease(contextRef);
	//CGColorSpaceRelease(colorSpace);
	
	cvReleaseMemStorage(&storage);
	
	opencvRunningFace = NO;
	
	return face_rect;
}


- (CGRect) opencvProfileDetect:(UIImage *)imageToProcess inFaceRect: (CGRect) faceRect  {

	//opencvRunningFace = YES;
	
	cvSetErrMode(CV_ErrModeParent);
    
	IplImage *image = [self CreateIplImageFromUIImage:imageToProcess];
	
	// Scaling down
	IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
	cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
    int scale = 2;
	
	CvMemStorage* storage = cvCreateMemStorage(0);
	
	/*
	 #define CV_HAAR_DO_CANNY_PRUNING    1
	 #define CV_HAAR_SCALE_IMAGE         2
	 #define CV_HAAR_FIND_BIGGEST_OBJECT 4
	 #define CV_HAAR_DO_ROUGH_SEARCH     8
	 */
	
	// Detect faces and draw rectangle on them
	CvSeq* faces = cvHaarDetectObjects(small_image, profileCascade, storage, 1.1f, 3, CV_HAAR_DO_CANNY_PRUNING, cvSize(20, 20), cvSize(100, 100));

	
	//opencvRunningFace = NO;
    CGRect profileRect;
    
    if (faces->total) {
        
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		// Calc the rect of faces
		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, 0);
        
		profileRect = CGRectMake(cvrect.x * scale, cvrect.y * scale,cvrect.width * scale, cvrect.height * scale);
        
        //Change OpenCV's face_rect dimensions to our needs
        profileRect.origin.y -= profileRect.size.height/10;
        profileRect.size.height += 2*profileRect.size.height/15;
        
        profileRect.origin.x += profileRect.size.width/15;
        profileRect.size.width -= 2*profileRect.size.width/15;
        
        mirror = FALSE;
        
        if (profileRect.origin.x < faceRect.origin.x || profileRect.size.height + 8 < faceRect.size.height) {
            
            profileRect = CGRectZero;
        }
        
        //debugLog(@"H face: %f, H profile: %f",faceRect.size.height, profileRect.size.height);
        
		[pool release];
    }
    else {
        
        CvMemStorage* storage2 = cvCreateMemStorage(0);
        
        IplImage *mirr_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
        
        cvFlip(small_image, mirr_image, 1);
        
        CvSeq* faces2 = cvHaarDetectObjects(mirr_image, profileCascade, storage2, 1.1f, 3, CV_HAAR_DO_CANNY_PRUNING, cvSize(20, 20), cvSize(100, 100));
        
        if (faces2->total) {
            
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
            
            // Calc the rect of faces
            CvRect cvrect = *(CvRect*)cvGetSeqElem(faces2, 0);
            
            profileRect = CGRectMake(cvrect.x * scale, cvrect.y * scale,cvrect.width * scale, cvrect.height * scale);
            
            //Change OpenCV's face_rect dimensions to our needs
            profileRect.origin.y -= profileRect.size.height/10;
            profileRect.size.height += 2*profileRect.size.height/15;
            
            profileRect.origin.x += profileRect.size.width/15;
            profileRect.size.width -= 2*profileRect.size.width/15;
            
            mirror = TRUE;
            
            if (mirr_image->width - profileRect.origin.x > faceRect.origin.x || profileRect.size.height + 8 < faceRect.size.height) {
                
                profileRect = CGRectZero;
            }
            
            //debugLog(@"H face: %f, H profile: %f",faceRect.size.height, profileRect.size.height);
            
            [pool release];
        }
        else {
            
            profileRect = CGRectZero;
        }
        
        cvReleaseImage(&mirr_image);
        cvReleaseMemStorage(&storage2);
    }
    
    cvReleaseImage(&image);
    cvReleaseImage(&small_image);
    cvReleaseMemStorage(&storage);
    
    return profileRect;
}


- (CvHistogram*) opencvCalcLuminosityHist: (UIImage *) image inFace: (CGRect) rect {
    
    // Set up image
	IplImage* src = [self CreateIplImageFromUIImage:image];
    
    IplImage* img = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 3);
    
    // Convert to other space (HLS)
    cvCvtColor(src, img, CV_BGR2HLS);
    
    //Luminosity plane
    IplImage* l_plane = cvCreateImage( cvGetSize(src), IPL_DEPTH_8U, 1 );
    
    cvSplit(img, NULL, l_plane, NULL, NULL);
    
    int bins = 256;
    
    cvSetImageROI(l_plane, cvRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.width));
    
    CvHistogram* hist = cvCreateHist(1, &bins, CV_HIST_ARRAY, NULL, 1);
    
    IplImage* imgProc[] = {l_plane};
    
    cvCalcHist(imgProc, hist, 0, NULL);
    
    cvNormalizeHist(hist, 100);
    
    cvReleaseImage( &img );
	cvReleaseImage( &src );
    cvReleaseImage( &l_plane );
    
    return hist;
}

- (double) opencvGetHistMean: (UIImage *) image inFace: (CGRect) rect {
    
    CvHistogram *hist = [self opencvCalcLuminosityHist:image inFace:rect];
    
    double mean = 0;
    double aux = 0;
    
    float* bins;
    
    for (int i = 0; i < 256; i++) {
        
        bins = ((float*)(cvPtr1D( (hist)->bins, i, 0 )));
        
        mean += bins[0]*i;
        
        aux += bins[0];
    }
    
    mean /= aux;
    
    cvReleaseHist( &hist );
    
    return mean;
}

- (double) opencvCompareHalfs: (UIImage *) image inFace: (CGRect) rect {

    double left = [self opencvGetHistMean:image inFace:CGRectMake(rect.origin.x, rect.origin.y + rect.size.width/6, rect.size.width/2, rect.size.height/2)];
    
    double right = [self opencvGetHistMean:image inFace:CGRectMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.width/6, rect.size.width/2, rect.size.height/2)];
    
    double diff = right - left;
    
    if (diff < 0) {
        diff *= -1;
    }
    
    return diff;
}

- (double) opencvCompareBorders: (UIImage *) image inFace: (CGRect) rect {
    
    double left = [self opencvGetHistMean:image inFace:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height/4, rect.size.width/8, rect.size.height/2)];
    
    double right = [self opencvGetHistMean:image inFace:CGRectMake(rect.origin.x + rect.size.width*7/8, rect.origin.y + rect.size.height/4, rect.size.width/8, rect.size.height/2)];
    
    double diff = right - left;
    
    if (diff < 0) {
        diff *= -1;
    }
    
    return diff;
}

- (UIImage *) opencvDetectEdges: (UIImage *) image {
    
	// Set up images
	IplImage* img = [self CreateIplImageFromUIImage:image];
    
    IplImage* gray = cvCreateImage(cvSize(img->width,img->height), IPL_DEPTH_8U, 1);
    IplImage* edge = cvCreateImage(cvSize(img->width,img->height), IPL_DEPTH_8U, 1);
    
    // Convert to grayscale
    cvCvtColor(img, gray, CV_BGR2GRAY);
	
	// Edge Detection Variables
	int aperature_size = 3;
	double thresh = 20;
        
    // Edge Detection
    cvCanny(gray, edge, thresh, thresh*3, aperature_size );
    
    IplImage* convert = cvCreateImage(cvSize(img->width,img->height), IPL_DEPTH_8U, 4);
    
    // Convert to rgb
    cvCvtColor(edge, convert, CV_GRAY2RGBA);
    
	UIImage *ret = [self UIImageFromIplImage:convert];
    
    /*
    CvMat* matrix = cvCreateMat(1, 1, CV_32FC2);
    
    cvHoughLines2(edge, matrix, CV_HOUGH_STANDARD, 2, 0.05, 5, 0, 0);
    */
     
	// Release
	cvReleaseImage( &img );
	cvReleaseImage( &gray );
	cvReleaseImage( &edge );
    cvReleaseImage( &convert );
    
	return ret;
}

- (CGRect) opencvEyeDetect:(UIImage *)imageToProcess inFaceRect:(CGRect ) face_rect  {
    
	opencvRunningEyes = YES;
	
	cvSetErrMode(CV_ErrModeParent);
	
	IplImage *image = [self CreateIplImageFromUIImage:imageToProcess];
    
    //Set ROI
    CGRect roiRect =CGRectMake(face_rect.origin.x, face_rect.origin.y + face_rect.size.height/4, face_rect.size.width, face_rect.size.height/2);
	
    cvSetImageROI(image, cvRect(roiRect.origin.x, roiRect.origin.y, roiRect.size.width, roiRect.size.height));
    
    /*
	// Scaling down
	IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
	cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
	int scale = 2;
	*/
     
	CvMemStorage* storage = cvCreateMemStorage(0);
	
	/*
	 #define CV_HAAR_DO_CANNY_PRUNING    1
	 #define CV_HAAR_SCALE_IMAGE         2
	 #define CV_HAAR_FIND_BIGGEST_OBJECT 4
	 #define CV_HAAR_DO_ROUGH_SEARCH     8
	 */
	
	// Detect eyes and draw rectangle on them
	CvSeq* eyes = cvHaarDetectObjects(image, eyeCascade, storage, 1.1f, 3, CV_HAAR_DO_CANNY_PRUNING, cvSize(40, 10), cvSize(160, 40));
	//cvReleaseImage(&small_image);
	cvReleaseImage(&image);
	
    
   // NSMutableArray *eyesArray = [[NSMutableArray alloc] init];
	
    CGRect eyeRect = CGRectZero;
    
	// Draw results on the image
	if(eyes->total) {
        
        for(int i = 0; i < eyes->total; i++) {
            
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
            
            // Calc the rect of eye
            CvRect cvrect = *(CvRect*)cvGetSeqElem(eyes, i);
            
            if (cvrect.y + face_rect.origin.y > eyeRect.origin.y) {
                eyeRect = CGRectMake(cvrect.x + roiRect.origin.x, cvrect.y + roiRect.origin.y,cvrect.width, cvrect.height);
            }
            
            //[eyesArray addObject:[NSValue valueWithCGRect:eyeRect]];
            
            [pool release];
        
            //debugLog(@"Eyes detected!");
        }
	}
	else {
		//debugLog(@"No eyes detected!");
	}
	
	cvReleaseMemStorage(&storage);
	
	opencvRunningEyes = NO;
	
	return eyeRect;
}

- (CGRect) opencvMouthDetect:(UIImage *)imageToProcess inFaceRect:(CGRect ) face_rect  {
    
	opencvRunningMouth = YES;
	
	cvSetErrMode(CV_ErrModeParent);
	
	IplImage *image = [self CreateIplImageFromUIImage:imageToProcess];
    
    //Set ROI
    CGRect roiRect =CGRectMake(face_rect.origin.x, face_rect.origin.y + face_rect.size.height/2, face_rect.size.width, face_rect.size.height/2);
	
    cvSetImageROI(image, cvRect(roiRect.origin.x, roiRect.origin.y, roiRect.size.width, roiRect.size.height));
    
    /*
     // Scaling down
     IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
     cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
     int scale = 2;
     */
    
	CvMemStorage* storage = cvCreateMemStorage(0);
	
	/*
	 #define CV_HAAR_DO_CANNY_PRUNING    1
	 #define CV_HAAR_SCALE_IMAGE         2
	 #define CV_HAAR_FIND_BIGGEST_OBJECT 4
	 #define CV_HAAR_DO_ROUGH_SEARCH     8
	 */
	
	// Detect eyes and draw rectangle on them
	CvSeq* mouth = cvHaarDetectObjects(image, mouthCascade, storage, 1.1f, 3, CV_HAAR_DO_CANNY_PRUNING, cvSize(25, 15), cvSize(100, 60));
	//cvReleaseImage(&small_image);
	cvReleaseImage(&image);
	
    
    // NSMutableArray *eyesArray = [[NSMutableArray alloc] init];
	
    CGRect mouthRect = CGRectZero;
    
	// Draw results on the image
	if(mouth->total) {
        
        //for(int i = 0; i < mouth->total; i++) {
            
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
            
            // Calc the rect of eye
            CvRect cvrect = *(CvRect*)cvGetSeqElem(mouth, 0);
            
            //if (cvrect.y + face_rect.origin.y > mouth.origin.y) {
                mouthRect = CGRectMake(cvrect.x + roiRect.origin.x, cvrect.y + roiRect.origin.y,cvrect.width, cvrect.height);
            //}
            
            //[eyesArray addObject:[NSValue valueWithCGRect:eyeRect]];
            
            [pool release];
            
            //debugLog(@"Mouth detected!");
        //}
	}
	else {
		//debugLog(@"No mouth detected!");
	}
	
	cvReleaseMemStorage(&storage);
	
	opencvRunningMouth = NO;
	
	return mouthRect;
}



- (CGImageRef ) drawRect: (CGRect ) face_rect inImage: (CGImageRef ) imageRef {
	
	if (CGRectIsEmpty(face_rect)) {
		return imageRef;
	}
	
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef contextRef = CGBitmapContextCreate(NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef),
													8, CGImageGetWidth(imageRef) * 4,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
	
	CGContextSetLineWidth(contextRef, 2);
	CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 1.0, 0.5);
	
	CGContextStrokeRect(contextRef, face_rect);
	
	CGImageRef newImageRef = CGBitmapContextCreateImage(contextRef);
					   
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	CGImageRelease(imageRef);
	
	return newImageRef;//no leak here, do not autorelease!!
}

- (UIImage*)imageWithImage:(UIImage*)image 
			  scaledToSize:(CGSize)newSize;
{
	UIGraphicsBeginImageContext( newSize );
	
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	
	return newImage;
}

//Image utils
- (CGRect) convertRectToCGImage:(CGRect) rect fromUIImageSize:(CGSize) uiSize {
    
    return CGRectMake(uiSize.height - rect.origin.y - rect.size.height, rect.origin.x, rect.size.height, rect.size.width);
}

- (CGRect) convertRect:(CGRect) rect fromContextSize:(CGSize) fromSize toContextSize:(CGSize) toSize {
    
    double xresize = toSize.width/fromSize.width;
    double yresize = toSize.height/fromSize.height;
    
    return CGRectMake(rect.origin.x*xresize, rect.origin.y*yresize, rect.size.width*xresize, rect.size.height*yresize);
}

@end
