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
    
    CGRect maskRect;
    
    BOOL distanceOK;
    
    BOOL positionOK;
    
    IBOutlet UILabel *feedbackLabel;
    
    IBOutlet UIImageView *animatingImage;
    
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

-(void) showFeedback;




@property (nonatomic, assign) CGRect maskRect;

@property (nonatomic, assign) BOOL distanceOK;

@property (nonatomic, assign) BOOL positionOK;

@property (nonatomic, assign) BOOL mirroredRect;

@end