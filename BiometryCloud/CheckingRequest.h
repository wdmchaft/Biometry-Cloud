//
//  CheckingRequest.h
//  BiometryCloud
//
//  Created by Pablo Mandiola on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIFormDataRequest.h"

@interface CheckingRequest : ASIFormDataRequest {
    
    UIImage *face;
    double lat;
    double lng;
    NSString *time;
    NSString *legal_id;
}

@property (nonatomic, retain) UIImage *face;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *legal_id;

@end
