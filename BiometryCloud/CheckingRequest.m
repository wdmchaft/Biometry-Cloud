//
//  EnrollRequest.m
//  SPF
//
//  Created by Pablo Mandiola on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckingRequest.h"


@implementation CheckingRequest

@synthesize face, lat, lng, time, legal_id;

- (void) dealloc {
    
    /*
    if ([face retainCount] > 1) {
        NSLog(@"¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡");
        NSLog(@"MEMORY LEAK: FACE in Checking request has retainCount = %u", [face retainCount] - 1);
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    
    if ([time retainCount] > 1) {
        NSLog(@"¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡");
        NSLog(@"MEMORY LEAK: TIME in Checking request has retainCount = %u", [time retainCount] - 1);
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
     */
    
    [face release];
    
    [time release];
    
    [legal_id release];
    
    [super dealloc];
}

@end
