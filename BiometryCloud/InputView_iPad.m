//
//  InputView_iPad.m
//  BiometryCloud
//
//  Created by Pablo Mandiola on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InputView_iPad.h"


@implementation InputView_iPad

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"InputView_iPad" owner:self options:nil];
        [self addSubview:[array objectAtIndex:0]];
        
        //Hide inputView
        [super hideAnimated:FALSE];
    }
    return self;
}

@end
