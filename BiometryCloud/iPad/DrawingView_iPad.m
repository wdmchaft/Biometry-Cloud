//
//  DrawingView_iPad.m
//  BiometryCloud
//
//  Created by Andrés Munita Irarrázaval on 20-10-11.
//  Copyright (c) 2011 Biometry Cloud. All rights reserved.
//

#import "DrawingView_iPad.h"

@implementation DrawingView_iPad

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DrawingView_iPad" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        limitRect = limitRectView.frame;
        
        feedbackLabel.frame = CGRectMake(limitRect.origin.x, limitRect.origin.y+limitRect.size.height, limitRect.size.width, feedbackLabel.frame.size.height);
        
        initialFrame=animatingImage.frame;
    }
    return self;
}

@end
