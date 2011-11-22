//
//  CheckView_iPhone.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckView_iPhone.h"

#import <QuartzCore/QuartzCore.h>

@implementation CheckView_iPhone

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CheckView_iPhone" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        [indicatorView.layer setCornerRadius:8.0f];
        
    }
    return self;
}

@end
