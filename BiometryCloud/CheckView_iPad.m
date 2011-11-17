//
//  CheckView_iPad.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckView_iPad.h"

#import <QuartzCore/QuartzCore.h>

@implementation CheckView_iPad

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CheckView_iPad" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        [indicatorView.layer setCornerRadius:20.0f];
        
    }
    return self;
}

@end
