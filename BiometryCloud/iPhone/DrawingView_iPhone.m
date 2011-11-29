//
//  DrawingView_iPhone.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 20-10-11.
//  Copyright (c) 2011 Biometry Cloud. All rights reserved.
//

#import "DrawingView_iPhone.h"

@implementation DrawingView_iPhone

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DrawingView_iPhone" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        feedbackLabel.frame = CGRectMake(limitRectView.frame.origin.x, limitRectView.frame.origin.y+limitRectView.frame.size.height, limitRectView.frame.size.width, feedbackLabel.frame.size.height);
        
        initialFrame=animatingImage.frame;
    }
    return self;
}

@end
