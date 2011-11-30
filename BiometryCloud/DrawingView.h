//
//  DrawingView.h
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 20-10-11.
//  Copyright (c) 2011 Biometry Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView

{
    CGRect faceRect;
    
    CGRect profileRect;
    
    CGRect eyesRect;
    
    CGRect mouthRect;
    
    BOOL distanceOK;
    
    BOOL positionOK;
    
    IBOutlet UILabel *feedbackLabel;
    
    IBOutlet UIImageView *animatingImage;
    
    IBOutlet UIView *__unsafe_unretained limitRectView;
    
    NSMutableArray *getCloserImages;
    
    NSMutableArray *centerFaceImages;
    
    NSString *currentFeedback;
    
    CGRect initialFrame;
    
    int hideFeedbackInt;
    
    BOOL isShowingFeedback;
    
    BOOL mirroredRect;
}

- (void) drawMouthRect:(CGRect)rect;

- (void) drawFaceRect:(CGRect)rect;

- (void) drawEyesRect:(CGRect)rect;

- (void) drawProfileRect:(CGRect)rect;

- (void) eraseRects;

- (void) safeStopAnimating;

- (void) hideFeedback;

- (void) hideFeedbackWithDelay;

- (void) showFeedback;

@property (nonatomic, assign) BOOL distanceOK;

@property (nonatomic, assign) BOOL positionOK;

@property (nonatomic, assign) BOOL mirroredRect;

@property (nonatomic, unsafe_unretained) UIView *limitRectView;

@end
