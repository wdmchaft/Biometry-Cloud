//
//  CheckView.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckView.h"

#import <QuartzCore/QuartzCore.h>

@implementation CheckView

@synthesize delegate, faceImage;

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [indicatorView.layer setMasksToBounds:YES];
        
        defaultColor = [UIColor colorWithRed:44/255.0 green:99/255.0 blue:30/255.0 alpha:1];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) showCheckViewForFace:(UIImage *) face inTimeStamp:(NSString *) time waitingForAnswer:(BOOL) wait {
    
    faceImage.image = [UIImage imageWithCGImage:[face CGImage] scale:1.0 orientation:UIImageOrientationRight];
    timeLabel.text = time;
    
    [self setAlpha:1];
    
    if (wait) {
        
        timeLabel.hidden = TRUE;
        nameLabel.hidden = TRUE;
        iconImage.hidden = TRUE;
        
        indicatorView.hidden = FALSE;
        
    }
    else {
        
        timeLabel.hidden = FALSE;
        iconImage.hidden = FALSE;
        
        nameLabel.hidden = TRUE;
        indicatorView.hidden = TRUE;
        
        //Set to hide after some delay
        [UIView animateWithDuration:.5f delay:.5f options:UIViewAnimationOptionTransitionNone animations:^{
            
            [self setAlpha:0.f];
        } completion:^(BOOL finished){
            
            //Call delegate's method when done
            [delegate checkViewDone];
        }];
    }
}

- (void) answerReceived:(NSDictionary *)answer {
    
    [self setAlpha:1];
    
    if ([[answer objectForKey:@"debug"] isEqualToString:@"OK"]) {
        
        nameLabel.text = [answer objectForKey:@"firstName"];
        nameLabel.hidden = FALSE;
        
        //Set image
        iconImage.image = [UIImage imageNamed:@"check.png"];
        
        //Set label colors
        nameLabel.backgroundColor = [UIColor colorWithCGColor:[defaultColor CGColor]];
        timeLabel.backgroundColor = [UIColor colorWithCGColor:[defaultColor CGColor]];
    }
    else {
    
        nameLabel.text = [answer objectForKey:@"debug"];
        nameLabel.hidden = FALSE;
        
        //Set image
        iconImage.image = [UIImage imageNamed:@"wrong.png"];
        
        //Set label colors
        nameLabel.backgroundColor = [UIColor redColor];
        timeLabel.backgroundColor = [UIColor redColor];
    }
    
    iconImage.hidden = FALSE;
    timeLabel.hidden = FALSE;
    
    indicatorView.hidden = TRUE;
    
    //Set to hide after some delay
    [UIView animateWithDuration:.5f delay:.5f options:UIViewAnimationOptionTransitionNone animations:^{
        
        [self setAlpha:0.f];
    } completion:^(BOOL finished){
        
        //Call delegate's method when done
        [delegate checkViewDone];
    }];
}


@end
