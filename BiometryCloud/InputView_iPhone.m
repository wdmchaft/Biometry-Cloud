//
//  InputView_iPhone.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InputView_iPhone.h"


@implementation InputView_iPhone

- (id) initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"InputView_iPhone" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        //Hide inputView
        [super hideAnimated:FALSE];
    }
    return self;
}



- (void) showAnimated:(BOOL)animated {

    [super showAnimated:animated];
    
    [_dummyField becomeFirstResponder];
}

- (void) hideAnimated:(BOOL)animated {
    
    [super hideAnimated:animated];
    
    [_dummyField resignFirstResponder];
}

@end
