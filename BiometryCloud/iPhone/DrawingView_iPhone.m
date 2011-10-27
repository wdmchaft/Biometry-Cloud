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
        
        maskRect=CGRectMake(self.frame.origin.x+25, self.frame.origin.y+45, 270, 410);
         feedbackLabel.frame = CGRectMake(feedbackLabel.frame.origin.x, maskRect.origin.y+maskRect.size.height, feedbackLabel.frame.size.width, feedbackLabel.frame.size.height);
        
    }
    return self;
}

@end
