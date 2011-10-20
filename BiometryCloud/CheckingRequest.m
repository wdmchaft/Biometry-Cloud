//
//  CheckingRequest.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckingRequest.h"
#import "BiometryCloudConfiguration.h"

@implementation CheckingRequest

@synthesize face, lat, lng, time, legal_id;

- (void) dealloc {
    
    [face release];
    
    [time release];
    
    [legal_id release];
    
    [super dealloc];
}

@end
