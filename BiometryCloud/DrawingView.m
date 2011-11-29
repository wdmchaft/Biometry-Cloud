//
//  DrawingView.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 20-10-11.
//  Copyright (c) 2011 Biometry Cloud. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView

@synthesize limitRect, distanceOK, positionOK, mirroredRect;

- (id) initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        faceRect = CGRectZero;
        
        eyesRect = CGRectZero;
        
        profileRect = CGRectZero;
        
        getCloserImages = [[NSMutableArray alloc]init];
        
        centerFaceImages = [[NSMutableArray alloc]init];
        
        for (int i=1; i<12; i++) {
            [getCloserImages addObject:[UIImage imageNamed:
                                        [NSString stringWithFormat:@"flecha%d.png", i]]];
        }
        
        for (int i=0; i<2; i++) {
            [centerFaceImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"centerface%d.png", i]]];
        }
        
        animatingImage.animationRepeatCount=0;
        
       
        
        currentFeedback=@"None";
        
        isShowingFeedback=FALSE;
        hideFeedbackInt=0;
    }
    return self;
}

- (void) eraseRects {
    
    mouthRect = CGRectZero;
    eyesRect = CGRectZero;
    faceRect = CGRectZero;
    profileRect = CGRectZero;
    
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

//for the following methods, if the camera is set to be the back one, the rect draws mirrored

- (void) drawMouthRect:(CGRect)rect{
    
    if (mirroredRect) {
        
        mouthRect=CGRectMake(self.frame.size.width - rect.origin.x - rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
    }
    
    else
        mouthRect = rect;
    
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void) drawEyesRect:(CGRect)rect{
    
    if (mirroredRect) {
        
        eyesRect=CGRectMake(self.frame.size.width - rect.origin.x - rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
    }
    
    else
        eyesRect = rect;
    
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void) drawFaceRect:(CGRect)rect {
    
    if (mirroredRect) {

        faceRect=CGRectMake(self.frame.size.width - rect.origin.x - rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
    }
    else
        faceRect = rect;
    
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void) drawProfileRect:(CGRect)rect{
    
    if (mirroredRect) {
        
        profileRect=CGRectMake(self.frame.size.width - rect.origin.x - rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
    }
    
    else 
        profileRect = rect;
    
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGContextSetLineWidth(context, 5);
    
    //Draw maskRect
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.8);
    CGContextAddRect(context, limitRect);
    CGContextStrokePath(context);
    
    //Set faceRect color
    if (positionOK && distanceOK) {
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 0.5);
    }
    else if (distanceOK) {
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.5);
    }
    else {
        
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.5);
    }
    
    //Draw faceRect
    CGContextAddRect(context, faceRect);
    CGContextStrokePath(context);
    
    if (!CGRectIsEmpty(profileRect)) {
        
        CGContextSetRGBStrokeColor(context, 0, 0, 1, 0.5);
        CGContextAddRect(context, profileRect);
        CGContextStrokePath(context);
    }
    
    UIGraphicsPopContext();
}

//Method called when the face is too far away or not centered

-(void) showFeedback
{
    //first define the feedback
    
    NSString *feedback;
    if (!positionOK) {
        feedback=@"centerFace";
    }
    else if (!distanceOK)
    {
        feedback=@"getCloser";
    }
    else feedback=@"";
    
    //reset the counter to hide the feedback with a delay (so it doesn't appear and disappear all the time)
    
    hideFeedbackInt=0;
    
    BOOL animating = isShowingFeedback;
    
    //if the feedback is the same, skip this part
    
    if (![currentFeedback isEqualToString:feedback]&&(!positionOK||!distanceOK)) {
        
        //if the face is not centered, show feedback to center face
        if (!positionOK) {
            
            animatingImage.animationDuration = 1.3;
            animatingImage.animationImages = [NSArray arrayWithArray:centerFaceImages]; 
            feedbackLabel.backgroundColor = [UIColor yellowColor];
            feedbackLabel.textColor = [UIColor blackColor];
            feedbackLabel.textAlignment=UITextAlignmentCenter;
            feedbackLabel.text = NSLocalizedString(@"center_feedback", @"center_message");//@"Centre su cara";
            animatingImage.frame = limitRect;
            currentFeedback=@"centerFace";
            if (animating) {
                
                [animatingImage startAnimating];
                
            }
        }
        
        //if the face is too small, show feedback to get closer
        
        else if (!distanceOK)
        {
            
            animatingImage.animationDuration = 0.7;
            animatingImage.animationImages = [NSArray arrayWithArray:getCloserImages];
            feedbackLabel.backgroundColor = [UIColor redColor];
            feedbackLabel.textColor = [UIColor whiteColor];
            feedbackLabel.textAlignment=UITextAlignmentCenter;
            feedbackLabel.text =NSLocalizedString(@"closer_feedback", @"closer_message");// @"Acérquese";
            animatingImage.frame = initialFrame;
            currentFeedback=@"getCloser";
            if (animating) {
                
                [animatingImage startAnimating];
                
            }
        }
        
        //if it isn't showing feedback, start the animations
        
        if (!isShowingFeedback) {
            
            [animatingImage startAnimating];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.7];
            
            animatingImage.alpha = 0.8;
            feedbackLabel.alpha = 0.8;
            
            feedbackLabel.frame = CGRectMake(feedbackLabel.frame.origin.x, feedbackLabel.frame.origin.y - feedbackLabel.frame.size.height, feedbackLabel.frame.size.width, feedbackLabel.frame.size.height);
            
            [UIView commitAnimations];
            
            isShowingFeedback = TRUE;
        }

    }
    
    //if everything is OK, then hide the feedback

    if (positionOK && distanceOK) {
        
        //if the feedback is hidden, skip this part
        
        if (isShowingFeedback) {
            [self performSelectorOnMainThread:@selector(hideFeedback) withObject:nil waitUntilDone:NO];
        }
    }
        
}

- (void) safeStopAnimating {
    
    //if the feedback is showing, the animation can't stop
    
    if (!isShowingFeedback) {
        
        [animatingImage stopAnimating];
    }
}

- (void) hideFeedback {
    
    //Only hide the feedback if it is showing
    
    if (isShowingFeedback) {
        
        isShowingFeedback = FALSE;
        
        hideFeedbackInt = 0;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(safeStopAnimating)];
        
        animatingImage.alpha = 0;
        feedbackLabel.alpha = 0;

        
        feedbackLabel.frame = CGRectMake(feedbackLabel.frame.origin.x, feedbackLabel.frame.origin.y + feedbackLabel.frame.size.height, feedbackLabel.frame.size.width, feedbackLabel.frame.size.height);
        
        [UIView commitAnimations];
        
        currentFeedback = @"None";
    }
}

- (void) hideFeedbackWithDelay {
    
    //in order to not hide the feedback inmediately we use this method
    
    if (isShowingFeedback) {
        
        hideFeedbackInt++;
        
        if (hideFeedbackInt > 3) {
            
            [self performSelectorOnMainThread:@selector(hideFeedback) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)dealloc
{
    [super dealloc];
}


@end
